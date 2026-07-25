# 4. Signals

**In this chapter:** you will make the card announce when it has been clicked —
without it needing to know anything about the game around it.

## The problem signals solve

The card gets clicked. Something needs to happen: check whether it matches the
last card, update the score, maybe flip both back over.

The obvious idea is to have the card just... do that. Reach up to the game and
call `get_parent().get_parent().check_match(self)`.

Do not do this. It breaks the moment you move the card somewhere else in the
tree, and it means the Card can only ever be used in this one game. You have
glued two things together that should be able to change independently.

**Signals** are the fix. A signal is an announcement. The card shouts "I was
clicked!" into the room and carries on with its life. Whoever cares is
listening. If nobody is listening, nothing breaks.

!!! quote "The mental model"
    A signal is a smoke alarm, not a phone call. The alarm does not know or care
    who is listening — it just goes off.

## Declare the signal

At the top of `card.gd`, under `extends Button`:

```gdscript
signal flipped(card: Card)
```

That line creates a new signal called `flipped` which carries one piece of
information: which card it was. Without that, a listener would hear "a card was
clicked" and have no idea which one.

## Emit it when clicked

`Button` already has a built-in signal called `pressed`. We listen to that, and
turn it into our own signal. Add to `_ready()`:

```gdscript
func _ready() -> void:
	pressed.connect(_on_pressed)
	flip_down()
```

`pressed.connect(_on_pressed)` means "when the `pressed` signal fires, run my
function called `_on_pressed`".

Note there are no brackets after `_on_pressed`. You are handing over the
function *itself*, not calling it. `_on_pressed()` with brackets would run it
immediately and pass the result — a very common typo.

Now write that function:

```gdscript
func _on_pressed() -> void:
	if is_face_up or is_matched:
		return
	flipped.emit(self)
```

Three things worth noticing:

- The guard comes first. A card already face up, or already matched, ignores the
  click entirely. Handling the "do nothing" cases early keeps the rest simple.
- `return` with nothing after it means "stop running this function now".
- `flipped.emit(self)` fires our signal. `self` means "this card" — that is how
  the listener knows which one.

!!! tip "Why not flip the card here?"
    Because the *card* should not decide whether it is allowed to turn over —
    that depends on the rules of the game, like whether two cards are already
    face up. The card reports; the game decides. Keeping that split clean is
    what makes the code easy to change later.

## Test it

Add a temporary line to prove the signal fires:

```gdscript
func _on_pressed() -> void:
	if is_face_up or is_matched:
		return
	print("clicked: ", pair_id)
	flipped.emit(self)
```

Open `scenes/card.tscn` and press ++f6++ — that runs the *current* scene rather
than the whole game. Click the card. Look at the **Output** panel at the bottom
of the editor: you should see `clicked: ` each time.

It prints an empty id because nothing has called `setup()` yet. That is fine —
you have proved the click reaches your code, which is the point.

Delete the `print` line once you have seen it work.

!!! note "`print()` is a real debugging tool"
    Not a beginner crutch. When something is not behaving, putting a `print()`
    in to see whether a function runs at all — and what the values are — is
    often the fastest way to find the problem. Professionals do this constantly.

## The whole file

`scripts/card.gd`:

```gdscript
class_name Card
extends Button

signal flipped(card: Card)

var pair_id := ""

var is_face_up := false
var is_matched := false

@onready var word_label: Label = $Face/Word
@onready var picture: TextureRect = $Face/Picture
@onready var back: Panel = $Back


func _ready() -> void:
	pressed.connect(_on_pressed)
	flip_down()


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


func mark_matched() -> void:
	is_matched = true
	disabled = true


func _on_pressed() -> void:
	if is_face_up or is_matched:
		return
	flipped.emit(self)
```

The Card is now finished. You will not need to change it again.

## Check yourself

<quiz>
What is the main advantage of a signal over calling the parent's function directly?
- [ ] Signals run faster
- [x] The card does not need to know what is listening, so it can be reused anywhere
- [ ] Signals can carry more data
- [ ] Godot requires signals for all clicks

A signal leaves the card independent. Move it, reuse it in another game, or
listen to it from somewhere else entirely — none of that requires changing the
card's code.
</quiz>

<quiz>
What is wrong with `pressed.connect(_on_pressed())`?
- [ ] Nothing, it is correct
- [x] The brackets call the function immediately instead of handing it over
- [ ] `connect` should be `emit`
- [ ] `pressed` needs to be declared as a signal first

`connect` wants the function itself, so you write its name with no brackets.
Adding brackets runs it there and then and passes whatever it returned.
</quiz>

<quiz>
Why does `_on_pressed()` pass `self` when emitting?
- [ ] To make the signal fire faster
- [ ] Because `emit` always needs an argument
- [x] So the listener knows *which* card was clicked
- [ ] To stop the card being clicked twice

The signal was declared as `flipped(card: Card)`, so it carries a card with it.
Sixteen cards will all be shouting the same signal; `self` is how the listener
tells them apart.
</quiz>

<quiz>
Sending a signal out is done with `flipped.[[emit]](self)`.

---

`emit` fires the signal. Everything currently connected to it runs, in the order
it was connected.
</quiz>

[Chapter 5: Building the board →](05-building-the-board.md)
