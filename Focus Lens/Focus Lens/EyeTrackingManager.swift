//
//  EyeTrackingManager.swift
//  FocusLens
//
//  Iris-based gaze tracking using Apple Vision + AVFoundation.
//  Uses a One Euro Filter for adaptive jitter reduction.
//  Optimized for performance and accuracy.
//

import AVFoundation
import Vision
import AppKit
import Combine

class EyeTrackingManager: NSObject, ObservableObject {
    /// Final screen-space gaze point using the default (uncalibrated) gain mapping.
    @Published var gazePoint: CGPoint = .zero
    /// Raw combined face+iris signal in normalised image space (0-1, top-left origin).
    /// Feed this into CalibrationManager to build a calibrated mapping.
    @Published var rawGazeSignal: CGPoint = .zero
    @Published var isTracking: Bool = false
    @Published var faceDetected: Bool = false
    @Published var errorMessage: String? = nil

    private var captureSession: AVCaptureSession?
    private let captureQueue = DispatchQueue(label: "com.focuslens.capture", qos: .userInitiated)
    private let visionQueue = DispatchQueue(label: "com.focuslens.vision", qos: .userInitiated)
    
    // Reuse Vision request for performance (Optimization #1)
    private lazy var faceLandmarkRequest: VNDetectFaceLandmarksRequest = {
        let request = VNDetectFaceLandmarksRequest()
        if #available(macOS 12, *) {
            request.revision = VNDetectFaceLandmarksRequestRevision3
        }
        return request
    }()
    
    // Sequence handler for temporal context (Optimization #1)
    private lazy var sequenceHandler = VNSequenceRequestHandler()

    // One Euro Filters for smoothing (Optimization #3 - consistent signal path)
    private var normalizedFilter = OneEuroFilter2D(minCutoff: 0.25, beta: 0.03, dCutoff: 2.0)
    private var screenFilter = OneEuroFilter2D(minCutoff: 0.2, beta: 0.02, dCutoff: 2.0)
    
    // Outlier detection with velocity awareness (Optimization #4 & #10)
    private var gazeHistory: [GazeFrame] = []
    private let maxHistory = 10  // Optimization #10: increased from 5
    private var lastFilteredGaze: CGPoint = .zero
    private var lastGazeVelocity: CGPoint = .zero
    private var lastTimestamp: TimeInterval = 0
    
    // Face scale smoothing (Optimization #7)
    private var smoothedFaceScale: CGFloat = 0.15
    private let faceScaleAlpha: CGFloat = 0.3
    
    // Tracking quality monitoring (Optimization #2 & #5)
    private var consecutiveVisionFailures = 0
    private var consecutiveOutliers = 0
    private let maxConsecutiveOutliers = 8
    private var isVisionBusy = false  // Optimization #2: drop frames if busy
    private var lastGoodQualityTime: TimeInterval = 0
    
    // Window for multi-display support (Optimization #9)
    weak var overlayWindow: NSWindow?

    // MARK: - Public API

    func startTracking() {
        DispatchQueue.main.async { self.errorMessage = nil }
        requestCameraPermission { [weak self] granted in
            guard let self else { return }
            guard granted else {
                DispatchQueue.main.async {
                    self.errorMessage = "Camera access denied. Enable in System Settings › Privacy › Camera."
                }
                return
            }
            self.captureQueue.async { self.setupCaptureSession() }
        }
    }

    func stopTracking() {
        captureQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.captureSession = nil
            self?.normalizedFilter.reset()
            self?.screenFilter.reset()
            self?.gazeHistory.removeAll()
            self?.consecutiveOutliers = 0
            self?.consecutiveVisionFailures = 0
            self?.isVisionBusy = false
            self?.smoothedFaceScale = 0.15
            self?.lastGoodQualityTime = 0
        }
        DispatchQueue.main.async {
            self.isTracking = false
            self.faceDetected = false
        }
    }

    // MARK: - Setup

    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        default:
            completion(false)
        }
    }

    private func setupCaptureSession() {
        guard let camera = bestCamera() else {
            DispatchQueue.main.async {
                self.errorMessage = "No camera found. Make sure a webcam is connected."
            }
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            DispatchQueue.main.async { self.errorMessage = "Could not open camera." }
            return
        }

        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720

        guard session.canAddInput(input) else {
            DispatchQueue.main.async { self.errorMessage = "Camera input rejected." }
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: captureQueue)  // Optimization #2

        guard session.canAddOutput(output) else {
            DispatchQueue.main.async { self.errorMessage = "Camera output rejected." }
            return
        }
        session.addOutput(output)

        captureSession = session
        session.startRunning()
        DispatchQueue.main.async { self.isTracking = true }
    }

    private func bestCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(for: .video) { return device }
        return AVCaptureDevice.devices(for: .video).first
    }
}

// MARK: - Frame capture (Optimization #2: lightweight capture handler)

extension EyeTrackingManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Optimization #2: If Vision is busy, drop this frame
        guard !isVisionBusy else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CACurrentMediaTime()
        
        // Dispatch heavy Vision work to separate queue
        isVisionBusy = true
        visionQueue.async { [weak self] in
            self?.performVision(on: pixelBuffer, timestamp: timestamp)
            self?.isVisionBusy = false
        }
    }
}

// MARK: - Vision processing

private extension EyeTrackingManager {
    
    func performVision(on pixelBuffer: CVPixelBuffer, timestamp: TimeInterval) {
        do {
            // Optimization #1: Reuse request and use sequence handler
            try sequenceHandler.perform([faceLandmarkRequest], on: pixelBuffer, orientation: .leftMirrored)
            consecutiveVisionFailures = 0
            processResults(faceLandmarkRequest.results, timestamp: timestamp)
        } catch {
            consecutiveVisionFailures += 1
            // Optimization #10: Surface error if persistent
            if consecutiveVisionFailures > 30 {
                DispatchQueue.main.async {
                    self.errorMessage = "Vision tracking failed. Try adjusting camera."
                    self.consecutiveVisionFailures = 0  // Reset to avoid spam
                }
            }
        }
    }

    func processResults(_ results: [VNFaceObservation]?, timestamp: Double) {
        guard
            let face = results?.first,
            let landmarks = face.landmarks,
            let leftPupil  = landmarks.leftPupil,
            let rightPupil = landmarks.rightPupil,
            let leftEye    = landmarks.leftEye,
            let rightEye   = landmarks.rightEye,
            !leftPupil.normalizedPoints.isEmpty,
            !rightPupil.normalizedPoints.isEmpty
        else {
            DispatchQueue.main.async { self.faceDetected = false }
            // Optimization #10: Freeze last gaze instead of resetting
            return
        }

        DispatchQueue.main.async { self.faceDetected = true }

        let faceBounds = face.boundingBox
        let faceConfidence = face.confidence
        
        // Optimization #7: Smooth face scale to reduce jitter amplification
        let rawFaceScale = sqrt(faceBounds.width * faceBounds.height)
        smoothedFaceScale = faceScaleAlpha * rawFaceScale + (1.0 - faceScaleAlpha) * smoothedFaceScale
        
        // Clamp scale changes to prevent sudden jumps (Optimization #7)
        let scaleChange = abs(rawFaceScale - smoothedFaceScale) / smoothedFaceScale
        if scaleChange > 0.15 {
            smoothedFaceScale = rawFaceScale  // Big change - probably valid head movement
        }

        // Compute pupil centers
        let leftPupilImg  = avgPoint(leftPupil.normalizedPoints, in: faceBounds)
        let rightPupilImg = avgPoint(rightPupil.normalizedPoints, in: faceBounds)

        let leftCenter  = eyeCenter(leftEye,  in: faceBounds)
        let rightCenter = eyeCenter(rightEye, in: faceBounds)
        let leftWidth   = eyeWidth(leftEye,   in: faceBounds)
        let rightWidth  = eyeWidth(rightEye,  in: faceBounds)

        // Optimization #6: Adaptive eye weights based on confidence
        let leftConf = computeEyeConfidence(width: leftWidth, pupilCount: leftPupil.pointCount)
        let rightConf = computeEyeConfidence(width: rightWidth, pupilCount: rightPupil.pointCount)
        let totalConf = leftConf + rightConf
        let leftWeight: CGFloat = totalConf > 0 ? leftConf / totalConf : 0.5
        let rightWeight: CGFloat = totalConf > 0 ? rightConf / totalConf : 0.5

        // Compute iris offsets
        let leftOffX  = leftWidth  > 0 ? (leftPupilImg.x  - leftCenter.x)  / leftWidth  : 0
        let leftOffY  = leftWidth  > 0 ? (leftPupilImg.y  - leftCenter.y)  / leftWidth  : 0
        let rightOffX = rightWidth > 0 ? (rightPupilImg.x - rightCenter.x) / rightWidth : 0
        let rightOffY = rightWidth > 0 ? (rightPupilImg.y - rightCenter.y) / rightWidth : 0

        let irisOffX = leftOffX * leftWeight + rightOffX * rightWeight
        let irisOffY = leftOffY * leftWeight + rightOffY * rightWeight

        // Optimization #7: Use smoothed face scale
        let scaleX: CGFloat = smoothedFaceScale * 1.2
        let scaleY: CGFloat = smoothedFaceScale * 1.4
        let yBiasCorrection: CGFloat = 0.08
        
        let gazeNormX = faceBounds.midX + irisOffX * scaleX
        let gazeNormY = faceBounds.midY + irisOffY * scaleY + yBiasCorrection

        let rawUnsmoothed = CGPoint(x: gazeNormX, y: 1.0 - gazeNormY)
        
        // Optimization #8: Soft clamp in normalized space
        let clampedX = softClamp(rawUnsmoothed.x, min: -0.1, max: 1.1)
        let clampedY = softClamp(rawUnsmoothed.y, min: -0.1, max: 1.1)
        let clampedRaw = CGPoint(x: clampedX, y: clampedY)
        
        // Optimization #4: Velocity-aware outlier detection
        let dt = timestamp - lastTimestamp
        if dt > 0 && !gazeHistory.isEmpty {
            let predicted = CGPoint(
                x: lastFilteredGaze.x + lastGazeVelocity.x * CGFloat(dt),
                y: lastFilteredGaze.y + lastGazeVelocity.y * CGFloat(dt)
            )
            let deviation = hypot(clampedRaw.x - predicted.x, clampedRaw.y - predicted.y)
            let speed = hypot(lastGazeVelocity.x, lastGazeVelocity.y)
            
            // Adaptive threshold based on current speed and face scale
            let baseThreshold: CGFloat = 0.15
            let speedFactor: CGFloat = 1.0 + min(speed * 2.0, 2.0)
            let scaleFactor: CGFloat = 1.0 / max(smoothedFaceScale, 0.1)
            let threshold = baseThreshold * speedFactor * scaleFactor
            
            if deviation > threshold {
                consecutiveOutliers += 1
                
                // Reset only if many consecutive outliers AND low confidence
                if consecutiveOutliers >= maxConsecutiveOutliers && faceConfidence < 0.8 {
                    normalizedFilter.reset()
                    screenFilter.reset()
                    gazeHistory.removeAll()
                    consecutiveOutliers = 0
                    smoothedFaceScale = rawFaceScale
                }
                return
            }
        }
        
        consecutiveOutliers = 0
        lastTimestamp = timestamp
        
        // Optimization #3: Consistent signal path - filter in normalized space first
        let filteredNormalized = normalizedFilter.filter(clampedRaw, timestamp: timestamp)
        
        // Update velocity
        if dt > 0 {
            lastGazeVelocity = CGPoint(
                x: (filteredNormalized.x - lastFilteredGaze.x) / CGFloat(dt),
                y: (filteredNormalized.y - lastFilteredGaze.y) / CGFloat(dt)
            )
        }
        lastFilteredGaze = filteredNormalized
        
        // Store in history
        gazeHistory.append(GazeFrame(point: filteredNormalized, timestamp: timestamp, confidence: faceConfidence))
        if gazeHistory.count > maxHistory {
            gazeHistory.removeFirst()
        }
        
        // Track quality for smart reset (Optimization #5)
        if faceConfidence > 0.85 && consecutiveOutliers == 0 {
            lastGoodQualityTime = timestamp
        }
        
        // Optimization #9: Use overlay window's screen if available
        let targetScreen = overlayWindow?.screen ?? NSScreen.main
        guard let screen = targetScreen else { return }
        let w = screen.frame.width
        let h = screen.frame.height

        // Map filtered normalized gaze to screen space (Optimization #3)
        let gainX: CGFloat = 3.0
        let gainY: CGFloat = 2.8
        let mappedX = (filteredNormalized.x - 0.5) * gainX + 0.5
        let mappedY = (filteredNormalized.y - 0.5) * gainY + 0.5
        
        // Optimization #8: Already soft-clamped, just convert to pixels
        let screenRaw = CGPoint(
            x: max(0, min(mappedX * w, w)),
            y: max(0, min((1.0 - mappedY) * h, h))
        )
        
        // Apply final screen-space smoothing (Optimization #3)
        let screenSmoothed = screenFilter.filter(screenRaw, timestamp: timestamp)

        DispatchQueue.main.async {
            self.rawGazeSignal = filteredNormalized  // Optimization #3: use filtered signal
            self.gazePoint = screenSmoothed
        }
    }

    // MARK: Helpers
    
    /// Optimization #6: Compute per-eye confidence
    func computeEyeConfidence(width: CGFloat, pupilCount: Int) -> CGFloat {
        var conf: CGFloat = 1.0
        
        // Penalize if eye width is too small (unreliable)
        if width < 0.02 {
            conf *= 0.5
        }
        
        // Prefer more pupil points
        if pupilCount < 3 {
            conf *= 0.7
        }
        
        return conf
    }
    
    /// Optimization #8: Soft saturation function
    func softClamp(_ value: CGFloat, min minVal: CGFloat, max maxVal: CGFloat) -> CGFloat {
        if value < minVal {
            let excess = minVal - value
            return minVal - tanh(excess) * 0.1
        } else if value > maxVal {
            let excess = value - maxVal
            return maxVal + tanh(excess) * 0.1
        }
        return value
    }
    
    func tanh(_ x: CGFloat) -> CGFloat {
        let ex = exp(2.0 * x)
        return (ex - 1.0) / (ex + 1.0)
    }
    
    func avgPoint(_ points: [CGPoint], in face: CGRect) -> CGPoint {
        let imgPoints = points.map { toImageCoords($0, in: face) }
        let n = CGFloat(imgPoints.count)
        return CGPoint(x: imgPoints.map(\.x).reduce(0, +) / n,
                       y: imgPoints.map(\.y).reduce(0, +) / n)
    }

    func toImageCoords(_ point: CGPoint, in face: CGRect) -> CGPoint {
        CGPoint(x: face.minX + point.x * face.width,
                y: face.minY + point.y * face.height)
    }

    func eyeCenter(_ region: VNFaceLandmarkRegion2D, in face: CGRect) -> CGPoint {
        let pts = region.normalizedPoints.map { toImageCoords($0, in: face) }
        let n = CGFloat(pts.count)
        return CGPoint(x: pts.map(\.x).reduce(0, +) / n,
                       y: pts.map(\.y).reduce(0, +) / n)
    }

    func eyeWidth(_ region: VNFaceLandmarkRegion2D, in face: CGRect) -> CGFloat {
        let xs = region.normalizedPoints.map { toImageCoords($0, in: face).x }
        return (xs.max() ?? 0) - (xs.min() ?? 0)
    }
}

// MARK: - Supporting Types

private struct GazeFrame {
    let point: CGPoint
    let timestamp: TimeInterval
    let confidence: Float
}

// MARK: - One Euro Filter

private class OneEuroFilter2D {
    private var fx: OneEuroFilter1D
    private var fy: OneEuroFilter1D

    init(minCutoff: Double, beta: Double, dCutoff: Double = 1.0) {
        fx = OneEuroFilter1D(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff)
        fy = OneEuroFilter1D(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff)
    }

    func filter(_ point: CGPoint, timestamp: Double) -> CGPoint {
        CGPoint(x: CGFloat(fx.filter(Double(point.x), t: timestamp)),
                y: CGFloat(fy.filter(Double(point.y), t: timestamp)))
    }

    func reset() {
        fx.reset()
        fy.reset()
    }
}

private class OneEuroFilter1D {
    let minCutoff: Double
    let beta: Double
    let dCutoff: Double

    private var xPrev: Double?
    private var dxPrev: Double = 0.0
    private var tPrev: Double?

    init(minCutoff: Double, beta: Double, dCutoff: Double) {
        self.minCutoff = minCutoff
        self.beta = beta
        self.dCutoff = dCutoff
    }

    func filter(_ x: Double, t: Double) -> Double {
        guard let xp = xPrev, let tp = tPrev else {
            xPrev = x; tPrev = t
            return x
        }

        let dt = t - tp
        guard dt > 0 else { return xp }

        let aDeriv = alpha(cutoff: dCutoff, dt: dt)
        let dx = (x - xp) / dt
        let dxHat = aDeriv * dx + (1.0 - aDeriv) * dxPrev

        let cutoff = minCutoff + beta * abs(dxHat)
        let a = alpha(cutoff: cutoff, dt: dt)
        let xHat = a * x + (1.0 - a) * xp

        xPrev = xHat
        dxPrev = dxHat
        tPrev = t
        return xHat
    }

    func reset() {
        xPrev = nil
        dxPrev = 0.0
        tPrev = nil
    }

    private func alpha(cutoff: Double, dt: Double) -> Double {
        let r = 2.0 * .pi * cutoff * dt
        return r / (r + 1.0)
    }
}
