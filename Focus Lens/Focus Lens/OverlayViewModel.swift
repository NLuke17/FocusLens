//
//  OverlayViewModel.swift
//  FocusLens
//
//  View model for overlay state management
//

import SwiftUI
import Combine

class OverlayViewModel: ObservableObject {
    @Published var enabled: Bool = true
    @Published var focusRadius: CGFloat = 200
    @Published var blurRadius: CGFloat = 30
    @Published var dimOpacity: Double = 0.3
    @Published var mousePosition: CGPoint = .zero
    @Published var darkMode: Bool = true
    
    init() {
        // Initialize with screen center
        if let screen = NSScreen.main {
            mousePosition = CGPoint(x: screen.frame.width / 2, y: screen.frame.height / 2)
        }
    }
}
