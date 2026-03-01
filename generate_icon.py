#!/usr/bin/env python3
"""
Generate FocusLens app icon - eye with focus ring design
Requires: pip install Pillow
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size):
    """Create a single icon size"""
    # Create image with gradient background
    img = Image.new('RGB', (size, size), '#1E1E1E')
    draw = ImageDraw.Draw(img)
    
    center_x, center_y = size // 2, size // 2
    
    # Modern gradient background (dark blue to purple)
    for i in range(size):
        color_val = int(30 + (i / size) * 50)  # Gradient from dark to slightly lighter
        draw.rectangle([(0, i), (size, i+1)], fill=(color_val, color_val//2, color_val))
    
    # Outer glow ring (focus effect)
    ring_thickness = max(2, size // 40)
    outer_radius = size // 2 - size // 10
    
    # Multiple rings for glow effect
    for i in range(4):
        ring_color = (100 + i * 30, 150 + i * 20, 255)  # Blue glow
        draw.ellipse(
            [center_x - outer_radius - i*ring_thickness, 
             center_y - outer_radius - i*ring_thickness,
             center_x + outer_radius + i*ring_thickness, 
             center_y + outer_radius + i*ring_thickness],
            outline=ring_color,
            width=ring_thickness
        )
    
    # Eye shape
    eye_width = size // 2.5
    eye_height = size // 4
    
    # White of eye
    draw.ellipse(
        [center_x - eye_width//2, center_y - eye_height//2,
         center_x + eye_width//2, center_y + eye_height//2],
        fill='white'
    )
    
    # Iris (blue)
    iris_radius = eye_height // 1.5
    draw.ellipse(
        [center_x - iris_radius, center_y - iris_radius,
         center_x + iris_radius, center_y + iris_radius],
        fill=(60, 120, 255)
    )
    
    # Pupil
    pupil_radius = iris_radius // 2
    draw.ellipse(
        [center_x - pupil_radius, center_y - pupil_radius,
         center_x + pupil_radius, center_y + pupil_radius],
        fill='black'
    )
    
    # Light reflection on eye
    reflection_radius = pupil_radius // 2
    draw.ellipse(
        [center_x - pupil_radius//2 - reflection_radius, 
         center_y - pupil_radius//2 - reflection_radius,
         center_x - pupil_radius//2 + reflection_radius, 
         center_y - pupil_radius//2 + reflection_radius],
        fill=(255, 255, 255, 180)
    )
    
    # Corner radius for modern macOS style
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = size // 5
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)
    
    # Apply mask
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, mask=mask)
    
    return output

def main():
    # Required icon sizes for macOS
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    output_dir = "Focus Lens/Focus Lens/Assets.xcassets/AppIcon.appiconset"
    
    print("🎨 Generating FocusLens app icons...")
    
    for size in sizes:
        icon = create_icon(size)
        
        # Save 1x version
        filename = f"icon_{size}x{size}.png"
        filepath = os.path.join(output_dir, filename)
        icon.save(filepath, 'PNG')
        print(f"  ✓ Created {filename}")
        
        # Save 2x version (double resolution)
        if size <= 512:
            icon_2x = create_icon(size * 2)
            filename_2x = f"icon_{size}x{size}@2x.png"
            filepath_2x = os.path.join(output_dir, filename_2x)
            icon_2x.save(filepath_2x, 'PNG')
            print(f"  ✓ Created {filename_2x}")
    
    print("\n✅ All icons generated successfully!")
    print(f"📁 Saved to: {output_dir}")
    print("\n🔧 Next steps:")
    print("1. Run: python3 update_icon_manifest.py")
    print("2. Open Xcode and verify the icon appears in Assets.xcassets")
    print("3. Build and run!")

if __name__ == "__main__":
    try:
        main()
    except ImportError:
        print("❌ Error: Pillow not installed")
        print("Install it with: pip3 install Pillow")
        exit(1)
