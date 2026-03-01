# Focus Lens - Installation Instructions for Testers

## ⚠️ About the Security Warning

When you try to open Focus Lens, macOS will show a security warning saying the app "cannot be opened" or might contain malware.

**This is NORMAL and the app is SAFE.** The warning appears because:
- The app isn't signed with an Apple Developer certificate ($99/year)
- This is standard for beta/development apps
- All testers will see this warning

You can bypass it easily using one of the methods below.

---

## 🚀 Installation Methods

### ✅ METHOD 1: Right-Click to Open (EASIEST - Recommended)

This is the simplest way and takes 10 seconds:

1. **Download and extract** `Focus-Lens-v1.0.zip`
2. You'll see a folder called `Focus-Lens` with:
   - `Focus Lens.app`
   - `install.sh` (installer script)
   - `README.txt`
3. **Right-click** on `Focus Lens.app`
4. Select **"Open"** from the menu (NOT double-click!)
5. In the dialog that appears, click **"Open"**
6. ✅ Done! macOS will remember your choice

**Video walkthrough:**
```
Right-click → Open → Click "Open" in dialog → App launches
```

---

### ✅ METHOD 2: Terminal Installer Script

If right-click doesn't work, use the included installer script:

1. **Download and extract** `Focus-Lens-v1.0.zip`
2. Open **Terminal** (Applications → Utilities → Terminal)
3. Type `cd ` (with a space after cd)
4. **Drag the `Focus-Lens` folder** into the Terminal window
5. Press **Enter**
6. Type: `bash install.sh`
7. Press **Enter**
8. ✅ The script will remove quarantine and launch the app

**Terminal commands:**
```bash
cd /path/to/Focus-Lens  # (drag folder to auto-fill path)
bash install.sh
```

---

### ✅ METHOD 3: System Settings Override

If you already tried to open the app and it was blocked:

1. Go to **System Settings** → **Privacy & Security**
2. Scroll down to the **Security** section
3. You'll see: _"Focus Lens" was blocked from use because it is not from an identified developer_
4. Click **"Open Anyway"**
5. Try opening `Focus Lens.app` again
6. Click **"Open"** in the confirmation dialog
7. ✅ Done!

---

### ✅ METHOD 4: Remove Quarantine (Advanced)

For advanced users comfortable with Terminal:

```bash
# Navigate to the Focus-Lens folder
cd /path/to/Focus-Lens

# Remove quarantine attributes
xattr -cr "Focus Lens.app"

# Open the app
open "Focus Lens.app"
```

---

## 🔐 Required Permissions

After opening Focus Lens for the first time, macOS will ask for permissions:

### 1. Camera Access
- **Why needed:** For eye tracking functionality
- **What to do:** Click **"OK"** when prompted
- **If denied:** Go to System Settings → Privacy & Security → Camera → Enable "Focus Lens"

### 2. Screen Recording
- **Why needed:** For the overlay effect to work
- **What to do:** Click **"Open System Settings"** when prompted
- **Manual setup:** System Settings → Privacy & Security → Screen Recording → Enable "Focus Lens"

**Important:** You must grant BOTH permissions for the app to work properly.

---

## 🎯 Using Focus Lens

Once the app launches:

1. You'll see a **control bar** at the top of your screen
2. Click the **power button** to enable/disable the overlay
3. Use **sliders** to adjust:
   - Focus radius (size of clear area)
   - Blur intensity
   - Dim opacity
4. Click **"Eye" button** to enable eye tracking
5. Click **"Calibrate"** to calibrate eye tracking (look at 5 points)
6. **Drag the control bar** to reposition it

---

## 🐛 Troubleshooting

### Problem: "The app is damaged and can't be opened"
**Solution:** 
- Use METHOD 2 (Terminal Installer Script) above
- OR run: `xattr -cr "Focus Lens.app"` in Terminal

### Problem: Eye tracking doesn't work
**Solution:**
1. Check System Settings → Privacy & Security → Camera
2. Make sure "Focus Lens" is enabled
3. Restart the app after granting permission

### Problem: The overlay is invisible
**Solution:**
1. Check System Settings → Privacy & Security → Screen Recording
2. Enable "Focus Lens"
3. Restart the app after granting permission

### Problem: Can't find System Settings
**Solution:**
- macOS 13+ (Ventura): It's called "System Settings"
- macOS 12 and older: It's called "System Preferences"
- Or search with Spotlight (Cmd + Space, type "Privacy")

### Problem: The security button is grayed out
**Solution:**
1. Click the lock icon in System Settings
2. Enter your Mac password to unlock
3. Now you can change the settings

### Problem: App crashes on launch
**Solution:**
1. Make sure you **extracted** the ZIP file (can't run from inside ZIP)
2. Try METHOD 2 (installer script)
3. Check Console.app for error messages

---

## 💡 Tips

- **Move to Applications folder:** For easier access, drag `Focus Lens.app` to `/Applications`
- **Create a dock icon:** Drag the app to your Dock for quick access
- **Eye tracking calibration:** Recalibrate if the gaze tracking seems off
- **Performance:** Close other camera apps (Zoom, FaceTime) before using eye tracking

---

## ❓ FAQ

**Q: Is this app safe? Why the warning?**  
A: Yes, it's completely safe. The warning appears because the app isn't signed with an Apple Developer certificate ($99/year). This is standard for beta apps.

**Q: Will the warning appear every time?**  
A: No! After you bypass it once (right-click → Open), macOS remembers and won't ask again.

**Q: Does this work on Apple Silicon (M1/M2/M3)?**  
A: Yes! The app is a universal binary supporting both Intel and Apple Silicon.

**Q: What macOS version do I need?**  
A: macOS 13.0 (Ventura) or later is recommended.

**Q: Can I uninstall it?**  
A: Yes, just drag `Focus Lens.app` to the Trash. No other files are installed.

**Q: Why do you need camera access?**  
A: The eye tracking feature uses your camera to detect where you're looking.

---

## 📧 Need Help?

If you're still having issues:

1. Check the **Console.app** for error messages
2. Try **restarting your Mac**
3. Contact the developer with:
   - macOS version (Apple menu → About This Mac)
   - Error messages or screenshots
   - Which installation method you tried

---

## 🎉 Success!

If Focus Lens is running, you should see:
- ✅ A control bar at the top of your screen
- ✅ When enabled, a blur/dim effect with a clear focus area
- ✅ When eye tracking is on, the focus follows your gaze

Enjoy testing Focus Lens! 🚀

---

_For developers: See DISTRIBUTION_GUIDE.md for signing and notarization instructions._
