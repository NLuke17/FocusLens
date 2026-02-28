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
                ControlBarView(viewModel: viewModel, isHovered: $isControlBarHovered)
                    .padding(.top, 20)
                
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
            // Use NSVisualEffectView for native blur
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
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
