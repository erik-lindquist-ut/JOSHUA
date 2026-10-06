#!/usr/bin/env python3
"""Covers for the six Armored business drills, in the series pattern.

Same pattern and code as build_cover() in
"Armored Accounting for Decision Making - The Fail Fast Compendium (book, V1)/_build/build_compendium.py":
1600 x 2560, flat palette, inset rule, title (no series line since 2026-09-25), tagline, by-line, V1. The title wraps to the
width inside the rule. Palettes continue the listing sheet's red / blue / yellow rotation from the
seventh title (red): 8 blue, 9 yellow, 10 red, 11 blue, 12 yellow, 13 red.

Usage: python3 build_covers.py [out_dir]   (needs Pillow and the DejaVu Sans fonts; set DEJAVU_DIR if they are
not in /usr/share/fonts/truetype/dejavu/)
"""
import os, sys
from PIL import Image as PILImage, ImageDraw, ImageFont

FD = os.environ.get("DEJAVU_DIR", "/usr/share/fonts/truetype/dejavu/")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
os.makedirs(OUT, exist_ok=True)

RED, BLUE, YELLOW = ("#8C4A4A", "#F3E3E0"), ("#4A5F8C", "#E3E8F3"), ("#C9B35A", "#3D3410")
BOOKS = [  # (title after "Armored", palette)
    ("Managing Organizations and Leading People", BLUE),
    ("Business Acumen", YELLOW),
    ("Managing Human Capital", RED),
    ("Becoming an Effective Leader", BLUE),
    ("Management Communication", YELLOW),
    ("Leading Teams", RED),
]

def wrap(dr, words, font, width):
    lines, cur = [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if cur and dr.textlength(t, font=font) > width: lines.append(cur); cur = w
        else: cur = t
    return lines + [cur]

def build_cover(path, name, bg, ink):
    W, H = 1600, 2560; im = PILImage.new("RGB", (W, H), bg); dr = ImageDraw.Draw(im)
    dr.rectangle([120, 120, W - 120, H - 120], outline=ink, width=5)
    fb = lambda z: ImageFont.truetype(FD + "DejaVuSans-Bold.ttf", z); fr = lambda z: ImageFont.truetype(FD + "DejaVuSans.ttf", z)
    y = 500
    for line in ["Armored"] + wrap(dr, name.split(), fb(118), W - 160 - 160): dr.text((160, y), line, font=fb(118), fill=ink); y += 142
    y += 40
    for line in ["For people who already know the", "easy version."]: dr.text((160, y), line, font=fr(62), fill=ink); y += 82
    dr.text((160, H - 390), "by Joshua", font=fr(76), fill=ink); dr.text((160, H - 280), "V1", font=fr(56), fill=ink)
    im.save(path, "JPEG", quality=92)

if __name__ == "__main__":
    for name, (bg, ink) in BOOKS:
        p = os.path.join(OUT, "Armored_" + name.replace(" ", "_") + "_cover.jpg")
        build_cover(p, name, bg, ink); print(p)
