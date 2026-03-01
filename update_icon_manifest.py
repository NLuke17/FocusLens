#!/usr/bin/env python3
"""
Update the Contents.json file in AppIcon.appiconset with the correct filenames
"""

import json
import os

def main():
    manifest = {
        "images": [
            {"filename": "icon_16x16.png", "idiom": "mac", "scale": "1x", "size": "16x16"},
            {"filename": "icon_16x16@2x.png", "idiom": "mac", "scale": "2x", "size": "16x16"},
            {"filename": "icon_32x32.png", "idiom": "mac", "scale": "1x", "size": "32x32"},
            {"filename": "icon_32x32@2x.png", "idiom": "mac", "scale": "2x", "size": "32x32"},
            {"filename": "icon_128x128.png", "idiom": "mac", "scale": "1x", "size": "128x128"},
            {"filename": "icon_128x128@2x.png", "idiom": "mac", "scale": "2x", "size": "128x128"},
            {"filename": "icon_256x256.png", "idiom": "mac", "scale": "1x", "size": "256x256"},
            {"filename": "icon_256x256@2x.png", "idiom": "mac", "scale": "2x", "size": "256x256"},
            {"filename": "icon_512x512.png", "idiom": "mac", "scale": "1x", "size": "512x512"},
            {"filename": "icon_512x512@2x.png", "idiom": "mac", "scale": "2x", "size": "512x512"}
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    output_path = "Focus Lens/Focus Lens/Assets.xcassets/AppIcon.appiconset/Contents.json"
    
    with open(output_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print("✅ Updated Contents.json with icon filenames")
    print(f"📁 {output_path}")

if __name__ == "__main__":
    main()
