# The Last Lightkeeper — Codex Visual Implementation Guide

**Purpose:** Repository-facing implementation rules for Codex to build cohesive Godot 4 screens, placeholder-ready gameplay scenes, and native visual effects without needing final PNG assets.

**Status:** Pre-production implementation guidance · 2026-11-11.

## 1. Authority and boundaries

Read these repository files together:
1. `The_Last_Lightkeeper_Game_Design.md` — gameplay systems, approved scope, three-region structure.
2. `The_Last_Lightkeeper_Story.md` — canonical characters, story order, scene IDs, clues, dialogue anchors, flags, outcomes.
3. `The_Last_Lightkeeper_Visual_and_Asset_Plan.md` — intended look, screen inventory, planned art assets, placeholder contracts.

**This document covers implementation, not asset generation.** Do **not** generate finished PNGs, AI image prompts, story illustrations, sprite sheets, or asset-generation checklists unless separately and explicitly requested. Implement screens and effects with Godot-native nodes, simple temporary visuals, and swappable texture references. Missing art must never block gameplay or story progression.

When asked to implement one feature, change only the relevant scene(s), scripts, and resources. Do not attempt to build the entire game in one agent task. Preserve existing project conventions and working scenes where possible.

## 2. Approved presentation and provisional scale

- Desktop-first, **top-down 2D** dark fantasy; medium-detail pixel-art target; **four-direction** character facing.
- UI: minimal exploration HUD, portrait dialogue, reusable story/memory overlay, atmospheric lightweight main menu and chapter transitions.
- World: three regional scene roots (`forest`, `village`, `sanctuary`) with reusable subareas and interiors; use `TileMapLayer` for modular tilemaps in Godot 4 versions supporting it.
- Starting values are **provisional**, not finalized: 640×360 logical 16:9 viewport, 32×32 tiles, 48×48 humanoid sprite frames, ~256×256 portraits, 16:9 stills. Do not hardcode screen dimensions into gameplay scripts.
- Keep nearest-neighbor filtering on pixel sprites. Scale/layout for desktop resolutions, readable fonts, and unclipped controls. Layer darkness without hiding enemy warnings or interaction targets.
- **White and amber beacon states must be distinct**, tied to story flags rather than purely aesthetic timers.

## 3. Reusable screen architecture

Build a shared game scene and reusable UI components rather than one bespoke interface for every story ID. Names below are descriptive suggestions, not mandatory API names.

| UI role | Suggested Godot composition | Requirements |
|---|---|---|
| Main menu | `Control` + background `TextureRect`/`Sprite2D`, `VBoxContainer`, Godot `Theme` | New Game, Continue only when save exists, Settings, Quit; animate optional fog/glow via Godot |
| Gameplay HUD | `CanvasLayer` + `Control`, bars/labels, interaction prompt | Health, lantern availability, current objective, nearby interaction; don't cover center of view |
| Dialogue | `CanvasLayer`/`Control` + `PanelContainer`, portrait slot, name label, `RichTextLabel` | Text advances, input can be disabled during combat, supports missing portrait and Voice dialogue |
| Memory/story | Reusable fullscreen `Control` + optional still `TextureRect`, `ColorRect`, text, `AnimationPlayer` | Fade in/out, optional image, anchored narrative lines; return safely to gameplay |
| Inventory/equipment | `Control`, grids/lists, selection details | Item icon fallback, quantities, equipment display; avoid image-dependent hit testing |
| Journal/clues | `TabContainer` or equivalent, objective/clue lists, detail text | Permanent clue entries and story flags; optional thumbnails only |
| Crafting | Workbench-triggered UI with recipe list/material amounts/output | Only unlocked when story permits; reusable for all regions |
| Boss HUD | Reusable boss health panel and name label | Activated by actual boss state; telegraph attacks in world coordinates |
| Pause/settings | Reusable modal/panel | Pause/unpause safely; Resume, Save, Settings, Main Menu |
| Death/retry | Overlay, fade/tint, retry and menu actions | Checkpoint/save recovery; never strand player behind UI |
| Chapter transition | Fade plus text layer | Trigger by story progression and region load; short, skippable if appropriate |
| Epilogue/credits | Reuse memory/story overlay and text scroller | Correct canonical ending, credits, then postgame available |

The 12 roles above do **not** require 12 separate gameplay scenes. Use smaller reusable `.tscn` UI components that work on every map.

### Navigation and game-state expectations

`Main Menu → New Game / Continue → gameplay`; gameplay can open Dialogue, Memory, Inventory, Journal, Crafting, Pause, Boss HUD, or Death as appropriate; chapter transitions swap region/subarea scenes; final epilogue unlocks postgame.

- Manage player input modes centrally (`gameplay`, `dialogue`, `menu`, `memory`, `dead` or equivalent). Prevent attacks/movement while blocking overlays are active.
- Inventory, journal, and pause should stop active combat or otherwise ensure player safety while open; reopening/closing must not duplicate input events.
- Store objective, dialogue, clue, beacon, and quest progression in shared state/save data. UI reads that state; UI itself should not be the source of truth.
- Use the Story file's `C1-*`, `C2-*`, `C3-*` IDs and requirements. For `C1-S01` through `C3-S10`, follow canonical prerequisites, events, and flags; never infer missing story requirements from this visual guide.
- At least one local save slot should persist region/position, chapter, quests, clues, equipment, NPC state when needed, bosses, and beacon colors. Story overlays shouldn't replay on load unless required by the underlying flags.

## 4. Placeholder asset contract

Codex is expected to implement functionality **before** art is delivered.

- Use clearly labeled placeholders: `ColorRect`, `Polygon2D`, `GradientTexture2D`, simple procedural `ImageTexture` created at runtime, or temporary **project-local** art already present. Choose whichever is simplest and stable in the current scene.
- Do not require external placeholder image downloads, new plugins, or generated PNG files to make scenes run.
- Define swappable sprite/portrait/still references through exported textures, resource definitions, or scene-local `TextureRect`/`Sprite2D` nodes. Final PNGs should replace a texture resource, not require rewriting feature logic.
- Sprite origins/pivots should be consistent, normally centered on the actor's feet for world placement; render scale and collision sizes must be configurable independently.
- Give placeholder characters visually distinct silhouettes/colors/labels so Aren, NPCs, enemies, and bosses are distinguishable during testing.
- Use visible, meaningful default UI content even without portraits, illustrations, or icons. A missing portrait must never suppress dialogue.
- Handle absent textures/null resources safely with a fallback shape/color and no runtime errors.
- Animation state names should remain stable (`idle`, `walk`, `attack`, `charge`, etc.) even if early visuals use frame reuse or simple tweening.

### Suggested resource paths (adapt to an existing repository, do not restructure blindly)

```text
res://assets/characters/{player,npcs,enemies,bosses}/
res://assets/environments/{shared,forest,village,sanctuary}/
res://assets/portraits/
res://assets/story_stills/
res://assets/items/
res://scenes/{menus,ui,player,characters,enemies,bosses,regions,narrative}/
res://scripts/{systems,combat,interactions}/
res://data/{dialogue,quests,items,enemies}/
```

Keep asset identity separate from literal file paths. Asset names/expected slots are documented in the visual plan; those files may **not** exist yet.

## 5. Godot-native visual systems — implementation guidance

**UI and screen composition**
- Prefer `Control`, `Container`, `CanvasLayer`, `Theme`, `StyleBoxFlat`, `TextureProgressBar`, `RichTextLabel`, and `AnimationPlayer`/`Tween` for layout and behavior.
- Build scalable nine-patch-like panel styling with Godot styles instead of PNG panel images. Keep small visual vocabulary: charcoal/slate backgrounds, restrained warm amber accents, readable off-white text.
- UI should be accessible at the target viewport: sufficient contrast, responsive anchors, keyboard navigation for menus, and text unaffected by missing art.
- Reuse one modal/dialogue style across all NPCs/chapters; text and narrative flags belong in data, not in graphics.

**Lantern and lighting**
- Use `PointLight2D`/`CanvasModulate`/light textures or a simple `ShaderMaterial` as appropriate for the project's Godot version. Share a single lantern pulse effect across combat, clue revealing, and mechanisms.
- Pulse feedback must correspond to **actual** hit/reveal/interact logic; visuals alone must not determine collision or combat results.
- White (`suppression`) and amber (`witnessed`) beacon presentation can reuse the same sprite/landmark while switching modulate, light color, emission, and particles based on saved flags.
- Prefer simple reproducible light effects rather than expensive full-screen shader stacks; preserve sightlines under dark overlays.

**Combat, enemies, and bosses**
- Separate `CollisionShape2D`, hurtboxes/hitboxes, attack arcs, AI state, and damage logic from visual sprites.
- Use `Polygon2D`, `Line2D`, basic circles/arcs, particles, or simple shader overlays for warning zones and attack trails; timed telegraphs must match actual attack activation.
- Hit flash, stagger, knockback, charge windup, and dodge can initially be built via `AnimationPlayer`/tweens and shared effects; final animation sheets can replace the look later.
- Reuse a shared enemy framework with per-type configuration. The **six** standard enemies and **three** canonical boss encounters remain distinct in behavior/presentation; don't create unrelated combat engines.
- Boss HUD overlays the normal gameplay scene; each boss's vulnerability and lantern response should be legible.

**Environments and interactions**
- Use `TileMapLayer` and reusable atlas tiles for most walkable scenes; region-specific atlases and landmarks are eventual art inputs.
- Initially build graybox layouts with clear collision boundaries, entrances, clue/NPC nodes, exits, and trigger regions. Avoid a single uneditable baked full-map background.
- Build large illustrated landmarks as separate `Sprite2D` or layered nodes with independently authored collisions and interactables. Do not place functional controls in an illustration.
- Use lightweight fog/particles and ambient sound hooks if available, but do not let missing effects or audio block scene loading.
- Clues, workbenches, waystones, exits, and other objects should implement a reusable interaction interface (or signals); their visual texture is interchangeable.

**Story presentation**
- Regular scenes use portrait dialogue. Memory/reveal scenes may use a full still if it exists, or a solid/tinted background with text and an optional portrait if it does not.
- The opening shelter, the Black Vigil document, Eva's scarf memory, the Stranger reveal, and the ending are important presentation beats, but final art is **optional at implementation time**.
- For story-critical text (e.g., Black Vigil names, authorizations, dialogue anchors), render native text with the exact canonical content. Never rely on generated art to carry important information.
- Effects such as memory desaturation, ghost/translucent waystone projection, white-to-amber light changes, and chapter fades should be reusable parameterized scenes/animations.

## 6. Story continuity that visual code must preserve

| Moment | Required visual-state behavior |
|---|---|
| `C1-S09` | Forest beacon becomes **WHITE**, not amber; Mira loses part of a treasured memory |
| `C2-S09` | Village beacon becomes **AMBER** as the bell rings and memories are witnessed |
| `C2-S10` | The lantern Voice is revealed as Vaela (not an unrelated entity) |
| `C3-S01` | Forest beacon becomes **AMBER** after Mira's testimony at the memorial |
| `C3-S06` | Ashen Stranger is a projection of **Aren's own recordings**, not another person |
| `C3-S08` | Vaela boss is defeated but **remains alive** |
| `C3-S09` | Sanctuary beacon becomes **AMBER**, extraction stops, and memories return safely |
| `C3-S10` | Canonical ending followed by credits and unlocked postgame; ordinary night remains |

For exact trigger conditions, clue IDs, canonical dialogue anchors, and order, consult the Story file. Its details supersede abbreviated notes here.

## 7. Coding constraints and acceptance expectations

- Deliver small, runnable vertical slices; prioritize functional `C1-S01` and core reusable screens before broad content implementation.
- Scenes must run with missing sprites/portraits/stills; do not add load failures or blocking references to uncreated PNGs.
- Put configurable HUD values, styles, sprite scale, region transitions, animation parameters, and visual resources outside hardcoded narrative/combat conditionals where practical.
- Verify pause/unpause, overlay opening/closing, keyboard controls, missing-image fallbacks, scene transitions, save/load, and story-flag consistency when touching these systems.
- Do not silently introduce new story canon, extra regions, mandatory quests, a minimap, dialogue branches changing the canonical ending, or new asset-generation work.
- This guide does **not** assign Codex responsibility for designing or producing final art. A teammate will provide approved PNG assets separately; implementation should accept them without reworking game logic.
