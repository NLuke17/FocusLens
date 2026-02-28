<<<<<<< HEAD
# FocusLens - Native macOS App

A native macOS overlay application that provides focus enhancement with real-time blur effects.

## Features

✅ **Native macOS Blur** - Uses `NSVisualEffectView` for hardware-accelerated blur
✅ **Real-time Focus Circle** - Follows your mouse with smooth tracking
✅ **Adjustable Parameters**:
- Blur radius (0-50px)
- Focus circle radius (50-500px)  
- Dimming opacity (0-80%)
✅ **Always-on-Top Overlay** - Floats above all windows
✅ **Click-through** - Doesn't interfere with your workflow
✅ **Status Bar Integration** - Minimal UI, accessible from menu bar
✅ **Dark/Light Mode Support**
✅ **Global Keyboard Shortcut** - Cmd+Shift+Q to quit

## Architecture

### Files Structure:
```
FocusLens/
├── FocusLensApp.swift           # App entry point & lifecycle
├── OverlayWindow.swift          # Window configuration & mouse tracking
├── OverlayViewModel.swift       # State management
├── OverlayContentView.swift     # Main view with blur layers
├── ControlBarView.swift         # Control UI with sliders
├── Info.plist                   # App configuration
└── FocusLens.entitlements       # Security permissions
```

### Key Components:

**OverlayWindow**
- Borderless, transparent window
- Floating level (above normal windows)
- Global mouse tracking
- Full-screen coverage

**BlurOverlayView**
- Uses native `NSVisualEffectView` with `.hudWindow` material
- Canvas-based circular mask
- `.behindWindow` blending mode for true background blur

**DimOverlayView**
- Semi-transparent black overlay
- Same circular mask as blur layer
- Independent opacity control

**FocusRingView**
- Visual indicator circle
- Smooth position tracking

## Building & Running

### Prerequisites:
- macOS 13.0+ (Ventura or later)
- Xcode 15.0+
- Swift 5.9+

### Option 1: Create Xcode Project

1. Open Xcode
2. Create new **macOS App** project:
   - Product Name: `FocusLens`
   - Bundle Identifier: `com.yourname.FocusLens`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: macOS 13.0

3. Replace default files with provided Swift files

4. Add entitlements:
   - Signing & Capabilities → Add Capability → App Sandbox (disable)
   - Use provided `FocusLens.entitlements`

5. Build & Run (Cmd+R)

### Option 2: Command Line Build

```bash
cd /Users/lukezhu/Documents/hackathon/FocusLens-Swift

# Create Xcode project (one-time)
xcodebuild -project FocusLens.xcodeproj \
  -scheme FocusLens \
  -configuration Release \
  build

# Run
open build/Release/FocusLens.app
```

### Option 3: Swift Package Manager (For Testing)

```bash
cd FocusLens
swift build
swift run
```

## Usage

1. **Launch App** - FocusLens icon appears in status bar
2. **Overlay Activates** - Blur and dim effects applied outside focus circle
3. **Move Mouse** - Focus circle follows cursor automatically
4. **Adjust Settings** - Use control bar at top of screen:
   - Toggle overlay on/off
   - Adjust blur intensity
   - Resize focus circle
   - Control dimming opacity
5. **Quit** - Click status bar icon → Quit, or press Cmd+Shift+Q

## Advantages Over Electron Version

| Feature | Electron | Native Swift |
|---------|----------|--------------|
| App Size | ~200 MB | ~5 MB |
| Memory Usage | ~150 MB | ~30 MB |
| Startup Time | 1-2 seconds | Instant |
| Background Blur | ❌ Not possible | ✅ Native support |
| Battery Impact | High (Chromium) | Minimal |
| System Integration | Limited | Perfect |

## Technical Details

### Blur Implementation:
- Uses `NSVisualEffectView` with `.behindWindow` blending
- Hardware-accelerated via Core Animation
- No manual screen capture needed
- Respects macOS accessibility settings

### Window Management:
- Level: `.floating` (above normal windows)
- Collection Behavior: `.canJoinAllSpaces`, `.fullScreenAuxiliary`
- Mouse Events: Selective (allows interaction with control bar)

### Performance:
- 60 FPS mouse tracking via `requestAnimationFrame` equivalent
- Canvas-based masking for efficient rendering
- No network or disk I/O during runtime

## Customization

Edit `OverlayViewModel.swift` to change defaults:

```swift
@Published var focusRadius: CGFloat = 200    // Default radius
@Published var blurRadius: CGFloat = 30      // Default blur
@Published var dimOpacity: Double = 0.3      // Default dim (30%)
@Published var darkMode: Bool = true         // Default theme
```

## Future Enhancements

Potential features to add:
- [ ] Eye-tracking integration (via ARKit)
- [ ] Multiple focus shapes (rectangle, spotlight)
- [ ] Hotkey configuration UI
- [ ] Focus zone presets
- [ ] Animation effects
- [ ] Settings persistence (UserDefaults)

## License

Copyright © 2024. All rights reserved.
=======
# FocusLens
>>>>>>> 37d7cf040cf5b0d9e77e7b6559c549dca704f70e
