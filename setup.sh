#!/bin/bash

# FocusLens Quick Setup Script
# This script helps you set up the Xcode project quickly

set -e

echo "🎯 FocusLens - Quick Setup Script"
echo "================================="
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    echo "Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -n 1)"
echo ""

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR"

echo "📁 Project directory: $PROJECT_DIR"
echo ""

# Check if source files exist
if [ ! -f "$PROJECT_DIR/FocusLens/FocusLensApp.swift" ]; then
    echo "❌ Error: Source files not found in FocusLens/ directory"
    echo "Please ensure all Swift files are present"
    exit 1
fi

echo "✅ Source files found"
echo ""

# Ask user what they want to do
echo "What would you like to do?"
echo "1) Create new Xcode project (manual setup required)"
echo "2) Build existing project"
echo "3) Build and run"
echo "4) Open in Xcode"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📝 To create a new Xcode project:"
        echo ""
        echo "1. Open Xcode"
        echo "2. File → New → Project"
        echo "3. Choose macOS → App"
        echo "4. Product Name: FocusLens"
        echo "5. Interface: SwiftUI"
        echo "6. Save in: $PROJECT_DIR"
        echo ""
        echo "Then:"
        echo "- Delete the default ContentView.swift and FocusLensApp.swift"
        echo "- Add all the Swift files from FocusLens/ folder"
        echo "- Replace Info.plist with the custom one"
        echo "- Add FocusLens.entitlements to the project"
        echo "- Disable App Sandbox in Signing & Capabilities"
        echo ""
        echo "See BUILD_GUIDE.md for detailed instructions"
        ;;
    
    2)
        echo ""
        echo "🔨 Building FocusLens..."
        
        if [ ! -d "FocusLens.xcodeproj" ]; then
            echo "❌ Error: FocusLens.xcodeproj not found"
            echo "Please create the Xcode project first (option 1)"
            exit 1
        fi
        
        xcodebuild -project FocusLens.xcodeproj \
            -scheme FocusLens \
            -configuration Release \
            -derivedDataPath ./build \
            build
        
        echo ""
        echo "✅ Build successful!"
        echo "📦 App location: ./build/Build/Products/Release/FocusLens.app"
        echo ""
        echo "To install: cp -R ./build/Build/Products/Release/FocusLens.app /Applications/"
        ;;
    
    3)
        echo ""
        echo "🔨 Building and running FocusLens..."
        
        if [ ! -d "FocusLens.xcodeproj" ]; then
            echo "❌ Error: FocusLens.xcodeproj not found"
            echo "Please create the Xcode project first (option 1)"
            exit 1
        fi
        
        xcodebuild -project FocusLens.xcodeproj \
            -scheme FocusLens \
            -configuration Release \
            -derivedDataPath ./build \
            build
        
        echo ""
        echo "✅ Build successful!"
        echo "🚀 Launching FocusLens..."
        
        open ./build/Build/Products/Release/FocusLens.app
        
        echo ""
        echo "✅ FocusLens is now running!"
        echo "   - Look for the scope icon in your status bar"
        echo "   - Press Cmd+Shift+Q to quit"
        ;;
    
    4)
        echo ""
        echo "📂 Opening in Xcode..."
        
        if [ ! -d "FocusLens.xcodeproj" ]; then
            echo "❌ Error: FocusLens.xcodeproj not found"
            echo "Please create the Xcode project first (option 1)"
            exit 1
        fi
        
        open FocusLens.xcodeproj
        
        echo ""
        echo "✅ Xcode opened"
        echo "   - Press Cmd+R to build and run"
        echo "   - Press Cmd+B to build only"
        ;;
    
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Done! 🎉"
