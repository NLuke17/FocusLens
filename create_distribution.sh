#!/bin/bash
# Quick Distribution Package Creator
# Creates a ZIP with the app + installer script for testers

set -e

APP_PATH="Focus Lens Release 3/Focus Lens.app"
ZIP_NAME="Focus-Lens-v1.0.zip"
TMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TMP_DIR/Focus-Lens"

echo "🧹 Cleaning quarantine attributes..."
xattr -cr "$APP_PATH" 2>/dev/null || true

echo "📦 Preparing distribution package..."
mkdir -p "$PACKAGE_DIR"

# Copy the app
cp -R "$APP_PATH" "$PACKAGE_DIR/"

# Copy the installer script
cp install.sh "$PACKAGE_DIR/"

# Create a README
cat > "$PACKAGE_DIR/README.txt" << 'EOF'
FOCUS LENS - Installation Instructions
======================================

METHOD 1: Simple Right-Click (Recommended)
-------------------------------------------
1. Right-click on "Focus Lens.app"
2. Select "Open" from the menu
3. Click "Open" in the security dialog
4. Grant Camera permission when prompted

METHOD 2: Terminal Install Script
----------------------------------
1. Open Terminal (Applications > Utilities > Terminal)
2. Type: cd 
3. Drag this folder into Terminal (adds the path)
4. Press Enter
5. Type: bash install.sh
6. Press Enter

The app is safe - the warning is just because it's not signed with
an Apple Developer certificate ($99/year, not needed for testing).

Need help? Check the full documentation in DISTRIBUTION_GUIDE.md

Enjoy! 🎯
EOF

echo "📦 Creating ZIP archive..."
rm -f "$ZIP_NAME"
cd "$TMP_DIR"
zip -r -q "$ZIP_NAME" "Focus-Lens"
mv "$ZIP_NAME" "$OLDPWD/"
cd "$OLDPWD"

# Clean up
rm -rf "$TMP_DIR"

echo "✅ Package created: $ZIP_NAME"
echo ""
echo "📧 What to send testers:"
echo "   • $ZIP_NAME"
echo "   • They'll get: app + installer script + README"
echo ""
echo "📝 Testers can either:"
echo "   1. Right-click app → Open (easiest)"
echo "   2. Run: bash install.sh (removes quarantine)"
