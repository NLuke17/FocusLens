#!/bin/bash
# Focus Lens Installer
# This script removes quarantine attributes and installs the app
#
# Usage: 
#   1. Download Focus-Lens-v1.0.zip
#   2. Extract it (you'll get this script and Focus Lens.app)
#   3. Open Terminal
#   4. Run: bash install.sh

set -e

echo "🎯 Focus Lens Installer"
echo "======================="
echo ""

# Find the app (should be in same directory as script)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_PATH="$SCRIPT_DIR/Focus Lens.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: Could not find Focus Lens.app"
    echo "Make sure this script is in the same folder as the app."
    exit 1
fi

echo "📍 Found app at: $APP_PATH"
echo ""

# Remove quarantine attributes
echo "🧹 Removing quarantine attributes..."
xattr -cr "$APP_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Quarantine attributes removed"
else
    echo "⚠️  Warning: Could not remove quarantine (this is OK)"
fi
echo ""

# Try to open the app
echo "🚀 Launching Focus Lens..."
open "$APP_PATH"

if [ $? -eq 0 ]; then
    echo "✅ App launched successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. macOS may ask for Camera permission - click OK"
    echo "   2. macOS may ask for Screen Recording permission - click OK"
    echo "   3. Grant these permissions in System Settings if needed"
    echo ""
    echo "🎉 You're all set! Enjoy Focus Lens!"
else
    echo "⚠️  Could not launch automatically."
    echo "Please try opening Focus Lens.app manually:"
    echo "   Right-click → Open"
fi
