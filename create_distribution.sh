#!/bin/bash
# Quick Distribution Package Creator
# This removes quarantine attributes and creates a clean ZIP for testers
# Testers will still see a warning, but it's easier to bypass

set -e

APP_PATH="Focus Lens Release 3/Focus Lens.app"
ZIP_NAME="Focus-Lens-v1.0.zip"

echo "🧹 Cleaning quarantine attributes..."
xattr -cr "$APP_PATH"

echo "📦 Creating distribution package..."
rm -f "$ZIP_NAME"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_NAME"

echo "✅ Package created: $ZIP_NAME"
echo ""
echo "📧 Instructions for distribution:"
echo "1. Send testers: $ZIP_NAME + INSTALLATION_INSTRUCTIONS.md"
echo "2. Testers should right-click the app and select 'Open'"
echo "3. This bypasses the Gatekeeper warning"
