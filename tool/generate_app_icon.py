#!/usr/bin/env python3
"""Generate app icon — circular profile photo like QueenAvatar (cover crop, no stretch)."""

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
for r, alpha in [(380, 40), (320, 55), (260, 75)]:
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    g = ImageDraw.Draw(glow)
    g.ellipse(
        (SIZE // 2 - r, SIZE // 2 - r, SIZE // 2 + r, SIZE // 2 + r),
        fill=(*PINK[:3], alpha),
    )
    canvas = Image.alpha_composite(canvas, glow)

# Rose-gold ring (matches profile avatar)
outer = 420
inner = 380
ring = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
rd = ImageDraw.Draw(ring)
rd.ellipse(
    (SIZE // 2 - outer, SIZE // 2 - outer, SIZE // 2 + outer, SIZE // 2 + outer),
    fill=ROSE,
)
rd.ellipse(
    (SIZE // 2 - inner, SIZE // 2 - inner, SIZE // 2 + inner, SIZE // 2 + inner),
    fill=(0, 0, 0, 0),
)
canvas = Image.alpha_composite(canvas, ring)

# Shadow
shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.ellipse(
    (SIZE // 2 - inner + 6, SIZE // 2 - inner + 10, SIZE // 2 + inner + 6, SIZE // 2 + inner + 10),
    fill=(236, 72, 153, 70),
)
shadow = shadow.filter(ImageFilter.GaussianBlur(16))
canvas = Image.alpha_composite(canvas, shadow)

# Center-crop photo to square, then clip to circle (BoxFit.cover style)
sw, sh = src.size
side = min(sw, sh)
left = (sw - side) // 2
top = (sh - side) // 2
cropped = src.crop((left, top, left + side, top + side))
photo = cropped.resize((inner * 2, inner * 2), Image.Resampling.LANCZOS)

mask = Image.new("L", (SIZE, SIZE), 0)
md = ImageDraw.Draw(mask)
photo_diameter = inner * 2 - 12
md.ellipse(
    (
        SIZE // 2 - photo_diameter // 2,
        SIZE // 2 - photo_diameter // 2,
        SIZE // 2 + photo_diameter // 2,
        SIZE // 2 + photo_diameter // 2,
    ),
    fill=255,
)

placed = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
px = SIZE // 2 - photo_diameter // 2
py = SIZE // 2 - photo_diameter // 2
placed.paste(
    photo.resize((photo_diameter, photo_diameter), Image.Resampling.LANCZOS),
    (px, py),
)
placed.putalpha(mask)
canvas = Image.alpha_composite(canvas, placed)

# White inner border
draw.ellipse(
    (
        SIZE // 2 - photo_diameter // 2,
        SIZE // 2 - photo_diameter // 2,
        SIZE // 2 + photo_diameter // 2,
        SIZE // 2 + photo_diameter // 2,
    ),
    outline=(255, 255, 255, 240),
    width=10,
)

# Small crown sparkle badge (top-right)
badge = 96
bx = SIZE // 2 + photo_diameter // 2 - badge // 2 - 8
by = SIZE // 2 - photo_diameter // 2 - badge // 2 + 8
draw.ellipse((bx, by, bx + badge, by + badge), fill=PINK)
draw.ellipse((bx + 8, by, bx + badge + 8, by + badge), fill=PINK_DARK)

out = "assets/images/app_icon.png"
canvas.convert("RGB").save(out, quality=95)
print(f"Wrote {out}")
