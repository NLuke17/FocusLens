//
//  ControlBarView.swift
//  FocusLens
//
//  Control bar with sliders and toggles
//

import SwiftUI

struct ControlBarView: View {
    @ObservedObject var viewModel: OverlayViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var currentDragOffset: CGSize = .zero
    @State private var isMinimized: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Enable/Disable toggle
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.enabled ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text("Overlay")
                    .font(.system(size: 12, weight: .medium))
                
                Toggle("", isOn: $viewModel.enabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            
            // Only show sliders when not minimized
            if !isMinimized {
                Divider()
                    .frame(height: 24)
                
                // Blur Radius slider
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Blur Intensity")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.blurRadius))")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                    }
                    .frame(width: 120)
                    
                    Slider(value: $viewModel.blurRadius, in: 0...50, step: 1)
                        .frame(width: 120)
                }
                
                // Focus Radius slider
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Focus Radius")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.focusRadius))")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                    }
                    .frame(width: 120)
                    
                    Slider(value: $viewModel.focusRadius, in: 50...500, step: 10)
                        .frame(width: 120)
                }
                
                // Dim Opacity slider
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Dim Opacity")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.dimOpacity * 100))%")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                    }
                    .frame(width: 120)
                    
                    Slider(value: $viewModel.dimOpacity, in: 0...0.8, step: 0.05)
                        .frame(width: 120)
                }
            }
            
            Divider()
                .frame(height: 24)
            
            // Status badge - fixed width for consistency
            Text(viewModel.enabled ? "Active" : "Inactive")
                .font(.system(size: 10, weight: .bold))
                .frame(width: 60)  // Fixed width
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(viewModel.enabled ? Color.green : Color.gray.opacity(0.5))
                )
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            Divider()
                .frame(height: 24)
            
            // Minimize button
            Button(action: {
                isMinimized.toggle()
            }) {
                Image(systemName: isMinimized ? "arrow.up.left.and.arrow.down.right" : "minus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help(isMinimized ? "Expand" : "Minimize")
            
            // Dark mode toggle
            Button(action: {
                viewModel.darkMode.toggle()
            }) {
                Image(systemName: viewModel.darkMode ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 14))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            // Eye tracking toggle + calibrate button
            EyeTrackingToggle(viewModel: viewModel)

            if viewModel.trackingMode == .eye {
                Button(action: { viewModel.calibration.startCalibration() }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.calibration.isCalibrated ? "checkmark.circle.fill" : "scope")
                            .font(.system(size: 12))
                        Text(viewModel.calibration.isCalibrated ? "Recalibrate" : "Calibrate")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(viewModel.calibration.isCalibrated ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .foregroundColor(viewModel.calibration.isCalibrated ? .green : .orange)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Run 5-point eye tracking calibration")
            }

            Divider()
                .frame(height: 24)
            
            // Quit button
            Button(action: {
                NSApp.terminate(nil)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("Quit FocusLens")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .fixedSize()  // Prevent shrinking
        .offset(x: dragOffset.width + currentDragOffset.width, 
                y: dragOffset.height + currentDragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    currentDragOffset = value.translation
                }
                .onEnded { value in
                    dragOffset.width += value.translation.width
                    dragOffset.height += value.translation.height
                    currentDragOffset = .zero
                }
        )
    }
}

// MARK: - Eye Tracking Toggle

struct EyeTrackingToggle: View {
    @ObservedObject var viewModel: OverlayViewModel

    private var isEyeMode: Bool { viewModel.trackingMode == .eye }

    var body: some View {
        HStack(spacing: 5) {
            // Status dot: green = face found, orange = searching, red = error
            if isEyeMode {
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
                    .help(dotHelp)
            }

             Button(action: {
                 viewModel.setTrackingMode(isEyeMode ? .cursor : .eye)
             }) {
                 HStack(spacing: 4) {
                     Image(systemName: isEyeMode ? "eye.fill" : "cursorarrow.click")
                        .font(.system(size: 13))
                    Text(isEyeMode ? "Eye" : "Cursor")
                        .font(.system(size: 10, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isEyeMode ? Color.blue.opacity(0.25) : Color.gray.opacity(0.15))
                .foregroundColor(isEyeMode ? .blue : .primary)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .help(isEyeMode ? "Switch to cursor tracking" : "Switch to eye tracking")

            // Inline error message
            if let error = viewModel.eyeTracker.errorMessage {
                Text(error)
                    .font(.system(size: 9))
                    .foregroundColor(.red)
                    .lineLimit(1)
                    .frame(maxWidth: 180)
            }
        }
        .alert("Camera Permission Required", isPresented: .constant(viewModel.eyeTracker.errorMessage != nil && isEyeMode)) {
            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                    NSWorkspace.shared.open(url)
                }
                viewModel.eyeTracker.errorMessage = nil
            }
            Button("Switch to Cursor", role: .cancel) {
                viewModel.setTrackingMode(.cursor)
                viewModel.eyeTracker.errorMessage = nil
            }
        } message: {
            Text(viewModel.eyeTracker.errorMessage ?? "Camera access is required for eye tracking.")
        }
    }

    private var dotColor: Color {
        if viewModel.eyeTracker.errorMessage != nil { return .red }
        return viewModel.eyeTracker.faceDetected ? .green : .orange
    }

    private var dotHelp: String {
        if let error = viewModel.eyeTracker.errorMessage { return error }
        return viewModel.eyeTracker.faceDetected ? "Face detected" : "Searching for face…"
    }
}
