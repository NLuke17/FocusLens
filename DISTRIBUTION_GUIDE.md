# FocusLens - Distribution Guide

## ✅ App Icon Created!

Your app now has a professional icon featuring:
- 🎨 Modern gradient background (dark blue → purple)
- 👁️ Eye design with blue iris
- 🎯 Focus ring glow effect
- ✨ Light reflection for depth
- 📱 Rounded corners (macOS style)

## 🚀 Next Steps: Export for Judges

### Method 1: Build DMG (Recommended)

1. **Open Xcode:**
   ```bash
   open "Focus Lens/Focus Lens.xcodeproj"
   ```

2. **Archive the app:**
   - In Xcode: **Product** → **Archive**
   - Wait for build to complete (~1-2 minutes)
   - Organizer window will open automatically

3. **Export the app:**
   - Click **Distribute App**
   - Choose **Copy App**
   - Click **Next** → **Export**
   - Save to Desktop as `Focus Lens.app`

4. **Create DMG installer:**
   ```bash
   cd ~/Desktop
   hdiutil create -volname "FocusLens" -srcfolder "Focus Lens.app" -ov -format UDZO FocusLens.dmg
   ```

5. **Test the DMG:**
   - Double-click `FocusLens.dmg`
   - Drag app to Applications
   - Right-click app → Open (bypass security warning)

### Method 2: Quick Build (For Testing)

```bash
cd "Focus Lens"
xcodebuild -project "Focus Lens.xcodeproj" -scheme "Focus Lens" -configuration Release
```

The app will be in: `Focus Lens/build/Release/Focus Lens.app`

---

## 📦 Hackathon Submission Package

Create a folder with:

```
FocusLens-Submission/
├── FocusLens.dmg                    # The app (from Method 1)
├── README.md                         # Installation instructions
├── screenshots/                      # App screenshots
│   ├── app-icon.png                 # Your new icon!
│   ├── control-bar.png
│   ├── eye-tracking.png
│   └── calibration.png
└── source-code/                      # (Optional) Link to GitHub
```

---

## 📝 README Template for Judges

Use this for your submission:

```markdown
# FocusLens - Eye-Tracking Focus Assistant 👁️

> Reduce distractions by blurring everything except where you're looking.

## 🚀 Quick Start (30 seconds)

1. Download `FocusLens.dmg`
2. Open DMG and drag app to Applications
3. **Right-click** → Open (bypass unsigned app warning)
4. Grant camera permissions when prompted
5. Click the **eye icon** in the control bar to start tracking!

## ⚠️ Security Warning (Normal!)

macOS will show a security warning because this app is **unsigned** (no $99 Apple Developer account). This is expected for all unsigned apps. The app is safe - source code available for review.

**To open:**
- ✅ Right-click → Open
- ❌ Don't double-click (will be blocked)

## ✨ Features

- 🎯 Real-time eye tracking (Vision framework)
- 🔵 Dynamic blur overlay (only blurs outside focus area)
- 📐 5-point calibration system
- 🎚️ Adjustable blur intensity, focus radius, dimming
- 🖱️ Click-through overlay (type/click normally)
- ⚡ <8% CPU, 60 FPS tracking
- 🌓 Dark/light mode support
- ⌨️ Keyboard shortcuts (ESC/Cmd+Q to quit)

## 🛠️ Technical Stack

- **Language:** Swift 5
- **UI:** SwiftUI + AppKit
- **Eye Tracking:** Vision framework + AVFoundation
- **Camera:** HD 1280x720, 30-60 FPS
- **Filters:** One Euro Filter (adaptive smoothing)
- **Calibration:** Least-squares affine transform
- **Performance:** Native macOS, no Electron overhead

## 🎮 Controls

| Action | Control |
|--------|---------|
| Toggle overlay | On/Off switch |
| Eye tracking | Eye/Cursor button |
| Calibrate | Calibrate button (appears in eye mode) |
| Adjust blur | Blur Intensity slider (0-50) |
| Adjust focus | Focus Radius slider (50-500px) |
| Adjust dimming | Dim Opacity slider (0-80%) |
| Dark mode | Sun/Moon button |
| Minimize | Orange minus button |
| Quit | Red X button or Cmd+Q or ESC |
| Drag bar | Click and drag anywhere on the control bar |

## 📸 Screenshots

[Include screenshots of your app in action]

## 🎥 Demo Video

[If you make one, link it here]

## 💻 Source Code

GitHub: [your-repo-link]

## 👨‍💻 Built By

[Your name]  
[Your email]  
Built at [Hackathon Name]

## 🙏 Acknowledgments

- Apple Vision framework for face landmark detection
- One Euro Filter by Casiez et al. (CHI 2012)
```

---

## 🎨 Optional: Customize the Icon

If you want to modify the icon design, edit `generate_icon.py`:

- **Change colors:** Line 20-25 (background gradient)
- **Change eye color:** Line 52 (iris color)
- **Change glow:** Line 34-43 (focus ring)
- **Make it simpler/more complex:** Adjust the drawing code

Then re-run:
```bash
python3 generate_icon.py
python3 update_icon_manifest.py
```

---

## 📊 Icon Sizes Included

✅ 16x16 (1x and 2x)  
✅ 32x32 (1x and 2x)  
✅ 128x128 (1x and 2x)  
✅ 256x256 (1x and 2x)  
✅ 512x512 (1x and 2x)  
✅ 1024x1024 (App Store / High-res)

All icons use rounded corners for modern macOS Big Sur+ style.

---

## 🎯 Final Checklist

- [ ] Icon appears in Xcode (Assets.xcassets → AppIcon)
- [ ] Build succeeds (Cmd+B)
- [ ] App runs with new icon (Cmd+R)
- [ ] Export as Copy App (Product → Archive)
- [ ] Create DMG
- [ ] Test DMG on another Mac (if possible)
- [ ] Write README for judges
- [ ] Take screenshots
- [ ] (Optional) Record demo video
- [ ] Upload to submission platform

---

Good luck with your hackathon! 🚀
