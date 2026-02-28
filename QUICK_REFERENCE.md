# Quick Reference Card

## 🚀 Quick Start

```bash
# Navigate to project
cd /Users/lukezhu/Documents/hackathon/FocusLens-Swift

# Run setup helper
./setup.sh

# Or manually open in Xcode
open FocusLens.xcodeproj  # (after creating project)
```

## 📋 Build Checklist

- [ ] Xcode 15.0+ installed
- [ ] macOS 13.0+ deployment target
- [ ] All 7 Swift files added to project
- [ ] Info.plist replaced with custom version
- [ ] FocusLens.entitlements added
- [ ] App Sandbox DISABLED in Signing & Capabilities
- [ ] Build succeeds (Cmd+B)
- [ ] App runs (Cmd+R)

## 🎮 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+Q` | Quit FocusLens |
| `Cmd+R` | Build & Run (in Xcode) |
| `Cmd+B` | Build Only (in Xcode) |

## 🎛️ Default Settings

```swift
enabled: true                 // Overlay on by default
focusRadius: 200              // 200px radius
blurRadius: 30                // 30px blur
dimOpacity: 0.3               // 30% dimming
darkMode: true                // Dark theme
```

## 📐 Adjustable Ranges

| Parameter | Min | Max | Step | Default |
|-----------|-----|-----|------|---------|
| Blur Radius | 0 | 50 | 1 | 30 |
| Focus Radius | 50 | 500 | 10 | 200 |
| Dim Opacity | 0 | 0.8 | 0.05 | 0.3 |

## 🗂️ File Responsibilities

| File | Purpose | Key Classes/Structs |
|------|---------|---------------------|
| `FocusLensApp.swift` | App lifecycle, status bar | `FocusLensApp`, `AppDelegate` |
| `OverlayWindow.swift` | Window setup, mouse tracking | `OverlayWindow` |
| `OverlayViewModel.swift` | State management | `OverlayViewModel` |
| `OverlayContentView.swift` | Main view composition | `OverlayContentView`, `BlurOverlayView`, `DimOverlayView`, `FocusRingView`, `VisualEffectBlur` |
| `ControlBarView.swift` | Control UI | `ControlBarView` |
| `Info.plist` | App metadata | - |
| `FocusLens.entitlements` | Permissions | - |

## 🔧 Common Customizations

### Change Default Blur Amount:
```swift
// In OverlayViewModel.swift
@Published var blurRadius: CGFloat = 30  // Change this value
```

### Change Blur Material:
```swift
// In OverlayContentView.swift
VisualEffectBlur(material: .hudWindow, ...)
// Options: .hudWindow, .underWindowBackground, .fullScreenUI, .menu
```

### Change Focus Ring Color:
```swift
// In OverlayContentView.swift, FocusRingView
.stroke(Color.blue.opacity(0.4), lineWidth: 2)
// Change Color.blue to any color
```

### Change Window Level:
```swift
// In OverlayWindow.swift
self.level = .floating
// Options: .normal, .floating, .statusBar, .popUpMenu, .screenSaver
```

## 🐛 Debug Mode

Add to any file for debugging:

```swift
print("Mouse: \(mousePosition)")
print("Blur: \(blurRadius)")
print("Radius: \(focusRadius)")
print("Enabled: \(enabled)")
```

View in Xcode Console while running.

## 📊 Performance Targets

| Metric | Target | How to Check |
|--------|--------|--------------|
| Memory | < 50 MB | Activity Monitor |
| CPU (idle) | < 0.5% | Activity Monitor |
| FPS | 60 | Xcode Instruments |
| Startup | < 0.2s | Timer |

## 🔍 Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| Won't build | Clean build folder (Cmd+Shift+K) |
| Blur not working | Check material & blendingMode |
| Window not transparent | Verify isOpaque = false |
| Mouse not tracking | Check global event monitor |
| High CPU | Reduce blur radius |
| Laggy tracking | Check for heavy computations |

## 📦 Distribution

### For Testing:
```bash
# Build release version
xcodebuild -project FocusLens.xcodeproj \
  -scheme FocusLens \
  -configuration Release \
  build

# Copy to Applications
cp -R build/Release/FocusLens.app /Applications/
```

### For Public Release:
1. Enroll in Apple Developer Program ($99/year)
2. Code sign with Developer ID
3. Notarize with Apple
4. Create DMG or PKG installer

## 🎨 UI Customization Ideas

```swift
// Glass effect for control bar
.background(VisualEffectBlur(material: .hudWindow))

// Add shadow
.shadow(color: .black.opacity(0.3), radius: 10)

// Rounded corners
.cornerRadius(20)

// Gradient background
.background(
  LinearGradient(
    colors: [.blue, .purple],
    startPoint: .leading,
    endPoint: .trailing
  )
)
```

## 📞 Getting Help

1. **Build Issues**: Check BUILD_GUIDE.md
2. **Architecture Questions**: Read MIGRATION.md
3. **Feature Details**: See README.md
4. **All Details**: Read PROJECT_COMPLETE.md

## ✅ Quick Test

After building, verify:
- [ ] App icon appears in status bar
- [ ] Blur visible outside focus circle
- [ ] Focus circle follows mouse smoothly
- [ ] Sliders change blur/radius/dim
- [ ] Toggle enables/disables overlay
- [ ] Dark/light mode switches theme
- [ ] Cmd+Shift+Q quits app

---

**Happy Coding!** 🎉

For full documentation, see README.md and BUILD_GUIDE.md
