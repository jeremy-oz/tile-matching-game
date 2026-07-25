class_name Board
extends GridContainer

## Lays the cards out in a grid. The Board builds cards and passes their clicks
## upwards; it does not know the rules of the game.

## Emitted when any card on the board is clicked while face down.
signal card_flipped(card: Card)

@export var card_scene: PackedScene
@export var card_size := Vector2(150, 140)


## Replace the board with a fresh set of cards.
func build(deck: Array, column_count: int) -> void:
	columns = maxi(1, column_count)
	clear()

	for entry in deck:
		var card: Card = card_scene.instantiate()
		card.custom_minimum_size = card_size
		# add_child() first so the card's @onready variables exist,
		# then fill in what it should show.
		add_child(card)
		card.setup(entry["pair"], entry["text"], entry["image"])
		card.flipped.connect(_on_card_flipped)


func clear() -> void:
	for child in get_children():
		child.queue_free()
		remove_child(child)


func cards() -> Array[Card]:
	var found: Array[Card] = []
	for child in get_children():
		if child is Card:
			found.append(child)
	return found


func _on_card_flipped(card: Card) -> void:
	card_flipped.emit(card)
