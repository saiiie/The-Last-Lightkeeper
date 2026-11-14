# Task 5 visual revision

Status: uncommitted; no local Godot execution, remote run or deployment. This is a revised visual candidate awaiting browser review. The earlier Task 5 report describes the superseded first layout.

## Diagnosis

Before: only 5 of 64 source tiles were used. Dark grass was one repeated texture. Moss used a periodic block formula; dirt overrode it throughout broad paths and every clearing. Mystical ground was restricted to just five cells behind scenery. Ground details were never selected. Transition tiles were deliberately excluded because adjacency was unverified. Dense, near-grid tree placement amplified repetition and hid the ground.

The inspected grass/dirt and grass/moss transitions contain baked directional borders or ground motifs. Their labels do not specify compatible edges or corner topology. These assets have not demonstrated a convincing seamless transition system; the revision does not introduce autotiling or claim seams are solved. Tile-level edges remain a limitation.

## Category usage (1536 cells)

| Category | Before | After | After % |
|---|---:|---:|---:|
| grass_dark | 882 | 1135 | 73.9% |
| grass_moss | 276 | 208 | 13.5% |
| soil_dirt | 373 | 150 | 9.8% |
| grass_dirt_transition | 0 | 0 | 0.0% |
| grass_moss_transition | 0 | 0 | 0.0% |
| ground_detail | 0 | 20 | 1.3% |
| mystical_ground | 5 | 23 | 1.5% |

## Per-tile usage (all 64 sources)

| Tile | Before | After |
|---|---:|---:|
| grass_dark_01.png | 882 | 77 |
| grass_dark_02.png | 0 | 118 |
| grass_dark_03.png | 0 | 133 |
| grass_dark_04.png | 0 | 116 |
| grass_dark_05.png | 0 | 202 |
| grass_dark_06.png | 0 | 117 |
| grass_dark_07.png | 0 | 191 |
| grass_dark_08.png | 0 | 181 |
| grass_moss_01.png | 276 | 2 |
| grass_moss_02.png | 0 | 50 |
| grass_moss_03.png | 0 | 29 |
| grass_moss_04.png | 0 | 20 |
| grass_moss_05.png | 0 | 39 |
| grass_moss_06.png | 0 | 13 |
| grass_moss_07.png | 0 | 20 |
| grass_moss_08.png | 0 | 35 |
| soil_dirt_01.png | 0 | 19 |
| soil_dirt_02.png | 318 | 58 |
| soil_dirt_03.png | 55 | 0 |
| soil_dirt_04.png | 0 | 8 |
| soil_dirt_05.png | 0 | 1 |
| soil_dirt_06.png | 0 | 7 |
| soil_dirt_07.png | 0 | 22 |
| soil_dirt_08.png | 0 | 35 |
| grass_dirt_transition_01.png | 0 | 0 |
| grass_dirt_transition_02.png | 0 | 0 |
| grass_dirt_transition_03.png | 0 | 0 |
| grass_dirt_transition_04.png | 0 | 0 |
| grass_dirt_transition_05.png | 0 | 0 |
| grass_dirt_transition_06.png | 0 | 0 |
| grass_dirt_transition_07.png | 0 | 0 |
| grass_dirt_transition_08.png | 0 | 0 |
| grass_dirt_transition_09.png | 0 | 0 |
| grass_dirt_transition_10.png | 0 | 0 |
| grass_dirt_transition_11.png | 0 | 0 |
| grass_dirt_transition_12.png | 0 | 0 |
| grass_dirt_transition_13.png | 0 | 0 |
| grass_dirt_transition_14.png | 0 | 0 |
| grass_dirt_transition_15.png | 0 | 0 |
| grass_dirt_transition_16.png | 0 | 0 |
| grass_moss_transition_01.png | 0 | 0 |
| grass_moss_transition_02.png | 0 | 0 |
| grass_moss_transition_03.png | 0 | 0 |
| grass_moss_transition_04.png | 0 | 0 |
| grass_moss_transition_05.png | 0 | 0 |
| grass_moss_transition_06.png | 0 | 0 |
| grass_moss_transition_07.png | 0 | 0 |
| grass_moss_transition_08.png | 0 | 0 |
| ground_detail_01.png | 0 | 1 |
| ground_detail_02.png | 0 | 2 |
| ground_detail_03.png | 0 | 2 |
| ground_detail_04.png | 0 | 5 |
| ground_detail_05.png | 0 | 1 |
| ground_detail_06.png | 0 | 7 |
| ground_detail_07.png | 0 | 0 |
| ground_detail_08.png | 0 | 2 |
| mystical_ground_01.png | 0 | 7 |
| mystical_ground_02.png | 0 | 0 |
| mystical_ground_03.png | 5 | 0 |
| mystical_ground_04.png | 0 | 0 |
| mystical_ground_05.png | 0 | 4 |
| mystical_ground_06.png | 0 | 2 |
| mystical_ground_07.png | 0 | 9 |
| mystical_ground_08.png | 0 | 1 |

## Revised layout

- Dark grass dominates. Nearby cells share texture variants through irregular spatial regions, with six moss patches and low-frequency boundary variation. Details occupy small pockets rather than a grid.
- Dirt follows the preserved loop with roughly 24–76 pixel visual width instead of a uniform 112 pixels. Its edge undulates; the camp retains a localized disturbed-soil patch. Visual dirt width is independent of walkable grass clearance.
- Mystical ground is confined to the damaged clearing and one selected northeastern trail edge.
- Trees use irregular, minimum-distance groves. Young trees break up ancient silhouettes; damaged groves favor charred/dead trees. Understory is restrained and clustered. Central floor is more exposed.
- Spawn remains open, the northern trail is enclosed by groves, camp supplies retain an open center, damaged forest retains broken trunks/roots/withered plants, and the obstacle zone keeps deliberate rocks/logs and bypasses.
- Objects: 349 → 121. Trees: 188 → 52. Solid object footprints: 208 → 72; plus four unchanged boundary shapes.

## Gray areas and bounds

The fixed 0.34 overview zoom shows approximately 1882×1059 world pixels inside a 640×360 viewport, exceeding the 1536×1024 map. That exposes the default clear background, including a bottom margin. The old placement loop also permitted top overhangs. A large dark teal Polygon2D backdrop now covers the viewport beyond the map, and revised placements keep every full sprite canvas inside the map. The browser screenshot was not provided, so this explains the source-level cause rather than proving every reported gray pixel came from it. No camera following or lighting was added.

## Validation

Safe checks passed: project/resource paths, PNG hashes/decodes, resource syntax checks, 1536 cells, all five clearing centers reachable, and the full closed route clear for a provisional 24×24 actor. Flood-fill reaches 4687 grid samples. Full sprite-canvas bounds were checked for every placed object. Original PNGs, TileSet, project configuration and GitHub workflows are unchanged.

Remote Godot validation and browser visual review remain pending. Existing terrain textures may still show seams or high contrast between categories; reduced repetition does not make the original illustration crops seamless. The overview also downsamples pixel art.

## Publish after approval

Run `python tools/validate_project.py` and `python tools/validate_assets.py`, review `git diff`, then commit the revised generator, level/main scenes, layout ledger, before-usage ledger, validator and this report. Push main to run the existing remote validation/export. After a successful run and deployment approval, manually run **Validate and export Web** on main with `deploy_pages` checked and `ENABLE_PAGES=true`. Review the new browser preview before accepting the visuals. No commit, push, deployment or Task 6 work was performed.
