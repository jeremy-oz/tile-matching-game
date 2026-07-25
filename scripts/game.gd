extends Control

## The rules. Holds the score, decides whether two flipped cards match, and
## flips them back when they do not.

@export_file("*.csv") var deck_path := "res://decks/spanish.csv"
@export var rows := 4
@export var columns := 4
## How long a mismatched pair stays visible, in seconds.
@export var flip_back_delay := 1.2

var score := 0
var turns := 0
var pairs_to_find := 0

var first_card: Card = null
var second_card: Card = null
## True while a mismatched pair is being shown, so extra clicks are ignored.
var is_busy := false

@onready var board: Board = %Board
@onready var score_label: Label = %ScoreLabel
@onready var turns_label: Label = %TurnsLabel
@onready var message_label: Label = %MessageLabel


func _ready() -> void:
	board.card_flipped.connect(_on_card_flipped)
	%RestartButton.pressed.connect(start_new_game)
	start_new_game()


func start_new_game() -> void:
	score = 0
	turns = 0
	first_card = null
	second_card = null
	is_busy = false
	message_label.text = ""

	var total_cards := rows * columns
	if total_cards % 2 != 0:
		push_error("A %dx%d board has %d squares, which cannot be filled with pairs"
			% [rows, columns, total_cards])
		return

	pairs_to_find = total_cards / 2
	var all_cards := Deck.load_csv(deck_path)
	var deck := Deck.build(all_cards, pairs_to_find)
	pairs_to_find = deck.size() / 2

	board.build(deck, columns)
	update_labels()


func _on_card_flipped(card: Card) -> void:
	if is_busy or card.is_face_up or card.is_matched:
		return

	card.flip_up()

	if first_card == null:
		first_card = card
		return

	second_card = card
	turns += 1

	if first_card.pair_id == second_card.pair_id:
		_handle_match()
	else:
		await _handle_mismatch()

	update_labels()
	_check_for_win()


func _handle_match() -> void:
	first_card.mark_matched()
	second_card.mark_matched()
	score += 1
	_clear_selection()


func _handle_mismatch() -> void:
	is_busy = true
	await get_tree().create_timer(flip_back_delay).timeout
	# The board may have been rebuilt while we were waiting.
	if is_instance_valid(first_card):
		first_card.flip_down()
	if is_instance_valid(second_card):
		second_card.flip_down()
	_clear_selection()
	is_busy = false


func _clear_selection() -> void:
	first_card = null
	second_card = null


func _check_for_win() -> void:
	if pairs_to_find > 0 and score >= pairs_to_find:
		message_label.text = "All pairs found in %d turns!" % turns


func update_labels() -> void:
	score_label.text = "Score: %d" % score
	turns_label.text = "Turns Taken: %d" % turns
