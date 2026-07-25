# Tile Matching Game

A memory / pairs game built in Godot 4.7. Card art is a folder of individual
SVG files, so the same game can be re-skinned for any lesson without touching
the scene or the code.

## Custom cards

Card faces live in `cards/`, one file per face, assembled into a TileSet when
the game starts. Adding or changing cards means dropping files in that folder.

| File | Meaning |
|---|---|
| `back.svg` | the face-down card (required) |
| `<name>.svg` | a pair of two identical cards |
| `<name>__1.svg` + `<name>__2.svg` | two *different* faces that match each other |

Cards match on the `<name>` part rather than on the image, which is what lets a
written word pair with a picture of the thing it names. All cards should share
the same pixel dimensions; the first one loaded sets the grid cell size.

A 4×4 board needs 8 pairs. `board_size` is exported, so it can be changed in the
inspector — an N×N board needs N²/2 pairs.

## Generating word cards

Godot rasterises SVGs at import time using ThorVG, which **does not render
`<text>` elements** — a card built with `<text>` imports as a blank rectangle.
Words therefore have to be converted to outlines before import.
`tools/make_cards.py` does that automatically, turning each glyph into a
`<path>` so the cards carry no font dependency:

```bash
pip install fonttools
python3 tools/make_cards.py            # reads cards.txt, writes cards/
```

Edit `cards.txt` to change the deck. One pair per line; `|` separates the two
faces:

```
perro | dog          # a word and its translation
triangle             # a single face, paired with a copy of itself
gato | art/cat.svg   # a word matched against existing artwork
```

Anything ending in `.svg` is copied in as-is, so hand-drawn artwork and
generated word cards can be mixed freely. Open the project in Godot once
afterwards so it imports the new files.

Useful flags: `--spec` (a different card list), `--out` (a different folder),
`--width` / `--height` (card size), `--font` (a specific TTF).

## Credit

Originally based on [GodotTileMatchingGameExample](https://github.com/Goldenlion5648/GodotTileMatchingGameExample)
by Goldenlion5648 / ThinkWithGames, MIT licensed — see `LICENSE`.
