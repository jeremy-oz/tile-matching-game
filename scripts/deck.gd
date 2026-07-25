class_name Deck
extends RefCounted

## Loads card definitions from a CSV file and turns them into a shuffled deck.
##
## The CSV has one row per card face and a header row:
##
##     pair,text,image
##     dog,perro,
##     dog,dog,
##     sun,sol,
##     sun,,res://art/sun.svg
##
## Rows sharing a "pair" value match each other, so a pair can be word/word,
## word/picture, or picture/picture. "text" and "image" may both be filled in
## to show a word underneath a picture.


## Read every card row from a CSV file. Returns an array of dictionaries with
## the keys "pair", "text" and "image".
static func load_csv(path: String) -> Array:
	var cards: Array = []

	if not FileAccess.file_exists(path):
		push_error("Deck file not found: %s" % path)
		return cards

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open %s (error %d)" % [path, FileAccess.get_open_error()])
		return cards

	# get_csv_line() understands quoted fields, so a card can contain a comma:
	#   maths,"2, 4, 6, 8",
	var header := file.get_csv_line()
	if header.size() < 2:
		push_error("%s does not look like a deck file (expected a pair,text,image header)" % path)
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


## Group the cards by pair, pick enough pairs to fill the board, and shuffle.
## A pair with only one row is used twice, giving two identical cards.
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
