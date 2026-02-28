//
//  OverlayWindow.swift
//  FocusLens
//
//  Main overlay window that sits on top of all other windows
//

import Cocoa
import SwiftUI

class OverlayWindow: NSWindow {
    let viewModel = OverlayViewModel()
    
    init() {
        let screen = NSScreen.main!
        
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Window configuration for transparent overlay
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        self.ignoresMouseEvents = true  // Enable click-through by default
        self.hasShadow = false
        self.isMovable = false
        
        // Create SwiftUI view
        var contentView = OverlayContentView(viewModel: viewModel)
        contentView.window = self
        self.contentView = NSHostingView(rootView: contentView)
        
        // Setup mouse tracking
        setupMouseTracking()
    }
    
    private func setupMouseTracking() {
        // Track mouse movement globally
        NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            let mouseLocation = NSEvent.mouseLocation
            // Convert from screen coordinates (bottom-left origin) to view coordinates (top-left origin)
            if let screen = NSScreen.main {
                let viewY = screen.frame.height - mouseLocation.y
                self?.viewModel.mousePosition = CGPoint(x: mouseLocation.x, y: viewY)
            }
        }
        
        // Also track local mouse events
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            let mouseLocation = NSEvent.mouseLocation
            if let screen = NSScreen.main {
                let viewY = screen.frame.height - mouseLocation.y
                self?.viewModel.mousePosition = CGPoint(x: mouseLocation.x, y: viewY)
            }
            return event
        }
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}
