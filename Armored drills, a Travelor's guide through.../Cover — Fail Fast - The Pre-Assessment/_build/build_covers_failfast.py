#!/usr/bin/env python3
"""Covers for the Armored Fail Fast set (store #865-#869), in the series pattern.

Same drawing code as build_covers_business.py: 1600 x 2560, flat palette, inset rule, top line, "Armored" then the
title, tagline, by-line, V1. Here the top line names the book's place in the set ("BOOK 1 OF 5"; no series name since 2026-09-25), the title is
"Fail Fast" and then the book's own title, and the tagline is the book's own (from its title page). The red / blue /
yellow rotation continues from #864.

Usage: python3 build_covers_failfast.py plan.json [out_dir]   (plan.json: [{"n", "book", "title", "tagline", "stem"}, ...])
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

def build_cover(path, book, title, tagline, bg, ink):
    W, H = 1600, 2560; im = PILImage.new("RGB", (W, H), bg); dr = ImageDraw.Draw(im)
    dr.rectangle([120, 120, W - 120, H - 120], outline=ink, width=5)
    dr.text((160, 225), f"BOOK {book} OF 5", font=fb(62), fill=ink)
    width = W - 160 - 160
    for size in (118, 104, 92, 80):
        lines = wrap(dr, title.split(), fb(size), width)
        if len(lines) <= 4 and all(dr.textlength(l, font=fb(size)) <= width for l in lines): break
    y = 500; step = round(size * 142 / 118)
    for line in ["Armored", "Fail Fast"] + lines: dr.text((160, y), line, font=fb(size), fill=ink); y += step
    y += 40
    for line in wrap(dr, tagline.split(), fr(62), width): dr.text((160, y), line, font=fr(62), fill=ink); y += 82
    assert y < H - 420, title
    dr.text((160, H - 390), "by Joshua", font=fr(76), fill=ink); dr.text((160, H - 280), "V1", font=fr(56), fill=ink)
    im.save(path, "JPEG", quality=92)
    return size, len(lines)

if __name__ == "__main__":
    books = json.load(open(sys.argv[1])); out = sys.argv[2] if len(sys.argv) > 2 else "out"; os.makedirs(out, exist_ok=True)
    for b in books:
        bg, ink = palette(b["n"]); size, nl = build_cover(os.path.join(out, b["stem"] + "_cover.jpg"), b["book"], b["title"], b["tagline"], bg, ink)
        print(b["n"], b["title"], "size", size, "lines", nl)
    print(len(books), "covers")
