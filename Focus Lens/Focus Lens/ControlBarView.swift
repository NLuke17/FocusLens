//
//  ControlBarView.swift
//  FocusLens
//
//  Control bar with sliders and toggles
//

import SwiftUI

struct ControlBarView: View {
    @ObservedObject var viewModel: OverlayViewModel
    
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
            
            Divider()
                .frame(height: 24)
            
            // Blur Radius slider
            HStack(spacing: 8) {
                Text("BLUR")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Slider(value: $viewModel.blurRadius, in: 0...50, step: 1)
                    .frame(width: 100)
                
                Text("\(Int(viewModel.blurRadius))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .trailing)
                    .monospacedDigit()
            }
            
            // Focus Radius slider
            HStack(spacing: 8) {
                Text("RADIUS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Slider(value: $viewModel.focusRadius, in: 50...500, step: 10)
                    .frame(width: 100)
                
                Text("\(Int(viewModel.focusRadius))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
            }
            
            // Dim Opacity slider
            HStack(spacing: 8) {
                Text("DIM")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Slider(value: $viewModel.dimOpacity, in: 0...0.8, step: 0.05)
                    .frame(width: 100)
                
                Text("\(Int(viewModel.dimOpacity * 100))%")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
                    .monospacedDigit()
            }
            
            Divider()
                .frame(height: 24)
            
            // Status badge
            Text(viewModel.enabled ? "Active" : "Inactive")
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(viewModel.enabled ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                .foregroundColor(viewModel.enabled ? .green : .gray)
                .cornerRadius(4)
            
            Divider()
                .frame(height: 24)
            
            // Dark mode toggle
            Button(action: {
                viewModel.darkMode.toggle()
            }) {
                Image(systemName: viewModel.darkMode ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 14))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            VisualEffectBlur(material: .hudWindow, blendingMode: .withinWindow)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}
