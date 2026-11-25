#!/usr/bin/env python3
"""
Normalize affiliation logos into uniform, on-theme cream monochrome PNGs.

Workflow:
  1. Drop the original logo files into  images/logos/raw/  named:
       ntu, arg, manipal, virya, exponent   (any of .png/.jpg/.jpeg/.webp)
  2. Run:  python3 process-logos.py
  3. Output overwrites images/logos/<name>.png  (cream, trimmed, centered, 2x).

For each logo it:
  - builds an alpha mask (uses existing transparency, else treats near-white as
    background so logos on white backgrounds work too),
  - recolors every foreground pixel to the site cream (#E9E1D1),
  - trims to content, centers on a transparent canvas of uniform height,
  - exports at 2x for crisp scaling across resolutions.
"""
import os, glob
from PIL import Image

CREAM = (0xE9, 0xE1, 0xD1)
TARGET_H = 160          # canvas height (logo art height ~ 112)
ART_H    = 112
PAD_X    = 16
RAW = "images/logos/raw"
OUT = "images/logos"
NAMES = ["ntu", "arg", "manipal", "virya", "exponent"]

def mask_alpha(im):
    im = im.convert("RGBA")
    px = im.load(); W, H = im.size
    # does the image already carry meaningful transparency?
    has_alpha = any(px[x, y][3] < 250 for y in range(0, H, 4) for x in range(0, W, 4))
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0)); op = out.load()
    for y in range(H):
        for x in range(W):
            r, g, b, a = px[x, y]
            if has_alpha:
                m = a
            else:
                # foreground = anything not near-white (captures dark + colored marks)
                m = 255 - min(r, g, b)
            if m > 8:
                op[x, y] = (CREAM[0], CREAM[1], CREAM[2], m)
    return out

def trim(im):
    bbox = im.getbbox()
    return im.crop(bbox) if bbox else im

def normalize(src, dst):
    im = trim(mask_alpha(Image.open(src)))
    w, h = im.size
    scale = ART_H / h
    im = im.resize((max(1, int(w * scale)), ART_H), Image.LANCZOS)
    canvas = Image.new("RGBA", (im.size[0] + PAD_X * 2, TARGET_H), (0, 0, 0, 0))
    canvas.alpha_composite(im, (PAD_X, (TARGET_H - ART_H) // 2))
    canvas.save(dst)
    print("normalized", dst, canvas.size)

def main():
    os.makedirs(RAW, exist_ok=True)
    found = False
    for name in NAMES:
        hits = glob.glob(os.path.join(RAW, name + ".*"))
        if hits:
            normalize(hits[0], os.path.join(OUT, name + ".png")); found = True
        else:
            print("  (no raw file for", name, "— keeping current placeholder)")
    if not found:
        print("No raw logos found in", RAW, "— add files and re-run.")

if __name__ == "__main__":
    main()
