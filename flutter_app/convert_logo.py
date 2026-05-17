#!/usr/bin/env python3
"""
Convert VAS Media SVG logo to PNG for Flutter app
Requires: pip install Pillow cairosvg
"""

try:
    import cairosvg
    from PIL import Image
    import os

    svg_path = r"C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\assets\logo.svg"
    output_dir = r"C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\assets"

    # Convert SVG to PNG at different sizes
    sizes = [
        (512, 512, "logo-512.png"),
        (1024, 1024, "logo-1024.png"),
        (192, 192, "logo-192.png"),
    ]

    for width, height, filename in sizes:
        output_path = os.path.join(output_dir, filename)
        
        # Convert SVG to PNG
        cairosvg.svg2png(
            url=svg_path,
            write_to=output_path,
            output_width=width,
            output_height=height
        )
        
        print(f"✓ Created {filename} ({width}x{height})")

    print("\n✅ All logos created successfully!")
    print(f"Location: {output_dir}")

except ImportError:
    print("❌ Required packages not installed!")
    print("\nInstall with:")
    print("pip install Pillow cairosvg")
    print("\nOr use online converter: https://cloudconvert.com/svg-to-png")

except Exception as e:
    print(f"❌ Error: {e}")
    print("\nAlternative: Use online converter at https://cloudconvert.com/svg-to-png")
