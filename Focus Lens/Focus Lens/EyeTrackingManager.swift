//
//  EyeTrackingManager.swift
//  FocusLens
//
//  Iris-based gaze tracking using Apple Vision + AVFoundation.
//  Uses a One Euro Filter for adaptive jitter reduction.
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
    private let sessionQueue = DispatchQueue(label: "com.focuslens.eyeTracking", qos: .userInteractive)

    // One Euro Filters — one for the raw signal (used by calibration),
    // one for the default screen-space output.
    // minCutoff: smoothing at rest (lower = smoother)
    // beta: speed responsiveness (higher = snappier on fast moves)
    private var rawFilter    = OneEuroFilter2D(minCutoff: 0.5,  beta: 0.008)  // More responsive
    private var screenFilter = OneEuroFilter2D(minCutoff: 0.5,  beta: 0.008)
    
    // Outlier detection - track recent gaze positions
    private var recentGazes: [CGPoint] = []
    private let maxHistory = 10

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
            self.sessionQueue.async { self.setupCaptureSession() }
        }
    }

    func stopTracking() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.captureSession = nil
            self?.rawFilter.reset()
            self?.screenFilter.reset()
            self?.recentGazes.removeAll()
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
        session.sessionPreset = .vga640x480

        guard session.canAddInput(input) else {
            DispatchQueue.main.async { self.errorMessage = "Camera input rejected." }
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: sessionQueue)

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

// MARK: - Frame capture

extension EyeTrackingManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest()
        if #available(macOS 12, *) {
            request.revision = VNDetectFaceLandmarksRequestRevision3
        }

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored,
            options: [:]
        )
        do {
            try handler.perform([request])
            let timestamp = CACurrentMediaTime()
            processResults(request.results, timestamp: timestamp)
        } catch { }
    }
}

// MARK: - Gaze estimation

private extension EyeTrackingManager {

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
            return
        }

        DispatchQueue.main.async { self.faceDetected = true }

        let faceBounds = face.boundingBox

        // Compute pupil centers more accurately by averaging all pupil points
        let leftPupilImg  = avgPoint(leftPupil.normalizedPoints, in: faceBounds)
        let rightPupilImg = avgPoint(rightPupil.normalizedPoints, in: faceBounds)

        let leftCenter  = eyeCenter(leftEye,  in: faceBounds)
        let rightCenter = eyeCenter(rightEye, in: faceBounds)
        let leftWidth   = eyeWidth(leftEye,   in: faceBounds)
        let rightWidth  = eyeWidth(rightEye,  in: faceBounds)

        // Compute iris offset relative to eye dimensions
        let leftOffX  = leftWidth  > 0 ? (leftPupilImg.x  - leftCenter.x)  / leftWidth  : 0
        let leftOffY  = leftWidth  > 0 ? (leftPupilImg.y  - leftCenter.y)  / leftWidth  : 0
        let rightOffX = rightWidth > 0 ? (rightPupilImg.x - rightCenter.x) / rightWidth : 0
        let rightOffY = rightWidth > 0 ? (rightPupilImg.y - rightCenter.y) / rightWidth : 0

        // Average both eyes
        let irisOffX = (leftOffX + rightOffX) / 2
        let irisOffY = (leftOffY + rightOffY) / 2

        // Combine face position with iris offset for gaze estimation
        // Use adaptive scaling based on face size (closer face = more sensitive)
        let faceScale = sqrt(faceBounds.width * faceBounds.height) * 0.7
        let gazeNormX = faceBounds.midX + irisOffX * faceScale
        let gazeNormY = faceBounds.midY + irisOffY * faceScale

        // Raw signal (top-left origin, 0-1)
        let rawUnsmoothed = CGPoint(x: gazeNormX, y: 1.0 - gazeNormY)
        
        // Outlier rejection: Check if this point is too far from recent history
        if !recentGazes.isEmpty && isOutlier(rawUnsmoothed, history: recentGazes) {
            // Skip this frame - likely a blink or tracking error
            return
        }
        
        // Update history
        recentGazes.append(rawUnsmoothed)
        if recentGazes.count > maxHistory {
            recentGazes.removeFirst()
        }
        
        // Apply smoothing filter
        let raw = rawFilter.filter(rawUnsmoothed, timestamp: timestamp)

        guard let screen = NSScreen.main else { return }
        let w = screen.frame.width
        let h = screen.frame.height

        // Default uncalibrated screen mapping with better gain
        let gain: CGFloat = 2.5  // Slightly increased for more screen coverage
        let mappedX = (gazeNormX - 0.5) * gain + 0.5
        let mappedY = (gazeNormY - 0.5) * gain + 0.5

        let screenRaw = CGPoint(
            x: Swift.max(0, Swift.min(mappedX * w, w)),
            y: Swift.max(0, Swift.min((1.0 - mappedY) * h, h))
        )
        let screenSmoothed = screenFilter.filter(screenRaw, timestamp: timestamp)

        DispatchQueue.main.async {
            self.rawGazeSignal = raw
            self.gazePoint = screenSmoothed
        }
    }

    // MARK: Helpers
    
    /// Check if a point is an outlier compared to recent history
    func isOutlier(_ point: CGPoint, history: [CGPoint]) -> Bool {
        // Calculate median distance to recent points
        let distances = history.map { hypot($0.x - point.x, $0.y - point.y) }
        let avgDistance = distances.reduce(0, +) / CGFloat(distances.count)
        
        // Reject if more than 0.3 units away (in normalized space)
        return avgDistance > 0.3
    }
    
    /// Average multiple points (e.g., all pupil landmark points)
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

// MARK: - One Euro Filter

/// Adaptive low-pass filter for real-time signal smoothing.
/// Reduces jitter when still, stays responsive during fast movements.
/// Reference: Casiez et al., "1€ Filter: A Simple Speed-based Low-pass Filter
/// for Noisy Input in Interactive Systems", CHI 2012.
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

        // Derivative low-pass
        let aDeriv = alpha(cutoff: dCutoff, dt: dt)
        let dx = (x - xp) / dt
        let dxHat = aDeriv * dx + (1.0 - aDeriv) * dxPrev

        // Adaptive cutoff based on speed
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
