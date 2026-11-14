# Task 5 — Whispering Forest test map

Implemented as an environment-only test scene. No player, input, following camera, lighting system, combat, NPCs or story logic. No Godot executable was run locally. Changes are uncommitted; remote validation/export is pending.

## Layout and presentation

48×32 cells at 32 pixels = 1536×1024 pixels. Five clearings form a winding closed loop:

- Spawn (288, 256): open ground surrounded by ancient/young trees.
- Dark trail (768, 224): bent northern path with dense tree silhouettes.
- Abandoned camp (1248, 384): workbench and intact/damaged supplies around an open center.
- Damaged forest (1184, 800): charred/dead trees, broken trunk, roots, withered plants and sparse mystical ground.
- Obstacle zone (448, 800): rocks, logs, roots and brambles with open approaches and bypasses.

The terrain corridor is approximately 112 pixels wide, with larger clearings. The obstacle zone varies passage width; clearance is checked separately from tile appearance. The world boundary prevents walking off the map. Tree rows conceal its edge visually. Muted teal/green modulation darkens existing art; mystical accents remain sparse. No PNGs were changed.

`scenes/main.tscn` instances the reusable map at its original pixel scale and supplies a fixed overview Camera2D (zoom 0.34). It displays the entire environment in the existing 640×360 viewport without camera following. Overview downscaling is for layout review, not final pixel-scale gameplay presentation. The reusable level itself contains no camera; future gameplay can supply its own camera. The pale diamond is the visible spawn marker.

## Scene hierarchy

```text
Main
├── Forest (whispering_forest_test.tscn)
│   ├── Terrain (TileMapLayer)
│   ├── WorldObjects (Y-sorted)
│   │   ├── Decorations (walkable plants/debris)
│   │   ├── Obstacles (solid tree bases, rocks, logs, roots, brambles)
│   │   └── EnvironmentalProps (camp supplies)
│   ├── Boundary (StaticBody2D + four shapes)
│   ├── SpawnMarker → VisibleMarker
│   └── LightingHooks → Camp, Corruption (empty markers only)
└── Overview (fixed Camera2D)
```

## Terrain limitations

The existing TileSet remains unchanged. Only source IDs 0, 8, 17, 18 and 58 are used: grass_dark_01, grass_moss_01, soil_dirt_02, soil_dirt_03 and mystical_ground_03. The original tiles were cropped from one illustration and are not verified seamless. Conservative patches avoid unverified transition tiles, adjacency rules and autotiling; visible seams may remain and need browser review.

`forest_terrain.gd` fills the TileMapLayer once in `_ready()` from serialized source IDs. This avoids guessing engine binary tile serialization. Props and collision geometry are authored in text scenes; terrain appears at runtime, not in an unexecuted editor preview. There is no procedural runtime randomness or per-frame processing.

## Collision contract

20 reusable prop scenes live under `scenes/props/forest/`. Each solid prefab uses a RectangleShape2D marked local-to-scene, so instances can have independently adjusted footprints. Shape sizes were authored explicitly, not generated from image/alpha bounds. Trees block only their bases; sprites extend upward from their base anchors and share Y-sorting across object groups. Solid objects use physics layer 1, mask 0. A future player must include layer 1 in its collision mask.

Grass, dirt, moss, ferns, bushes, withered shrubs and loose charred debris have no collision. Large roots and broken trunks are solid in this test. Four boundary rectangles enclose the map.

Footprints in pixels (width × depth):

- `tree_ancient`: 28×18
- `tree_young`: 18×14
- `tree_dead`: 22×16
- `tree_charred`: 24×16
- `forest_rock_cluster`: 40×24
- `prop_boulder_small`: 22×16
- `prop_fallen_log`: 52×14
- `prop_workbench_small`: 46×20
- `prop_crate`: 24×20
- `prop_crate_broken`: 22×16
- `prop_barrel`: 20×18
- `prop_barrel_damaged`: 20×16
- `forest_brambles`: 42×24
- `forest_broken_trunk`: 30×18
- `forest_roots`: 36×12
- `forest_stump`: 28×18
- `forest_ferns`: 0×0 (walkable)
- `forest_bush`: 0×0 (walkable)
- `forest_withered_shrub`: 0×0 (walkable)
- `prop_wood_debris_charred`: 0×0 (walkable)

## Reused artwork

Terrain: grass_dark_01.png, grass_moss_01.png, soil_dirt_02.png, soil_dirt_03.png, mystical_ground_03.png.

Objects: each prefab name in the footprint list corresponds to its existing PNG in `assets/environments/forest/{trees,props,vegetation}/`. All 100 approved PNG hashes remain unchanged. No new artwork, spritesheets or terrain atlases were generated.

## Files

- Modified `scenes/main.tscn`: forest instance and fixed overview.
- Added `scenes/levels/whispering_forest_test.tscn`: terrain data, 349 objects, boundary, spawn and hooks.
- Added 20 `scenes/props/forest/*.tscn` reusable prefabs.
- Added `scripts/forest_terrain.gd`: one-time TileMapLayer population.
- Added `resources/forest_test_layout.json`: layout, placement and footprint ledger.
- Added `tools/build_forest_test.py`: deterministic filesystem-only scene authoring utility. Re-running overwrites the authored map/prefabs/main; preserve manual scene edits before using it.
- Added `tools/validate_forest_test.py`: static geometry/connectivity checks.
- Modified `tools/validate_project.py`: runs the forest checker locally and in existing CI.
- Modified `tests/remote_resource_check.gd`: remote-only forest resource/hierarchy checks.
- Added this report. Project settings, assets and workflow unchanged.

## Static validation and remaining checks

`python tools/validate_project.py`, `python tools/validate_assets.py`, and `git diff --check` pass. Forest validation checks 208 obstacle rectangles, all five connected clearings, the closed loop, 1536 terrain cells, scene placement records and four boundary shapes. Conservative 16-pixel grid flood-fill reaches 2785 samples with a provisional 24×24 actor footprint; the entire authored route is also checked continuously at one-pixel increments against inflated obstacle rectangles.

These checks establish geometric clearance under that assumption, not actual physics gameplay. Larger future actors require rechecking. Remote Godot parsing/import/runtime tile population, sprite sorting/anchors, perceived darkness, terrain seams and actual movement/collision behavior remain to be validated. Movement testing awaits the separately approved player task.

## Commit and remote validation instructions

After review, from the repository root:

```powershell
python tools/validate_project.py
python tools/validate_assets.py
git add scenes/main.tscn scenes/levels/whispering_forest_test.tscn scenes/props/forest scripts/forest_terrain.gd resources/forest_test_layout.json tools/build_forest_test.py tools/validate_forest_test.py tools/validate_project.py tests/remote_resource_check.gd docs/Task_5_Forest_Test_Map.md
git diff --cached --check
git commit -m "feat(forest): add environment test map and collisions"
git push origin main
```

Pushing main runs existing remote Godot 4.5.2 validation and Web export; the deployment job is skipped for pushes. Review the run and downloaded artifacts. To manually validate, select Actions → Validate and export Web → Run workflow on main, leaving deploy_pages unchecked. Only after separate deployment approval should you run it with deploy_pages enabled (and ENABLE_PAGES=true). Do not run Godot or a local workflow emulator on the laptop.

Task 6 has not begun.
