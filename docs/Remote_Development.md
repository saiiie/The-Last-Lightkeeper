# Safe remote development

## Status and boundaries

Godot was not invoked locally. Do not open the editor, run scenes, use headless Godot, export locally, or run a local workflow emulator on this laptop. Only filesystem/static Python checks are authorized here. No software or system settings were changed.

The project has an empty Node2D main scene, not a playable map. Remote import, resource loading and Web export are **not yet verified**: no commit, push, workflow run or deployment was performed. Task 5 requires separate approval.

`docs/Asset_Preparation_Report.md` was absent at inspection and could not be read. The four existing design/story/visual documents, asset manifests and prepared resources were used instead. No existing files were edited; all 100 PNGs match their manifest hashes. The two existing `.tres` resources required no corrections. Aren still has four static idle directions and no walking frames; terrain remains visual-only.

## Version and settings

CI pins **Godot 4.5.2-stable**, standard Linux x86_64, with **4.5.2.stable** export templates. This is an official stable maintenance release supporting the existing Godot 4 resource formats and single-threaded Web exports; the project documents specified only Godot 4. It is a reproducible baseline, not a claim to use the latest release. Engine and templates are downloaded from the official godotengine/godot-builds release and checked against its SHA-512 checksum list on the runner.

Project settings: Compatibility/OpenGL, 640×360 base viewport, canvas_items stretch with keep aspect, nearest texture filtering, windowed mode and V-Sync enabled. The Node2D root establishes the 2D project; no nonexistent “game type” configuration property is used. `config/features` declares the 4.5 feature baseline; the workflow pins the exact patch.

The Web preset disables threads and GDExtensions. PWA is disabled; no cross-origin isolation workaround is needed for this configuration. Documentation, tools, CI tests, previews and design references are excluded from exports. Gameplay assets remain unchanged and available.

## Files and directory tree

All entries marked “new” were created by this task. Existing assets, documentation and `tools/validate_assets.py` were preserved.

```text
.github/workflows/web.yml                 new
.gitignore                               new
project.godot                            new
export_presets.cfg                       new
assets/                                  unchanged (100 PNGs, manifests, resources)
docs/
  Game_Design.md                          existing
  The_Last_Lightkeeper_Story.md            existing
  Visual_and_Asset_Plan.md                 existing
  Visual_Implementation_Guide.md           existing
  Remote_Development.md                   new
scenes/
  main.tscn                              new
  levels/.gitkeep                         new
  characters/.gitkeep                     new
  props/.gitkeep                          new
scripts/.gitkeep                          new
resources/.gitkeep                        new
tests/remote_resource_check.gd            new; remote CI only
tools/
  validate_assets.py                      existing; safe local check, needs Pillow
  validate_project.py                     new; safe local check, standard library
  remote_validate_export.py               new; GitHub-hosted CI only
```

The workflow uses JSON syntax in a `.yml` file (JSON is a YAML subset), allowing its structure to be checked locally without installing a YAML parser. Godot cache, export credentials, build output and CI logs are ignored. Source `.import` sidecars and `.uid` files are not ignored.

## Local static validation

Safe commands, from the repository root:

```powershell
python tools/validate_project.py
python tools/validate_assets.py
git diff --check
```

These passed during initialization. Checks cover configuration values, existing resource/main-scene paths, all 100 PNG hashes and decodes, original dimensions/alpha data, duplicate names, resource IDs/load steps/delimiters, terrain source count, idle sheet order, export settings, workflow structure and deployment gates, Python syntax and required directories. This is not Godot syntax/import/rendering validation. `git diff --check` checks tracked changes; new configuration files were also read and parsed by the static checker.

Do not execute `tools/remote_validate_export.py` locally. It has an environment guard before any engine lookup/execution and refuses to run outside a GitHub-hosted runner. Do not bypass that guard or emulate the CI environment.

## Commit and push, after approval

The current branch is `main`; the configured origin is `https://github.com/saiiie/The-Last-Lightkeeper.git`. The existing assets/docs/tools were already untracked at the start of this task, so include the asset preparation work in the commit or the remote build will lack its dependencies. Review everything being staged:

```powershell
git status --short
git add .github .gitignore project.godot export_presets.cfg scenes scripts resources tests tools assets docs
git diff --cached --stat
git diff --cached --check
git commit -m "chore(godot): initialize project and remote web validation"
git push origin main
```

These commands are instructions only; they were not executed. **Pushing main automatically runs the remote validation/export workflow**, so approval to push must also cover that run. It does not deploy Pages. If branch protections require a PR, use the repository's normal branch/PR process instead; merging to main triggers the build.

## Manually run validation and download the artifact

1. After approved changes reach the default branch, open the repository on GitHub.
2. Select **Actions → Validate and export Web → Run workflow**.
3. Select `main`, leave **Publish preview after approval** unchecked, then run.
4. The GitHub-hosted Ubuntu runner checks files, downloads the pinned engine/templates, imports resources, loads both prepared resources and the main scene, runs the empty scene for two headless frames, and exports Web.
5. Steps fail on nonzero engine exits or detected error messages, even if Godot returns zero. A successful export must contain nonempty HTML, JS, WASM and PCK files.
6. Download `lightkeeper-web-<commit SHA>` from the run's **Artifacts** section. Logs are uploaded as `godot-logs-<run ID>` when available, including on failure. Retention is 14 days.

Do not open the downloaded HTML as a `file://` page; Web builds require HTTP(S) hosting. The optional Pages job below supplies that hosting without installing a local server. A successful headless export is not a browser rendering test.

## Enable browser preview only after approval

Deployment is disabled by default. All gates must be satisfied: successful build in the same run, manual workflow dispatch, checked deployment input, `main` branch, and repository variable `ENABLE_PAGES` exactly `true`.

1. In **Settings → Pages → Build and deployment → Source**, select **GitHub Actions**. Availability for private repositories depends on the GitHub plan.
2. In **Settings → Secrets and variables → Actions → Variables**, create repository variable `ENABLE_PAGES` with value `true`. No new secret is required.
3. In **Settings → Environments → github-pages**, optionally configure required reviewers if supported, and restrict deployment branches to `main`.
4. Manually run **Validate and export Web** on `main` with the deployment option checked. This builds and validates that commit again; the separate deploy job downloads only its successful artifact, packages it with official Pages actions and deploys it.
5. Use the URL shown by the deployment job/environment. The expected default is `https://saiiie.github.io/The-Last-Lightkeeper/`, but it is not live or verified by this task.

Remove the variable or set it to `false` to prevent future workflow deployments. This does not unpublish an existing site; use Pages settings to unpublish if needed. Ordinary pushes continue to build artifacts only.

Browser playback still runs the WebAssembly game and WebGL rendering on the viewing device; it is not remote streaming and is not guaranteed to avoid the laptop's shutdown problem. No browser/GPU test was performed. The initial preview will be empty because the main scene deliberately contains no gameplay or artwork.

## Pending verification and issues

- First approved remote run must confirm actual engine parsing, import, resource loading, release downloads/template layout and Web export. Workflow structure has only been checked statically.
- After successful export, browser compatibility, pixel filtering, scaling and visual rendering still need testing on a safe device.
- The missing asset preparation report may be restored from the user's copy if needed; it was not reconstructed or overwritten here.
- No task beyond initialization, remote build preparation and optional deployment setup is included. Wait for approval before Task 5.

## Official references

- [Godot 4.5.2 stable release](https://godotengine.org/download/archive/4.5.2-stable/)
- [Godot 4.5 project settings](https://docs.godotengine.org/en/4.5/classes/class_projectsettings.html)
- [Godot command-line import/export](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
- [Godot 4.5 Web export and single-thread support](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html)
- [GitHub Pages custom workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
