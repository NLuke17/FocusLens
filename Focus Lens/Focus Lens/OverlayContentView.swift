//
//  OverlayContentView.swift
//  FocusLens
//
//  Main overlay view with blur and focus effects
//

import SwiftUI

struct OverlayContentView: View {
    @ObservedObject var viewModel: OverlayViewModel
    @State private var isControlBarHovered = false
    weak var window: NSWindow?
    
    var body: some View {
        ZStack {
            if viewModel.enabled {
                // Blur layer with circular cutout
                BlurOverlayView(
                    mousePosition: viewModel.mousePosition,
                    focusRadius: viewModel.focusRadius,
                    blurRadius: viewModel.blurRadius
                )
                .allowsHitTesting(false)
                .zIndex(0)
                
                // Dim layer with circular cutout
                DimOverlayView(
                    mousePosition: viewModel.mousePosition,
                    focusRadius: viewModel.focusRadius,
                    dimOpacity: viewModel.dimOpacity
                )
                .allowsHitTesting(false)
                .zIndex(1)
                
                // Focus ring
                FocusRingView(
                    mousePosition: viewModel.mousePosition,
                    focusRadius: viewModel.focusRadius
                )
                .allowsHitTesting(false)
                .zIndex(2)
            }
            
            // Calibration overlay — sits above the focus effects, below the control bar
            if viewModel.calibration.isCalibrating {
                CalibrationOverlayView(calibration: viewModel.calibration)
                    .allowsHitTesting(true)
                    .zIndex(100)
                    .onAppear  { window?.ignoresMouseEvents = false }
                    .onDisappear { window?.ignoresMouseEvents = true }
            }

            // Control bar at the top - always on top with highest z-index
            VStack {
                ControlBarView(viewModel: viewModel)
                    .padding(.top, 60)
                    .onHover { hovering in
                        // Enable mouse events when hovering control bar
                        window?.ignoresMouseEvents = !hovering
                    }

                Spacer()
            }
            .zIndex(999)  // Always on top
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .preferredColorScheme(viewModel.darkMode ? .dark : .light)
    }
}

struct BlurOverlayView: View {
    let mousePosition: CGPoint
    let focusRadius: CGFloat
    let blurRadius: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            // Only show blur if blurRadius > 0
            if blurRadius > 0 {
                ZStack {
                    // Finer blur control: use fewer layers with smoother opacity scaling
                    // This provides more noticeable changes across the 0-50 range
                    let layers = max(1, Int(blurRadius / 16.67))  // 0-50 → 0-3 layers
                    let opacity = min(1.0, blurRadius / 50.0)     // Linear 0-50 → 0-1
                    
                    ForEach(0..<layers, id: \.self) { _ in
                        VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                            .opacity(opacity)
                    }
                }
                .mask(
                    Canvas { context, size in
                        // Fill entire screen
                        context.fill(
                            Path(CGRect(origin: .zero, size: size)),
                            with: .color(.black)
                        )
                        
                        // Cut out the focus circle
                        let circlePath = Path(
                            ellipseIn: CGRect(
                                x: mousePosition.x - focusRadius,
                                y: mousePosition.y - focusRadius,
                                width: focusRadius * 2,
                                height: focusRadius * 2
                            )
                        )
                        context.blendMode = .destinationOut
                        context.fill(circlePath, with: .color(.white))
                    }
                )
            }
        }
    }
}

struct DimOverlayView: View {
    let mousePosition: CGPoint
    let focusRadius: CGFloat
    let dimOpacity: Double
    
    var body: some View {
        GeometryReader { geometry in
            Color.black.opacity(dimOpacity)
                .mask(
                    Canvas { context, size in
                        // Fill entire screen
                        context.fill(
                            Path(CGRect(origin: .zero, size: size)),
                            with: .color(.black)
                        )
                        
                        // Cut out the focus circle
                        let circlePath = Path(
                            ellipseIn: CGRect(
                                x: mousePosition.x - focusRadius,
                                y: mousePosition.y - focusRadius,
                                width: focusRadius * 2,
                                height: focusRadius * 2
                            )
                        )
                        context.blendMode = .destinationOut
                        context.fill(circlePath, with: .color(.white))
                    }
                )
        }
    }
}

struct FocusRingView: View {
    let mousePosition: CGPoint
    let focusRadius: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                .frame(width: focusRadius * 2, height: focusRadius * 2)
                .position(mousePosition)
        }
    }
}

// MARK: - Calibration overlay

struct CalibrationOverlayView: View {
    @ObservedObject var calibration: CalibrationManager

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Semi-transparent backdrop
                Color.black.opacity(0.80)
                    .ignoresSafeArea()

                // Instructions (top)
                VStack(spacing: 8) {
                    Text("Eye Tracking Calibration")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("Look directly at the dot and keep still")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.75))

                    Text("Step \(calibration.currentStep + 1) of \(calibration.points.count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 2)
                }
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                // Pulsing calibration dot with progress ring
                let pt = calibration.points[calibration.currentStep]
                CalibrationDotView(progress: calibration.stepProgress)
                    .position(x: pt.x * geo.size.width,
                              y: pt.y * geo.size.height)

                // Cancel button (bottom)
                VStack {
                    Spacer()
                    Button("Cancel Calibration") {
                        calibration.cancelCalibration()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct CalibrationDotView: View {
    let progress: Double
    @State private var pulsing = false

    var body: some View {
        ZStack {
            // Background progress ring track
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .frame(width: 64, height: 64)

            // Filling progress arc
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: progress)

            // Pulsing centre dot
            Circle()
                .fill(Color.white)
                .frame(width: pulsing ? 18 : 12, height: pulsing ? 18 : 12)
                .shadow(color: .cyan.opacity(0.8), radius: pulsing ? 8 : 4)
                .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: pulsing)
                .onAppear { pulsing = true }
        }
    }
}

// Native NSVisualEffectView wrapper for proper blur
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
