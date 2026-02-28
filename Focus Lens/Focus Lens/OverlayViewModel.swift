//
//  OverlayViewModel.swift
//  FocusLens
//
//  View model for overlay state management
//

import SwiftUI
import Combine

enum TrackingMode {
    case cursor
    case eye
}

enum EyeTrackerBackend {
    case native  // Vision framework
    case python  // dlib-based Python tracker
}

class OverlayViewModel: ObservableObject {
    @Published var enabled: Bool = true
    @Published var focusRadius: CGFloat = 200
    @Published var blurRadius: CGFloat = 30
    @Published var dimOpacity: Double = 0.3
    @Published var mousePosition: CGPoint = .zero
    @Published var darkMode: Bool = true
    @Published var trackingMode: TrackingMode = .cursor
    @Published var backend: EyeTrackerBackend = .python  // Try Python first

    let nativeTracker = EyeTrackingManager()
    let pythonTracker = PythonEyeTracker()
    let calibration = CalibrationManager()
    private var cancellables = Set<AnyCancellable>()
    
    private var currentTracker: AnyObject {
        backend == .python ? pythonTracker : nativeTracker
    }

    init() {
        if let screen = NSScreen.main {
            mousePosition = CGPoint(x: screen.frame.width / 2, y: screen.frame.height / 2)
        }
        subscribeToTrackers()
    }

    // MARK: - Tracking mode

    func setTrackingMode(_ mode: TrackingMode) {
        trackingMode = mode
        if mode == .eye {
            startEyeTracking()
        } else {
            stopEyeTracking()
        }
    }
    
    func switchBackend(_ newBackend: EyeTrackerBackend) {
        let wasTracking = trackingMode == .eye
        
        // Stop current tracker
        if wasTracking {
            stopEyeTracking()
        }
        
        // Switch backend
        backend = newBackend
        
        // Restart if needed
        if wasTracking {
            startEyeTracking()
        }
    }
    
    private func startEyeTracking() {
        if backend == .python {
            pythonTracker.startTracking()
            
            // Fallback to native if Python fails
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self else { return }
                if self.pythonTracker.errorMessage != nil && !self.pythonTracker.isTracking {
                    print("⚠️ Python tracker failed, falling back to native Vision")
                    self.backend = .native
                    self.nativeTracker.startTracking()
                }
            }
        } else {
            nativeTracker.startTracking()
        }
    }
    
    private func stopEyeTracking() {
        pythonTracker.stopTracking()
        nativeTracker.stopTracking()
    }

    /// Called by mouse monitors in OverlayWindow. No-op while eye tracking is active.
    func updateCursorPosition(_ point: CGPoint) {
        guard trackingMode == .cursor else { return }
        mousePosition = point
    }

    // MARK: - Subscriptions

    private func subscribeToTrackers() {
        // Subscribe to Python tracker
        pythonTracker.$rawGazeSignal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signal in
                guard let self, self.trackingMode == .eye, self.backend == .python, signal != .zero else { return }
                self.calibration.addSample(signal)
                if self.calibration.isCalibrated,
                   let screen = NSScreen.main,
                   let pt = self.calibration.mapToScreen(signal, screenSize: screen.frame.size) {
                    self.mousePosition = pt
                }
            }
            .store(in: &cancellables)
        
        pythonTracker.$gazePoint
            .receive(on: DispatchQueue.main)
            .sink { [weak self] point in
                guard let self,
                      self.trackingMode == .eye,
                      self.backend == .python,
                      !self.calibration.isCalibrated,
                      point != .zero else { return }
                self.mousePosition = point
            }
            .store(in: &cancellables)
        
        // Subscribe to native tracker
        nativeTracker.$rawGazeSignal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signal in
                guard let self, self.trackingMode == .eye, self.backend == .native, signal != .zero else { return }
                self.calibration.addSample(signal)
                if self.calibration.isCalibrated,
                   let screen = NSScreen.main,
                   let pt = self.calibration.mapToScreen(signal, screenSize: screen.frame.size) {
                    self.mousePosition = pt
                }
            }
            .store(in: &cancellables)

        nativeTracker.$gazePoint
            .receive(on: DispatchQueue.main)
            .sink { [weak self] point in
                guard let self,
                      self.trackingMode == .eye,
                      self.backend == .native,
                      !self.calibration.isCalibrated,
                      point != .zero else { return }
                self.mousePosition = point
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed properties for UI
    
    var currentTrackerIsTracking: Bool {
        backend == .python ? pythonTracker.isTracking : nativeTracker.isTracking
    }
    
    var currentTrackerFaceDetected: Bool {
        backend == .python ? pythonTracker.faceDetected : nativeTracker.faceDetected
    }
    
    var currentTrackerError: String? {
        backend == .python ? pythonTracker.errorMessage : nativeTracker.errorMessage
    }
}
