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
