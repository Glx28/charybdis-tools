# Charybdis Keyboard System

Charybdis split keyboard with PMW3610 thumb trackball. The Windows runtime (coach, logger, beacon handler) is self-contained in `charybdis-tools`; firmware and layout optimization remain separate development projects.

## Hardware

| Component | Detail |
|-----------|--------|
| Keyboard | Charybdis split (V&Z), 36 + 3 thumb keys per half |
| Controllers | 2x Nice!Nano v2 (nRF52840) |
| Trackball | PMW3610 on right thumb cluster |
| Connectivity | BLE (5 profiles) + USB-C |
| Host OS | Windows 11, Norwegian keyboard layout |
| Layout | 11 layers, 616 total key bindings |

## Repositories

Only `charybdis-tools` is needed to run the Windows coach, shortcut logger, and beacon handler. It bundles the coach UI and host-side layout/config data. Firmware and layout optimization repos are optional and only needed for those development workflows.

| Repo | What it does |
|------|-------------|
| [charybdis-tools](https://github.com/Glx28/charybdis-tools) | Self-contained Windows runtime: bundled coach, AHK shortcut logger/beacon handler, launcher, trackball utilities. |
| [charybdis-zmk-config](https://github.com/Glx28/zmk-config-charybdis-beacons) | Optional ZMK firmware and layout development; firmware builds via GitHub Actions. |
| [charybdis-coach](https://github.com/Glx28/charybdis-coach) | Optional coach UI source repository; published runtime snapshot is bundled in `charybdis-tools/coach/`. |
| [charybdis-optimizer](https://github.com/Glx28/charybdis-optimizer) | Optional Node.js/Python layout analysis and optimization. |

## Fresh Windows Setup

Install prerequisites first:
- [Git](https://git-scm.com/download/win)
- [Python 3.10+](https://www.python.org/downloads/)
- [AutoHotkey v2](https://www.autohotkey.com/)

Clone the runtime once, then start the complete stack:

```powershell
git clone https://github.com/Glx28/charybdis-tools.git charybdis-tools
cd charybdis-tools
pwsh -NoProfile -ExecutionPolicy Bypass -File .\start_charybdis.ps1
```

Run `pwsh -NoProfile -ExecutionPolicy Bypass -File .\charybdis.ps1 install-startup` once to start automatically at logon.

## Start Everything After Reboot

With `install-startup` run once, the Scheduled Task starts everything automatically after logon. Update the runtime with `git pull`, then restart:

```powershell
git pull
pwsh -NoProfile -ExecutionPolicy Bypass -File .\start_charybdis.ps1 -Restart
```

The launcher starts:
- The AHK helper (shortcut logger + beacon)
- Python HTTP server (uses port 8765 when available; otherwise selects and reports a free port)
- Coach UI at `http://127.0.0.1:<selected-port>/charybdis-coach/`

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

For layout development, **zmk-config** is the source of truth. The optimizer reads from it and generates apply/verify scripts. Runtime uses the versioned coach/layout snapshot bundled in `charybdis-tools`; the tools repo logs usage locally.

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

This updates the separate firmware/optimizer development repositories. The Windows runtime consumes the files bundled in `charybdis-tools`; publish those runtime snapshot updates from this repository separately.

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

# 5. Sync development repos (runtime bundle is updated separately)
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
