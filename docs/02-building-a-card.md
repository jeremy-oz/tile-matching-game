# 2. Building a card

**In this chapter:** you will build a Card as its own scene — one card, done
properly, ready to be copied 16 times later.

## What a card needs to do

Think about a real playing card face down on a table. It has:

- a **front** with something on it (a word, a picture, or both)
- a **back** that hides the front
- and it is **clickable**

That is three requirements, and they map straight onto three nodes.

## Start a new scene

**Scene → New Scene** from the menu. Then click **Other Node** and search for
`Button`.

!!! question "A Button? Really?"
    Yes. A card is a thing you click, and `Button` already handles clicking,
    hovering, keyboard focus and touch — all of which you would otherwise have
    to write yourself. Reusing a node that nearly fits is almost always better
    than building from scratch.

Rename the root node to `Card`.

In the **Inspector**, find **Custom Minimum Size** and set it to `150` × `140`.
This is how big each card will be.

## Add the front

Right-click `Card` → **Add Child Node** → `VBoxContainer`. Name it `Face`.

A `VBoxContainer` stacks its children **v**ertically and does the positioning
maths for you. Set its anchor preset to **Full Rect** so it covers the card, and
in the Inspector set **Alignment** to **Center**.

Now give `Face` two children:

1. **TextureRect**, named `Picture` — this shows an image.
   Set **Expand Mode** to `Ignore Size` and **Stretch Mode** to
   `Keep Aspect Centered`, and set its **Custom Minimum Size** height to `62`.
2. **Label**, named `Word` — this shows text.
   Set **Horizontal Alignment** and **Vertical Alignment** both to **Center**.
   Under **Theme Overrides → Font Sizes**, set **Font Size** to `30`.

### One easy thing to get wrong

Select `Face`, `Picture` and `Word` in turn and set **Mouse → Filter** to
**Ignore** for each.

If you skip this, these nodes will swallow the mouse click and your card will
never notice it was pressed. It is a classic beginner bug and it is invisible
until you wonder why clicking does nothing.

## Add the back

Right-click `Card` (not `Face`) → **Add Child Node** → `Panel`. Name it `Back`.

Set its anchor preset to **Full Rect** and its **Mouse → Filter** to **Ignore**.

`Back` comes *after* `Face` in the tree, and **later siblings are drawn on top**.
So `Back` covers `Face` completely — which is exactly what a face-down card is.

### Make the back opaque

Here is a trap. Godot's default `Panel` style is slightly see-through. If you
run the game now, the words underneath would show through faintly — and a
memory game where you can read the cards is not a game.

In the Inspector, under **Theme Overrides → Styles**, click the **Panel** slot
and choose **New StyleBoxFlat**. Click it to expand, then:

- **BG Color:** a solid blue, e.g. `4F78DB`
- **Corner Radius:** set all four corners to `10`

Do the same for the card front: select the `Card` node, and under
**Theme Overrides → Styles** set **Normal** to a new `StyleBoxFlat` with a
white background and corner radius `10`.

!!! tip "Check it properly"
    Toggle the little eye icon next to `Back` in the Scene panel to hide and
    show it. Hidden, you see the white front. Visible, you should see **only**
    blue. If you can make out the front through the back, the style is still
    transparent.

## Save it

Save as `scenes/card.tscn`. Godot will offer to create the `scenes` folder.

Your Card scene:

```
Card          (Button)      150x140, white StyleBoxFlat
├── Face      (VBoxContainer)   Full Rect, centred, mouse ignore
│   ├── Picture (TextureRect)   mouse ignore
│   └── Word    (Label)         font 30, centred, mouse ignore
└── Back      (Panel)       Full Rect, blue StyleBoxFlat, mouse ignore
```

You cannot run this scene as a game yet — it has no behaviour. That is the next
chapter.

## Check yourself

<quiz>
Why is the `Back` node placed *after* `Face` in the scene tree?
- [ ] Because Godot sorts nodes alphabetically
- [x] Because later siblings are drawn on top, so `Back` covers `Face`
- [ ] Because `Face` needs to load first
- [ ] It makes no difference where it goes

Draw order follows tree order for siblings. If `Back` came first, the face would
be drawn over it and the card would always look face up.
</quiz>

<quiz>
You click a card and nothing happens. Which is the most likely cause, given this chapter?
- [ ] The Button is disabled
- [x] A child node has Mouse Filter set to Stop and is swallowing the click
- [ ] The card is too small to click
- [ ] Buttons cannot be clicked inside containers

Any Control node sitting on top of the Button with Mouse Filter set to Stop will
absorb the click. Setting child nodes to Ignore lets the click pass through to
the Button underneath.
</quiz>

<quiz>
Which node stacks its children vertically and works out their positions for you?
- [ ] Panel
- [ ] TextureRect
- [x] VBoxContainer
- [ ] Control

Containers position their children automatically. `VBoxContainer` stacks
vertically, `HBoxContainer` horizontally, and `GridContainer` — which you will
meet in Chapter 5 — in a grid.
</quiz>

## Where you are

```
matching-game/
├── main.tscn
└── scenes/
    └── card.tscn      Card (Button)
                       ├── Face (VBoxContainer)
                       │   ├── Picture (TextureRect)
                       │   └── Word (Label)
                       └── Back (Panel)
```

[Chapter 3: Your first script →](03-your-first-script.md)
