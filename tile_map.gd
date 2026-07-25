extends Node2D

var board_size = 4
var SOURCE_NUM = 0
const hidden_tile_coords = Vector2i(6,2)
const hidden_tile_alt = 1
var revealed_spots = []
var tile_pos_to_atlas_pos = {}
var score = 0
var turns_taken = 0

# Each board layer is its own TileMapLayer node. "hidden" draws on top of
# "revealed" (see its z_index in tile_map.tscn), so erasing a hidden cell
# uncovers the card underneath it.
@onready var hidden_layer: TileMapLayer = $hidden
@onready var revealed_layer: TileMapLayer = $revealed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_board()
	update_text()

func get_tiles_to_use():
	var chosen_tile_coords = []
	var options = range(10)
	options.shuffle()
	for i in range(board_size * int(board_size / 2)):
		var current = Vector2i(options.pop_back(), 1)
		for j in range(2):
			chosen_tile_coords.append(current)
	chosen_tile_coords.shuffle()
	return chosen_tile_coords

func setup_board():
	var cards_to_use = get_tiles_to_use()
	for y in range(board_size):
		for x in range(board_size):
			var current_spot = Vector2i(x, y)
			place_single_face_down_card(current_spot)
			var card_atlas_coords = cards_to_use.pop_back()
			tile_pos_to_atlas_pos[current_spot] = card_atlas_coords
			revealed_layer.set_cell(current_spot, SOURCE_NUM, card_atlas_coords)


func place_single_face_down_card(coords: Vector2i):
	hidden_layer.set_cell(coords, SOURCE_NUM, hidden_tile_coords, hidden_tile_alt)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			var pos_clicked = hidden_layer.local_to_map(hidden_layer.to_local(global_clicked))
			print(pos_clicked)
			var current_tile_alt = hidden_layer.get_cell_alternative_tile(pos_clicked)
			if current_tile_alt == hidden_tile_alt and revealed_spots.size() < 2:
				hidden_layer.erase_cell(pos_clicked)
				revealed_spots.append(pos_clicked)
				if revealed_spots.size() == 2:
					when_two_cards_revealed()

func when_two_cards_revealed():
	# the cards match
	if tile_pos_to_atlas_pos[revealed_spots[0]] == tile_pos_to_atlas_pos[revealed_spots[1]]:
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
