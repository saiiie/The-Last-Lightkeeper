# The Last Lightkeeper: Hold the Light — MASTER MVP

**Version:** 3.0 · **Date:** November 19, 2026  
**Deadline:** November 20, 2026 at 1:00 PM (Asia/Manila)  
**Team:** Two developers + separate Codex sessions · **Engine:** Godot 4 / GDScript  
**Companions:** `DEVELOPER_A_MVP.md`, `DEVELOPER_B_MVP.md`  
**Source of truth:** This master document governs scope and integration. The two developer documents govern work ownership and individual task acceptance. **Only these three documents are required.**

## 1. Approved MVP

**Premise:** Aren Vale, the last Lightkeeper, protects one remaining beacon in a forest threatened by the Hush. Defeat attackers, collect **light shards**, repair the beacon, survive **10 waves**, defeat the **Hush Warden**, then interact with the beacon to perform the **Witness Rite**. The beacon changes from the old **white** light to **amber** light. Use only opening text and a short victory ending; this is a condensed alternate adaptation of the original story, not the original three-chapter campaign.

**Core loop:** Menu → opening text → protect beacon with melee/ranged/pulse → earn shards → repair → survive 10 waves → defeat wave-10 boss AND all remaining enemies → press E at beacon → amber ending → replay/menu.

### Locked feature scope

- [ ] One bounded **large scrolling** top-down arena (~1800×1100 world units), centered beacon, `Camera2D`, readable boundaries.
- [ ] WASD movement; **mouse-directed melee (LMB)**, **mouse-directed ranged (RMB)**, and **Q lantern pulse** with cooldown.
- [ ] **Three distinct standard enemies:** Thornbound (melee chaser), Cinder Wisp (ranged), Hush Brute (slow high-HP/high-damage).
- [ ] **10 waves** defined by data; escalating mixes; staggered perimeter spawns; no next wave until spawn queue empty **and** all enemies dead.
- [ ] A unique **Hush Warden boss** in wave 10, with **3-shot volley** and **telegraphed area slam**; count as alive until defeated.
- [ ] Enemies attack the beacon; attacks/projectiles may hurt player. Player or beacon HP reaching zero produces defeat/restart.
- [ ] Standard enemies drop collectible **light shards**. Near beacon, press **E** to spend **3 shards to repair 30 HP**, up to max.
- [ ] Fixed HUD: player HP, beacon HP, wave, shard count, pulse cooldown, contextual interaction prompt; boss health display.
- [ ] Main menu, controls hint, short opening text, defeat/retry, short ending, quit. Victory only after boss + wave 10 clear **and E Witness Rite**.
- [ ] Tested standalone features, integrated start-to-end playthrough, tested Windows exported build.

**Out of scope:** Original 29 scenes and three-region RPG; NPC quests; crafting/inventory; save/load; complex pathfinding; separate levels; skill trees; multiplayer; branching story; cinematic animations; postgame. Build with **Godot-native placeholder art first**, replace assets only when stable.

**Honest success criterion:** A playable and testable short game; “80–85% complete” describes this revised MVP, not the original larger RPG.

## 2. Provisional implementation values (approved starting defaults, tune after testing)

| Parameter | Default |
|---|---|
| Arena | 1800×1100 px, obstacle-free; beacon at center |
| Player | 100 HP, ~230 px/sec, spawn near beacon |
| Beacon | 200 max HP, starts white; amber only after Rite |
| Melee | Aim at mouse; ~65 px reach, 20 damage, 0.35 s cooldown |
| Ranged | Straight aimed projectile, 12 damage, unlimited ammo, 0.55 s cooldown |
| Lantern pulse | ~110 px radius, briefly stuns/knocks back enemies, 6 s cooldown |
| Shards | 1 collectible per standard enemy; generous ~35 px pickup radius |
| Repair | E within 90 px; 3 shards → +30 HP, including mid-wave; no repair when full |
| Intermissions | 7 s after wave clears; automatic next wave |
| Spawning | Queue every ~1.2–2 s; cap ~8–12 living regular enemies |
| Enemy targeting | Beacon by default; player can intercept / be hit |
| Defeat | Player HP or beacon HP 0; restart run from wave 1 |
| Hush Warden | ~450 HP; volley + telegraphed slam; no extra phases |
| Game duration | 12–15 minutes aspirational, **not guaranteed** until playtested |

### Wave configurations (data, not ten hand-written scripts)

| Wave | Thornbound | Cinder Wisp | Hush Brute | Hush Warden |
|---:|---:|---:|---:|---:|
| 1 | 3 | 0 | 0 | 0 |
| 2 | 4 | 1 | 0 | 0 |
| 3 | 4 | 2 | 0 | 0 |
| 4 | 5 | 2 | 1 | 0 |
| 5 | 5 | 3 | 1 | 0 |
| 6 | 5 | 3 | 2 | 0 |
| 7 | 6 | 3 | 2 | 0 |
| 8 | 6 | 4 | 2 | 0 |
| 9 | 7 | 4 | 3 | 0 |
| 10 | 3 | 2 | 1 | 1 |

Basic initial enemies: **Thornbound** ~35 HP / 8 beacon melee damage; **Cinder Wisp** ~25 HP / 5 projectile beacon damage; **Hush Brute** ~100 HP / 20 beacon melee damage. These are tuning values only. Give each distinct silhouettes/colors when using placeholders.

## 3. Frozen shared integration contract (copy into both Codex sessions)

**Shared foundation is created ONCE on `main` in Phase 0.** Both developers branch from the same commit. Do not create a fourth contract document. Update this section by team agreement before changing public interfaces.

### Git and file ownership

| Owner | Branch | Exclusive paths |
|---|---|---|
| **Developer A — gameplay** | `feature/gameplay` | `scenes/player/`, `scenes/enemies/`, `scenes/projectiles/`, `scenes/pickups/`, `scripts/player/`, `scripts/enemies/`, `scripts/combat/`, `scripts/pickups/`, `scripts/systems/wave_manager.gd`, A test scenes |
| **Developer B — presentation + integration** | `feature/arena-ui` | `scenes/arena/`, `scenes/beacon/`, `scenes/ui/`, `scenes/menus/`, `scenes/main.tscn`, `scripts/arena/`, `scripts/beacon/`, `scripts/ui/`, `scripts/main.gd`, B test scenes |
| **Shared baseline, then B integrator only** | `main` / integration branch | `project.godot`, Input Map, collision setup, approved contract edits, exported build |

Use distinct test filenames (`scenes/tests/a_*` and `scenes/tests/b_*`). The two agents **never edit the same workspace or file simultaneously**. B owns final `main.tscn` assembly. If working on one PC, use two cloned directories or Git worktrees.

**Input Map (create in shared baseline):** `move_up` W; `move_down` S; `move_left` A; `move_right` D; `melee_attack` LMB; `ranged_attack` RMB; `lantern_pulse` Q; `interact` E; `pause_game` Esc (pause optional). Collision layers: 1 world, 2 player, 3 enemies, 4 projectiles, 5 pickups; test masks with actual bodies/areas.

### Stable cross-team APIs

**Developer A — Player:** root `CharacterBody2D` with `global_position` and:

```gdscript
signal health_changed(current: int, maximum: int)
signal died
signal shards_changed(count: int)
signal pulse_cooldown_changed(remaining: float, total: float)
func take_damage(amount: int) -> void: pass
func add_shards(amount: int) -> void: pass
func spend_shards(amount: int) -> bool: return false
func set_controls_enabled(enabled: bool) -> void: pass
```

Player exposes current health, max health, shards, and cooldown for initial HUD sync (or emits initial signals after listeners bind). Player owns attack inputs **not E**.

**Developer A — Enemies:** all standard enemies and boss are `Node2D`-based, implement `set_targets(player: Node2D, beacon: Node2D) -> void`, emit `signal died(world_position: Vector2)` **once**, and attack via `take_damage(amount)` on valid targets. Standard deaths drop collectible shards; pickup calls `player.add_shards(1)` once.

**Developer A — Wave manager:** `Node` at `res://scripts/systems/wave_manager.gd`:

```gdscript
signal wave_started(current: int, total: int)
signal wave_cleared(current: int)
signal all_waves_cleared
func start_run(player: Node2D, beacon: Node2D, spawn_parent: Node2D) -> void: pass
func stop_run() -> void: pass
```

Manager owns spawns, active-alive counting, shard creation hookup, wave completion. **No early `all_waves_cleared`**. Provide development-only wave jump within isolated test harness, never unmarked public release controls.

**Developer B — Beacon:** root `Node2D` with `global_position`:

```gdscript
signal health_changed(current: int, maximum: int)
signal destroyed
signal witness_rite_completed
func take_damage(amount: int) -> void: pass
func repair(amount: int) -> void: pass
func perform_witness_rite() -> void: pass
```

Beacon owns HP and white→amber state; **does not spend shards**. B's main controller handles E distance check, `player.spend_shards(3)` and then `beacon.repair(30)` only if damaged; after wave 10 clear, E invokes `perform_witness_rite()` instead. Prevent duplicate Rite.

**Developer B — HUD:** provides `set_player_health(current, maximum)`, `set_beacon_health(current, maximum)`, `set_wave(current, total)`, `set_shards(count)`, `set_pulse_cooldown(remaining, total)`, `set_prompt(message)`; boss HP bar is a B-owned extension wired during Phase 4.

**Developer B — Main/overlays:** main exclusively connects A+B signals; defeat overlay `show_defeat(reason)`, victory overlay `show_victory()`; menu/retry/quit works. On defeat call `wave_manager.stop_run()` and disable gameplay. Victory only after `all_waves_cleared` **plus E at beacon**.

**Change control:** pause affected tasks → both humans agree → B changes contract in master → both update callers → re-run tests. Avoid hard-coded cross-team node paths and missing PNG dependencies.

## 4. Phases 0–4 — shared sequential checklist

> **Rule:** A checkbox is complete only when feature code is committed, tested locally in Godot (not merely generated), and the acceptance check passes. Integrate and preserve a runnable baseline at each gate.

### Phase 0 — Foundation, **together**

- [ ] **F0.1** Create one NEW Godot 4 project/repository; agree exact Godot 4 version; preserve old RPG separately.
- [ ] **F0.2** Add folders for both owners, `.gitignore` ignoring `.godot/`, `project.godot`, minimal launchable `main.tscn`.
- [ ] **F0.3** Configure window/stretch, all Input Map actions, collision layers; read and freeze Section 3 APIs.
- [ ] **F0.4** Commit/push shared baseline on `main`; both machines open and run it.
- [ ] **F0.5** Branch A `feature/gameplay`, B `feature/arena-ui` from same baseline; separate folders/worktrees.

**Gate 0:** Both Godot environments launch same baseline; branches and ownership agreed. **Do not split development before this.**

### Phase 1 — Parallel foundations

**A track:**
- [ ] **A1** Player: movement, collision, `Camera2D`, HP/damage/death; standalone test.
- [ ] **A2** Melee + ranged projectile aimed at mouse, independent cooldowns; dummy target test.
- [ ] **A3** Lantern pulse AoE, stun/knockback, cooldown + feedback; dummy test.
- [ ] **A4** Enemy base + Thornbound chase/attack/die; mock beacon test.

**B track:**
- [ ] **B1** Large arena, visible center beacon marker, perimeter spawn markers, bounds; standalone test.
- [ ] **B2** Beacon HP, damage/repair/destroy, white/amber state, Rite signal; standalone test.
- [ ] **B3** Fixed HUD with fake values and all required setters; test while camera moves.
- [ ] **B4** Main menu + opening text + controls hint; Play/Quit test.

**Gate 1:** A can move, hit, pulse, kill Thornbound in its harness; B can damage/repair mock beacon and see HUD change. Both branches pushed.

### Phase 2 — Parallel full feature tracks

**A track:**
- [ ] **A5** Cinder Wisp ranged behavior + projectile tests.
- [ ] **A6** Hush Brute tank/melee behavior + identity tests.
- [ ] **A7** Light shard drop and single collection, increments player counter.
- [ ] **A8** 10-wave data-driven spawner + signals + living-enemy accounting; test waves 1, 2 and debug-jump to 9.

**B track:**
- [ ] **B5** Main scene/controller assembles placeholders using frozen interfaces (do not modify A files).
- [ ] **B6** E repair 3 shards/30 HP within range, full-health checks, contextual feedback.
- [ ] **B7** Defeat when player OR beacon dies; stop spawner, disable controls, Restart/Menu.
- [ ] **B8** Victory UI + white→amber Rite transition gated behind wave-10 clear; use mock completion signal for isolated test.

**Gate 2:** Three distinct enemies and waves work in A harness; B can simulate repair, defeat, and properly gated Rite. Commit/push clean branches.

### Phase 3 — First full integration (B leads, A fixes A-owned code)

- [ ] **I1** Stop feature changes; push both branches; B creates `integration/first-playable` from baseline/main and merges both in controlled sequence.
- [ ] **I2** B wires Player + Arena + Beacon + WaveManager + HUD + menu/overlays into `main.tscn`.
- [ ] **I3** Check actual enemy→beacon damage; player attacks; death→shard→pickup→E repair.
- [ ] **I4** Check player/beacon HUD, defeat→spawn stop, restart resetting all state.
- [ ] **I5** Play waves 1–3, then test 4–9 with local developer harness; verify spawn queue AND live count, no duplicates or softlocks.
- [ ] **I6** Push **known-good integrated commit**; both teammates pull/run/approve, and back it up.

**Gate 3:** Stable integrated waves 1–9, damage/repair, defeat/restart, UI. No polish before this gate.

### Phase 4 — Boss, full ending, polish, test, export

**A track (isolated code):**
- [ ] **A9** Hush Warden boss with projectile volley AND visibly telegraphed slam; test attacks in harness.
- [ ] **A10** Add wave-10 boss and ensure wave 10 only clears after all enemies + boss die; `all_waves_cleared` once.

**B track:**
- [ ] **B9** Boss HP HUD wired to boss state when integrated.
- [ ] **B10** White→amber final E Rite + short ending + Replay/Menu; lock until wave-10 clear.
- [ ] **B11** Merge A9–A10; full run from menu through wave 10, loss/retry, and Rite/ending.

**Joint release checks:**
- [ ] **R1** Readable contrasting placeholders; correct beacon color transition and enemy identities.
- [ ] **R2** Tune damage, projectile readability, repairs and spawn rates; avoid unwinnable difficulty spikes.
- [ ] **R3** Full normal run with developer shortcuts disabled (record real time, no softlocks).
- [ ] **R4** Test BOTH defeat causes; restart/menu; all three player abilities; shard pickup and repair; boss's two attacks.
- [ ] **R5** Export Windows executable, launch exported build on presentation PC, keep zipped known-good version.
- [ ] **R6** Rehearse 3–5-minute presentation; if showing wave 10 quickly, describe any developer-only skip explicitly.
- [ ] **R7** Freeze features. Fix only crashes, blockers, unreadable gameplay; no untested late asset swaps.

**Final release gate:** Menu → complete 10 waves and boss → Rite → ending; both defeats and restart work; exported build launches. If behind schedule, follow fallback ladder below.

## 5. Time-risk fallback ladder

1. Reduce enemy **counts** and shorten spawn/intermission durations **without cutting the 10-wave progression**.
2. Keep all three enemies **mechanically distinct**, but use colored shapes instead of sprite animations.
3. Keep melee/ranged/pulse, simplify combat hit effects rather than removing an input.
4. Reuse the Wisp projectile for boss volley; one circle telegraph for boss slam; no phases/cinematics.
5. Keep collectible shard drops but use glowing circles; if pickup bugs block delivery, flag any automatic shard award as an **explicit deviation**.
6. Drop optional pause/sound/decorative art before dropping required functionality.
7. If the boss is broken at final gate, seek team approval for the smallest playable two-attack approximation and document any missing behavior; don't claim an incomplete feature works.
8. Use development-only wave jump during *testing*, not as hidden normal gameplay. The class demo can show a documented shortcut if explicitly labeled.

**Stop rule:** A functioning exported build outranks any visual improvement. Do not claim completion based solely on agent output or headless parsing; manually play Godot and the export.

## 6. Team workflow / updates

- Give Codex **one task ID at a time** and tell it to read `MASTER_MVP.md` + its developer file first. Demand changed filenames, tests performed, blockers, and commit hash; don't tell it to build the entire game in one go.
- B acts as integrator. Before every merge, both commit/push/stop writing; B merges and opens the game in Godot; A fixes only A-owned bugs in own branch.
- Checkpoint format: `Task | not started / coding / locally tested / merged | commit | blocker | next step`.
- For changed API, coordinate first. Never let two Codex sessions work on the same physical project folder.
- Temporary scenes are fine. Never depend on missing final art. All text on actual UI is generated by Godot, not baked into artwork.

**Example opening text:** “I am Aren Vale, the last Lightkeeper. The Hush is approaching, and only one beacon remains. If its light fails, the forest will forget itself.”  
**Example ending text:** “The light turned amber. Memories returned to those willing to witness them. The night remained—and it was no longer the enemy.”
