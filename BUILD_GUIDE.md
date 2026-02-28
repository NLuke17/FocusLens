# Building FocusLens

## Quick Start

### Method 1: Using Xcode (Recommended)

1. **Open Xcode** (version 15.0 or later)

2. **Create New Project:**
   - File → New → Project
   - Choose **macOS** → **App**
   - Click **Next**

3. **Configure Project:**
   - Product Name: `FocusLens`
   - Team: Your Apple Developer account (or leave as "None" for local testing)
   - Organization Identifier: `com.yourname` (or your preference)
   - Bundle Identifier: Will be `com.yourname.FocusLens`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Click **Next**
   - Choose save location: `/Users/lukezhu/Documents/hackathon/FocusLens-Swift/`

4. **Replace Files:**
   
   Delete these auto-generated files from the project:
   - `ContentView.swift`
   - `FocusLensApp.swift` (the default one)
   
   Add the custom files by dragging them into the project navigator:
   - `FocusLensApp.swift`
   - `OverlayWindow.swift`
   - `OverlayViewModel.swift`
   - `OverlayContentView.swift`
   - `ControlBarView.swift`
   
   Replace `Info.plist` with the custom one provided.

5. **Configure Signing & Capabilities:**
   
   - Select the project in the navigator
   - Select the **FocusLens** target
   - Go to **Signing & Capabilities** tab
   - **Disable App Sandbox** (important!)
   - Add the custom `FocusLens.entitlements` file to the project
   - In **Signing & Capabilities**, click **+ Capability** → **App Sandbox** → Set to **OFF**

6. **Set Minimum Deployment Target:**
   
   - In **General** tab
   - Set **Minimum Deployments** to **macOS 13.0** or later

7. **Build & Run:**
   ```
   Press Cmd+R or click the ▶️ button
   ```

### Method 2: Command Line Build

If you already have the Xcode project set up:

```bash
cd /Users/lukezhu/Documents/hackathon/FocusLens-Swift

# Build in Release mode
xcodebuild -project FocusLens.xcodeproj \
  -scheme FocusLens \
  -configuration Release \
  -derivedDataPath ./build \
  build

# The app will be in:
# ./build/Build/Products/Release/FocusLens.app

# Run it
open ./build/Build/Products/Release/FocusLens.app
```

## Project Structure

After setup, your project should look like this:

```
FocusLens-Swift/
├── FocusLens/
│   ├── FocusLensApp.swift          # ✅ Main app entry point
│   ├── OverlayWindow.swift         # ✅ Window setup
│   ├── OverlayViewModel.swift      # ✅ State management
│   ├── OverlayContentView.swift    # ✅ Main overlay view
│   ├── ControlBarView.swift        # ✅ Control UI
│   ├── Info.plist                  # ✅ App metadata
│   ├── FocusLens.entitlements      # ✅ Permissions
│   └── Assets.xcassets/            # Auto-generated
├── FocusLens.xcodeproj/            # Xcode project file
└── README.md                       # Documentation
```

## Troubleshooting

### Issue: "App is damaged and can't be opened"

**Solution:** The app is not code-signed. Either:
1. Sign it with your Apple Developer account in Xcode
2. Remove the quarantine flag:
   ```bash
   xattr -cr /path/to/FocusLens.app
   ```

### Issue: "Window doesn't appear transparent"

**Solution:** Check the following:
1. App Sandbox is **disabled** in entitlements
2. Window background is set to `.clear`
3. `isOpaque` is set to `false`
4. Running on macOS 13.0 or later

### Issue: "Blur doesn't work"

**Solution:** 
1. Ensure `NSVisualEffectView` is used (not SwiftUI blur)
2. Check blending mode is `.behindWindow`
3. Verify the mask is properly applied
4. Try changing material to `.hudWindow` or `.underWindowBackground`

### Issue: "Mouse tracking is laggy"

**Solution:**
1. Ensure global mouse monitoring is enabled
2. Check that `NSEvent.addGlobalMonitorForEvents` is called
3. Verify no heavy computations in mouse move handler

### Issue: "Control bar not interactive"

**Solution:**
1. Ensure `ignoresMouseEvents` is `false` for the window
2. Check that control bar's `allowsHitTesting(true)`
3. Verify the control bar is in the view hierarchy

## Performance Optimization

### For Better Performance:

1. **Reduce blur radius** if experiencing lag
2. **Lower refresh rate** for mouse tracking if needed
3. **Use `.reduced` material** for less intensive blur
4. **Disable shadows** on the control bar

### Memory Usage:

Expected memory footprint:
- Idle: ~30 MB
- Active tracking: ~40-50 MB

If memory exceeds 100 MB, check for:
- Retained image buffers
- Uncleared event monitors
- Memory leaks in SwiftUI views

## Distribution

### For Personal Use:

Build in Release mode and copy the .app to `/Applications`

```bash
xcodebuild -project FocusLens.xcodeproj \
  -scheme FocusLens \
  -configuration Release \
  build

cp -R build/Release/FocusLens.app /Applications/
```

### For Distribution:

1. **Sign with Developer ID:**
   - Requires Apple Developer Program membership ($99/year)
   - Set up Code Signing in Xcode
   - Export for distribution

2. **Notarize:**
   ```bash
   xcrun notarytool submit FocusLens.app \
     --apple-id "your@email.com" \
     --team-id "YOUR_TEAM_ID" \
     --password "app-specific-password"
   ```

3. **Create DMG:**
   ```bash
   hdiutil create -volname FocusLens \
     -srcfolder FocusLens.app \
     -ov -format UDZO \
     FocusLens.dmg
   ```

## Debugging

### Enable Debug Logging:

Add to `OverlayWindow.swift`:

```swift
print("Mouse position: \(mouseLocation)")
print("Focus radius: \(viewModel.focusRadius)")
print("Blur enabled: \(viewModel.enabled)")
```

### View Hierarchy Debugging:

In Xcode, while running:
- Debug → View Debugging → Capture View Hierarchy
- Inspect the layer structure

### Performance Profiling:

- Instruments → Time Profiler
- Look for high CPU usage in mouse event handlers
- Check for memory leaks in Allocations instrument

## Next Steps

Once the app is built and running:

1. ✅ Test all sliders and controls
2. ✅ Verify blur effect works properly
3. ✅ Check focus circle follows mouse smoothly
4. ✅ Test keyboard shortcut (Cmd+Shift+Q)
5. ✅ Verify status bar icon works
6. 📋 Add persistence for settings
7. 📋 Implement eye-tracking (future)
8. 📋 Add more focus shapes (future)

Enjoy your native macOS focus overlay app! 🎉
