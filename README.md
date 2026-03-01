# FocusLens - Eye-Tracking Focus Enhancement for macOS

FocusLens is a native macOS overlay application that provides focus enhancement with real-time blur effects and eye tracking. Perfect for distraction-free work and privacy while browsing.

## 🚀 Installation

### ⚠️ **IMPORTANT: macOS Security Warning**

When downloading from GitHub, macOS will show a security warning. **The app is safe** - this happens because it's not signed with an Apple Developer certificate.

### Quick Install (5 seconds):

1. **Download** `Focus-Lens-v1.0.zip` from [Releases](../../releases)
2. **Extract** the ZIP file
3. **Open Terminal** and run:

```bash
xattr -cr ~/Downloads/Focus-Lens*/Focus\ Lens.app && open ~/Downloads/Focus-Lens*/Focus\ Lens.app
```

✅ Done! The app will launch and request Camera & Screen Recording permissions.

**📖 Having trouble?** See **[GITHUB_INSTALL.md](GITHUB_INSTALL.md)** for detailed instructions and troubleshooting.

---

## ⚡ Quick Start

1. **Enable overlay** - Click the power button in the control bar
2. **Adjust effects** - Use sliders for focus radius, blur intensity, and dimming
3. **Eye tracking** - Click "Eye" button, then "Calibrate" (look at 5 points)
4. **Move control bar** - Drag it anywhere on screen

## Features

✅ **Eye Tracking** - Focus follows your gaze using native Vision framework  
✅ **5-Point Calibration** - Accurate gaze tracking calibrated to your eyes  
✅ **Native macOS Blur** - Hardware-accelerated blur using `NSVisualEffectView`  
✅ **Real-time Focus Circle** - Follows mouse or gaze with smooth tracking  
✅ **Adjustable Parameters**:
- Focus radius (50-500px)
- Blur intensity (0-50px)
- Dimming opacity (0-80%)

✅ **Always-on-Top Overlay** - Floats above all windows  
✅ **Click-through** - Doesn't interfere with your workflow  
✅ **Draggable Control Bar** - Move it anywhere on screen  
✅ **Dark/Light Mode Support** - Matches your system theme  

---

## 📋 Requirements

- macOS 13.0 (Ventura) or later
- Camera access (for eye tracking)
- Screen Recording permission (for overlay)
- Apple Silicon (M1/M2/M3) or Intel Mac

---

## 🎯 Usage

### Basic Mode (Mouse Tracking)
1. Launch Focus Lens
2. Click the **power button** to enable overlay
3. Adjust sliders to customize the effect
4. The focus area follows your mouse cursor

### Eye Tracking Mode
1. Click the **Eye button** to enable eye tracking
2. Click **Calibrate**
3. Look at each of the 5 dots that appear (center + corners)
4. Wait ~3 seconds at each dot
5. The focus area now follows your gaze!

**Tips:**
- Keep your head relatively still during calibration
- Ensure good lighting for best eye tracking
- Recalibrate if tracking seems off
- Eye tracking works best with camera at eye level

---

## 🛠️ Building from Source

### Prerequisites
- Xcode 15 or later
- macOS 13+ SDK

### Build Steps
```bash
# Clone the repository
git clone https://github.com/yourusername/FocusLens-Swift.git
cd FocusLens-Swift

# Open in Xcode
open "Focus Lens/Focus Lens.xcodeproj"

# Build and run (Cmd+R)
```

The app will be built to: `Focus Lens/DerivedData/.../Focus Lens.app`

---

## 📖 Documentation

- **[GITHUB_INSTALL.md](GITHUB_INSTALL.md)** - Installation guide for GitHub downloads
- **[DISTRIBUTION_GUIDE.md](DISTRIBUTION_GUIDE.md)** - Guide for signing and distribution
- **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** - Comprehensive installation help

---

## 🐛 Troubleshooting

### "The application cannot be opened" or "App is damaged"
**Solution:** Run this command in Terminal:
```bash
xattr -cr "/path/to/Focus Lens.app"
```
See [GITHUB_INSTALL.md](GITHUB_INSTALL.md) for details.

### Eye tracking doesn't work
- Enable Camera permission: System Settings → Privacy & Security → Camera
- Ensure good lighting
- Recalibrate with "Calibrate" button

### Overlay is invisible
- Enable Screen Recording: System Settings → Privacy & Security → Screen Recording
- Restart the app after granting permission

### More help
See [GITHUB_INSTALL.md](GITHUB_INSTALL.md) for comprehensive troubleshooting.

---

## 🔐 Privacy

- **Camera access** is only used for eye tracking (local processing)
- **No data is sent** to any server
- **No analytics** or tracking
- All processing happens on-device using Apple's Vision framework

---

## 📝 License

[Add your license here]

---

## 🙏 Acknowledgments

Built with:
- SwiftUI for the UI
- Vision framework for eye tracking
- AVFoundation for camera access
- AppKit for native macOS integration

---

## 💬 Support

Having issues? Check:
1. [GITHUB_INSTALL.md](GITHUB_INSTALL.md) - Installation help
2. [Issues](../../issues) - Known issues and solutions
3. [Discussions](../../discussions) - Community help

---

**Enjoy distraction-free work with FocusLens!** 🎯