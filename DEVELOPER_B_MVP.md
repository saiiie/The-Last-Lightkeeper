# The Last Lightkeeper: Hold the Light — DEVELOPER B MVP

**Role:** Arena, beacon, HUD, menu, win/lose experience, final scene assembly, Git integration, export.  
**Branch:** `feature/arena-ui` (then `integration/first-playable`) · **Read first:** `MASTER_MVP.md` (especially Sections 2–4).  
**Deadline:** November 20, 2026, 1:00 PM Asia/Manila.

## Your boundaries (important for Codex)

**Own only:** `scenes/arena/`, `scenes/beacon/`, `scenes/ui/`, `scenes/menus/`, `scenes/main.tscn`, `scripts/arena/`, `scripts/beacon/`, `scripts/ui/`, `scripts/main.gd`, and `scenes/tests/b_*`. After Phase 0, you are the **sole integration owner** for `project.godot` and master API changes approved by both humans.

**Do not edit A's files:** player, enemies, projectiles, pickups, wave manager, or A harness. Test with stand-ins for A APIs until merge. Never ask Codex to generate duplicate player/enemy implementations in B-owned files.

**Delivery contract:** Beacon root `Node2D` exposes signals `health_changed(current,maximum)`, `destroyed`, `witness_rite_completed`, and methods `take_damage(amount)`, `repair(amount)`, `perform_witness_rite()`. HUD setters: `set_player_health`, `set_beacon_health`, `set_wave`, `set_shards`, `set_pulse_cooldown`, `set_prompt`. Your `main.gd` is sole owner of E interaction, proximity check and 3-shard spend for +30 HP, defeat shutdown and Rite gating. **Master Section 3 has exact signatures.**

## Phase 0 — Shared foundation (with A)

- [ ] **F0.1** Agree exact Godot 4 version; create one new repo/project (preserve old RPG separately).
- [ ] **F0.2** Create shared directories, `.gitignore` ignoring `.godot/`, `project.godot`, simple launchable `scenes/main.tscn`.
- [ ] **F0.3** Configure window/stretch, Input Map (WASD/LMB/RMB/Q/E/Esc) and collision layers (1–5). Freeze Master Section 3 interface agreement.
- [ ] **F0.4** Commit/push baseline `main`; both humans verify Godot launches.
- [ ] **F0.5** Create `feature/arena-ui`, confirm A created `feature/gameplay` from SAME commit; separate working directories.

**Gate 0:** A and B both run same project, control names and API contracts are stable.

## Phase 1 — Arena, beacon, HUD, menu

- [ ] **B1 — Arena.** Build an approximately 1800×1100 walkable rectangular map, visible center beacon marker and several perimeter spawn markers; simple walls/boundary collision; no required PNGs or pathfinding. **Test:** open standalone arena scene, verify dimensions/markers and visible boundaries; cannot walk outside in a mock test. Commit.
- [ ] **B2 — Beacon.** Build `scenes/beacon/beacon.tscn` and B script with 200 HP, white glow, hit/repair methods, clamped HP, `destroyed` exactly once, `perform_witness_rite()` switches white to amber exactly once and emits completion. **Test:** mock damage/repair, zero HP, repeat Rite doesn't duplicate signal, proper colors. Commit.
- [ ] **B3 — HUD.** Screen-fixed (`CanvasLayer` or equivalent), labels/bars: player HP, beacon HP, wave X/10, shards, pulse cooldown, contextual E prompt; public setters from Master Section 3. **Test:** use fake values to exercise all setters, test camera scrolling doesn't move HUD. Commit.
- [ ] **B4 — Menu/opening.** Play, Quit, controls hint, short intro overlay; start gameplay only when main assembly exists (mock transition acceptable now). **Test:** navigation, labels and button wiring in standalone scene. Commit.

**Gate 1:** Standalone arena + beacon + HUD + menu run with placeholder data; no A code required. Push and share commit.

## Phase 2 — Main assembly and game state (still in B-owned files)

- [ ] **B5 — Main controller.** `scenes/main.tscn` + `scripts/main.gd`: establish nodes/containers for Player, Arena, Beacon, WaveManager, HUD, overlays; create lightweight mocks/test doubles for missing A components **only in `scenes/tests/b_*`**. Connect A signals only after merge; avoid hard-coded unavailable resources. **Test:** main scene launches, visible arena + beacon and HUD. Commit.
- [ ] **B6 — Repair interaction.** E within 90 px of beacon; if damaged and at least 3 shards, call `player.spend_shards(3)` first; only on success `beacon.repair(30)`; full HP means spend nothing. Show insufficient-shards, full-health, and available-repair prompts. **Test:** with mock player verify 2 shards cannot repair, 3 can, repairs clamp at 200, E out of range fails. Commit.
- [ ] **B7 — Defeat/reset.** Subscribe to player `died` and beacon `destroyed`; on either, call wave manager `stop_run()`, disable input, show reason + Restart/Menu buttons. Restart starts **new state** (wave 1, fresh HP, zero shards); menu navigates safely. **Test:** trigger both loss modes in B harness independently, buttons work. Commit.
- [ ] **B8 — Victory/Rite.** Keep an internal `all_waves_cleared` boolean from wave manager; after TRUE, E near beacon calls `perform_witness_rite()` instead of repair. Beacon turns amber; show brief ending overlay with Replay/Menu. **Test:** E on wave 1 cannot win, E after mock all-clear can, repeat input never triggers twice. Commit.

**Gate 2:** All B-owned systems independently exercise repair, loss, win gating and restart with mocked A signals. Push.

## Phase 3 — You lead actual integration

- [ ] **I1** Request both branches committed/pushed and stop concurrent edits; create integration branch from `main` (or approved baseline) and merge A and B in controlled sequence.
- [ ] **I2** Wire real A Player, enemies, WaveManager and shard pickups into `main.tscn` and connect their published signals. Initialize HUD from current state, not only future signals. Spawn enemies under a stable world container; connect `start_run(player, beacon, spawn_parent)` when gameplay starts.
- [ ] **I3** Test enemy target assignment; player attacks; enemy hits; shard pickup → HUD count → E repair. Fix glue in **your files**; ask A to fix player/enemy issues in A files.
- [ ] **I4** Test each loss path, stop timers/spawns, restart clear state and reload world, correct HUD after reset.
- [ ] **I5** Verify waves 1–3; development-jump to waves 4–9 to ensure no duplicate spawns / stalled wave transitions / broken beacon attacks.
- [ ] **I6** Push one known-good playable integration commit, ask A to run it and report. Back up this build before adding boss.

**Gate 3:** One coherent game with waves 1–9, damage, shard collection, repairs, death/restart. You alone edit integrated `main.tscn`/`main.gd`.

## Phase 4 — Boss presentation, ending, release

- [ ] **B9 — Boss UI.** Add readable boss health bar when the boss spawns; hide on death/other waves. Coordinate health signal/read-only fields with A **before** coding any new boss API. Test health values and correct visibility. Commit.
- [ ] **B10 — Finale.** When `all_waves_cleared` fires (boss included), show “Return to beacon” prompt; require E near beacon; animate white → amber; show short ending and Replay/Menu. Never allow ending early. Commit.
- [ ] **B11 — Final merge.** Merge A9/A10 boss work; verify exact wave 10 roster, boss's two attacks, wave only clears when boss + all adds dead. Re-run normal victory and defeat paths. Commit.
- [ ] **R1** Readability pass: contrast, wave counter, boss indicator, world borders, cooldown and prompts; use placeholders rather than block on PNGs.
- [ ] **R2** Balance with A: test repairs and waves 7–10; reduce enemy counts/damage before dropping approved mechanics.
- [ ] **R3** Play full normal game from menu; ensure no debug skips, runtime errors, softlocks or repeated boss spawn.
- [ ] **R4** Independently test player death and beacon destruction, replay/menu, white→amber Rite.
- [ ] **R5** Export for Windows; launch **exported exe** on presentation machine; keep known-good copy and backup archive.
- [ ] **R6** Rehearse 3–5 minute showcase with controls, multiple enemy types, damage/repair, and boss/Rite; label any test-only wave skip if used.
- [ ] **R7** Lock features; only crash/softlock/readability fixes after export.

**Final B acceptance:** Integrated project loads; on-screen fixed HUD tracks state; repair interaction is transactional; no premature win; player/beacon defeat pathways work; boss appears in wave 10; exported game launches and demos reliably.

## Copy-ready Codex starter prompt (B1 only)

> Read `MASTER_MVP.md` and `DEVELOPER_B_MVP.md`. You are Developer B, responsible only for the arena/UI-owned paths stated in my file. Implement **B1 ONLY** in Godot 4: an ~1800×1100 bounded top-down arena with readable placeholder ground, central beacon marker, several edge spawn markers, and a standalone `scenes/tests/b_arena_test.tscn`. Do not modify Developer A paths, `project.godot`, or the master files. Do not require final PNG art, and do not create a separate player/combat system. Report exact files changed, Godot tests and manual verification instructions, blockers, and STOP after B1.

**Every follow-up prompt:** “Implement task `B#` from `DEVELOPER_B_MVP.md`, obey Master Section 3, edit only my owned paths, include a test scene/manual acceptance steps, and stop.”

**Status handoff to A:** `B task | coded / locally tested / merged | branch + commit | integration blocker | next action`.
