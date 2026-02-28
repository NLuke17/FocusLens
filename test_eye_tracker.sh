#!/bin/bash
# Test the Python eye tracker to verify it works

cd "$(dirname "$0")"

echo "🧪 Testing Python Eye Tracker..."
echo ""

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found!"
    echo "   Run: ./setup_python_tracker.sh"
    exit 1
fi

echo "✅ Virtual environment found"

# Activate venv
source venv/bin/activate

# Check script exists
if [ ! -f "eye_tracker_mediapipe.py" ]; then
    echo "❌ eye_tracker_mediapipe.py not found!"
    exit 1
fi

echo "✅ Python script found"

# Test import
echo ""
echo "Testing Python imports..."
python3 -c "
import sys
print('Python:', sys.version.split()[0])
try:
    import cv2
    print('✅ opencv-python:', cv2.__version__)
except ImportError as e:
    print('❌ opencv-python:', e)
    sys.exit(1)

try:
    import mediapipe as mp
    print('✅ mediapipe:', mp.__version__)
except ImportError as e:
    print('❌ mediapipe:', e)
    sys.exit(1)

try:
    import numpy as np
    print('✅ numpy:', np.__version__)
except ImportError as e:
    print('❌ numpy:', e)
    sys.exit(1)
"

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Dependencies missing!"
    echo "   Run: ./setup_python_tracker.sh"
    exit 1
fi

echo ""
echo "Testing eye tracker script (will run for 3 seconds)..."
echo "Press Ctrl+C if it hangs"
echo ""

# Run script and capture first few lines
python3 eye_tracker_mediapipe.py 2>&1 &
PID=$!

sleep 3

if ps -p $PID > /dev/null 2>&1; then
    echo ""
    echo "✅ Python eye tracker is running!"
    echo "   PID: $PID"
    kill $PID 2>/dev/null
    wait $PID 2>/dev/null
    echo ""
    echo "✅ All tests passed!"
    echo ""
    echo "📝 Next step:"
    echo "   Build and run in Xcode (Cmd+Shift+K, then Cmd+R)"
    echo "   The app should now find the Python script automatically."
else
    echo ""
    echo "❌ Python tracker failed to start or crashed"
    echo "   Check the error messages above"
    exit 1
fi
