#!/bin/bash
# Setup script for Python eye tracking with MediaPipe (easier than dlib!)

set -e

echo "🔧 Setting up Python eye tracking with MediaPipe..."

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Install it with:"
    echo "   brew install python3"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"

# Create virtual environment (optional but recommended)
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install dependencies (MediaPipe is MUCH easier than dlib!)
echo "📥 Installing Python packages..."
pip install opencv-python mediapipe numpy

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Add eye_tracker_mediapipe.py to your Xcode project as a resource"
echo "   2. In Xcode: File → Add Files → Select eye_tracker_mediapipe.py"
echo "   3. Make sure 'Copy items if needed' is checked"
echo "   4. Update PythonEyeTracker.swift to use 'eye_tracker_mediapipe.py'"
echo "   5. Build and run!"
echo ""
echo "🧪 To test the Python tracker standalone:"
echo "   python3 eye_tracker_mediapipe.py"
echo ""
echo "💡 Why MediaPipe?"
echo "   ✅ No model download needed (built-in)"
echo "   ✅ Actual iris tracking (not just pupil estimation)"
echo "   ✅ Much easier to install (no CMake required)"
echo "   ✅ Better accuracy than dlib for eye tracking"
echo "   ✅ 30+ FPS on most machines"
