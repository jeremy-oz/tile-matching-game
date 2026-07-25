# 3. Your first script

**In this chapter:** you will give the card behaviour — the ability to turn
face up and face down.

## Attach a script

Open `scenes/card.tscn`. Select the `Card` node, and click the **Attach Script**
icon above the Scene panel (a scroll with a `+`).

- **Path:** change it to `res://scripts/card.gd`
- **Template:** choose **Empty** — the default template fills the file with
  comments you will only delete

Click **Create**. Godot switches to the Script editor.

!!! info "What is `res://`?"
    It means "the root of this project". Godot uses it instead of a normal file
    path so your game works the same on Windows, Mac and Linux, and after it is
    exported. Get used to seeing it.

## The first two lines

Type this at the top:

```gdscript
class_name Card
extends Button
```

`extends Button` says: this script is attached to a Button, so it can do
everything a Button does, plus whatever we add.

`class_name Card` gives our type a name. This means that elsewhere in the
project we can write `var c: Card` and Godot will know what we mean — and will
tell us off if we make a typo. It is optional, but it makes the rest of the
course much less error-prone.

## Remembering things: variables

A card needs to remember three things:

```gdscript
var pair_id := ""

var is_face_up := false
var is_matched := false
```

`pair_id` is the important one. **Two cards match if their `pair_id` is the
same.** Not if they look the same — if their id is the same.

That distinction is what lets you match the word "dog" with a *picture* of a
dog, or "6 × 7" with "42". The two cards show completely different things but
share an id, so the game counts them as a pair. Keep that in mind; it pays off
in Chapter 7.

!!! note "`:=` versus `=`"
    `var x := ""` means "make a variable called `x`, and work out its type from
    the value". Since `""` is text, `x` is now a `String` forever. Try to put a
    number in it later and Godot will stop you — which is a *good* thing,
    because it catches mistakes early.

## Reaching the child nodes

Our script is on the `Card` node, but the text lives on the `Word` node
underneath it. We need a way to reach it:

```gdscript
@onready var word_label: Label = $Face/Word
@onready var picture: TextureRect = $Face/Picture
@onready var back: Panel = $Back
```

`$Face/Word` means "the child called `Face`, then *its* child called `Word`".
It is the same shape as a file path, and it is case-sensitive — `$face/word`
will not work.

`@onready` matters. When your script first starts existing, its child nodes do
not exist yet. `@onready` says "wait until this node is properly in the scene
tree, *then* look these up". Without it you get a crash that says
`Cannot call method 'get_node' on a null value`, which is Godot's way of saying
"you asked too early".

## `_ready()`

```gdscript
func _ready() -> void:
	flip_down()
```

`_ready()` is a function Godot calls automatically, once, when the node has
entered the scene tree and is ready to go. It is where setup goes.

You never call `_ready()` yourself. Godot calls it for you. Functions like this
that Godot calls automatically start with an underscore.

## Flipping

Now the two functions that do the actual work:

```gdscript
func flip_up() -> void:
	is_face_up = true
	back.hide()


func flip_down() -> void:
	is_face_up = false
	back.show()
```

Read those again — they are almost embarrassingly simple. Turning a card over is
just hiding or showing the blue panel that covers it. Most game code is like
this: a small, obvious change to something you can see.

## Filling in the card

One more function, to put content on the card:

```gdscript
func setup(id: String, text: String, image_path: String) -> void:
	pair_id = id

	word_label.text = text
	word_label.visible = text != ""

	var has_image := image_path != "" and ResourceLoader.exists(image_path)
	if has_image:
		picture.texture = load(image_path)
	picture.visible = has_image
```

The `visible` lines mean a card with only a word does not leave an empty gap
where the picture would be, and vice versa. That is how one Card scene handles
words, pictures, or both.

`ResourceLoader.exists()` checks a file is really there before loading it. Skip
that check and one typo in a filename crashes the whole game.

## Marking a match

```gdscript
func mark_matched() -> void:
	is_matched = true
	disabled = true
```

`disabled` is a property `Button` already has — setting it stops the card
responding to clicks, and Godot draws it differently so the player can see it is
done. We got that for free by choosing `Button` in Chapter 2.

## The whole file

Your `scripts/card.gd` should now look like this:

```gdscript
class_name Card
extends Button

var pair_id := ""

var is_face_up := false
var is_matched := false

@onready var word_label: Label = $Face/Word
@onready var picture: TextureRect = $Face/Picture
@onready var back: Panel = $Back


func _ready() -> void:
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
```

!!! warning "Indentation is not decoration"
    GDScript uses indentation to decide what is inside a function. Every line
    inside a `func` must be indented by one tab. Mixing tabs and spaces causes
    errors that are hard to spot — let the editor insert tabs and do not fight
    it.

Save. The card still does nothing when clicked, because nothing is listening.
That is Chapter 4.

## Check yourself

<quiz>
Why do the node lookups use `@onready`?
- [ ] It makes the game load faster
- [x] Child nodes do not exist yet when the script is first created, so the lookup must wait
- [ ] It is required for all variables in GDScript
- [ ] It stops other scripts changing the variable

`@onready` delays the lookup until the node has entered the scene tree. Without
it, `$Face/Word` runs too early and gives you `null`.
</quiz>

<quiz>
Two cards are considered a match when...
- [ ] they show the same word
- [ ] they show the same picture
- [x] their `pair_id` values are the same
- [ ] they were clicked one after the other

Matching on an id rather than on appearance is what lets a word card pair with a
picture card, or a times-table question pair with its answer.
</quiz>

<quiz>
Which function does Godot call automatically when a node is ready to use?
- [ ] `setup()`
- [ ] `start()`
- [x] `_ready()`
- [ ] `main()`

`_ready()` runs once, after the node enters the scene tree. You never call it
yourself. The leading underscore is the convention for functions Godot calls for
you.
</quiz>

<quiz>
Turning a card face up is done by calling `back.[[hide]]()`.

---

Flipping a card over is nothing more than hiding or showing the panel that
covers its face. Small, visible changes like this are what most game code is
made of.
</quiz>

[Chapter 4: Signals →](04-signals.md)
