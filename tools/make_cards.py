#!/usr/bin/env python3
"""Generate individual SVG card faces for the tile matching game.

Godot rasterises SVGs at import time with ThorVG, which does NOT render <text>
elements - a card built with <text> imports as a blank rectangle. So any word on
a card has to be converted to outlines first. This script does that conversion,
turning each glyph into a <path>, so the generated cards have no font dependency
and render correctly in Godot.

Card pairs are described in a plain text file, one pair per line:

    perro | dog          two different faces that match each other
    triangle             a single face; the pair is two copies of it
    gato | res://art/cat.svg   a word matched against an existing SVG

Anything that looks like a file path is copied in as-is; anything else is
rendered as outlined text.

Usage:
    python3 tools/make_cards.py                      # uses cards.txt -> cards/
    python3 tools/make_cards.py --spec my.txt --out cards --width 128 --height 120
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

try:
    from fontTools.pens.svgPathPen import SVGPathPen
    from fontTools.ttLib import TTFont
except ImportError:  # pragma: no cover
    sys.exit("fontTools is required:  pip install fonttools")

FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/freefont/FreeSansBold.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "C:/Windows/Fonts/arialbd.ttf",
]

INK = "#13161F"
CARD_BG = "#FFFFFF"
CARD_EDGE = "#D8DEEA"
BACK_FILL = "#B66EFF"
BACK_MARK = "#4F78DB"


def find_font(explicit: str | None) -> str:
    if explicit:
        if not Path(explicit).is_file():
            sys.exit(f"font not found: {explicit}")
        return explicit
    for c in FONT_CANDIDATES:
        if Path(c).is_file():
            return c
    sys.exit("no usable font found; pass --font /path/to/font.ttf")


def glyph_outlines(word: str, font_path: str):
    """Return (list of (path_data, x_offset), total_advance, units_per_em)."""
    font = TTFont(font_path)
    glyphs = font.getGlyphSet()
    cmap = font.getBestCmap()
    hmtx = font["hmtx"]
    upem = font["head"].unitsPerEm

    parts: list[tuple[str, float]] = []
    x = 0.0
    for ch in word:
        name = cmap.get(ord(ch))
        if name is None:
            x += upem * 0.35  # unmapped char -> blank space
            continue
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(pen)
        data = pen.getCommands()
        if data.strip():
            parts.append((data, x))
        x += hmtx[name][0]
    return parts, x, upem


def card_frame(w: int, h: int) -> str:
    return (
        f'<rect x="1" y="1" width="{w - 2}" height="{h - 2}" rx="8" '
        f'fill="{CARD_BG}" stroke="{CARD_EDGE}" stroke-width="2"/>'
    )


def text_card(word: str, w: int, h: int, font_path: str) -> str:
    parts, advance, upem = glyph_outlines(word, font_path)
    if advance <= 0:
        advance = upem

    # fit the word inside the card with a margin, but never scale past a size
    # that would look comically large for a single character
    margin = w * 0.12
    scale = min((w - 2 * margin) / advance, (h * 0.42) / (upem * 0.72))

    tx = (w - advance * scale) / 2.0
    ty = h / 2.0 + (upem * 0.72 * scale) / 2.0  # roughly optical centre

    glyph_svg = "".join(
        f'<path transform="translate({x:.1f},0)" d="{d}"/>' for d, x in parts
    )
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
        f'viewBox="0 0 {w} {h}">\n'
        f"  {card_frame(w, h)}\n"
        f'  <g transform="translate({tx:.2f},{ty:.2f}) scale({scale:.5f},-{scale:.5f})" '
        f'fill="{INK}">{glyph_svg}</g>\n'
        f"</svg>\n"
    )


def back_card(w: int, h: int) -> str:
    cx, cy = w / 2.0, h / 2.0
    r = min(w, h) * 0.26
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
        f'viewBox="0 0 {w} {h}">\n'
        f'  <rect x="1" y="1" width="{w - 2}" height="{h - 2}" rx="8" fill="{BACK_FILL}"/>\n'
        f'  <circle cx="{cx}" cy="{cy}" r="{r}" fill="none" '
        f'stroke="{BACK_MARK}" stroke-width="{r * 0.42:.1f}"/>\n'
        f"</svg>\n"
    )


def looks_like_path(token: str) -> bool:
    return token.endswith(".svg") or "/" in token


def resolve_source(token: str, spec_dir: Path) -> Path | None:
    raw = token[len("res://") :] if token.startswith("res://") else token
    for base in (spec_dir, Path.cwd()):
        p = (base / raw).resolve()
        if p.is_file():
            return p
    return None


def safe_name(text: str) -> str:
    keep = [c if (c.isalnum() or c in "-_") else "-" for c in text.lower()]
    return "".join(keep).strip("-") or "card"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--spec", default="cards.txt", help="pair list (default: cards.txt)")
    ap.add_argument("--out", default="cards", help="output directory (default: cards)")
    ap.add_argument("--width", type=int, default=128)
    ap.add_argument("--height", type=int, default=120)
    ap.add_argument("--font", default=None, help="TTF used for outlining text")
    ap.add_argument("--keep", action="store_true", help="don't clear the output directory first")
    args = ap.parse_args()

    spec_path = Path(args.spec)
    if not spec_path.is_file():
        sys.exit(f"spec file not found: {spec_path}")
    font_path = find_font(args.font)

    out = Path(args.out)
    if out.exists() and not args.keep:
        for f in out.glob("*.svg"):
            f.unlink()
    out.mkdir(parents=True, exist_ok=True)

    written = 0
    used: set[str] = set()

    for lineno, raw in enumerate(spec_path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        sides = [s.strip() for s in line.split("|") if s.strip()]
        if not sides:
            continue
        if len(sides) > 2:
            print(f"  line {lineno}: more than two sides, using the first two", file=sys.stderr)
            sides = sides[:2]

        pair = safe_name(sides[0])
        n = 2
        while pair in used:
            pair, n = f"{safe_name(sides[0])}-{n}", n + 1
        used.add(pair)

        # one side -> classic identical-card pair; two sides -> different faces
        targets = [f"{pair}.svg"] if len(sides) == 1 else [f"{pair}__1.svg", f"{pair}__2.svg"]

        for token, target in zip(sides, targets):
            dest = out / target
            if looks_like_path(token):
                src = resolve_source(token, spec_path.parent)
                if src is None:
                    print(f"  line {lineno}: cannot find {token}, skipping", file=sys.stderr)
                    continue
                shutil.copyfile(src, dest)
            else:
                dest.write_text(text_card(token, args.width, args.height, font_path), encoding="utf-8")
            written += 1
            print(f"  {dest}")

    back = out / "back.svg"
    back.write_text(back_card(args.width, args.height), encoding="utf-8")
    written += 1
    print(f"  {back}")

    print(f"\n{written} card file(s) written to {out}/  ({args.width}x{args.height})")
    print("Open the project in Godot once so it imports them.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
