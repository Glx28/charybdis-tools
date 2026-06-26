# Charybdis Tools — Windows Host-Side Helpers

AHK automation, PowerShell scripts, trackball benchmarks, and runtime state for the Charybdis split keyboard.

## Structure

- `ahk/` — AutoHotkey scripts
  - `charybdis_helpers.ahk` — main helper (beacon detection, layer state tracking, shortcut usage logger)
  - `coach_beacon_only.ahk` — standalone beacon listener
  - `send_beacon_smoke.ahk` / `test_beacon.ahk` — beacon test utilities
- `powershell/` — setup and launcher scripts
  - `start_charybdis_coach.ps1` — launches the coach app server
  - `start_charybdis_helpers.ps1` — launches AHK helper
  - `apply_mouse_settings.ps1` — Windows mouse config (1:1 pointer speed, no acceleration)
  - `setup_rawaccel.ps1` — Raw Accel integration for trackball acceleration curves
  - `validate_layout_bundle.ps1` — layout validation
- `python/` — serial/USB utilities
  - `coach_beacon_listener.py` — serial port beacon listener
  - `usb_state_monitor.py` — USB connection monitor
- `trackball_benchmarks/` — benchmark system for trackball tuning
  - `run_benchmark.ps1 -ProfileName <name>` — run a benchmark
- `runtime/` — live state files (mostly gitignored)
  - `charybdis_state.json` — current layer/app state (read by coach app)
  - `shortcut_usage.jsonl` — usage log (read by optimizer pipeline)
  - `charybdis_events.jsonl` — state heartbeats

## Mouse Settings

Windows pointer speed must be 1:1 (`MouseSensitivity=10`), acceleration OFF. Use `apply_mouse_settings.ps1` to set. Never set `MouseSensitivity=20` (max) — it amplifies low-CPI coarseness.

## Shortcut Usage Tracker

The AHK helper logs Ctrl/Alt/Win combos + F-keys to `runtime/shortcut_usage.jsonl` (never bare letters). Sequence tracking records previous shortcut + gap within 5s. The optimizer's `aggregate_usage.js` reads this file.

## Optimizer Rules — MANDATORY

1. **NEVER freeze or protect layer access key positions.** Layer keys (coach_*, Toggle Layer, Momentary Layer) must be movable by the optimizer. The algorithm must learn to place them correctly through fitness scoring, not through freezing.
2. **Fix the algorithm, not the data.** When the optimizer produces bad output (wrong layer targets, missing keys, broken access), fix the fitness function, validation, or export code — NEVER manually patch the CSV or apply script.
3. **The verify JSON from ZMK Studio is the source of truth** for what the keyboard actually has. When updating the coach or CSV, diff against the verify JSON, not assumptions.

## Sibling Repos

All repos live in the same parent directory.
- `../charybdis-zmk-config` — ZMK firmware config, keymap, layout CSV, ZMK Studio scripts
- `../charybdis-coach` — Browser-based interactive keyboard layout coach
- `../charybdis-optimizer` — Node.js pipeline + Python DEAP evolutionary layout optimizer
