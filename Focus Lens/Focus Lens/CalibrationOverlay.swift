//
//  CalibrationOverlay.swift
//  FocusLens
//
//  Visual overlay for 5-point gaze calibration
//

import SwiftUI

struct CalibrationOverlay: View {
    @ObservedObject var calibration: CalibrationManager
    
    var body: some View {
        if calibration.isCalibrating {
            ZStack {
                // Semi-transparent dark background
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                // Calibration points
                GeometryReader { geometry in
                    ForEach(0..<calibration.points.count, id: \.self) { index in
                        let point = calibration.points[index]
                        let screenPos = CGPoint(
                            x: CGFloat(point.x) * geometry.size.width,
                            y: CGFloat(point.y) * geometry.size.height
                        )
                        
                        CalibrationPoint(
                            isActive: index == calibration.currentStep,
                            progress: index == calibration.currentStep ? calibration.stepProgress : (index < calibration.currentStep ? 1.0 : 0.0),
                            position: screenPos
                        )
                    }
                }
                
                // Instructions
                VStack {
                    Spacer().frame(height: 80)
                    
                    VStack(spacing: 16) {
                        Text("Eye Tracking Calibration")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Look at each circle and keep your gaze steady")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Step \(calibration.currentStep + 1) of \(calibration.points.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.5))
                            .shadow(radius: 20)
                    )
                    
                    Spacer()
                    
                    // Cancel button
                    Button(action: { calibration.cancelCalibration() }) {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 40)
                }
            }
            .allowsHitTesting(true)
        }
    }
}

struct CalibrationPoint: View {
    let isActive: Bool
    let progress: Double
    let position: CGPoint
    
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Outer ring - progress indicator
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    isActive ? Color.blue : Color.green,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            
            // Middle ring - pulse effect when active
            if isActive {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    .frame(width: pulse ? 80 : 60, height: pulse ? 80 : 60)
                    .opacity(pulse ? 0 : 1)
                    .animation(
                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: pulse
                    )
                    .onAppear { pulse = true }
            }
            
            // Center dot
            Circle()
                .fill(isActive ? Color.blue : (progress > 0 ? Color.green : Color.white.opacity(0.5)))
                .frame(width: 16, height: 16)
            
            // Inner dot
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
        }
        .position(position)
    }
}

// MARK: - Preview
struct CalibrationOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let calibration = CalibrationManager()
        calibration.isCalibrating = true
        calibration.currentStep = 0
        calibration.stepProgress = 0.6
        
        return CalibrationOverlay(calibration: calibration)
            .frame(width: 1440, height: 900)
    }
}
