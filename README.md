# Charybdis Tools

Windows host-side helpers for the Charybdis split keyboard: AHK automation, beacon layer tracking, shortcut usage logging, trackball benchmarks, and launcher scripts.

## Fresh Windows Setup (All Repos)

Install prerequisites first:
- [Git](https://git-scm.com/download/win)
- [Node.js LTS](https://nodejs.org/)
- [Python 3.10+](https://www.python.org/downloads/)
- [AutoHotkey v2](https://www.autohotkey.com/)

Then run the bootstrap — it clones all 4 repos, installs deps, applies mouse settings, and starts the coach + beacon:

```powershell
git clone https://github.com/Glx28/charybdis-tools.git charybdis-tools
powershell -ExecutionPolicy Bypass -File charybdis-tools\bootstrap.ps1
```

For the main dev machine (includes optimizer/evolution deps):

```powershell
powershell -ExecutionPolicy Bypass -File charybdis-tools\bootstrap.ps1 -IncludeOptimizer
```

## Start Everything After Reboot

The AHK helper auto-starts via a Windows Startup shortcut (created by bootstrap). To start the coach + beacon manually:

```powershell
powershell -ExecutionPolicy Bypass -File charybdis-tools\powershell\start_charybdis_coach.ps1
```

This starts the HTTP server (port 8765), beacon listener, and opens the coach in your browser.

## What's Here

```
ahk/
  charybdis_helpers.ahk       # Main helper — beacon detection, shortcut logging, layer tracking
  coach_beacon_only.ahk       # Minimal beacon listener (fallback)

powershell/
  start_charybdis_coach.ps1   # Start coach server + beacon listener + open browser
  start_charybdis_helpers.ps1  # Start AHK helper + create Startup shortcut
  apply_mouse_settings.ps1     # Set 1:1 pointer speed, disable acceleration
  setup_rawaccel.ps1           # Raw Accel integration for acceleration curves
  validate_layout_bundle.ps1   # Validate layout data consistency across repos

python/
  coach_beacon_listener.py     # HID beacon listener (writes charybdis_state.json)
  usb_state_monitor.py         # USB connection monitor

trackball_benchmarks/
  start_benchmark_session.ps1  # Benchmark trackball tuning profiles
  run_benchmark.ps1

runtime/                       # Live state (gitignored, created at runtime)
  charybdis_state.json         # Current layer/app (read by coach for live display)
  shortcut_usage.jsonl         # Every shortcut logged (consumed by optimizer)
  charybdis_events.jsonl       # State heartbeats
```

## Sibling Repos

All repos live in the same parent directory:

| Repo | Purpose |
|------|---------|
| [charybdis-zmk-config](https://github.com/Glx28/zmk-config-charybdis-beacons) | ZMK firmware config, layout CSV (source of truth), ZMK Studio scripts |
| [charybdis-coach](https://github.com/Glx28/charybdis-coach) | Browser-based interactive keyboard layout coach |
| [charybdis-optimizer](https://github.com/Glx28/charybdis-optimizer) | Node.js analysis pipeline + Python evolutionary optimizer |
| charybdis-tools (this repo) | Windows AHK helpers, beacon system, usage logging |
