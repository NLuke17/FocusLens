# 🚀 Focus Lens - GitHub Installation Guide

## ⚠️ IMPORTANT: About the Security Warning

When downloading Focus Lens from GitHub, macOS will show a security warning saying the app "cannot be opened" or contains malware.

**The app is 100% SAFE.** This warning appears because:
1. The app is downloaded from the internet (GitHub)
2. It's not signed with an Apple Developer certificate ($99/year)
3. macOS blocks all unsigned downloaded apps by default

**This affects EVERYONE downloading from GitHub** - it's not a problem with your Mac.

---

## ✅ SOLUTION: Remove Quarantine After Download

Choose ONE of these methods:

---

### 🟢 METHOD 1: One-Line Terminal Command (FASTEST - 5 seconds)

1. Download and extract `Focus-Lens-v1.0.zip` from GitHub
2. Open **Terminal** (Applications → Utilities → Terminal)
3. Type this command and press Enter:

```bash
xattr -cr ~/Downloads/Focus-Lens*/Focus\ Lens.app
```

4. **Double-click** `Focus Lens.app` to launch

✅ This removes the quarantine attribute so you can open the app normally!

**If the folder isn't in Downloads, replace `~/Downloads` with the actual path.**

---

### 🔵 METHOD 2: Use the Included Installer Script (20 seconds)

1. Download and extract `Focus-Lens-v1.0.zip` from GitHub
2. Open **Terminal**
3. Type: `cd ` (with a space)
4. **Drag the `Focus-Lens` folder** into Terminal (auto-fills the path)
5. Press **Enter**
6. Type: `bash install.sh`
7. Press **Enter**

The script will:
- ✅ Remove quarantine attributes
- ✅ Launch Focus Lens
- ✅ Show permission instructions

---

### 🟡 METHOD 3: Right-Click Method (Often doesn't work for GitHub downloads)

This method works for local files but **may not work** for GitHub downloads because of how the quarantine is applied:

1. Extract the ZIP
2. Right-click `Focus Lens.app`
3. Select "Open"
4. Click "Open" in the dialog

**If this doesn't work (app still won't open), use METHOD 1 or 2 instead.**

---

### 🟠 METHOD 4: System Settings Override (If you already tried to open)

If you already tried opening the app and it was blocked:

1. Go to **System Settings** → **Privacy & Security**
2. Scroll to the **Security** section
3. Find: _"Focus Lens was blocked..."_
4. Click **"Open Anyway"**
5. Try opening the app again
6. Click **"Open"** in the dialog

---

## 📋 Step-by-Step for GitHub Downloads

### Complete workflow:

```bash
# 1. Download from GitHub (browser adds quarantine)
#    - Click "Code" → "Download ZIP" on GitHub
#    - OR download the release ZIP

# 2. Extract the ZIP
cd ~/Downloads
unzip Focus-Lens-v1.0.zip

# 3. Remove quarantine and launch
cd Focus-Lens
xattr -cr "Focus Lens.app"
open "Focus Lens.app"

# 4. Grant permissions when prompted
#    - Camera: Required for eye tracking
#    - Screen Recording: Required for overlay
```

---

## 🔐 Required Permissions

After launching, macOS will request:

### 1. Camera Access
- **Why:** Eye tracking uses your webcam
- **Action:** Click "OK" when prompted
- **Manual:** System Settings → Privacy & Security → Camera → Enable "Focus Lens"

### 2. Screen Recording
- **Why:** The overlay needs to draw over other apps
- **Action:** Click "Open System Settings" → Enable "Focus Lens"
- **Manual:** System Settings → Privacy & Security → Screen Recording → Enable "Focus Lens"

**Both permissions are required** for full functionality.

---

## 🐛 Troubleshooting

### "The application cannot be opened"
**Cause:** Quarantine attribute from GitHub download  
**Fix:** Run METHOD 1 (one-line terminal command)

### "App is damaged and can't be opened"
**Cause:** Same issue, different error message  
**Fix:** 
```bash
xattr -cr "/path/to/Focus Lens.app"
```

### "Operation not permitted"
**Cause:** Need admin privileges  
**Fix:** Add `sudo` before the command (will ask for password):
```bash
sudo xattr -cr "/path/to/Focus Lens.app"
```

### Eye tracking doesn't work
**Fix:** Enable Camera in System Settings → Privacy & Security → Camera

### Overlay is invisible
**Fix:** Enable Screen Recording in System Settings → Privacy & Security → Screen Recording

### Can't find Terminal
**Location:** Applications → Utilities → Terminal  
**Or:** Press `Cmd + Space`, type "Terminal", press Enter

---

## 💡 Why This Happens with GitHub

When you download files from GitHub:

1. ✅ GitHub creates the ZIP file
2. ✅ Your browser downloads it
3. ⚠️ **macOS adds quarantine attribute** to downloaded files
4. ⚠️ The quarantine attribute prevents the app from opening
5. ✅ The `xattr -cr` command removes this attribute

**This is a security feature**, not a bug. It affects ALL apps downloaded from the internet that aren't signed with an Apple Developer certificate.

---

## 🎯 Quick Reference

| Problem | Solution |
|---------|----------|
| Downloaded from GitHub, won't open | `xattr -cr "Focus Lens.app"` |
| "App is damaged" | Same: `xattr -cr "Focus Lens.app"` |
| Right-click doesn't work | Use Terminal: `xattr -cr "Focus Lens.app"` |
| Eye tracking not working | Enable Camera in System Settings |
| Overlay invisible | Enable Screen Recording in System Settings |

---

## 🚀 Using Focus Lens

Once installed successfully:

1. **Control Bar** appears at top of screen
2. **Power Button** - Enable/disable overlay
3. **Sliders** - Adjust focus radius, blur, and dim
4. **Eye Button** - Enable eye tracking mode
5. **Calibrate** - Run 5-point calibration (look at dots)
6. **Drag** - Move the control bar anywhere

---

## ❓ FAQ

**Q: Is this safe? Why the warning?**  
A: 100% safe. The warning is because the app isn't signed with Apple's $99/year developer certificate. Standard for open source/beta apps.

**Q: Will I need to do this every time?**  
A: No! Once you remove the quarantine, macOS remembers. You only do it once.

**Q: Why not just sign the app?**  
A: Signing requires a $99/year Apple Developer membership. For open source/beta testing, the terminal command is free and works perfectly.

**Q: Does this work on Apple Silicon (M1/M2/M3)?**  
A: Yes! The app is a universal binary supporting both Intel and Apple Silicon.

**Q: Can I move the app to Applications folder?**  
A: Yes! After removing quarantine, you can move it anywhere.

---

## 🆘 Still Having Issues?

If none of the methods work:

1. **Check Console.app** for error messages
2. **Verify macOS version** (need macOS 13+ recommended)
3. **Try a different download** (file might be corrupted)
4. **Restart your Mac** (sometimes clears stubborn quarantine)

Open an issue on GitHub with:
- macOS version (Apple menu → About This Mac)
- Error messages or screenshots
- Output from: `xattr -l "Focus Lens.app"`

---

## 📧 Quick Copy-Paste Commands

Save these for quick reference:

```bash
# Remove quarantine (if in Downloads)
xattr -cr ~/Downloads/Focus-Lens*/Focus\ Lens.app

# Remove quarantine (current directory)
xattr -cr "Focus Lens.app"

# Check quarantine status
xattr -l "Focus Lens.app"

# Remove quarantine (admin)
sudo xattr -cr "Focus Lens.app"
```

---

**Enjoy Focus Lens!** 🎯

_For developers: See DISTRIBUTION_GUIDE.md for information about signing and notarization._
