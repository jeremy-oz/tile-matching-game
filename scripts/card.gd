class_name Card
extends Button

## A single card. It knows which pair it belongs to, shows a word and/or a
## picture, and can be face up or face down. It does NOT decide whether two
## cards match - that is the Game's job. The card only reports being clicked.

## Emitted when the player clicks this card while it is face down.
signal flipped(card: Card)

## Cards with the same pair_id match each other. Two cards in a pair can show
## completely different things - a word and a picture, or a word and its
## translation - because matching compares this id, not what is on screen.
var pair_id := ""

var is_face_up := false
var is_matched := false

@onready var word_label: Label = $Face/Word
@onready var picture: TextureRect = $Face/Picture
@onready var back: Panel = $Back


func _ready() -> void:
	# Button already emits "pressed" for us; we turn that into our own signal
	# so the Game does not need to know a Card is a Button.
	pressed.connect(_on_pressed)
	flip_down()


## Fill in what this card shows. Call this AFTER add_child(), because the
## @onready variables above are not ready until the node enters the tree.
func setup(id: String, text: String, image_path: String) -> void:
	pair_id = id

	word_label.text = text
	word_label.visible = text != ""

	var has_image := image_path != "" and ResourceLoader.exists(image_path)
	if has_image:
		picture.texture = load(image_path)
	picture.visible = has_image


func flip_up() -> void:
	is_face_up = true
	back.hide()


func flip_down() -> void:
	is_face_up = false
	back.show()


## Matched cards stay face up and stop responding to clicks.
func mark_matched() -> void:
	is_matched = true
	disabled = true


func _on_pressed() -> void:
	if is_face_up or is_matched:
		return
	flipped.emit(self)
