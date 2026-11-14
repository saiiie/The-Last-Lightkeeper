# The Last Lightkeeper — Game Design & Project Handoff

**Document status:** Planning baseline · **Last updated:** 2026-11-05  
**Companion file:** `The_Last_Lightkeeper_Story.md` (canonical narrative and scene-by-scene implementation reference)

> **Purpose:** Carry established decisions into a new planning/development conversation. This is a design baseline, **not** a claim that the game is implemented. Items labeled *recommended* or *provisional* may change during production.

## 1. Project identity

| Field | Decision |
|---|---|
| Game title | **The Last Lightkeeper** |
| Course | Game Development — final project (2026) |
| Team | 2 developers |
| Production window | **4–6 weeks** |
| Repository | <https://github.com/saiiie/The-Last-Lightkeeper.git> |
| Target platform | **Desktop-first** (chosen as the simpler initial target; mobile not planned) |
| Engine / language | **Godot 4 / GDScript** |
| Perspective | **Top-down 2D** |
| Main genre | **Story-driven action-adventure** |
| Additional elements | Dark fantasy, mystery, semi-open exploration, crafting, RPG-lite progression, sandbox-style postgame |
| Development approach | Heavy use of **AI coding agents** for implementation, with human review, integration, playtesting, and art/narrative direction |
| Current stage | **Pre-production / concept established** |

**Short pitch:** A world once protected by ancient beacons is slowly consumed by a phenomenon called *the Hush*. Aren Vale, the last Lightkeeper, sets out to restore three beacons, fighting corrupted creatures and following fragments of a forgotten past. The beacons themselves are implicated in the catastrophe, and restoring their original function may erase the very memories the world needs to reclaim.

**Creative priority:** **Narrative mystery is non-negotiable.** The world, combat, light mechanic, crafting, and exploration should reinforce the plot instead of distracting from it.

## 2. Confirmed direction and priorities

- **Three long chapters**, each centered on a distinct region and its own narrative arc. Long = substantial story developments, exploration, character relationships, and set pieces; **not** padded quests or grinding.
- **Semi-open world:** exploration within unlocked regions is flexible; story milestones unlock subsequent regions. Earlier regions remain revisitable.
- **Hybrid freedom:** the player has clear objectives plus optional exploration, clues, encounters, and crafting.
- **Combat matters:** deliberate melee timing paired with tactical use of light. Encounters should be engaging, not merely obstacles between dialogue scenes.
- **Storytelling:** both NPC conversations and environmental clues/memory echoes.
- **Persistent progress:** sessions can be long; save/load required.
- **Complete story ending**, followed by free exploration and repeatable restoration/combat milestones.
- **Simple reusable mechanics, polished execution:** agentic coding feasibility is a hard constraint; avoid unique technical systems for every scene.

## 3. World and chapter layout

| Chapter | Region | Narrative function | Major ending beat |
|---|---|---|---|
| **I — The Whispering Forest** | Corrupted forest, survivor camp, ruins, first beacon | Introduce Aren, Mira, the lantern, the mystery of memory loss | Defeat **Briar Hart** and restore beacon 1 to its old **white** light; Mira loses part of a cherished memory |
| **II — The Hollow Village** | Inhabited but unsettling village, archive, bell tower, second beacon | Investigate the missing, uncover the Black Vigil and Aren's signature; learn the Witness Rite | Defeat **Hollow Bellkeeper**, ring the bell, restore beacon 2 to **amber**; the guiding Voice reveals itself as Vaela |
| **III — The Forgotten Sanctuary** | Ancient research complex, chambers, final beacon, central reservoir | Expose the Mercy Engine's full history, recover Aren's plan, confront Vaela | Convert beacon 1 to **amber** through Mira's testimony; defeat **Vaela** and complete the final Witness Rite at beacon 3; main ending |

**Region implementation:** Prefer three separate map/region scenes with multiple subareas and transition points rather than a seamless open-world map. Use backtracking for story and crafting. Regions can include interiors as smaller Godot scenes.

## 4. Core player loop

1. **Explore** accessible paths, ruins, settlements, and optional corners of a region.
2. **Encounter** enemies and environmental obstacles; use deliberate attacks and light abilities.
3. **Discover** a clue, character conversation, memory echo, useful material, or new route.
4. **Craft/upgrade** equipment or recover consumables for tougher encounters.
5. **Advance** a chapter objective, change the region, unlock a route, or confront a boss.
6. **Return** to previous regions for optional mysteries, material gathering, and later restoration tasks.

**Signature mechanic:** One reusable **lantern pulse** ties gameplay and story together: it briefly exposes/interrupts certain enemies, reveals selected hidden markings/memory echoes, and operates ancient mechanisms. It should have clear feedback and reasonable cooldown/energy constraints (**exact numbers TBD**).

## 5. Player systems

### Combat — agreed actions

| Action | Intended behavior |
|---|---|
| **Basic melee** | Reliable, faster, lower-damage attack; one primary melee action |
| **Charge / strong hit** | Hold/release for a slower high-impact strike; can stagger or break defenses |
| **Dodge** | Short evasive repositioning tool; timing matters |
| **Lantern pulse** | Expose weaknesses, disrupt selected attacks/defenses, uncover environmental/memory interactions |

Combat feel: deliberate pacing, readable enemy tells, punishable recovery windows, tactical lantern use. **Do not** add complicated combos or multiple active spell systems by default.

### Enemies — agreed per-chapter content

| Chapter | Standard enemy A | Standard enemy B | Boss |
|---|---|---|---|
| I | **Thornbound** — pursuing melee/root creature | **Cinder Wisp** — ranged projectile spirit | **Briar Hart** — root-antlered forest guardian |
| II | **Lantern Warden** — defensive melee construct | **Bell Wraith** — sound-wave ranged spirit | **Hollow Bellkeeper** — Orin's stolen memory bound to a guardian |
| III | **Gilded Sentinel** — armored defensive guardian | **Unbound Remnant** — mobile ranged/short-teleport manifestation | **Vaela, Warden of the First Dawn** — final boss |

**Total: 6 unique standard enemy types + 3 bosses.** Reuse a shared enemy state-machine/controller and configurable attacks. Reuse telegraph, hit, damage, stagger, and health logic. Three boss *encounters* are required; do not interpret this as a requirement for three unrelated combat engines. Boss phases may be implemented as parameters/attack sequences.

### Crafting — agreed inclusion

Crafting must cover **all three categories**:

| Category | Example recipes (*provisional names*) | Function |
|---|---|---|
| **Weapons** | Iron Sword → Reinforced Blade → Lightforged Sword | Damage / charged strike improvements |
| **Potions** | Healing Tonic, Lantern Elixir, Shadow Resistance Potion | Healing, lantern support, temporary defense |
| **Armor** | Traveler's Coat → Reinforced Armor → Lightkeeper's Mantle | Protection / survivability |

- Crafting occurs at a **workbench/menu** with material requirements, item preview, and success feedback.
- Gather materials from world pickups, enemies, and story/side objectives; use minimal resource types.
- **Recommended** for scope: roughly 5–8 meaningful recipes initially, then expand only after the complete story is playable.
- Exact item stats, ingredient counts, loot tables, crafting UI, and equipment slots are **TBD**.
- Bram introduces crafting in Chapter I; crafting remains available throughout the game.

### Exploration and progression

- Story objectives, region transitions, NPC dialogue, interactable clues, memory visions, environmental changes, and optional side stories.
- **3–6 discoverable clues per chapter** (**5 / 5 / 6** defined in companion story file). Important facts must still reach players even if optional clues are missed.
- Number of NPCs/scenes/quests varies with each chapter; no arbitrary cap, but must fit production time.
- Upgrades may affect weapon damage, armor durability, and lantern effectiveness (**mechanics/stats TBD**).
- World state evolves: **old beacon white** (suppression at a cost) versus **restored amber** (witnessed memories, safe stabilization).

### Persistence and postgame

- At least **one local save slot** recommended. Persist: region/position, chapter, completed objectives and bosses, clue flags, inventory/equipment/crafting, beacon states, and any essential character/story flags.
- End credits/epilogue are followed by **post-story exploration** of all three regions.
- Postgame can include repeatable Hush disturbances, crafting, residual enemies, and restoring waystones/routes. It does **not** require a new campaign or endless procedural world.

## 6. Cast (narrative roles)

| Character | Role / story function |
|---|---|
| **Aren Vale** | Playable last Lightkeeper. Memory-erased protagonist who helped build the Mercy Engine and signed the Black Vigil authorization. Must take responsibility without expecting forgiveness. |
| **Mira Fen** | Forest scavenger and major companion. Carries a red scarf; learns her mother **Eva Fen** was sacrificed and her memories erased. Key witness in Chapter III. |
| **Bram Thorne** | Wandering blacksmith; crafting mentor and former beacon-equipment maker, wrestling with complicity. |
| **Tessa Reed** | Village archivist; preserves names and records, seeks her father Orin, rings the village bell. |
| **Vaela Rhos** | Mercy Engine creator, Warden, Aren's guiding lantern Voice, and final antagonist; lost son **Cass** in the Ashfall. |
| **Orin Reed** | Tessa's father, dissident bellkeeper; killed after trying to expose the Black Vigil; memory bound into Chapter II boss. |
| **Eva Fen** | Mira's mother, ranger, one of the forty-seven victims; journal and scarf anchor Mira's recovery. |
| **Ashen Stranger** | Projection of Aren's preserved waystone recordings, made shortly before memory erasure; not a time traveler or separate person. |
| **Cass** | Vaela's deceased son; memories of him explain her motivation but do not excuse her actions. |

## 7. World logic (keep consistent in all dialogue)

- **Great Ashfall:** a devastating series of fires, crop failures, and disease about **14 years before** the game.
- **Mercy Engine / first beacon conversion:** developed approximately **12 years before** the game, originally as consensual temporary relief from traumatic memories.
- Stored memories became unstable and formed **the Hush**; artificial beacon light suppressed manifestations while further extraction worsened the underlying problem.
- **Black Vigil:** **3 years before** the game, **47 people** used as fatal living anchors without consent. Vaela authorized it; Aren knowingly co-signed under perceived emergency. Public memory and records were suppressed.
- **Nine days before** the opening, Aren opposed Vaela's final plan, recorded memory backups in waystones, and had their memories erased by Vaela.
- **White beacon light** runs on the extraction/suppression system and can cost people memories.
- **Amber beacon light** represents the **Witness Rite**: controlled return/acknowledgment stabilizes memories without fresh extraction. It does not magically erase grief or undo deaths.
- **Ordinary night is harmless.** The Hush is dangerous because separated memories have become unstable.
- **Destroying beacons immediately** would release concentrated memories dangerously; **Vaela's purge** would permanently destroy memories. The story resolves this through phased restoration/witnessing.
- Vaela is **alive** after the final battle; she is removed from power, not absolved. Aren is not absolved either.

## 8. Narrative-to-game requirements

- Dialogue UI with speaker names, portraits (optional), text progression, and conditional variants.
- Quest journal/objective tracker; **chapter and scene IDs** from `The_Last_Lightkeeper_Story.md`.
- Clue journal (readable notes, memories, portraits, documents); 3–6 clues each chapter.
- Event flags for story progression, doors, NPC state, boss unlocks, and white/amber beacons.
- Reusable **memory vision** presentation (fade, portrait/image overlay, dialogue/text, return to world). Avoid requiring cinematic character animation.
- Region state changes and short story sequences using existing scene/animation primitives.
- Story-critical discoveries must be mandatory or repeated via required dialogue; optional clues add depth, not missing context.

## 9. Production guidance (recommendations, not locked requirements)

**Likely risk:** Three story-rich chapters, six enemy types, three bosses, crafting, and a save system are **ambitious** for two people in 4–6 weeks, even with agents. A previously suggested **3.5–5-hour** total story is an **aspirational writing/playtime target, not a promised deliverable**. Prioritize narrative completeness over runtime.

| Stage | Deliverable |
|---|---|
| **Week 1** | Movement, collisions, camera, basic/charged melee, dodge, first enemy, placeholder map |
| **Week 2** | Lantern pulse, shared enemy framework, drops, inventory/crafting prototype, basic combat feel |
| **Week 3** | Region transitions, quest/dialogue/flag systems, save/load, first complete chapter slice |
| **Week 4** | Playable critical path through all three chapters and canonical ending, using placeholder content where necessary |
| **Weeks 5–6 (if available)** | Boss/encounter polish, optional scenes, cohesive audio/visuals, balancing, testing, demo preparation |

**Implementation style:** Build one reusable system at a time. Let agents code small bounded tasks with acceptance criteria, run the project frequently, review changes, and commit working states. Godot `.tscn`, `.tres`, and GDScript are appropriate for text-based iteration. Manual testing is required for controls, difficulty, visuals, and integration.

**Scope protection:** Cut **optional dialogue, extra quests, map size, and recipe variety first** if behind schedule. Do not cut the key narrative chain, three chapter bosses, three chapter conclusions, or the ending. Prefer short but complete chapters to long unfinished ones.

**Art direction:** Dark-fantasy 2D, readable silhouettes, forest/village/sanctuary contrasts, and white-to-amber light shifts. **Exact asset style, palettes, sprite dimensions, tile sizes, animations, audio sources, and UI visual language are not yet finalized.** Pixel art is an attractive *reference*, not an irrevocable decision.

## 10. Still to decide during production planning

- Overall map sizes, layout diagrams, subarea counts, and room entrances.
- Concrete controls/key bindings and gamepad support.
- Player/enemy HP, stamina (if any), charge time, lantern cost/cooldown, combat tuning.
- Player death/checkpoint rules; loot rates; item/equipment stats; recipes.
- Whether NPC companions follow visibly or participate only through scripted encounters.
- Dialogue system implementation (Godot-native/custom/plugin) and text storage format.
- Visual art pipeline/asset licensing, audio pipeline, resolution/scaling, and performance targets.
- Scope of optional quests/postgame, automated tests, and demo route.
- Exact rubric checklist from the course handout (revalidate when planning deliverables).

## 11. Related documentation and collaboration rule

- **Use `The_Last_Lightkeeper_Story.md` as the source of truth for plot, scene order, clues, canonical dialogue, and narrative progression flags.**
- **Use this file** for gameplay scope, technology, design principles, and implementation priorities.
- Do not invent additional canon when implementing a scene. Surface proposed changes as questions/decisions, and update both documents if they are approved.
- In future Codex tasks, specify **which scene IDs and systems** to implement; avoid prompting an agent to generate the entire game at once.
