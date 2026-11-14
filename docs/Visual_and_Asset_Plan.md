# The Last Lightkeeper — Visual, Screen & Asset Plan

**Purpose:** Shared visual-design reference documenting the agreed screen flow, art direction, sprites, and planned assets, including the specifications needed to create artwork later or work with temporary placeholders now.

**Status:** Pre-production specification · 2026-11-11 · No assets are claimed to exist.

**Sources of truth:** `The_Last_Lightkeeper_Game_Design.md` governs gameplay scope; `The_Last_Lightkeeper_Story.md` governs scene order, characters, clues, story flags, and outcomes. This document governs **presentation and proposed art requirements** only. If a story detail differs, the Story file wins. Values labeled *provisional* can change after in-engine visual testing.

## 1. Approved visual direction

| Decision | Agreed direction |
|---|---|
| Perspective / platform | Top-down 2D, desktop-first, Godot 4 |
| Primary art | Medium-detail **pixel art** with consistent pixel density |
| Movement | Four-direction facing/movement; essential animation only |
| World | Three distinct semi-open regions made from **modular tiles + selected landmark illustrations** |
| Mood | **Dark and atmospheric**; readable foregrounds and high-contrast lantern/beacon light |
| Storytelling | **Portrait-driven dialogue** and a small number of illustrated memory/story stills |
| Main menu / chapters | Atmospheric but lightweight; modest layered animation and fades, not elaborate cinematics |
| HUD | Minimal immersive HUD; detailed information in overlays |
| Production | Efficiency-first hybrid: AI-produced PNGs when illustration is required; Godot-native UI, effects, composition, and transformations |

**Color/story continuity:** Old beacon light is **white** (and potentially harmful); Witness Rite light is **amber**. Forest beacon: dim → **WHITE** at `C1-S09` → **AMBER** at `C3-S01`; village beacon **AMBER** at `C2-S09`; Sanctuary beacon **AMBER** at `C3-S09`. Ordinary nighttime is not the Hush.

### Provisional dimensions and visual rules

| Element | Initial target | Notes |
|---|---|---|
| Logical viewport | 640 × 360, 16:9 | Render/scaling strategy to be validated on desktop |
| Ground tile grid | 32 × 32 px | Atlases must align to this grid |
| Aren and most humanoid sprite frames | 48 × 48 px canvas | Visual body can occupy less; feet/origin consistent |
| Larger creatures | 64 × 64 px or larger | Depending on silhouette; bosses about 96 × 96+ px |
| Dialogue portraits | 256 × 256 px | One consistent crop, lighting, and framing |
| Full story stills | 1280 × 720 px, 16:9 | Composition should leave space for separate in-engine captions |
| Pixel filtering | Nearest-neighbor for pixel assets | Prefer integer scaling; preserve clean edges |

Do not bake UI text, dialogue, names, or readable critical documents into generated images. Godot should render actual text for accessibility, localization flexibility, and accurate canon.

## 2. Screen and interface inventory

These are **12 reusable presentation types**, not 12 mandatory independent Godot scenes. Overlays can live on a shared gameplay screen.

| ID | Presentation | What the player sees | Access / transition | Asset treatment |
|---|---|---|---|---|
| UI-01 | Main menu | Title, New Game, Continue (when save exists), Settings, Quit; dim forest / distant beacon, subtle fog and glow | Game launch / return to menu | One layered or static backdrop; all buttons/text in Godot |
| UI-02 | Exploration / combat HUD | Region tilemap, sprites, health, lantern state, current objective hint, context-sensitive `Interact` prompt | New Game, Continue, region load | Tilemaps/sprites PNG; bars/prompts/lights in Godot |
| UI-03 | Dialogue | Bottom panel, speaker name, portrait, text, advance cue; world remains visible if feasible | NPC/story interactions | Portrait PNG, native panel/text |
| UI-04 | Memory / illustrated story | Screen fade to still/portrait/overlay, sequential narrative text; then return to world | `MEMORY` story event | Limited still PNGs, reusable native fades/tint/text |
| UI-05 | Inventory / equipment | Item list/slots, description, amounts, equipped items | Input/menu | Item icon atlas, native panels/slots |
| UI-06 | Journal / clues | Objectives and Clues tabs, lists, current descriptions and permanent discovered entries | Input/menu; clue discovery updates | Text-first; optional document thumbnails |
| UI-07 | Crafting | Workbench recipe list, materials required/owned, result preview, Craft action and feedback | Workbench interaction, after Bram unlocks crafting | Shared item icons/native UI; no new screen background per bench |
| UI-08 | Boss combat | Normal world/HUD + boss title, large boss HP bar, readable attack telegraphs | Boss arena trigger | Distinct boss sprites; effects/bars native |
| UI-09 | Pause / settings | Resume, Save, Settings, Main Menu; audio/display settings | Pause input; menu Settings | Native UI, same visual theme |
| UI-10 | Defeat / retry | Darkened gameplay, defeat label, Retry/Load, Main Menu | Player defeat | Native overlay and fade |
| UI-11 | Chapter / region transition | Chapter heading, subtitle/objective, fade to next loaded area | Chapter start/unlocked region travel | Native typography/fades, optional reused backdrop |
| UI-12 | Epilogue / credits | Short illustrated/text vignettes, final title card, credits, option to enter postgame | `C3-S10` after final Witness Rite | Reuse story stills and text animation |

**Menus and behavior:** Inventory/journal/pause should pause active combat or otherwise protect the player while open. Crafting opens only at workbenches. A dedicated world map is **not** part of the initial plan; use objective hints and region exits. Save/load requires at least one local slot (per Game Design). An explicit standalone Save Slot Selection screen is not required.

### Screen navigation

`Launch → UI-01 Main Menu → (New Game / Continue) → UI-11 Intro or region transition → UI-02 Gameplay`.

From gameplay: `NPC → UI-03 → gameplay`; `memory → UI-04 → gameplay`; `inventory → UI-05 → gameplay`; `journal/clue → UI-06 → gameplay`; `workbench → UI-07 → gameplay`; `boss → UI-08 → victory scene or UI-10 defeat`; `pause → UI-09 → resume/menu`. `Chapter I → Chapter II → Chapter III → UI-12 ending → postgame gameplay`.

## 3. Story-scene presentation mapping

The canonical story has **29 main scenes** (9 + 10 + 10). Their narrative steps and flags are specified in the Story file; the mappings below describe only reusable visual/UI templates.

| Scene IDs | Main world locations / sequence | Presentation emphasis |
|---|---|---|
| `C1-S01` | Ruined shelter → tutorial path | Black opening, exploration/HUD, initial Voice dialogue and Thornbound tutorial |
| `C1-S02`–`C1-S03` | Mira rescue → survivor camp | Combat, portrait dialogue, Bram's workbench UI |
| `C1-S04`–`C1-S05` | Logging settlement, memorial garden, old waystation | Flexible exploration, inspectable clues, Ashen Stranger memory overlay |
| `C1-S06`–`C1-S07` | Camp defense → upper forest | Combat telegraphs, objective/route unlock, inscriptions |
| `C1-S08`–`C1-S09` | First beacon arena → camp | Briar Hart boss bar, first-light echo, **white** beacon transition, Mira dialogue |
| `C2-S01`–`C2-S03` | Village square, records, Festival | Village NPC portraits/dialogue, clues and environment changes |
| `C2-S04`–`C2-S06` | Archive and restricted records → bell records | Clue inspection, Black Vigil memory still, Mira/Eva dialogue |
| `C2-S07`–`C2-S08` | Bell tower → boss chamber | Tower exploration, Hollow Bellkeeper bar, Orin memory overlay |
| `C2-S09`–`C2-S10` | Bell and village beacon → memorial | Bell event, village **amber** light, Vaela voice reveal, chapter transition |
| `C3-S01` | Forest memorial (return visit) | Eva/Mira memory still; forest beacon converts to **amber** |
| `C3-S02`–`C3-S05` | Sanctuary gates, gallery, labs, Vaela's quarters | Reused exploration, documents, portraits, memory overlays |
| `C3-S06`–`C3-S07` | Lightkeeper archives → central reservoir | Stranger identity still, witness-key reveal, Vaela dialogue |
| `C3-S08`–`C3-S09` | Reservoir arena / machinery | Vaela three-phase boss; final Witness Rite; Sanctuary **amber** |
| `C3-S10` | Epilogue → postgame | Illustrated/text vignettes, credits, return to all three regions |

Optional side stories and clues use the **same** dialogue/inspection/memory/journal patterns. Clues total **5 / 5 / 6** for Chapters I/II/III. Do not create a unique UI screen for each clue.

## 4. Planned art inventory

These counts are **estimated asset groups**, not orders to generate files and not evidence that any assets exist. Keep logical asset identities stable even while placeholders are used.

### 4.1 Characters and enemies

| Group | Named designs | Approx. scope / notes |
|---|---|---|
| Player | Aren Vale | One gameplay character, four facing directions; walk/idle, basic melee, charged hit; dodge/hit/death can partly use Godot animation/effects |
| Major visible NPCs | Mira Fen, Bram Thorne, Tessa Reed, Vaela Rhos | Four distinct in-world designs; idle and movement only where story requires |
| Standard enemies | Thornbound, Cinder Wisp; Lantern Warden, Bell Wraith; Gilded Sentinel, Unbound Remnant | **Six** unique silhouettes; share animation/controller conventions but not necessarily identical movement styles |
| Bosses | Briar Hart, Hollow Bellkeeper, Vaela (Warden's Harness) | **Three** unique combat presentations; attack readability over frame count |
| Crowd NPCs | Generic survivor/villager variants | ~2–3 reused generic looks, placed as needed |
| Narrative-only characters | Eva Fen, Orin Reed, Cass | Portray via portraits, documents, memories; no dedicated world sprites by default |
| Ashen Stranger | Aren's preserved projection | Reuse Aren identity/appearance in hooded/tinted treatment; **not** a distinct person |

**Sprite budget:** Initial humanoid canvas ~48 px; larger entities scaled to purpose. Reserve consistent anchor points, collision footprint separate from visuals, and four directional animations only where motion needs them. Attack swings should read clearly; dodge, hit flashes, shadows, glow, and death fades can be driven by Godot.

### 4.2 Terrain, structures, and props

| Art group | Proposed atlas / illustration count | Shared usage |
|---|---|---|
| Shared terrain | 1 atlas | Ground, dirt/stone paths, transitions, common edges |
| Forest | 1 atlas | Trees, roots, rocks, bushes, forest trail details; shelter/camp/memorial/waystation/beacon approach |
| Village | 1 atlas | Village road/ground, timber structures, fences, stones, festival props |
| Sanctuary | 1 atlas | Architectural flooring, walls, pillars, machinery, crystal supports |
| Shared world props | 1–2 atlases | Crates, workbench, doors, signs, containers, candles, rubble, clue markers |
| Unique landmark artwork | ~3–5 compositions | First beacon, village bell/beacon, reservoir, select memorable structures; reuse existing tiles for surrounding walkable space |
| State variants | Primarily Godot-native | Beacon dim/white/amber, Hush disturbance, lit vs unlit props, color changes |

**Map layout:** Three region root scenes with smaller subareas/interiors and transitions, not one giant bitmap. Use large landmark art as layered/background scenery where possible; collisions and walkable routes remain tile-/shape-based. Earlier regions remain revisitable.

### 4.3 Narrative illustrations and UI art

| Group | Proposed quantity | Use |
|---|---|---|
| Core portraits | 5 | Aren, Mira, Bram, Tessa, Vaela; same framing/art rules |
| Additional portrait/echo art | 2–3 if justified | Eva, Orin, and another important memory character |
| Story stills | **Up to 7** | Key reveals below; can be reused or replaced by in-engine presentation |
| Clue/document art | Small shared atlas / selected thumbnails | Journal framing and illustrated artifacts; long text rendered by Godot |
| Items/materials icons | ~12–18 initial icons in atlas | Weapons, armor, potions, crafting materials; exact recipes/stats TBD |
| UI furniture | Godot-native | Text, borders, backgrounds, slots, tooltips, bars, buttons, selection states |

**Priority story still candidates:** `C1-S01` Awakening (optional), `C1-S05` Ashen Stranger, `C2-S05` Forty-Seven authorization, `C2-S09` Bell Rings (optional), `C3-S01` Eva's red scarf memory, `C3-S06` Stranger is Aren, `C3-S10` peaceful night and amber beacons. These are **visual candidates**, not newly required plot beats or seven mandatory production files.

### 4.4 Godot-native effects (not separate PNG deliverables)

- Lantern illumination, short pulse ring, exposed enemy/core indicator, cooldown/energy feedback.
- White/amber beacon illumination, light bloom approximation, state transitions.
- Atmospheric fog/mist, drifting dust/embers, dark tint/occlusion; keep combat sight lines clear.
- Melee trails, charged-hit windup, impact flash, stagger feedback, dodge displacement.
- Enemy attack windups, floor telegraphs, projectile primitives, boss warning zones.
- Clue outline, interact prompt, pickup feedback, optional memory-echo distortion.
- Dialogue typing/advance, fades, memory desaturation/overlay, chapter transitions.
- Progress bars, HUD, buttons, slots, inventory/crafting/journal layouts.

## 5. Asset identity and integration contract

**Asset files will be authored separately from game coding.** Codex and either developer can begin with labeled placeholders, provided the following conventions are preserved:

- Each sprite represents one **logical entity** (`aren`, `mira`, `thornbound`, etc.). Do not tie world logic or animation state transitions to the current PNG filename.
- Each environment atlas is associated with a **region/category** (`shared`, `forest`, `village`, `sanctuary`). Logic should not depend on atlas tile IDs where an interaction node or semantic tag would be more stable.
- Portrait and story-still slots accept missing textures gracefully; show readable speaker/text/scene even without the final image.
- Real collision, hitboxes, navigation, and interaction areas are configured in Godot, **not inferred** from artwork shape.
- Use stable shared asset names, e.g. `aren_walk.png`, `forest_tiles.png`, `portrait_mira.png`, `story_c2_s05.png` (illustrative names, not required existing files).
- Replacing a placeholder must not force rewriting narrative conditions, map transitions, or gameplay systems.
- Keep visible text and scene flags in data/configuration, not embedded in art.

## 6. Explicit scope boundaries

- **No instruction here to generate images.** This document is the reference for future art-direction and integration decisions.
- Audio source selection, final sprite frame counts, tile adjacency rules, exact map dimensions, equipment values, and final image formats remain **TBD**.
- Do not add a minimap, cinematic animation system, extra playable characters, branching endings, or dedicated new screens for each story scene by default.
- Under time pressure, prioritize the complete canonical story, three boss encounters, readable combat, saving, and key visual moments; reduce optional art/quests first.
