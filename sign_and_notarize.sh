#!/bin/bash
# Sign and Notarize Focus Lens for Distribution
# Requires: Apple Developer Account ($99/year)
#
# Setup:
# 1. Join the Apple Developer Program: https://developer.apple.com/programs/
# 2. Create a Developer ID Application certificate in Xcode
# 3. Create an app-specific password: https://appleid.apple.com/account/manage
# 4. Store credentials: xcrun notarytool store-credentials "AC_PASSWORD" \
#        --apple-id "your@email.com" \
#        --team-id "YOUR_TEAM_ID" \
#        --password "app-specific-password"

set -e

# Configuration - UPDATE THESE VALUES
DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"
APPLE_ID="your@email.com"
TEAM_ID="YOUR_TEAM_ID"
KEYCHAIN_PROFILE="AC_PASSWORD"  # Name you used with 'notarytool store-credentials'

# Paths
APP_PATH="Focus Lens Release 3/Focus Lens.app"
DMG_NAME="Focus-Lens-Installer.dmg"
DMG_VOLUME_NAME="Focus Lens Installer"

echo "🔏 Step 1: Code Signing the app..."

# Sign the app with hardened runtime
codesign --force --options runtime \
    --sign "$DEVELOPER_ID" \
    --timestamp \
    --entitlements "Focus Lens/Focus Lens/FocusLens.entitlements" \
    "$APP_PATH"

echo "✅ App signed successfully"
echo ""

echo "📦 Step 2: Creating DMG installer..."

# Remove old DMG if it exists
rm -f "$DMG_NAME"

# Create temporary directory for DMG contents
TMP_DIR=$(mktemp -d)
cp -R "$APP_PATH" "$TMP_DIR/"

# Create symbolic link to Applications folder
ln -s /Applications "$TMP_DIR/Applications"

# Create DMG
hdiutil create -volname "$DMG_VOLUME_NAME" \
    -srcfolder "$TMP_DIR" \
    -ov -format UDZO \
    "$DMG_NAME"

# Clean up
rm -rf "$TMP_DIR"

echo "✅ DMG created: $DMG_NAME"
echo ""

echo "📝 Step 3: Notarizing the DMG..."

# Submit for notarization
xcrun notarytool submit "$DMG_NAME" \
    --keychain-profile "$KEYCHAIN_PROFILE" \
    --wait

echo "✅ Notarization complete"
echo ""

echo "✂️ Step 4: Stapling notarization ticket..."

# Staple the notarization ticket to the DMG
xcrun stapler staple "$DMG_NAME"

echo "✅ Notarization ticket stapled"
echo ""

echo "🎉 SUCCESS! Your app is ready for distribution."
echo "📦 Distribute: $DMG_NAME"
echo ""
echo "Users can now install without any security warnings!"
