#!/usr/bin/env python3
"""Covers for the rest of the Armored business drills (store #14 onward), in the series pattern.

Same drawing code as build_covers.py (and the Accounting for Decision Making cover builder): 1600 x 2560, flat
palette, inset rule, "Armored" then the title, tagline, by-line, V1. The title wraps to the width inside
the rule at the series size (118); a title that would need more than five lines, or has a word too wide for one line,
steps down in size (104, 92, 80) so it stays inside the rule. The red / blue / yellow rotation continues from #13.

Usage: python3 build_covers_business.py plan.json [out_dir]   (plan.json: [{"n", "title", "stem"}, ...])
"""
import json, os, sys
from PIL import Image as PILImage, ImageDraw, ImageFont
FD = os.environ.get("DEJAVU_DIR", "/usr/share/fonts/truetype/dejavu/")
RED, BLUE, YELLOW = ("#8C4A4A", "#F3E3E0"), ("#4A5F8C", "#E3E8F3"), ("#C9B35A", "#3D3410")
def palette(n): return {1: RED, 2: BLUE, 0: YELLOW}[n % 3]
fb = lambda z: ImageFont.truetype(FD + "DejaVuSans-Bold.ttf", z); fr = lambda z: ImageFont.truetype(FD + "DejaVuSans.ttf", z)

def wrap(dr, words, font, width):
    lines, cur = [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if cur and dr.textlength(t, font=font) > width: lines.append(cur); cur = w
        else: cur = t
    return lines + [cur]

def build_cover(path, title, bg, ink):
    W, H = 1600, 2560; im = PILImage.new("RGB", (W, H), bg); dr = ImageDraw.Draw(im)
    dr.rectangle([120, 120, W - 120, H - 120], outline=ink, width=5)
    width = W - 160 - 160
    for size in (118, 104, 92, 80):
        lines = wrap(dr, title.split(), fb(size), width)
        if len(lines) <= 5 and all(dr.textlength(l, font=fb(size)) <= width for l in lines): break
    y = 500; step = round(size * 142 / 118)
    for line in ["Armored"] + lines: dr.text((160, y), line, font=fb(size), fill=ink); y += step
    y += 40
    for line in ["For people who already know the", "easy version."]: dr.text((160, y), line, font=fr(62), fill=ink); y += 82
    assert y < H - 420, title
    dr.text((160, H - 390), "by Joshua", font=fr(76), fill=ink); dr.text((160, H - 280), "V1", font=fr(56), fill=ink)
    im.save(path, "JPEG", quality=92)
    return size, len(lines)

if __name__ == "__main__":
    books = json.load(open(sys.argv[1])); out = sys.argv[2] if len(sys.argv) > 2 else "out"; os.makedirs(out, exist_ok=True)
    for b in books:
        bg, ink = palette(b["n"]); size, nl = build_cover(os.path.join(out, b["stem"] + "_cover.jpg"), b["title"], bg, ink)
        if size != 118 or nl > 3: print(b["n"], b["title"], "size", size, "lines", nl)
    print(len(books), "covers")
