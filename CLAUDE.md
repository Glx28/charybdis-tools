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
  - `shortcut_usage.jsonl` — usage log; AHK's nominal write target, but check the repo root first (see Shortcut Usage Tracker below)
  - `charybdis_events.jsonl` — state heartbeats; same root-first caveat applies

## Mouse Settings

Windows pointer speed must be 1:1 (`MouseSensitivity=10`), acceleration OFF. Use `apply_mouse_settings.ps1` to set. Never set `MouseSensitivity=20` (max) — it amplifies low-CPI coarseness.

## Shortcut Usage Tracker

The AHK helper logs Ctrl/Alt/Win combos + F-keys to `runtime/shortcut_usage.jsonl` (never bare letters). Sequence tracking records previous shortcut + gap within 5s.

**Known path drift:** the substantial, real accumulated usage log has been observed living at the repo root (`shortcut_usage.jsonl`, `charybdis_events.jsonl`) rather than under `runtime/` — the `runtime/` copies can be much smaller/staler snapshots. Anything reading these logs should check the repo root first, then fall back to `runtime/` — this is the order `../charybdis-optimizer-v2/pipeline/aggregate_usage.js` already uses (`USAGE_CANDIDATES`), and `runtime/evolved_v2_export/export_and_analyze.py` and `runtime/evolved_v2_export/usage_mismatch_report.py` follow the same order. Which process actually writes the root-level copy on the live Windows host has not been confirmed — treat this as a known open question, not settled behavior.

### Automatic shortcut-gap discovery

`runtime/evolved_v2_export/shortcut_discovery.py` runs automatically from `promote.py` on every promotion. It finds apps with real, regular usage (from the log above) that have zero representation in `charybdis_apps.json`/`coach/workflows/`/`app_shortcut_reference.json` (same detection `usage_mismatch_report.py` already reports), then searches the open web (DuckDuckGo HTML, no API key) for each one's shortcut docs and generically extracts key-combo/description pairs from whatever HTML tables or definition lists it finds — no per-app hardcoding, works the same for an app never seen before. Results land in `runtime/evolved_v2_export/shortcut_candidates/<exe>.json` with `status: "needs_review"`. It never writes `app_shortcut_reference.json` directly.

Caveats, found the hard way: the search backend rate-limits/anomaly-blocks aggressively on repeated queries from the same IP (`status: "search_blocked"` in the candidate file means "retry later," not "no shortcuts exist" — the script backs off `INTER_APP_DELAY_SECONDS` between apps and just skips writing garbage rather than guessing). Extraction is regex/HTML-structure heuristics, not an LLM read — spot-check a candidate's `shortcuts` against its `source_url` before trusting it.

`runtime/evolved_v2_export/merge_shortcut_candidate.py <exe> --apply` folds an approved candidate into both `app_shortcut_reference.json` copies (`coach/data/` and `../charybdis-coach/data/`) and marks it `approved` so future discovery runs don't re-draft it. This merge step is deliberately not automatic — a bad shortcut entry here eventually feeds `app_shortcut_scores.json` in `../charybdis-optimizer-v2`, which drives real fitness scoring (see Optimizer Rules below: fix data via verified sources, never guesses).

## Optimizer Rules — MANDATORY

1. **NEVER freeze or protect layer access key positions.** Layer keys (coach_*, Toggle Layer, Momentary Layer) must be movable by the optimizer. The algorithm must learn to place them correctly through fitness scoring, not through freezing.
2. **Fix the algorithm, not the data.** When the optimizer produces bad output (wrong layer targets, missing keys, broken access), fix the fitness function, validation, or export code — NEVER manually patch the CSV or apply script.
3. **The verify JSON from ZMK Studio is the source of truth** for what the keyboard actually has. When updating the coach or CSV, diff against the verify JSON, not assumptions.

## Sibling Repos

All repos live in the same parent directory.
- `../charybdis-zmk-config` — ZMK firmware config, keymap, layout CSV, ZMK Studio scripts
- `../charybdis-coach` — Browser-based interactive keyboard layout coach
- `../charybdis-optimizer` — Node.js pipeline + Python DEAP evolutionary layout optimizer
