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

class OverlayViewModel: ObservableObject {
    @Published var enabled: Bool = true
    @Published var focusRadius: CGFloat = 200
    @Published var blurRadius: CGFloat = 30
    @Published var dimOpacity: Double = 0.3
    @Published var mousePosition: CGPoint = .zero
    @Published var darkMode: Bool = true
    @Published var trackingMode: TrackingMode = .cursor

    let eyeTracker = EyeTrackingManager()
    let calibration = CalibrationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        if let screen = NSScreen.main {
            mousePosition = CGPoint(x: screen.frame.width / 2, y: screen.frame.height / 2)
        }
        subscribeToEyeTracker()
    }

    // MARK: - Tracking mode

    func setTrackingMode(_ mode: TrackingMode) {
        trackingMode = mode
        if mode == .eye {
            eyeTracker.startTracking()
        } else {
            eyeTracker.stopTracking()
        }
    }

    /// Called by mouse monitors in OverlayWindow. No-op while eye tracking is active.
    func updateCursorPosition(_ point: CGPoint) {
        guard trackingMode == .cursor else { return }
        mousePosition = point
    }

    // MARK: - Subscriptions

    private func subscribeToEyeTracker() {
        print("👀 Setting up eye tracker subscriptions...")
        
        // Raw signal → calibration samples + calibrated screen position
        eyeTracker.$rawGazeSignal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signal in
                guard let self else { return }
                
                // Debug: Always log when calibrating
                if self.calibration.isCalibrating {
                    if Int.random(in: 0..<30) == 0 {
                        print("🔵 Signal received: (\(String(format: "%.3f", signal.x)), \(String(format: "%.3f", signal.y))), trackingMode: \(self.trackingMode == .eye ? "eye" : "cursor")")
                    }
                }
                
                guard self.trackingMode == .eye else {
                    if self.calibration.isCalibrating {
                        print("⚠️ Calibrating but trackingMode is not .eye!")
                    }
                    return
                }
                
                // Feed samples to calibration (even if signal is near zero)
                // Calibration needs all data points to build accurate mapping
                if self.calibration.isCalibrating {
                    self.calibration.addSample(signal)
                }
                
                // If calibrated, use the fitted affine transform
                if self.calibration.isCalibrated,
                   let screen = NSScreen.main,
                   let pt = self.calibration.mapToScreen(signal, screenSize: screen.frame.size) {
                    self.mousePosition = pt
                }
            }
            .store(in: &cancellables)

        // Fallback: use the default gain-mapped gaze point when not calibrating/calibrated
        eyeTracker.$gazePoint
            .receive(on: DispatchQueue.main)
            .sink { [weak self] point in
                guard let self,
                      self.trackingMode == .eye,
                      !self.calibration.isCalibrated,
                      !self.calibration.isCalibrating,
                      point != .zero else { return }
                self.mousePosition = point
            }
            .store(in: &cancellables)
    }
}
