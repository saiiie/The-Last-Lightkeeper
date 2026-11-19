# The Last Lightkeeper: Hold the Light — DEVELOPER A MVP

**Role:** Player, combat, enemies, drops, spawning, wave manager, boss.  
**Branch:** `feature/gameplay` · **Read first:** `MASTER_MVP.md` (especially Sections 2–4).  
**Deadline:** November 20, 2026, 1:00 PM Asia/Manila.

## Your boundaries (important for Codex)

**Own only:** `scenes/player/`, `scenes/enemies/`, `scenes/projectiles/`, `scenes/pickups/`, `scripts/player/`, `scripts/enemies/`, `scripts/combat/`, `scripts/pickups/`, `scripts/systems/wave_manager.gd`, and `scenes/tests/a_*`. Keep any additional A-owned helper scripts in those paths.

**Do not edit:** `project.godot`, `scenes/main.tscn`, `scripts/main.gd`, `scenes/arena/`, `scenes/beacon/`, `scenes/ui/`, `scenes/menus/`, B test scenes, or any master document while B is integrating. Godot inputs/collision layers are set together in Phase 0.

**Delivery contract:** player root `CharacterBody2D` with signals `health_changed(current,maximum)`, `died`, `shards_changed(count)`, `pulse_cooldown_changed(remaining,total)`; methods `take_damage(amount)`, `add_shards(amount)`, `spend_shards(amount)->bool`, `set_controls_enabled(enabled)`; readable current values. Enemies expose `set_targets(player,beacon)` and emit `died(world_position)` exactly once. WaveManager exposes `start_run(player,beacon,spawn_parent)`, `stop_run()` and signals `wave_started(current,total)`, `wave_cleared(current)`, `all_waves_cleared`. **Master Section 3 has exact API definitions.** Player does NOT handle E/repair or ending.

## Phase 0 — Shared foundation (with B; do not code tasks yet)

- [ ] **F0.1–F0.5** Agree Godot version, initialize single repo, verify inputs + collisions, review frozen master interface, pull same baseline, create `feature/gameplay` branch in own workspace.
- [ ] Confirm B owns main scene and integration; you own gameplay components. Confirm how you will provide standalone test scenes.

**Gate 0:** `main` loads on both machines; your branch starts from same commit as B.

## Phase 1 — Player and first enemy

- [ ] **A1 — Player (first).** Implement reusable `scenes/player/player.tscn`: WASD, `CharacterBody2D`, collision, `Camera2D`, movement ~230 px/s, 100 HP, invulnerability against repeated overlapping damage if needed, death emitted once. **Test:** walk in all directions, camera follows, collide with a test boundary, call damage until dead. Commit.
- [ ] **A2 — Melee and ranged.** Mouse-direction melee (~65 px, 20 dmg, 0.35 s cooldown), straight light projectile (12 dmg, 0.55 s cooldown; unlimited ammo). Avoid self-hits, hit once per projectile/attack, free offscreen/lifetime projectiles. **Test:** rotate aim, hit a dummy from several angles, measure cooldown. Commit.
- [ ] **A3 — Lantern pulse.** Q emits obvious temporary ~110 px circle, briefly stuns/knocks back nearby enemies, 6 s cooldown, informs HUD signal. **Test:** two dummy enemies interrupted, out-of-range target unaffected, cooldown blocks repeated cast. Commit.
- [ ] **A4 — Enemy base + Thornbound.** Basic chase toward mock beacon, stop and melee beacon in range; 35 HP, ~8 damage/strike; player attacks reduce enemy HP; `died(world_position)` exactly once. **Test:** enemy reaches stationary mock beacon and deals damage; can be killed; no attack after death. Commit.

**Gate 1:** A standalone Godot test scene proves A1–A4 with no missing B assets or scenes. Push and tell B branch/commit.

## Phase 2 — Three enemies, shards, 10-wave controller

- [ ] **A5 — Cinder Wisp.** ~25 HP; holds distance and shoots aimed enemy projectiles toward beacon (~5 beacon damage). Player can be hit when intercepted. **Test:** Wisp fires without approaching on top of beacon, projectile collision and cleanup work. Commit.
- [ ] **A6 — Hush Brute.** ~100 HP, slow direct path and heavy beacon melee (~20). Clearly bigger/different placeholder. **Test:** slow/heavy distinct from Thornbound; can take melee and ranged damage, die once. Commit.
- [ ] **A7 — Light shard.** Spawn one collectible per standard death; generous pickup radius, award via `player.add_shards(1)` once. No full inventory. **Test:** dead enemy drops once, collected shard disappears, player count increments exactly once; collecting from multiple kills works. Commit.
- [ ] **A8 — WaveManager.** Create `scripts/systems/wave_manager.gd` Node, ten-wave table from master, stagger spawn 1.2–2s, cap ~8–12 alive standards, spawn near arena edges (get allowed spawn bounds/markers from B via stable runtime references/initialization rather than editing B). Waves clear only if **queue exhausted AND living count 0**. Intermission ~7 seconds. `stop_run()` cancels pending timer/spawns. Provide A-only temporary test tool to jump to waves 9/10. **Test:** wave 1 clears once; wave 2 triggers; debug waves 9/10 counts correct; no duplicate callbacks; stoppage prevents new enemy. Commit.

**Gate 2:** A's independent harness demonstrates 3 types, collectible shards, all ten wave definitions and correct wave transitions. Push; give B exact tested commit.

## Phase 3 — Integrate, don't edit B's scenes

- [ ] **I1** Pause after pushing stable A branch, send B changed files and API notes.
- [ ] **I2–I5** Help B verify movement, enemy targeting, hit detection, collectible collision layers, and live-count logic on merged project. If broken, fix only A paths, commit/push, ask B to re-merge.
- [ ] **I6** Run the integrated build on your own Godot after B posts a known-good commit; validate waves 1–9, repair loop, defeat/restart.

**Gate 3:** B confirms merged core game works. Save known-good checkpoint before boss work.

## Phase 4 — Boss, wave-10 completion, final test

- [ ] **A9 — Hush Warden boss.** Unique bigger enemy ~450 HP with **two distinct attacks**: 3-shot aimed volley reusing projectile system, and clearly warned ground slam with delayed actual damage. Beacons/player damaged only when attack legitimately hits; display callback/data so B can read boss health. **Test:** both attacks fire and hit as intended; warning precedes slam; boss can die; no attacks post-death. Commit.
- [ ] **A10 — Wave 10.** Boss + exactly 3 Thornbound, 2 Wisps, 1 Brute using master's wave list. Count boss in living-enemy accounting; **`all_waves_cleared` only once after every enemy (including boss) dies**, no wave 11. **Test:** defeat boss early while adds remain (no win), defeat adds before boss (no win), kill all (single completion). Commit/push.
- [ ] **R1–R4** Support B's final full test: reliable collisions, clear effects, no death loops, appropriate wave damage, fair repair economy. Fix only A-owned bugs; do not chase art polish.
- [ ] **R5–R7** Run exported build with B and verify keyboard/mouse controls. Freeze features when integration/export is verified.

**Final A acceptance:** Three standard enemies have different behaviors; melee, ranged and pulse all work; each kill drops a shard; all ten waves complete in order; Hush Warden demonstrates volley + slam; no duplicate wave ending or rogue spawns after defeat.

## Copy-ready Codex starter prompt (A1 only)

> Read `MASTER_MVP.md` and `DEVELOPER_A_MVP.md`. You are Developer A, responsible only for the gameplay-owned paths stated in my file. Implement **A1 ONLY** in Godot 4: a reusable player scene with WASD movement, collisions, Camera2D, health/damage/death API and visible placeholders. Do not edit `project.godot`, `main.tscn`, any B files, or shared docs. Create a standalone `scenes/tests/a_player_test.tscn` with dummy boundary and a way to test damage. Run/check what you can, list exact files changed, explain how I test A1 in Godot, note blockers, and STOP. Do not implement later tasks yet.

**Every follow-up prompt:** “Implement task `A#` from `DEVELOPER_A_MVP.md`, obey Master Section 3, edit only my owned paths, include a test scene/manual acceptance steps, and stop.”

**Status handoff to B:** `A task | coded / locally tested / pushed | branch + commit | API change? | blocker | next action`.
