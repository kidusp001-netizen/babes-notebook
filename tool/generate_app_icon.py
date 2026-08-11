#!/usr/bin/env python3
"""Generate app icon — queen photo in a creative curved rectangle frame."""

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
BG = (255, 245, 247, 255)
PINK = (236, 72, 153, 255)
PINK_DARK = (219, 39, 119, 255)
ROSE = (232, 180, 188, 255)

src = Image.open("assets/images/queen_avatar.png").convert("RGBA")
canvas = Image.new("RGBA", (SIZE, SIZE), BG)
draw = ImageDraw.Draw(canvas)

# Soft background glow
for r, alpha in [(420, 35), (360, 50), (300, 70)]:
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    g = ImageDraw.Draw(glow)
    g.ellipse(
        (SIZE // 2 - r, SIZE // 2 - r - 40, SIZE // 2 + r, SIZE // 2 + r - 40),
        fill=(*PINK[:3], alpha),
    )
    canvas = Image.alpha_composite(canvas, glow)

# Frame geometry — portrait rounded rectangle (squircle feel)
frame_w, frame_h = 520, 640
x0 = (SIZE - frame_w) // 2
y0 = (SIZE - frame_h) // 2 - 30
radius = 88

# Outer decorative ring
for i, col in enumerate([ROSE, PINK, PINK_DARK]):
    inset = i * 10
    draw.rounded_rectangle(
        (x0 - 18 + inset, y0 - 18 + inset, x0 + frame_w + 18 - inset, y0 + frame_h + 18 - inset),
        radius=radius + 18 - inset,
        outline=col,
        width=6 - i,
    )

# Shadow layer
shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.rounded_rectangle(
    (x0 + 8, y0 + 16, x0 + frame_w + 8, y0 + frame_h + 16),
    radius=radius,
    fill=(236, 72, 153, 60),
)
shadow = shadow.filter(ImageFilter.GaussianBlur(18))
canvas = Image.alpha_composite(canvas, shadow)

# Clip photo to rounded rect
mask = Image.new("L", (SIZE, SIZE), 0)
md = ImageDraw.Draw(mask)
md.rounded_rectangle((x0, y0, x0 + frame_w, y0 + frame_h), radius=radius, fill=255)

photo = src.copy()
photo = photo.resize((frame_w, frame_h), Image.Resampling.LANCZOS)
placed = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
placed.paste(photo, (x0, y0))
placed.putalpha(mask)
canvas = Image.alpha_composite(canvas, placed)

# White inner border
draw.rounded_rectangle(
    (x0, y0, x0 + frame_w, y0 + frame_h),
    radius=radius,
    outline=(255, 255, 255, 230),
    width=8,
)

# Small heart badge bottom-right
hx, hy = x0 + frame_w - 72, y0 + frame_h - 72
draw.ellipse((hx - 4, hy - 4, hx + 68, hy + 68), fill=PINK)
draw.ellipse((hx + 10, hy - 4, hx + 82, hy + 68), fill=PINK)

out = "assets/images/app_icon.png"
canvas.convert("RGB").save(out, quality=95)
print(f"Wrote {out}")
