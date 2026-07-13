# Charybdis Tools

> Windows host-side helpers for the Charybdis split keyboard: AHK automation, beacon layer tracking, shortcut usage logging, trackball benchmarks, and launcher scripts.

---

## AI Agent Quick Reference

If you are an AI agent reading this repo, here is everything you need to know in one place.

### What This Repo Does
- **AHK logger** (`ahk/charybdis_helpers.ahk`): Captures every shortcut, mouse click, scroll, layer change, and app switch. Writes to `runtime/shortcut_usage.jsonl`.
- **Beacon handler**: Receives BLE layer beacons from the keyboard via F13-F24 hotkeys. Writes `runtime/charybdis_state.json`.
- **Coach server**: Serves the browser-based keyboard visualizer at `http://127.0.0.1:8765/charybdis-coach/`.
- **Mouse settings**: Enforces 1:1 pointer speed, no acceleration.

### Layout Optimizer Analysis Rules For Agents

For generated layout/checkpoint analysis, use the repo's existing tools before any ad hoc inspection:

1. Read `runtime/evolved_v2_export/HANDOFF_LAYOUT_OPTIMIZATION.md`.
2. Identify the active/latest run with `pgrep -af run_evolution`, `../charybdis-optimizer-v2/build/latest_run_dir`, and direct checkpoint listing under `../charybdis-optimizer-v2/build/runs/<run>/`.
3. Run the standard checkpoint tools:
   - `python3 runtime/evolved_v2_export/promote.py --checkpoint <checkpoint.json>`
   - `python runtime/evolved_v2_export/analyze_checkpoint_standalone.py <checkpoint.json>`
   - `../charybdis-optimizer-v2/.venv/bin/python runtime/evolved_v2_export/acceptance_check.py <checkpoint.json>`
4. Compare against `../charybdis-zmk-config/layout/final_user_layout_v2.json` before recommending promotion.

Do not reverse-engineer checkpoint schemas or hand-edit generated layout artifacts unless the existing tools expose a specific bug to fix.

### One-Command Runtime Refresh

After a layout/default update, future agents should use `charybdis.ps1 update` instead of manually pulling repos, editing cache-busters, and restarting processes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\nos\charybdis-tools\charybdis.ps1 update
```

It pulls `charybdis-tools`, `../charybdis-coach`, and `../charybdis-zmk-config` (ensuring the ZMK repo is on `codex/build-coach-layers-cpi750`), fails loudly instead of silently skipping the pull if any repo has dirty tracked files (pass `-UseCurrent` to proceed anyway), validates the release via `runtime/evolved_v2_export/release_check.py` against `release_manifest.json`, then restarts the helper/logger, beacon listener, and coach server and prints `{ok, release, tools, coach, zmk, url}` (add `-Json` for machine-readable output). There is no cache-buster step anymore — `python/coach_http_server.py` sends `Cache-Control: no-cache` headers instead, so the tools repo never dirties itself just from starting.

### Prerequisites

The copy-paste installer below tries to install missing prerequisites with `winget`:

1. [Git for Windows](https://git-scm.com/download/win)
2. [Python 3.10+](https://www.python.org/downloads/) — for the coach server and optional Python beacon listener
3. [AutoHotkey v2](https://www.autohotkey.com/) — primary logger + beacon helper

If `winget` is unavailable, install those three manually and rerun the same block.

### Directory Layout (all repos share the same parent)
```
C:\Users\<user>\charybdis\            # parent directory used by the copy-paste commands
├── charybdis-tools\                  # this repo (AHK, logging, launchers)
│   ├── ahk\charybdis_helpers.ahk
│   ├── powershell\start_charybdis_helpers.ps1
│   ├── powershell\start_charybdis_coach.ps1
│   └── runtime\                      # live state (gitignored, created at runtime)
│       ├── charybdis_state.json      # current layer/app (read by coach)
│       ├── shortcut_usage.jsonl      # usage log (consumed by optimizer)
│       └── charybdis_events.jsonl    # heartbeats
├── charybdis-zmk-config\            # ZMK firmware, layout CSV (source of truth)
├── charybdis-coach\                  # browser-based keyboard visualizer
├── charybdis-optimizer\              # Node.js pipeline + Python evolution
└── charybdis-optimizer-v2\           # new Python-only optimizer (surrogate fitness)
```

---

## Copy-Paste Install / Repair / Start Everything

Use this on a new Windows machine, or on an existing machine when you want to repair/update all Charybdis host-side tooling.

Prerequisites (install manually first, `charybdis.ps1 bootstrap` checks for these but does not install them): [Git for Windows](https://git-scm.com/download/win), [Python 3.10+](https://www.python.org/downloads/), [AutoHotkey v2](https://www.autohotkey.com/). Node.js is optional and only needed for coach/keymap JavaScript development.

```powershell
# === CHARYBDIS FULL WINDOWS INSTALL / UPDATE / START ===
# Safe to rerun. Existing repos are updated; missing repos are cloned.
$Parent = Join-Path $env:USERPROFILE "charybdis"
$Tools = Join-Path $Parent "charybdis-tools"
if (-not (Test-Path (Join-Path $Tools ".git"))) {
    New-Item -ItemType Directory -Force -Path $Parent | Out-Null
    git clone https://github.com/Glx28/charybdis-tools.git $Tools
}
Set-Location $Tools
.\charybdis.ps1 bootstrap
.\charybdis.ps1 install-startup   # run once: creates the Scheduled Task for reboot recovery
```

`bootstrap` clones the sibling repos (`charybdis-zmk-config`, `charybdis-coach`; pass `-IncludeOptimizer` for `charybdis-optimizer` too), creates a `.venv` with `requirements-runtime.txt` installed, applies mouse settings, and starts the full stack. `install-startup` replaces old manually-added Startup shortcuts with a single Scheduled Task that starts AHK + beacon + coach together, ~10s after logon, with no network required. Run it from an elevated PowerShell for Scheduled Task retry/delay support; if registration is denied, it installs one current-user Startup shortcut instead so reboot recovery still works.

---

## Copy-Paste Daily Start / Update

With `install-startup` run once, you normally don't need to run anything after a reboot - the Scheduled Task starts everything. Use these when you want to check on or update the running stack:

```powershell
.\charybdis.ps1 status    # health report
.\charybdis.ps1 update    # pull latest, validate the release, restart everything
```

`update` pulls all three repositories with checked Git exit codes, validates the complete release while the current stack remains available, then restarts only after validation succeeds. It fails loudly instead of silently continuing on stale code if any repo has dirty tracked files, and refuses to restart onto a mixed/invalid release if `release_check.py` fails.

---

## What Each Command/Script Does

| Command/Script | Purpose | When to run |
|--------|---------|-------------|
| `charybdis.ps1 start` / `stop` / `restart` | Start/stop/restart the AHK helper, beacon listener, and coach server together | Ad hoc, or via the Scheduled Task from `install-startup` |
| `charybdis.ps1 status` | Health report (process identity, heartbeat recency, served release) | Check on the running stack |
| `charybdis.ps1 update` | Pull all 3 repos, validate the release, restart | After a new layout is promoted |
| `charybdis.ps1 doctor` | Diagnose venv/deps/git-state/release-manifest issues; `-Repair` fixes venv/deps | Something looks wrong |
| `charybdis.ps1 install-startup` | Create the Scheduled Task for reboot recovery | Once, after `bootstrap` |
| `charybdis.ps1 bootstrap` | Fresh-machine clone + first-time setup | Once, on a new machine |
| `powershell/apply_latest_layout.ps1` | Checks promoted layout CSV sync, copies ZMK Studio apply script to clipboard, optionally restarts coach/logger | When applying the current default layout |
| `powershell/setup_rawaccel.ps1` | Installs Raw Accel for trackball acceleration curves | Optional, once |

---

## How Data Flows

1. **Keyboard** sends BLE beacons → **AHK helper** (`charybdis_helpers.ahk`) receives them → writes `runtime/charybdis_state.json`
2. **AHK helper** also logs every shortcut, mouse click, scroll, layer change → writes `runtime/shortcut_usage.jsonl`
3. **Coach** (`http://127.0.0.1:8765/charybdis-coach/`) reads `charybdis_state.json` to show live layer status
4. **Optimizer** (`node pipeline/aggregate_usage.js`) reads `shortcut_usage.jsonl` → produces `build/usage_stats.json`
5. **Optimizer** uses `usage_stats.json` to evolve better keyboard layouts

---

## Files

```
charybdis.ps1                  # Unified launcher - run this, not the scripts below directly

ahk/
  charybdis_helpers.ahk       # Main helper — beacon detection, shortcut logging, layer tracking
  coach_beacon_only.ahk       # Minimal beacon listener (fallback)

powershell/
  lib/Charybdis.Common.ps1    # Shared functions dot-sourced by everything else
  start_charybdis_coach.ps1   # Start coach server + beacon listener + open browser
  start_charybdis_helpers.ps1  # Start AHK helper
  apply_mouse_settings.ps1     # Set 1:1 pointer speed, disable acceleration
  setup_rawaccel.ps1           # Raw Accel integration for acceleration curves
  apply_latest_layout.ps1      # Stage promoted layout for manual ZMK Studio paste
  pull_and_apply_layout.ps1    # Same, without the full CSV-hash sync check

python/
  coach_beacon_listener.py     # HID beacon listener (alternative to AHK)
  coach_http_server.py         # Static server with no-cache headers (used by start_charybdis_coach.ps1)
  usb_state_monitor.py         # USB connection monitor

requirements-runtime.txt       # keyboard, pyserial - installed into .venv by bootstrap/doctor -Repair
release_manifest.json          # Cross-repo commit + CSV hashes for the last promotion

trackball_benchmarks/
  start_benchmark_session.ps1  # Benchmark trackball tuning profiles
  run_benchmark.ps1

runtime/                       # Live state (mostly gitignored, created at runtime)
  charybdis_state.json         # Current layer/app (read by coach for live display)
  shortcut_usage.jsonl         # Every shortcut logged (consumed by optimizer)
  charybdis_events.jsonl       # State heartbeats
  logs/                        # Rotated per-component logs
  status.json                  # Last-known launcher status snapshot
```

---

## Sibling Repos

All repos live in the same parent directory. They must be cloned side-by-side.

| Repo | Purpose | GitHub URL |
|------|---------|------------|
| `charybdis-zmk-config` | ZMK firmware config, layout CSV (source of truth), ZMK Studio scripts | `Glx28/zmk-config-charybdis-beacons` |
| `charybdis-coach` | Browser-based interactive keyboard layout coach | `Glx28/charybdis-coach` |
| `charybdis-optimizer` | Node.js analysis pipeline + Python evolutionary optimizer | `Glx28/charybdis-optimizer` |
| `charybdis-optimizer-v2` | Python-only optimizer with surrogate fitness | `Glx28/charybdis-optimizer-v2` |
| `charybdis-tools` | Windows AHK helpers, beacon system, usage logging | `Glx28/charybdis-tools` |

---

## Sync After Layout Changes

After applying a new layout in ZMK Studio, run this from the `charybdis-optimizer` directory:

```powershell
cd ..\charybdis-optimizer
powershell -ExecutionPolicy Bypass -File sync_repos.ps1 -CommitMessage "feat: apply new layout" -Push
```
