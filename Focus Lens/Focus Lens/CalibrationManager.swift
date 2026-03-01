//
//  CalibrationManager.swift
//  FocusLens
//
//  5-point gaze calibration using least-squares affine transform fitting.
//  The calibration maps raw iris signals (0-1 normalised, top-left origin)
//  to normalised screen coordinates (0-1), which are then scaled to pixels.
//

import AppKit
import Combine

// MARK: - Calibration Manager

class CalibrationManager: ObservableObject {
    // MARK: Published state

    @Published var isCalibrating: Bool = false
    @Published var isCalibrated: Bool = false
    @Published var currentStep: Int = 0        // 0 … points.count-1
    @Published var stepProgress: Double = 0    // 0 … 1 within the current step

    // MARK: Calibration points (normalised screen coords, top-left origin)

    let points: [CGPoint] = [
        CGPoint(x: 0.50, y: 0.50),  // centre         — step 0
        CGPoint(x: 0.15, y: 0.15),  // top-left       — step 1
        CGPoint(x: 0.85, y: 0.15),  // top-right      — step 2
        CGPoint(x: 0.15, y: 0.85),  // bottom-left    — step 3
        CGPoint(x: 0.85, y: 0.85),  // bottom-right   — step 4
    ]

    // How many frames to collect per point (~3 seconds at 30 fps for more stable calibration)
    private let samplesPerPoint = 90

    // MARK: Private

    private var collected: [[CGPoint]] = []   // averaged later
    private var currentSamples: [CGPoint] = []
    private var transform: GazeTransform?

    // MARK: - Public API

    func startCalibration() {
        collected = []
        currentSamples = []
        transform = nil
        currentStep = 0
        stepProgress = 0
        isCalibrated = false
        isCalibrating = true
        
        // Force update on main thread
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        print("🎯 Calibration started - waiting for samples...")
    }

    func cancelCalibration() {
        isCalibrating = false
        currentStep = 0
        stepProgress = 0
    }

    /// Feed every raw gaze signal from EyeTrackingManager here.
    /// Automatically advances through steps and finalises when done.
    func addSample(_ signal: CGPoint) {
        guard isCalibrating else { return }

        currentSamples.append(signal)
        
        // Force UI update for progress
        DispatchQueue.main.async {
            self.stepProgress = Double(self.currentSamples.count) / Double(self.samplesPerPoint)
            self.objectWillChange.send()
        }
        
        // Debug: Log progress every 10 samples
        if currentSamples.count % 10 == 0 {
            print("📊 Calibration step \(currentStep): \(currentSamples.count)/\(samplesPerPoint) samples, progress: \(stepProgress)")
        }

        if currentSamples.count >= samplesPerPoint {
            collected.append(currentSamples)
            currentSamples = []
            
            DispatchQueue.main.async {
                self.stepProgress = 0
                
                if self.collected.count >= self.points.count {
                    self.finalise()
                } else {
                    self.currentStep += 1
                    print("✅ Calibration step \(self.currentStep - 1) complete, moving to step \(self.currentStep)")
                    self.objectWillChange.send()
                }
            }
        }
    }

    /// Map a raw gaze signal to a screen point using the fitted transform.
    /// Returns nil if calibration hasn't been completed yet.
    func mapToScreen(_ signal: CGPoint, screenSize: CGSize) -> CGPoint? {
        transform?.apply(signal, screenSize: screenSize)
    }

    // MARK: - Private helpers

    private func finalise() {
        // Average the collected samples for each calibration point
        // Use median instead of mean to better reject outliers
        let avgSignals: [CGPoint] = collected.map { samples in
            // Sort and take median 50% of samples (remove outliers)
            let sortedX = samples.map(\.x).sorted()
            let sortedY = samples.map(\.y).sorted()
            let count = samples.count
            let trimAmount = count / 4  // Remove 25% from each end
            
            let trimmedX = sortedX.dropFirst(trimAmount).dropLast(trimAmount)
            let trimmedY = sortedY.dropFirst(trimAmount).dropLast(trimAmount)
            
            let n = CGFloat(trimmedX.count)
            return CGPoint(
                x: trimmedX.reduce(0, +) / n,
                y: trimmedY.reduce(0, +) / n
            )
        }

        if let t = fitAffineTransform(rawPoints: avgSignals, screenPoints: points) {
            transform = t
            isCalibrated = true
        }
        isCalibrating = false
    }
}

// MARK: - Affine transform

/// Affine mapping: normalisedScreen = A · rawSignal + b
/// screen_x_norm = ax*raw_x + bx*raw_y + cx
/// screen_y_norm = ay*raw_x + by*raw_y + cy
struct GazeTransform {
    let ax, bx, cx: Double
    let ay, by, cy: Double

    func apply(_ raw: CGPoint, screenSize: CGSize) -> CGPoint {
        let nx = ax * Double(raw.x) + bx * Double(raw.y) + cx
        let ny = ay * Double(raw.x) + by * Double(raw.y) + cy
        return CGPoint(
            x: Swift.max(0, Swift.min(nx * Double(screenSize.width),  Double(screenSize.width))),
            y: Swift.max(0, Swift.min(ny * Double(screenSize.height), Double(screenSize.height)))
        )
    }
}

// MARK: - Least-squares affine fit

/// Fits screen_coord = a*raw_x + b*raw_y + c independently for X and Y
/// using ordinary least squares (normal equations → 3×3 Gaussian elimination).
private func fitAffineTransform(rawPoints: [CGPoint], screenPoints: [CGPoint]) -> GazeTransform? {
    let n = rawPoints.count
    guard n >= 3, n == screenPoints.count else { return nil }

    // Accumulate A^T A and A^T b for both axes
    var ATA  = [[Double]](repeating: [Double](repeating: 0, count: 3), count: 3)
    var ATbX = [Double](repeating: 0, count: 3)
    var ATbY = [Double](repeating: 0, count: 3)

    for i in 0..<n {
        let rx = Double(rawPoints[i].x)
        let ry = Double(rawPoints[i].y)
        let sx = Double(screenPoints[i].x)
        let sy = Double(screenPoints[i].y)
        let row = [rx, ry, 1.0]

        for r in 0..<3 {
            ATbX[r] += row[r] * sx
            ATbY[r] += row[r] * sy
            for c in 0..<3 {
                ATA[r][c] += row[r] * row[c]
            }
        }
    }

    guard let cx = solveLinear3x3(ATA, ATbX),
          let cy = solveLinear3x3(ATA, ATbY) else { return nil }

    return GazeTransform(ax: cx[0], bx: cx[1], cx: cx[2],
                         ay: cy[0], by: cy[1], cy: cy[2])
}

/// Gaussian elimination with partial pivoting for a 3×3 system A·x = b.
private func solveLinear3x3(_ A: [[Double]], _ b: [Double]) -> [Double]? {
    // Build augmented matrix [A | b]
    var M = (0..<3).map { i in A[i] + [b[i]] }

    for col in 0..<3 {
        // Partial pivot
        var maxRow = col
        for row in (col + 1)..<3 {
            if abs(M[row][col]) > abs(M[maxRow][col]) { maxRow = row }
        }
        guard abs(M[maxRow][col]) > 1e-12 else { return nil }
        M.swapAt(col, maxRow)

        // Eliminate below
        for row in (col + 1)..<3 {
            let factor = M[row][col] / M[col][col]
            for j in col...3 { M[row][j] -= factor * M[col][j] }
        }
    }

    // Back-substitution
    var x = [Double](repeating: 0, count: 3)
    for i in stride(from: 2, through: 0, by: -1) {
        x[i] = M[i][3]
        for j in (i + 1)..<3 { x[i] -= M[i][j] * x[j] }
        x[i] /= M[i][i]
    }
    return x
}
