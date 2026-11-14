# Aren Vale — Blue Lantern Idle Sprite Pack (Task 2 draft)

## What is an actual gameplay asset?

- `assets/characters/aren/idle/aren_idle_down.png` — 64 × 64 RGBA idle frame, face south
- `assets/characters/aren/idle/aren_idle_up.png` — 64 × 64 RGBA idle frame, face north
- `assets/characters/aren/idle/aren_idle_left.png` — 64 × 64 RGBA idle frame, face west
- `assets/characters/aren/idle/aren_idle_right.png` — 64 × 64 RGBA idle frame, face east
- `assets/characters/aren/idle/aren_idle_spritesheet.png` — 256 × 64 RGBA atlas; columns **down, up, left, right**

These are **actual importable gameplay PNGs**, not merely references. They are a **review draft**, not final approved artwork. Idle is one static frame per direction.

## What is reference art?

- `references/aren_reference_{down,up,left,right}_blue.png` are large **blue-lantern character design references**. Never use them as 64 × 64 gameplay frames.
- `references/aren_original_design_approved_legacy_amber.png` archives the original approved character design, whose lantern has the older amber color. The new blue variants supersede its lantern color only.

## Godot 4 quick integration

- Use `AnimatedSprite2D` with `SpriteFrames`, frame size 64 × 64, 1 idle frame per direction.
- Sprite texture filtering `Nearest`, not linear.
- Sprite visual center and collision footprint are independent. Do not size collisions from alpha bounds.
- For an actual **blue emission/glow**, add a `PointLight2D` or lightweight material/effect at the lantern offset. The PNG has bright glass pixels but no broad pre-baked bloom.
- **Lore note:** Aren's magical lantern can be blue while the canonical *beacon states* remain **white** (old suppression) and **amber** (Witness Rite). They are different light systems.

## Known review limitations

- Existing side-facing body/armor frames were derived from a mirrored base and may need a later directional asymmetry cleanup, especially for equipment placement.
- The blue lantern is a direct pixel edit to the established small sprites; visual readability should be checked in Godot at actual display scale.
- Do not mark Task 2 complete until the user approves.
