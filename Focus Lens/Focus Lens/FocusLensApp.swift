//
//  FocusLensApp.swift
//  FocusLens
//
//  Native macOS focus overlay with blur effect
//

import SwiftUI

@main
struct FocusLensApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: OverlayWindow?
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Create status bar item
        setupStatusBar()
        
        // Create overlay window
        overlayWindow = OverlayWindow()
        overlayWindow?.orderFront(nil)
        
        // Register global keyboard shortcuts
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Cmd+Shift+Q to quit
            if event.modifierFlags.contains([.command, .shift]) && event.charactersIgnoringModifiers == "q" {
                NSApp.terminate(nil)
                return nil
            }
            // Escape key to quit (easier!)
            if event.keyCode == 53 { // Escape key
                NSApp.terminate(nil)
                return nil
            }
            // Cmd+Q to quit (standard Mac quit)
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "q" {
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
    }
    
    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "scope", accessibilityDescription: "FocusLens")
            button.action = #selector(statusBarClicked)
            button.target = self
        }
    }
    
    @objc func statusBarClicked() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "FocusLens", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit FocusLens", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = .command
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
