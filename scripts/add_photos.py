#!/usr/bin/env python3
"""
add_photos.py — compress + EXIF-stamp new gallery photos.

Drop full-res images into EITHER folder, then run the script:
    images/photography-originals/    (recommended: inbox + archive of sources)
    images/photography/              (loose drop-ins; moved to originals after)

    python3 scripts/add_photos.py            # process + write
    python3 scripts/add_photos.py --dry-run  # show what would happen

For every NEW source image (content hasn't been processed before) it:
  - reads EXIF (capture date, camera, aperture/shutter/ISO) via macOS `mdls`,
    falling back to the timestamp in the filename, then the file's mtime
  - compresses to JPEG, longest edge 1800px, via macOS `sips`
  - names it images/photography/YYYY-MM-DD-NN.jpg (NN auto-incremented per day)
  - keeps the full-res original in images/photography-originals/ (git-ignored)
  - inserts an entry into _data/photography.yml, kept newest-first
  - records the original's sha1 in .processed.json so re-runs never duplicate it

No third-party deps — pure stdlib + sips/mdls, which ship with macOS.
title/location are left blank for you to fill in later, like the rest of the feed.
"""

import hashlib
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT      = Path(__file__).resolve().parent.parent
PHOTO_DIR = ROOT / "images" / "photography"
ORIG_DIR  = ROOT / "images" / "photography-originals"
DATA      = ROOT / "_data" / "photography.yml"
MANIFEST  = ORIG_DIR / ".processed.json"

MAX_EDGE = 1800          # longest edge in px (matches existing gallery)
QUALITY  = 82            # sips JPEG quality 0-100
SRC_EXTS = {".jpg", ".jpeg", ".png", ".heic", ".heif", ".tif", ".tiff", ".webp"}
CONFORMING = re.compile(r"^\d{4}-\d{2}-\d{2}-\d{2}\.jpe?g$", re.I)

DRY = "--dry-run" in sys.argv or "-n" in sys.argv


def sh(*args):
    return subprocess.run(args, capture_output=True, text=True)


def g(x):
    """Trim trailing zeros: 1.90 -> 1.9, 2.0 -> 2."""
    return f"{x:g}"


def sha1(path):
    h = hashlib.sha1()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ---- EXIF -----------------------------------------------------------------
def to_float(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def unquote(v):
    if not v or v == "(null)":
        return None
    return v[1:-1] if v.startswith('"') and v.endswith('"') else v


def date_from_name(path):
    """Pixel / most phones encode the timestamp in the filename."""
    s = path.name
    m = re.search(r"(20\d{2})(\d{2})(\d{2})[_-](\d{2})(\d{2})(\d{2})", s)
    if m:
        try:
            return datetime(*(int(x) for x in m.groups()), tzinfo=timezone.utc)
        except ValueError:
            pass
    m = re.search(r"(20\d{2})[-_]?(\d{2})[-_]?(\d{2})", s)
    if m:
        try:
            return datetime(int(m[1]), int(m[2]), int(m[3]), tzinfo=timezone.utc)
        except ValueError:
            pass
    return None


def read_meta(path):
    d = {}
    if shutil.which("mdls"):
        keys = ["kMDItemContentCreationDate", "kMDItemAcquisitionModel",
                "kMDItemFNumber", "kMDItemExposureTimeSeconds", "kMDItemISOSpeed"]
        args = ["mdls"]
        for k in keys:
            args += ["-name", k]
        args.append(str(path))
        for line in sh(*args).stdout.splitlines():
            if "=" in line:
                k, _, v = line.partition("=")
                d[k.strip()] = v.strip()

    dt = None
    raw = unquote(d.get("kMDItemContentCreationDate"))
    if raw:
        try:
            dt = datetime.strptime(raw, "%Y-%m-%d %H:%M:%S %z")
        except ValueError:
            pass
    if dt is None:
        dt = date_from_name(path) or datetime.fromtimestamp(
            path.stat().st_mtime, tz=timezone.utc)

    return {
        "dt": dt,
        "camera": unquote(d.get("kMDItemAcquisitionModel")),
        "fnum": to_float(d.get("kMDItemFNumber")),
        "exp": to_float(d.get("kMDItemExposureTimeSeconds")),
        "iso": to_float(d.get("kMDItemISOSpeed")),
    }


def fmt_exif(meta):
    parts = []
    if meta["fnum"]:
        parts.append(f"f/{g(meta['fnum'])}")
    exp = meta["exp"]
    if exp:
        parts.append(f"{g(round(exp, 1))}s" if exp >= 1 else f"1/{round(1 / exp)}")
    if meta["iso"]:
        parts.append(f"ISO {int(meta['iso'])}")
    return " · ".join(parts)


# ---- compression ----------------------------------------------------------
def compress(src, dst):
    if not shutil.which("sips"):
        return False
    r = sh("sips", "-s", "format", "jpeg", "-s", "formatOptions", str(QUALITY),
           "-Z", str(MAX_EDGE), str(src), "--out", str(dst))
    return r.returncode == 0 and dst.exists()


# ---- YAML -----------------------------------------------------------------
def existing_max_nn(date_str, extra):
    mx = extra
    for f in PHOTO_DIR.glob(f"{date_str}-*.jp*g"):
        m = re.match(rf"^{re.escape(date_str)}-(\d{{2}})\.jpe?g$", f.name, re.I)
        if m:
            mx = max(mx, int(m.group(1)))
    return mx


def yaml_block(name, date_str, camera, exif):
    lines = [f"- src: /images/photography/{name}", '  title: ""',
             '  location: ""', f"  date: {date_str}"]
    if camera:
        lines.append(f'  camera: "{camera}"')
    if exif:
        lines.append(f'  exif: "{exif}"')
    return "\n".join(lines)


def split_data():
    lines = DATA.read_text().splitlines(keepends=True)
    start = next((i for i, l in enumerate(lines) if l.startswith("- ")), len(lines))
    header = "".join(lines[:start])
    blocks, cur = [], []
    for l in lines[start:]:
        if l.startswith("- ") and cur:
            blocks.append("".join(cur))
            cur = [l]
        else:
            cur.append(l)
    if cur:
        blocks.append("".join(cur))
    parsed = []
    for b in blocks:
        if not b.strip():
            continue
        dm = re.search(r"date:\s*(\d{4}-\d{2}-\d{2})", b)
        nm = re.search(r"/(\d{4}-\d{2}-\d{2})-(\d{2})\.jpe?g", b)
        date = dm.group(1) if dm else (nm.group(1) if nm else "0000-00-00")
        nn = int(nm.group(2)) if nm else 0
        parsed.append((date, nn, b.strip("\n")))
    return header, parsed


def write_data(header, entries):
    entries.sort(key=lambda e: (e[0], e[1]), reverse=True)  # newest first
    body = "\n\n".join(e[2] for e in entries)
    DATA.write_text(header.rstrip("\n") + "\n\n" + body + "\n")


# ---- sources --------------------------------------------------------------
def gather_sources():
    """New source images from BOTH folders, de-duped by content hash."""
    seen, out = set(), []
    loose = [(f, True) for f in PHOTO_DIR.iterdir()] if PHOTO_DIR.is_dir() else []
    arch  = [(f, False) for f in ORIG_DIR.iterdir()] if ORIG_DIR.is_dir() else []
    for f, is_loose in sorted(loose + arch, key=lambda t: t[0].name):
        if not f.is_file() or f.name.startswith("."):
            continue
        if f.suffix.lower() not in SRC_EXTS:
            continue
        if is_loose and CONFORMING.match(f.name):
            continue   # already a finished gallery image
        h = sha1(f)
        if h in seen:
            continue
        seen.add(h)
        out.append((f, is_loose, h))
    return out


def main():
    manifest = json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {}
    sources = [t for t in gather_sources() if t[2] not in manifest]
    if not sources:
        print("No new photos to process "
              "(checked images/photography/ and images/photography-originals/).")
        return

    items = sorted(((read_meta(f), f, loose, h) for f, loose, h in sources),
                   key=lambda x: x[0]["dt"])

    header, entries = split_data()
    per_day, added = {}, 0

    for meta, src, is_loose, h in items:
        date_str = meta["dt"].strftime("%Y-%m-%d")
        nn = existing_max_nn(date_str, per_day.get(date_str, 0)) + 1
        per_day[date_str] = nn
        name = f"{date_str}-{nn:02d}.jpg"
        dst = PHOTO_DIR / name
        camera, exif = meta["camera"], fmt_exif(meta)

        print(f"\n{src.name}  ->  {name}")
        print(f"    date={date_str}  camera={camera or '-'}  exif={exif or '-'}")
        if DRY:
            print("    [dry-run] would compress + add YAML entry + record hash")
            entries.append((date_str, nn, yaml_block(name, date_str, camera, exif)))
            added += 1
            continue

        if not compress(src, dst):
            print("    !! sips not available — cannot compress. Skipped.")
            continue
        print(f"    compressed -> {dst.stat().st_size / 1024:.0f} KB")

        if is_loose:
            ORIG_DIR.mkdir(parents=True, exist_ok=True)
            target = ORIG_DIR / src.name
            if target.exists():
                target = ORIG_DIR / f"{src.stem}-{h[:8]}{src.suffix}"
            shutil.move(str(src), str(target))
            print(f"    original -> {target.relative_to(ROOT)}")

        manifest[h] = name
        entries.append((date_str, nn, yaml_block(name, date_str, camera, exif)))
        added += 1

    if DRY:
        print(f"\n[dry-run] {added} photo(s) would be added. Nothing changed.")
        return

    write_data(header, entries)
    ORIG_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print(f"\nDone: {added} photo(s) added to {DATA.relative_to(ROOT)} (newest-first).")
    print("Edit title/location in _data/photography.yml when you have a moment.")


if __name__ == "__main__":
    main()
