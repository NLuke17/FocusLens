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
                
                // Dim layer with circular cutout
                DimOverlayView(
                    mousePosition: viewModel.mousePosition,
                    focusRadius: viewModel.focusRadius,
                    dimOpacity: viewModel.dimOpacity
                )
                .allowsHitTesting(false)
                
                // Focus ring
                FocusRingView(
                    mousePosition: viewModel.mousePosition,
                    focusRadius: viewModel.focusRadius
                )
                .allowsHitTesting(false)
            }
            
            // Control bar at the top
            VStack {
                ControlBarView(viewModel: viewModel)
                    .padding(.top, 20)
                    .onHover { hovering in
                        // Enable mouse events when hovering control bar
                        window?.ignoresMouseEvents = !hovering
                    }
                
                Spacer()
            }
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
