# 7. Loading decks from CSV

**In this chapter:** you will move the card content out of the code and into a
spreadsheet file, so the game can be re-skinned for any topic without
programming.

## Why bother?

Right now the words are typed into `game.gd`. To make a French deck, or a
chemistry deck, you would edit the code — and anyone who wanted a new deck would
need to be a programmer.

A **CSV** file fixes that. CSV means *comma-separated values*: a plain text file
where each line is a row and commas separate the columns. Excel, Google Sheets
and Numbers all open and save it.

This is the shape we want:

```csv
pair,text,image
dog,perro,
dog,dog,
sun,sol,res://art/sun.svg
sun,sun,
```

One row per **card face**. Cards sharing a `pair` value match each other.

Look at the `sun` rows: one shows the Spanish word *and* a picture, the other
shows just the English word. Different faces, same pair — they match. That is
the payoff from making `pair_id` separate from what is on screen, back in
Chapter 3.

## Make a deck file

Create a folder `decks/` and a file `decks/spanish.csv`:

```csv
pair,text,image
dog,perro,
dog,dog,
cat,gato,
cat,cat,
house,casa,
house,house,
book,libro,
book,book,
water,agua,
water,water,
sun,sol,
sun,sun,
moon,luna,
moon,moon,
tree,arbol,
tree,tree,
```

Eight pairs, which is exactly what a 4×4 board needs.

!!! danger "Do this or your deck will break"
    Godot treats `.csv` files as **translation files** by default — it assumes
    the columns are languages. It will try to import your deck as translations
    and may stop your game reading it properly once exported.

    Fix it: click `decks/spanish.csv` in the **FileSystem** panel, go to the
    **Import** tab (next to the Inspector), change **Import As** to
    **Keep File (No Import)**, and click **Reimport**.

    Do this for every deck file you add. If your deck loads in the editor but
    breaks in an exported game, this is almost always why.

## The Deck script

Create `scripts/deck.gd`. This one is not attached to any node — it is a
toolbox of functions.

```gdscript
class_name Deck
extends RefCounted
```

`RefCounted` is the lightest thing a class can be: no position, not in the scene
tree, just code and data. Perfect for a helper.

### Reading the file

```gdscript
static func load_csv(path: String) -> Array:
	var cards: Array = []

	if not FileAccess.file_exists(path):
		push_error("Deck file not found: %s" % path)
		return cards

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s (error %d)" % [path, FileAccess.get_open_error()])
		return cards

	var header := file.get_csv_line()
	if header.size() < 2:
		push_error("%s does not look like a deck file" % path)
		return cards

	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < 2:
			continue
		var pair := row[0].strip_edges()
		if pair == "" or pair.begins_with("#"):
			continue
		cards.append({
			"pair": pair,
			"text": row[1].strip_edges(),
			"image": row[2].strip_edges() if row.size() > 2 else "",
		})

	return cards
```

A `static` function belongs to the class rather than to any particular object,
so you call it as `Deck.load_csv(...)` without creating a Deck first.

**`get_csv_line()` is doing real work here.** You might think splitting on
commas would be enough:

```gdscript
var parts = line.split(",")   # DON'T
```

But what about a card that contains a comma?

```csv
maths,"2, 4, 6, 8",
```

`split(",")` would chop that into four broken pieces. `get_csv_line()` knows
about quotes and returns `2, 4, 6, 8` as one value, exactly as a spreadsheet
would. Using the built-in tool saves you from a bug you would not find until a
student typed a comma.

`strip_edges()` removes stray spaces, so `dog , perro` still works.

### Dictionaries

Each card is stored as a **dictionary** — a set of labelled values:

```gdscript
{"pair": "dog", "text": "perro", "image": ""}
```

You read a value by its key: `card["pair"]`. Unlike an array, where you have to
remember that position 0 was the pair, a dictionary says what it means.

### Dealing a deck

```gdscript
static func build(cards: Array, pairs_needed: int) -> Array:
	var groups := {}
	for card in cards:
		var key: String = card["pair"]
		if not groups.has(key):
			groups[key] = []
		groups[key].append(card)

	var keys := groups.keys()
	keys.shuffle()

	if keys.size() < pairs_needed:
		push_error("Deck has %d pair(s) but the board needs %d" % [keys.size(), pairs_needed])
		pairs_needed = keys.size()

	var deck: Array = []
	for i in range(pairs_needed):
		var group: Array = groups[keys[i]]
		deck.append(group[0])
		deck.append(group[1] if group.size() > 1 else group[0])

	deck.shuffle()
	return deck
```

Three steps: group the rows by `pair`, shuffle the pair names and take as many
as the board needs, then take two faces from each group and shuffle the result.

`group[1] if group.size() > 1 else group[0]` means a pair listed only once
becomes two identical cards — so a plain deck of matching pictures also works.

Shuffling the **keys** matters: it means a 20-pair deck gives you a different
8 pairs every game, not the same eight in a different order.

## Use it in the game

In `game.gd`, add an exported path near the top:

```gdscript
@export_file("*.csv") var deck_path := "res://decks/spanish.csv"
```

`@export_file("*.csv")` gives you a file picker in the Inspector that only shows
CSV files.

Now replace the temporary deck in `start_new_game()`:

```gdscript
	pairs_to_find = total_cards / 2
	var all_cards := Deck.load_csv(deck_path)
	var deck := Deck.build(all_cards, pairs_to_find)
	pairs_to_find = deck.size() / 2

	board.build(deck, columns)
	update_labels()
```

Delete the `words` array and the loop that used it.

`pairs_to_find` is set twice on purpose. The first is what we *want*; the second
is what we actually got. If the deck is too small, the board is smaller than
asked for — and the win check still works because it uses the real number.

## Try it

Run the game. It should look the same but now be reading from your file.

Now prove it: open `decks/spanish.csv` in a text editor, change `perro` to
something silly, save, and run again. No Godot restart, no code change.

**That is the goal.** A teacher can now make a deck in a spreadsheet.

## Check yourself

<quiz>
Why use `FileAccess.get_csv_line()` instead of `split(",")`?
- [ ] It is faster
- [x] It understands quoted fields, so a value can contain a comma
- [ ] `split()` does not work on files
- [ ] It automatically skips the header row

`"2, 4, 6, 8"` is a single value in CSV. `split(",")` would break it into four.
The built-in reader handles quotes exactly as a spreadsheet does.
</quiz>

<quiz>
What must you do to a new `.csv` deck file after adding it to the project?
- [ ] Nothing, Godot handles it
- [ ] Rename it to `.txt`
- [x] Set Import As to "Keep File (No Import)" in the Import tab
- [ ] Add it to the project settings translation list

Godot assumes `.csv` files are translations. Marking them "keep" stops it
importing them and leaves the plain file for your code to read.
</quiz>

<quiz>
Why does `build()` shuffle `keys` rather than only shuffling the final deck?
- [ ] To make the shuffle more random
- [x] So a large deck gives a different selection of pairs each game, not just a different order
- [ ] Because dictionaries cannot be shuffled
- [ ] It stops the same card appearing twice

With 20 pairs and a board that needs 8, shuffling the keys first means you get a
different eight every time you play.
</quiz>

<quiz>
A value stored with labelled keys like `{"pair": "dog"}` is called a [[dictionary]].

---

Dictionaries let you write `card["pair"]` instead of remembering that position 0
held the pair id.
</quiz>

[Chapter 8: Make it yours →](08-make-it-yours.md)
