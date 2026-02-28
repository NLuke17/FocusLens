//
//  EyeTrackingManager.swift
//  FocusLens
//
//  Iris-based gaze tracking using Apple Vision + AVFoundation
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

    // Exponential moving average — lower = smoother/more lag, higher = snappier/more jitter
    private let smoothingFactor: CGFloat = 0.12
    private var smoothedPoint: CGPoint = .zero
    private var hasInitialPoint = false

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
            self?.hasInitialPoint = false
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

    /// Returns the best available camera. Uses the system default first (most reliable
    /// on macOS), then falls back to a full device enumeration.
    private func bestCamera() -> AVCaptureDevice? {
        // AVCaptureDevice.default(for:) is the most reliable way to get the
        // system-selected camera on macOS regardless of device type or position.
        if let device = AVCaptureDevice.default(for: .video) {
            return device
        }

        // Fallback: enumerate all video devices
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

        // .leftMirrored un-mirrors the front camera so Vision's "left" == user's left
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored,
            options: [:]
        )
        do {
            try handler.perform([request])
            processResults(request.results)
        } catch {
            // Frame dropped — ignore
        }
    }
}

// MARK: - Gaze estimation

private extension EyeTrackingManager {

    func processResults(_ results: [VNFaceObservation]?) {
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

        let faceBounds = face.boundingBox  // normalized, bottom-left origin

        // Convert from face-local normalized → full-image normalized coordinates
        let leftPupilImg  = toImageCoords(leftPupil.normalizedPoints[0],  in: faceBounds)
        let rightPupilImg = toImageCoords(rightPupil.normalizedPoints[0], in: faceBounds)

        let leftCenter  = eyeCenter(leftEye,  in: faceBounds)
        let rightCenter = eyeCenter(rightEye, in: faceBounds)
        let leftWidth   = eyeWidth(leftEye,   in: faceBounds)
        let rightWidth  = eyeWidth(rightEye,  in: faceBounds)

        // Iris offset relative to eye center, normalized by eye width.
        // Encodes gaze direction independent of head size or distance from camera.
        let leftOffX  = leftWidth  > 0 ? (leftPupilImg.x  - leftCenter.x)  / leftWidth  : 0
        let leftOffY  = leftWidth  > 0 ? (leftPupilImg.y  - leftCenter.y)  / leftWidth  : 0
        let rightOffX = rightWidth > 0 ? (rightPupilImg.x - rightCenter.x) / rightWidth : 0
        let rightOffY = rightWidth > 0 ? (rightPupilImg.y - rightCenter.y) / rightWidth : 0

        let irisOffX = (leftOffX + rightOffX) / 2
        let irisOffY = (leftOffY + rightOffY) / 2

        // Face centre = coarse head-direction; iris offset = fine gaze direction
        let gazeNormX = faceBounds.midX + irisOffX * 0.5
        let gazeNormY = faceBounds.midY + irisOffY * 0.5  // bottom-left origin

        // Raw signal: flip Y to top-left origin, keep in 0-1 normalised space.
        // This is what CalibrationManager uses to build a calibrated mapping.
        let raw = CGPoint(x: gazeNormX, y: 1.0 - gazeNormY)

        guard let screen = NSScreen.main else { return }
        let w = screen.frame.width
        let h = screen.frame.height

        // Default (uncalibrated) mapping: gain expands the typical movement range to the full screen
        let gain: CGFloat = 2.2
        let mappedX = (gazeNormX - 0.5) * gain + 0.5
        let mappedY = (gazeNormY - 0.5) * gain + 0.5

        let screenX = Swift.max(0, Swift.min(mappedX * w, w))
        let screenY = Swift.max(0, Swift.min((1.0 - mappedY) * h, h))  // flip Y → top-left

        let smoothed = applyEMA(to: CGPoint(x: screenX, y: screenY))
        DispatchQueue.main.async {
            self.rawGazeSignal = raw
            self.gazePoint = smoothed
        }
    }

    // MARK: Helpers

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

    func applyEMA(to new: CGPoint) -> CGPoint {
        guard hasInitialPoint else {
            smoothedPoint = new
            hasInitialPoint = true
            return new
        }
        let s = smoothingFactor
        smoothedPoint = CGPoint(
            x: smoothedPoint.x + s * (new.x - smoothedPoint.x),
            y: smoothedPoint.y + s * (new.y - smoothedPoint.y)
        )
        return smoothedPoint
    }
}
