#!/bin/bash
# Quick reference for FocusLens Python eye tracking

cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════════╗
║                 🎯 FocusLens - Quick Reference Card                      ║
╚══════════════════════════════════════════════════════════════════════════╝

┌─ SETUP (One-Time) ─────────────────────────────────────────────────────┐
│                                                                          │
│  1. Install dependencies:                                               │
│     cd FocusLens-Swift                                                  │
│     ./setup_python_tracker.sh                                           │
│                                                                          │
│  2. Add to Xcode:                                                       │
│     File → Add Files → eye_tracker_mediapipe.py                        │
│     ✓ Copy items if needed                                             │
│     ✓ Focus Lens target                                                │
│                                                                          │
│  3. Build & Run:                                                        │
│     Cmd+Shift+K (Clean)                                                 │
│     Cmd+R (Run)                                                         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ KEYBOARD SHORTCUTS ───────────────────────────────────────────────────┐
│                                                                          │
│  ESC         → Quit app                                                 │
│  Cmd+Q       → Quit app                                                 │
│  Cmd+Shift+K → Clean build (Xcode)                                     │
│  Cmd+R       → Build & run (Xcode)                                     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ CONTROL BAR BUTTONS ──────────────────────────────────────────────────┐
│                                                                          │
│  [Toggle]     → Enable/disable overlay                                  │
│  [Blur ∼]     → Adjust blur radius (0-50)                              │
│  [Focus ○]    → Adjust focus circle size                               │
│  [Dim ◐]      → Adjust dimming opacity                                 │
│  [Active]     → Shows current overlay status                           │
│  [−]          → Minimize/expand sliders                                │
│  [☀/☾]        → Light/dark mode                                        │
│  [👁/➤]       → Eye tracking / Cursor tracking                         │
│  [MediaPipe]  → Switch between backends                                │
│  [Calibrate]  → Run 5-point calibration                               │
│  [X]          → Quit app                                               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ STATUS DOT COLORS ────────────────────────────────────────────────────┐
│                                                                          │
│  🟢 Green    → Face & iris detected, tracking working                  │
│  🟠 Orange   → Searching for face...                                   │
│  🔴 Red      → Error (camera permission, script missing, etc.)         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ BACKEND COMPARISON ───────────────────────────────────────────────────┐
│                                                                          │
│             MediaPipe 🐍          vs          Native Vision 🍎          │
│  ────────────────────────────────────────────────────────────────────  │
│  Accuracy   ⭐⭐⭐⭐⭐                         ⭐⭐⭐                     │
│  FPS        28-32                            55-60                      │
│  CPU        ~22%                             ~8%                        │
│  Setup      pip install                      Works immediately          │
│  Best for   Precision work, coding          Battery life, casual use   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ TYPICAL WORKFLOW ─────────────────────────────────────────────────────┐
│                                                                          │
│  1. Launch app → Overlay appears (cursor mode by default)              │
│  2. Click [➤ Cursor] → Switches to [👁 Eye] mode                      │
│  3. Status dot shows: 🟠 (searching) → 🟢 (tracking)                  │
│  4. Backend switcher appears: [Vision]                                 │
│  5. Click [Vision] → Switches to [MediaPipe]                          │
│  6. Click [Calibrate] → Follow 5 dots, improve accuracy               │
│  7. Focus circle now follows your eyes!                                │
│  8. Adjust blur/focus/dim with sliders as needed                       │
│  9. Press ESC or click [X] to quit                                     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ TROUBLESHOOTING ──────────────────────────────────────────────────────┐
│                                                                          │
│  Problem: Python tracker not starting                                   │
│  Fix:     Check Xcode console for errors                               │
│           Verify eye_tracker_mediapipe.py is in Resources              │
│           Run: ./setup_python_tracker.sh                                │
│                                                                          │
│  Problem: Low accuracy / jumpy tracking                                 │
│  Fix:     Run calibration (click Calibrate button)                    │
│           Ensure good lighting on face                                 │
│           Sit 50-70cm from camera                                      │
│           Face camera directly                                         │
│                                                                          │
│  Problem: Camera permission denied                                      │
│  Fix:     System Settings → Privacy → Camera                          │
│           Enable for "Focus Lens"                                      │
│           Restart app                                                  │
│                                                                          │
│  Problem: High CPU usage                                                │
│  Fix:     Switch to Vision backend (click MediaPipe → Vision)         │
│           Or edit eye_tracker_mediapipe.py:                            │
│           - Lower FPS: cap.set(cv2.CAP_PROP_FPS, 20)                  │
│           - Smaller res: cap.set(WIDTH, 480)                           │
│                                                                          │
│  Problem: Can't click through overlay                                   │
│  Fix:     Hover over control bar to enable mouse events                │
│           Overlay should be click-through everywhere else              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ TUNING PARAMETERS ────────────────────────────────────────────────────┐
│                                                                          │
│  Edit: eye_tracker_mediapipe.py                                        │
│                                                                          │
│  Line 54:  self.alpha = 0.4              # Smoothing                   │
│            → Lower (0.2) = smoother but slower                         │
│            → Higher (0.6) = faster but jerkier                         │
│                                                                          │
│  Line 88:  gain_x = 2.2                  # Horizontal range            │
│  Line 89:  gain_y = 2.0                  # Vertical range              │
│            → Lower (1.5) = less coverage                               │
│            → Higher (3.0) = more coverage                              │
│                                                                          │
│  Line 58:  outlier_threshold = 0.25      # Blink filtering             │
│            → Lower (0.15) = more filtering                             │
│            → Higher (0.4) = less filtering                             │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ FILES OVERVIEW ───────────────────────────────────────────────────────┐
│                                                                          │
│  Python Eye Tracker:                                                    │
│    eye_tracker_mediapipe.py      # Main tracker (use this!)            │
│    setup_python_tracker.sh       # Dependency installer                │
│    test_dependencies.py          # Verify installation                 │
│                                                                          │
│  Swift Code:                                                            │
│    PythonEyeTracker.swift        # Subprocess bridge                   │
│    EyeTrackingManager.swift      # Native Vision tracker               │
│    OverlayViewModel.swift        # State management                    │
│    ControlBarView.swift          # UI controls                         │
│                                                                          │
│  Documentation:                                                         │
│    IMPLEMENTATION_COMPLETE.md    # Full implementation summary          │
│    PYTHON_INTEGRATION_GUIDE.md   # Setup & usage guide                 │
│    SYSTEM_OVERVIEW.md            # Architecture diagrams                │
│    QUICK_REFERENCE.md            # This file!                          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ USEFUL COMMANDS ──────────────────────────────────────────────────────┐
│                                                                          │
│  # Test Python tracker standalone:                                     │
│  cd FocusLens-Swift                                                    │
│  source venv/bin/activate                                              │
│  python3 eye_tracker_mediapipe.py                                      │
│                                                                          │
│  # Verify dependencies:                                                │
│  python3 test_dependencies.py                                          │
│                                                                          │
│  # Reinstall dependencies:                                             │
│  rm -rf venv                                                           │
│  ./setup_python_tracker.sh                                             │
│                                                                          │
│  # Check Python version:                                               │
│  venv/bin/python3 --version                                            │
│                                                                          │
│  # View Xcode console logs:                                            │
│  In Xcode: View → Debug Area → Activate Console (Cmd+Shift+Y)         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─ PERFORMANCE TIPS ─────────────────────────────────────────────────────┐
│                                                                          │
│  For Battery Life:                                                      │
│    ✓ Use Vision backend                                                │
│    ✓ Lower Python FPS (20 instead of 30)                              │
│    ✓ Reduce camera resolution (480 instead of 640)                    │
│                                                                          │
│  For Accuracy:                                                          │
│    ✓ Use MediaPipe backend                                             │
│    ✓ Always calibrate (5-point)                                        │
│    ✓ Bright, even lighting                                             │
│    ✓ Clean camera lens                                                 │
│                                                                          │
│  For Responsiveness:                                                    │
│    ✓ Increase alpha (0.5-0.6)                                          │
│    ✓ Use Vision backend (lower latency)                                │
│    ✓ Lower outlier threshold (0.15-0.2)                                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

╔══════════════════════════════════════════════════════════════════════════╗
║                   Need help? Check the docs:                             ║
║  • PYTHON_INTEGRATION_GUIDE.md - Complete setup                         ║
║  • SYSTEM_OVERVIEW.md - Architecture & design                           ║
║  • IMPLEMENTATION_COMPLETE.md - Feature summary                         ║
╚══════════════════════════════════════════════════════════════════════════╝

EOF
