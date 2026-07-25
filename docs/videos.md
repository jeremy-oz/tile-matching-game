# Companion video scripts

These are recording scripts for the eight short videos that accompany the
chapters. Each is written to run **2–3 minutes**. They are deliberately short:
the video shows *where to click*, the text explains *why*. Students who get lost
in the writing watch the video first, then follow the chapter.

## How to record these

You need nothing fancy. OBS Studio (free) or the built-in recorder on your
laptop is plenty.

- **Record at 1920 × 1080.** Godot's editor text is small; anything less and
  students on phones cannot read it.
- **Zoom the Godot editor** to 150% before recording: **Editor → Editor
  Settings → Interface → Editor → Display Scale**.
- **Say the node names out loud** as you click them. Students are pausing and
  copying, and they cannot always see what you selected.
- **Do not edit out your mistakes.** If you mistype and Godot shows an error,
  leave it in and fix it on camera. Watching someone read an error message and
  recover is one of the most useful things a beginner can see.
- **Stop talking at the end.** Leave two silent seconds before you cut, so the
  final state stays on screen.

The `[SHOW]` lines are the shot list — what should be on screen. The plain text
is what to say.

---

## Video 1 — Scenes and nodes (2:00)

**[SHOW] Godot Project Manager, empty**

> Let's make the project. Click Create, call it matching-game, and pick an
> empty folder. For Renderer, choose Compatibility — that's the one that runs on
> the widest range of machines, including old school laptops.

**[SHOW] Create & Edit, editor opens (0:25)**

> Here's the editor. Before we touch anything, one idea that everything in Godot
> is built on.

**[SHOW] Slow pan across the Scene panel (0:35)**

> A *node* is one thing that does one job — shows text, plays a sound, arranges
> things in a grid. A *scene* is a group of nodes saved as a file. And here's
> the trick: any scene can be used as a node inside another scene. We'll build
> one card, then use sixteen copies of it.

**[SHOW] Click Other Node, search "Control", create, rename to Game (1:00)**

> Other Node, search Control, create. Control is the base node for anything
> that's part of the interface. Rename it to Game — double-click the name.

**[SHOW] Anchor preset dropdown → Full Rect (1:20)**

> It's a tiny box in the corner. Up here is the anchor preset — choose Full
> Rect. Now it fills the window, and it keeps filling it if the player resizes.

**[SHOW] Add ColorRect child, rename Background, Full Rect, set colour (1:35)**

> Right-click Game, Add Child Node, ColorRect. Rename it Background, Full Rect
> again, and in the Inspector set the colour to something dark. 282C36.

**[SHOW] Ctrl+S saving as main.tscn, then F5 to run (1:50)**

> Save as main dot tscn. F5 to run, pick main as the main scene — and there's
> our dark window. Not a game yet. But the structure is right.

---

## Video 2 — Building a card (3:00)

**[SHOW] Scene → New Scene**

> A card has three jobs: show a front, hide it with a back, and be clickable.
> Three jobs, three nodes.

**[SHOW] Other Node → Button, rename Card (0:20)**

> The root is a Button. That surprises people — but a card is a thing you click,
> and Button already handles clicking, hovering, keyboard and touch. Reusing a
> node that nearly fits beats building from scratch.

**[SHOW] Custom Minimum Size → 150 x 140 (0:35)**

> Custom Minimum Size, 150 by 140. That's our card.

**[SHOW] Add VBoxContainer "Face", Full Rect, Alignment Center (0:50)**

> Add a VBoxContainer called Face. Full Rect, and set Alignment to Center. A
> VBox stacks its children vertically and does the positioning for us.

**[SHOW] Add TextureRect "Picture" and Label "Word", set properties (1:15)**

> Inside it, a TextureRect called Picture — Expand Mode Ignore Size, Stretch
> Mode Keep Aspect Centered, minimum height 62. And a Label called Word,
> centred both ways, font size 30.

**[SHOW] Select Face, Picture, Word in turn; set Mouse Filter to Ignore (1:45)**

> Now the thing everyone gets wrong. Select Face, Picture and Word, and set
> Mouse Filter to Ignore on each. If you skip this, they swallow the click and
> your card never notices it was pressed. Invisible bug, very annoying.

**[SHOW] Add Panel "Back" as child of Card, Full Rect, Mouse Ignore (2:10)**

> Back on the Card node — not inside Face — add a Panel called Back. Full Rect,
> Mouse Ignore. It comes after Face in the tree, and later siblings draw on top,
> so it covers the face completely.

**[SHOW] Theme Overrides → Styles → Panel → New StyleBoxFlat, blue, radius 10 (2:30)**

> One trap: Godot's default Panel is slightly see-through, so the words would
> show through. Theme Overrides, Styles, Panel, New StyleBoxFlat. Blue
> background, corner radius 10 on all four.

**[SHOW] Toggle Back's eye icon on and off (2:45)**

> Check it by toggling the eye. Hidden: white front. Visible: only blue. If you
> can read the front through the back, your style is still transparent.

**[SHOW] Save as scenes/card.tscn (2:55)**

> Save as scenes slash card dot tscn.

---

## Video 3 — Your first script (3:00)

**[SHOW] Card node selected, click Attach Script**

> Select Card, click Attach Script. Change the path to scripts slash card dot
> gd, and choose the Empty template — the default one is full of comments you'd
> only delete.

**[SHOW] Typing the first two lines (0:25)**

> `class_name Card`, `extends Button`. Extends means this script is on a Button,
> so it can do everything a Button does plus what we add. `class_name` lets other
> scripts refer to this type by name.

**[SHOW] Typing the three variables (0:45)**

> Three things to remember: `pair_id`, `is_face_up`, `is_matched`. `pair_id` is
> the important one — two cards match if their pair id is the same. Not if they
> *look* the same. That's what lets us match the word "dog" with a picture of a
> dog.

**[SHOW] Typing the @onready lines (1:20)**

> Now we reach the child nodes. Dollar sign, Face slash Word — like a file path,
> and it's case sensitive. `@onready` means "wait until this node is properly in
> the tree, then look these up". Without it you get a null error, because when
> the script starts existing the children don't yet.

**[SHOW] Typing _ready() and flip_up/flip_down (1:50)**

> `_ready` is called automatically by Godot, once, when the node is ready. You
> never call it yourself — that's what the underscore means.
>
> And then flipping. Look how simple this is: turning a card over is just hiding
> or showing the blue panel. Most game code is like this.

**[SHOW] Typing setup() (2:20)**

> `setup` fills in what the card shows. The `visible` lines mean a card with only
> a word doesn't leave a gap where the picture would be. And `ResourceLoader.exists`
> checks the file is really there before loading — skip that and one typo in a
> filename crashes everything.

**[SHOW] Typing mark_matched(), then save (2:45)**

> `disabled` is something Button already gives us — it stops responding to clicks
> and draws differently. Free, because we chose Button.

---

## Video 4 — Signals (2:30)

**[SHOW] card.gd open**

> The card gets clicked. Something needs to check for a match. The obvious idea
> is to have the card reach up and call the game directly — `get_parent`,
> `get_parent`, and so on. Don't. That breaks the moment you move anything, and
> the card can then only ever work in this one game.

**[SHOW] Typing `signal flipped(card: Card)` (0:30)**

> Signals are the fix. A signal is an announcement. The card shouts "I was
> clicked" and gets on with its life. It's a smoke alarm, not a phone call — it
> doesn't know or care who's listening.

**[SHOW] Adding pressed.connect(_on_pressed) in _ready() (0:55)**

> Button already has a `pressed` signal. We connect it to our own function.
>
> Notice: no brackets after `_on_pressed`. You're handing over the function
> itself, not calling it. Brackets there would run it immediately — very common
> typo, and the error message is confusing.

**[SHOW] Typing _on_pressed() (1:20)**

> The guard first: if it's already face up or matched, return, do nothing. Then
> `flipped.emit(self)`. `self` means "this card" — sixteen cards will all be
> shouting the same signal, so that's how the listener tells them apart.

**[SHOW] Adding a temporary print, pressing F6, clicking, Output panel (1:50)**

> Let's prove it works. Add a print. F6 runs just the current scene. Click —
> and there it is in the Output panel. The id is empty because nothing's called
> setup yet, and that's fine. We've proved the click reaches our code.

**[SHOW] Deleting the print line (2:20)**

> Delete the print. And by the way, print is a real debugging tool, not a
> beginner's crutch — professionals use it constantly.

---

## Video 5 — Building the board (3:00)

**[SHOW] main.tscn open**

> Now the good bit. We turn one card into sixteen, while the game is running.
> That's called instancing, and it's the most useful thing in Godot — enemies,
> bullets, inventory slots, all the same pattern.

**[SHOW] Building the layout: Margin, Columns, BoardArea, Board (0:45)**

> MarginContainer with 32 all round. Inside it an HBoxContainer. Then a
> CenterContainer set to Fill Expand, and inside that a GridContainer called
> Board with 4 columns and 12 separation.
>
> Notice I haven't typed a single x or y position. Containers do that maths.
> Hard-coded positions break the moment anything resizes.

**[SHOW] Adding SidePanel with labels and button (1:15)**

> A VBox for the side: ScoreLabel, TurnsLabel, MessageLabel, and a Button called
> RestartButton.

**[SHOW] Right-click Board → Access as Unique Name, repeat for others (1:35)**

> Right-click Board, Access as Unique Name. See the percent sign. Now I can
> write `%Board` instead of the whole path — and if I move things around later,
> it still works. Long node paths are one of the biggest sources of breakage.

**[SHOW] Attach board.gd, type the exports (2:00)**

> `@export var card_scene: PackedScene`. Export puts it in the Inspector.

**[SHOW] Dragging card.tscn into the Card Scene slot (2:15)**

> Save, select Board, and drag card dot tscn into the slot.

**[SHOW] Typing build() (2:40)**

> And here's the loop. Instantiate makes a copy. `add_child` puts it in the tree —
> **and that's when `_ready` runs**. Which means only now is it safe to call
> `setup`, because setup touches `word_label`, which didn't exist a second ago.
>
> Swap those two lines and you get a null error. Nearly everyone does this once.

---

## Video 6 — The rules (3:00)

**[SHOW] Attaching game.gd to the Game node**

> Now the game becomes playable.

**[SHOW] Typing the state variables (0:30)**

> `first_card` and `second_card` hold what's face up. Null means nothing yet —
> that's how we know if this is the first or second click of a turn.
>
> And `is_busy`. When two cards don't match we leave them visible for a moment.
> During that pause the player can still click — and without a guard they'd flip
> a third and a fourth and break everything. Any time you make a player wait,
> ask what happens if they click anyway.

**[SHOW] Typing _ready() with the two connections (1:00)**

> Connect to the *board's* signal. The game never touches an individual card.

**[SHOW] Typing _on_card_flipped() (1:30)**

> Read it as English. Ignore the click if we're busy. Turn the card over. If it's
> the first, remember it and wait. Otherwise count a turn and compare the ids.

**[SHOW] Typing _handle_mismatch(), highlighting the await line (2:10)**

> Here's the one to understand. `await get_tree().create_timer(1.2).timeout`
> means: pause *this function* for 1.2 seconds, then carry on. The rest of the
> game keeps running. If you instead wrote a loop that span for a second, the
> whole window would freeze.

**[SHOW] Highlighting is_instance_valid (2:35)**

> And during that pause, the player might hit New Game — which deletes these
> cards. So we check they still exist before touching them. General lesson:
> after an await, the world may have changed.

**[SHOW] F5, playing the game, matching a pair (2:50)**

> F5. Click two cards. Matches stay up and go green, the rest flip back. That's
> a game.

---

## Video 7 — Loading decks from CSV (3:00)

**[SHOW] The words array hard-coded in game.gd**

> Right now the words are typed into the code. To make a French deck you'd have
> to be a programmer. Let's fix that.

**[SHOW] A spreadsheet with pair, text, image columns (0:25)**

> CSV — comma separated values. Every spreadsheet program saves it. One row per
> card face, and cards sharing a `pair` value match each other.
>
> Look at these two rows: one shows the Spanish word and a picture, the other
> just the English word. Different faces, same pair. They match. That's the
> payoff from keeping `pair_id` separate from what's on screen.

**[SHOW] FileSystem → click the csv → Import tab → Keep File (No Import) → Reimport (1:00)**

> Now, important. Godot assumes CSV files are *translations* — it thinks your
> columns are languages. Click the file, Import tab, change to Keep File, No
> Import, Reimport. Do this for every deck you add. If your deck works in the
> editor but breaks when exported, this is why.

**[SHOW] Creating deck.gd, typing load_csv() (1:45)**

> `extends RefCounted` — the lightest thing a class can be. No position, not in
> the tree, just code.
>
> And `get_csv_line` is doing real work. You might think splitting on commas
> would do — but what about a card containing a comma? Quote it in the file, and
> get_csv_line returns it as one value, exactly like a spreadsheet. Split would
> chop it into four.

**[SHOW] Typing build(), highlighting keys.shuffle() (2:25)**

> Group by pair, shuffle the pair names, take what the board needs. Shuffling the
> *keys* matters — with twenty pairs and a board that needs eight, you get a
> different eight every game.

**[SHOW] Editing the CSV in a text editor, saving, re-running (2:45)**

> And here's the point. Change a word in the file. Save. Run. No code change, no
> Godot restart. A teacher can now make a deck in a spreadsheet.

---

## Video 8 — Make it yours (2:30)

**[SHOW] Inspector, changing rows and columns**

> Rows and columns are exported, so change them right here. Two rules: the total
> has to be even, and your deck needs at least that many pairs.

**[SHOW] Setting 3 x 3 and showing the error in Output (0:30)**

> Try 3 by 3 on purpose. Nine squares can't be filled with pairs, and the code
> tells you so in the Output panel. Read errors — they're usually telling you
> exactly what's wrong.

**[SHOW] Adding an image path to a CSV row, running (0:55)**

> Pictures: drop a file in the art folder and put its path in the image column.
> Leave text empty for picture-only.

**[SHOW] An SVG with text importing as a blank card (1:15)**

> One warning. If you draw an SVG with words in it, Godot imports it blank —
> its SVG reader doesn't do text. Convert to outlines in Inkscape, Path, Object
> to Path. Or just use the text column, which looks better anyway.

**[SHOW] A spreadsheet with times tables (1:35)**

> Now make your own. Times tables, chemical symbols, French verbs, fractions to
> decimals. The pair column never appears on screen — it's just a label tying two
> rows together.

**[SHOW] Scrolling the "Where to take it next" section (2:00)**

> There's a list of extensions in the chapter: a turn limit, a sound on match, an
> animated flip, a high score saved to a file, a deck chooser.
>
> Pick one. And don't look anything up until you've been stuck for ten minutes —
> getting unstuck is the actual job.
