extends Node2D

# Card art lives as individual files in res://cards/ - one file per card face.
# The TileSet is assembled from them at startup, so adding or changing cards is
# a matter of dropping files in that folder; nothing here needs editing.
#
#   back.svg          the face-down card (required)
#   <name>.svg        a pair of two identical cards
#   <name>__1.svg     \ two different faces that match each other, e.g. a word
#   <name>__2.svg     / on one and the matching picture on the other
#
# Cards are matched on the <name> part, not on the image, which is what lets a
# written word pair with a picture.

const CARDS_DIR := "res://cards"
const BACK_CARD := "back"

@export var board_size := 4

var revealed_spots = []
var tile_pos_to_pair = {}
var score = 0
var turns_taken = 0

var back_source_id := -1
var pairs := {}

# "hidden" draws on top of "revealed" (see its z_index in tile_map.tscn), so
# erasing a hidden cell uncovers the card underneath it.
@onready var hidden_layer: TileMapLayer = $hidden
@onready var revealed_layer: TileMapLayer = $revealed


func _ready() -> void:
	build_tile_set()
	setup_board()
	update_text()


func card_files() -> Array[String]:
	var names: Array[String] = []
	var dir := DirAccess.open(CARDS_DIR)
	if dir == null:
		push_error("Cannot open %s" % CARDS_DIR)
		return names
	for f in dir.get_files():
		# exported builds expose .import / .remap wrappers, not the raw source file
		f = f.trim_suffix(".remap").trim_suffix(".import")
		if not f.get_extension().to_lower() in ["svg", "png"]:
			continue
		if not names.has(f):
			names.append(f)
	names.sort()
	return names


func build_tile_set() -> void:
	var files := card_files()
	if files.is_empty():
		push_error("No card art found in %s" % CARDS_DIR)
		return

	var tile_set := TileSet.new()
	var cell_size := Vector2i.ZERO

	for f in files:
		var tex: Texture2D = load("%s/%s" % [CARDS_DIR, f])
		if tex == null:
			push_warning("Could not load %s" % f)
			continue
		var size := Vector2i(tex.get_size())
		if cell_size == Vector2i.ZERO:
			cell_size = size
			tile_set.tile_size = size
		elif size != cell_size:
			push_warning("%s is %s but the first card was %s; cards should all match" % [f, size, cell_size])

		# one source per file, each holding a single tile at 0,0
		var source := TileSetAtlasSource.new()
		source.texture = tex
		source.texture_region_size = size
		source.create_tile(Vector2i.ZERO)
		var id := tile_set.add_source(source)

		var stem: String = f.get_basename()
		if stem == BACK_CARD:
			back_source_id = id
		else:
			var key: String = stem.split("__")[0]
			if not pairs.has(key):
				pairs[key] = []
			pairs[key].append(id)

	if back_source_id == -1:
		push_error("%s/%s.svg is missing - that file is the face-down card art" % [CARDS_DIR, BACK_CARD])

	hidden_layer.tile_set = tile_set
	revealed_layer.tile_set = tile_set
	# card art is smooth vector work rather than pixel art
	hidden_layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	revealed_layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func get_cards_to_use() -> Array:
	var needed := int(board_size * board_size / 2.0)
	var keys := pairs.keys()
	keys.shuffle()
	if keys.size() < needed:
		push_error("A %dx%d board needs %d pairs but only %d found in %s"
			% [board_size, board_size, needed, keys.size(), CARDS_DIR])
		needed = keys.size()

	var deck := []
	for i in range(needed):
		var key = keys[i]
		var ids: Array = pairs[key]
		# a single file pairs with itself; two files give the card two faces
		deck.append({"key": key, "id": ids[0]})
		deck.append({"key": key, "id": ids[ids.size() - 1]})
	deck.shuffle()
	return deck


func setup_board():
	var deck := get_cards_to_use()
	for y in range(board_size):
		for x in range(board_size):
			if deck.is_empty():
				return
			var current_spot := Vector2i(x, y)
			var card = deck.pop_back()
			place_single_face_down_card(current_spot)
			tile_pos_to_pair[current_spot] = card["key"]
			revealed_layer.set_cell(current_spot, card["id"], Vector2i.ZERO)


func place_single_face_down_card(coords: Vector2i):
	hidden_layer.set_cell(coords, back_source_id, Vector2i.ZERO)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			var pos_clicked = hidden_layer.local_to_map(hidden_layer.to_local(global_clicked))
			var still_face_down = hidden_layer.get_cell_source_id(pos_clicked) != -1
			if still_face_down and revealed_spots.size() < 2:
				hidden_layer.erase_cell(pos_clicked)
				revealed_spots.append(pos_clicked)
				if revealed_spots.size() == 2:
					when_two_cards_revealed()


func when_two_cards_revealed():
	# the cards match
	if tile_pos_to_pair[revealed_spots[0]] == tile_pos_to_pair[revealed_spots[1]]:
		score += 1
		revealed_spots.clear()
	else:
		# the cards did not match
		put_back_cards_with_delay()
	turns_taken += 1
	update_text()


func update_text():
	$"../CanvasLayer/score_label".text = "Score: %d" % score
	$"../CanvasLayer/turns_label".text = "Turns Taken: %d" % turns_taken


func put_back_cards_with_delay():
	await self.get_tree().create_timer(1.5).timeout
	for spot in revealed_spots:
		place_single_face_down_card(spot)
	revealed_spots.clear()
