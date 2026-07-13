# Charybdis Keyboard System

Complete software stack for a Charybdis split keyboard with PMW3610 thumb trackball: firmware, layout optimization, interactive coach, and Windows automation — split across 4 repos that work together.

## Hardware

| Component | Detail |
|-----------|--------|
| Keyboard | Charybdis split (V&Z), 36 + 3 thumb keys per half |
| Controllers | 2x Nice!Nano v2 (nRF52840) |
| Trackball | PMW3610 on right thumb cluster |
| Connectivity | BLE (5 profiles) + USB-C |
| Host OS | Windows 11, Norwegian keyboard layout |
| Layout | 11 layers, 616 total key bindings |

## Repos

All 4 repos must be cloned into the same parent directory.

| Repo | What it does |
|------|-------------|
| [charybdis-zmk-config](https://github.com/Glx28/zmk-config-charybdis-beacons) | ZMK firmware config, layout CSV (source of truth), ZMK Studio apply/verify scripts. Firmware builds via GitHub Actions. |
| [charybdis-optimizer](https://github.com/Glx28/charybdis-optimizer) | 13-module Node.js analysis pipeline + Python DEAP evolutionary optimizer. Evolves shortcut placement using a 12-factor fitness function. |
| [charybdis-coach](https://github.com/Glx28/charybdis-coach) | Browser-based interactive keyboard visualizer. Shows all 11 layers, live layer tracking, per-app workflow guides, practice mode. Zero build — static HTML + JS. |
| [charybdis-tools](https://github.com/Glx28/charybdis-tools) | Windows host helpers: AHK shortcut logger, beacon layer tracker, trackball benchmarks, mouse settings, launcher scripts, and the bootstrap installer. |

## Fresh Windows Setup

Install prerequisites first:
- [Git](https://git-scm.com/download/win)
- [Node.js LTS](https://nodejs.org/)
- [Python 3.10+](https://www.python.org/downloads/)
- [AutoHotkey v2](https://www.autohotkey.com/)

Then one command does everything — clones all repos, installs deps, applies mouse settings, starts coach + beacon:

```powershell
git clone https://github.com/Glx28/charybdis-tools.git charybdis-tools
powershell -ExecutionPolicy Bypass -File charybdis-tools\charybdis.ps1 bootstrap
```

For the main dev machine (adds Python deps for evolutionary optimizer):

```powershell
powershell -ExecutionPolicy Bypass -File charybdis-tools\charybdis.ps1 bootstrap -IncludeOptimizer
```

Then run `charybdis.ps1 install-startup` once to install a Scheduled Task for reboot recovery.

## Start Everything After Reboot

With `install-startup` run once, a Scheduled Task starts everything automatically ~10s after logon - no manual step needed. To do it manually, or to pull the latest promoted layout first:

```powershell
powershell -ExecutionPolicy Bypass -File charybdis-tools\charybdis.ps1 update
```

This pulls all repos, validates the release, and (re)starts:
- The AHK helper (shortcut logger + beacon)
- Python HTTP server on port 8765 (serves the coach app)
- Beacon listener (tracks which keyboard layer is active)
- Opens the coach in your browser at http://127.0.0.1:8765/charybdis-coach/

## How Data Flows Between Repos

```
zmk-config                optimizer                  coach               tools
(source of truth)          (analysis + evolution)     (visualization)     (runtime)
                                                                    
charybdis.json ──────────> canonical.json                                 
keybindings_explained.csv ─────────────────────────> data/*.csv           
layout_spec.json ──────────────────────────────────> data/*.json          
charybdis_apps.json ───────────────────────────────> data/*.json          
                                                                          
                           evolved_apply.js ──> ZMK Studio console        
                           evolved_verify.js ─> ZMK Studio console        
                                                                          
                                                     app.js <──────── charybdis_state.json
                           usage_stats.json <──────────────────────── shortcut_usage.jsonl
```

**zmk-config** is the source of truth. The optimizer reads from it, evolves better layouts, and generates apply/verify scripts. After applying in ZMK Studio, `sync_repos.ps1` pushes updated data to coach and optimizer. The tools repo logs usage at runtime, which feeds back into the optimizer for the next evolution cycle.

## Sync After Layout Changes

After applying a new layout in ZMK Studio:

1. Export the new layout from ZMK Studio (paste `zmk_studio_layout_exporter.js` in console)
2. Save the exported `charybdis.json` to `charybdis-zmk-config/config/`
3. Re-export `keybindings_explained.csv` from Studio
4. Run the sync script:

```powershell
cd charybdis-optimizer
powershell -ExecutionPolicy Bypass -File sync_repos.ps1 -CommitMessage "feat: apply evolved layout" -Push
```

This copies canonical.json, keybindings CSV, layout_spec, apps config, and Norwegian host config to the repos that need them, then commits and pushes all 4 repos.

## Evolving a New Layout (Dev Machine Only)

```powershell
# 1. Run the analysis pipeline
cd charybdis-optimizer
node pipeline/run_pipeline.js

# 2. Run evolution (hours/days depending on config)
python evolve/run_evolution.py build

# 3. Generate ZMK Studio scripts
cd evolve && python export_zmk.py ../build

# 4. Apply in ZMK Studio
#    Paste build/evolved_apply.js in console
#    Paste build/evolved_verify.js to confirm

# 5. Sync all repos
cd ..
powershell -ExecutionPolicy Bypass -File sync_repos.ps1 -CommitMessage "feat: apply evolved layout" -Push
```

## Directory Layout

```
charybdis-zmk-config/         # Firmware + layout source of truth
  config/charybdis.json        #   ZMK Studio device export
  config/charybdis.keymap      #   ZMK keymap (input processors, trackball)
  layout/keybindings_explained.csv  # All 616 keys (canonical reference)
  scripts/zmk-studio/         #   Apply/verify/export scripts for ZMK Studio
  firmware/                    #   Pre-built UF2 files

charybdis-optimizer/           # Analysis + evolution
  pipeline/                    #   13-module Node.js pipeline
  evolve/                      #   Python DEAP optimizer (12-factor fitness)
  app-keybindings/             #   18 app shortcut definitions
  workflows/                   #   28 workflow simulations
  build/                       #   Pipeline output, evolved scripts
  sync_repos.ps1               #   Cross-repo sync script

charybdis-coach/               # Interactive keyboard coach
  index.html, app.js           #   Zero-build SPA
  data/                        #   Synced from zmk-config
  workflows/                   #   Per-app shortcut guides

charybdis-tools/               # Windows host helpers
  charybdis.ps1                #   Unified launcher: start/stop/update/doctor/bootstrap/install-startup
  ahk/charybdis_helpers.ahk   #   Beacon + shortcut logger (auto-starts)
  powershell/                  #   Scripts charybdis.ps1 calls
  python/                      #   Beacon listener, USB monitor, coach HTTP server
  runtime/                     #   Live state files (mostly gitignored)
```
