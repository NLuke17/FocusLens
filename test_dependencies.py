#!/usr/bin/env python3
"""
Test script to verify dlib and dependencies are working correctly.
Run this before adding to Xcode to ensure everything is set up.
"""

import sys

print("🧪 Testing Python eye tracking dependencies...\n")

# Test 1: Python version
print("1️⃣ Python version:", sys.version)
if sys.version_info < (3, 7):
    print("   ❌ Python 3.7+ required")
    sys.exit(1)
print("   ✅ Python version OK\n")

# Test 2: Import dependencies
print("2️⃣ Testing imports...")
try:
    import cv2
    print("   ✅ opencv-python:", cv2.__version__)
except ImportError as e:
    print(f"   ❌ opencv-python: {e}")
    print("      Install with: pip install opencv-python")
    sys.exit(1)

try:
    import dlib
    print("   ✅ dlib:", dlib.__version__)
except ImportError as e:
    print(f"   ❌ dlib: {e}")
    print("      Install with: pip install dlib")
    sys.exit(1)

try:
    import numpy as np
    print("   ✅ numpy:", np.__version__)
except ImportError as e:
    print(f"   ❌ numpy: {e}")
    print("      Install with: pip install numpy")
    sys.exit(1)

try:
    import imutils
    print("   ✅ imutils:", imutils.__version__)
except ImportError as e:
    print(f"   ❌ imutils: {e}")
    print("      Install with: pip install imutils")
    sys.exit(1)

print()

# Test 3: Model file
print("3️⃣ Checking for facial landmark model...")
import os
model_path = "shape_predictor_68_face_landmarks.dat"
if os.path.exists(model_path):
    size_mb = os.path.getsize(model_path) / (1024 * 1024)
    print(f"   ✅ Model found: {size_mb:.1f} MB")
else:
    print(f"   ❌ Model not found: {model_path}")
    print("      Download from: http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2")
    print("      Extract with: bunzip2 shape_predictor_68_face_landmarks.dat.bz2")
    sys.exit(1)

print()

# Test 4: Camera access
print("4️⃣ Testing camera access...")
cap = cv2.VideoCapture(0)
if cap.isOpened():
    ret, frame = cap.read()
    if ret:
        h, w = frame.shape[:2]
        print(f"   ✅ Camera working: {w}x{h}")
    else:
        print("   ⚠️ Camera opened but cannot read frames")
    cap.release()
else:
    print("   ❌ Cannot open camera")
    print("      Check camera permissions in System Settings")

print()

# Test 5: Load model and detector
print("5️⃣ Testing dlib face detection...")
try:
    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor(model_path)
    print("   ✅ Face detector initialized")
    print("   ✅ Facial landmark predictor loaded")
except Exception as e:
    print(f"   ❌ Failed to load dlib models: {e}")
    sys.exit(1)

print()
print("✅ All tests passed! Eye tracking should work correctly.")
print()
print("📝 Next steps:")
print("   1. Add python_eye_tracker.py to Xcode as a resource")
print("   2. Add shape_predictor_68_face_landmarks.dat to Xcode as a resource")
print("   3. Build and run!")
