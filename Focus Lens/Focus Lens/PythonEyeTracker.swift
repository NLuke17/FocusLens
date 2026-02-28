//
//  PythonEyeTracker.swift
//  FocusLens
//
//  Bridge to Python-based eye tracking using dlib for better accuracy.
//  Falls back to native Vision if Python not available.
//

import Foundation
import Combine
import AppKit

class PythonEyeTracker: ObservableObject {
    @Published var gazePoint: CGPoint = .zero
    @Published var rawGazeSignal: CGPoint = .zero
    @Published var isTracking: Bool = false
    @Published var faceDetected: Bool = false
    @Published var errorMessage: String? = nil
    @Published var fps: Double = 0
    
    private var process: Process?
    private var outputPipe: Pipe?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public API
    
    func startTracking() {
        guard process == nil else { return }
        
        errorMessage = nil
        
        // Find Python script (prefer OpenCV version, then MediaPipe, then dlib)
        guard let scriptPath = Bundle.main.path(forResource: "eye_tracker_opencv", ofType: "py") ??
                Bundle.main.path(forResource: "eye_tracker_mediapipe", ofType: "py") ??
                Bundle.main.path(forResource: "python_eye_tracker", ofType: "py") ??
                findScriptInWorkspace() else {
            errorMessage = "Python eye tracker script not found. Using native tracking."
            return
        }
        
        startPythonProcess(scriptPath: scriptPath)
    }
    
    func stopTracking() {
        process?.terminate()
        process = nil
        outputPipe = nil
        
        DispatchQueue.main.async {
            self.isTracking = false
            self.faceDetected = false
        }
    }
    
    // MARK: - Private
    
    private func findScriptInWorkspace() -> String? {
        // Look in common locations (prefer OpenCV, then MediaPipe, then dlib)
        let scripts = [
            "eye_tracker_opencv.py",
            "eye_tracker_mediapipe.py",
            "python_eye_tracker.py"
        ]
        
        // Try absolute path first (most reliable for development)
        let absolutePath = "/Users/lukezhu/Documents/hackathon/FocusLens-Swift"
        for script in scripts {
            let fullPath = "\(absolutePath)/\(script)"
            if FileManager.default.fileExists(atPath: fullPath) {
                print("✅ Found Python script at: \(fullPath)")
                return fullPath
            }
        }
        
        // Try relative to current directory
        for script in scripts {
            let locations = [
                FileManager.default.currentDirectoryPath + "/\(script)",
                FileManager.default.currentDirectoryPath + "/../\(script)",
                FileManager.default.currentDirectoryPath + "/../../\(script)",
                FileManager.default.currentDirectoryPath + "/../../../\(script)",
            ]
            
            for path in locations {
                if FileManager.default.fileExists(atPath: path) {
                    print("✅ Found Python script at: \(path)")
                    return path
                }
            }
        }
        
        print("❌ Python script not found. Searched:")
        print("   - \(absolutePath)/eye_tracker_opencv.py")
        print("   - Current dir: \(FileManager.default.currentDirectoryPath)")
        return nil
    }
    
    private func startPythonProcess(scriptPath: String) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        // Use system Python to avoid sandbox permission issues with venv
        // macOS blocks access to venv/pyvenv.cfg when running from app bundle
        print("🐍 Using system Python3 (sandbox-safe)")
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [scriptPath]
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Read stderr for debugging
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty, let errorStr = String(data: data, encoding: .utf8) {
                print("🐍 Python stderr:", errorStr)
            }
        }
        
        // Handle process termination
        process.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                self?.isTracking = false
                if process.terminationStatus != 0 {
                    self?.errorMessage = "Python tracker crashed (exit \(process.terminationStatus))"
                    print("❌ Python process exited with code: \(process.terminationStatus)")
                }
            }
        }
        
        self.process = process
        self.outputPipe = outputPipe
        
        // Start reading output
        startReadingOutput(pipe: outputPipe)
        
        // Launch process
        do {
            print("🚀 Starting Python tracker: \(scriptPath)")
            try process.run()
            DispatchQueue.main.async {
                self.isTracking = true
                print("✅ Python tracker started successfully")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to start Python: \(error.localizedDescription)"
                print("❌ Failed to start Python:", error.localizedDescription)
            }
        }
    }
    
    private func startReadingOutput(pipe: Pipe) {
        let handle = pipe.fileHandleForReading
        
        handle.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            
            guard let output = String(data: data, encoding: .utf8) else { return }
            
            // Process each line (one JSON object per line)
            let lines = output.components(separatedBy: .newlines)
            for line in lines {
                guard !line.isEmpty else { continue }
                self?.processOutput(line)
            }
        }
    }
    
    private func processOutput(_ line: String) {
        guard let data = line.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("⚠️ Failed to parse JSON: \(line)")
            return
        }
        
        // Check for errors
        if let error = json["error"] as? String {
            DispatchQueue.main.async {
                self.errorMessage = "Python: \(error)"
            }
            return
        }
        
        // Check for ready status
        if let status = json["status"] as? String, status == "ready" {
            print("✅ Python eye tracker ready")
            return
        }
        
        // Parse gaze data
        guard let gazeX = json["gaze_x"] as? Double,
              let gazeY = json["gaze_y"] as? Double,
              let faceDetected = json["face_detected"] as? Bool else {
            return
        }
        
        guard let screen = NSScreen.main else { return }
        let w = screen.frame.width
        let h = screen.frame.height
        
        // Convert normalized coordinates to screen pixels
        let screenX = gazeX * w
        let screenY = gazeY * h
        
        DispatchQueue.main.async {
            self.faceDetected = faceDetected
            self.rawGazeSignal = CGPoint(x: gazeX, y: gazeY)
            self.gazePoint = CGPoint(x: screenX, y: screenY)
            
            if let fps = json["fps"] as? Double {
                self.fps = fps
            }
        }
    }
}
