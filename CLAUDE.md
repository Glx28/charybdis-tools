# Charybdis Tools — Windows Host-Side Helpers

AHK automation, PowerShell scripts, trackball benchmarks, and runtime state for the Charybdis split keyboard.

## Structure

- `charybdis.ps1` — unified launcher (see "Launcher" below). Run this, not the individual scripts under `powershell/`.
- `ahk/` — AutoHotkey scripts
  - `charybdis_helpers.ahk` — main helper (beacon detection, layer state tracking, shortcut usage logger)
  - `coach_beacon_only.ahk` — standalone beacon listener
  - `send_beacon_smoke.ahk` / `test_beacon.ahk` — beacon test utilities
- `powershell/` — scripts `charybdis.ps1` calls; not meant to be run standalone day-to-day
  - `lib/Charybdis.Common.ps1` — shared functions (checked git commands, PID-record process identity, launcher mutex, rotated logs, release-manifest/health checks). Dot-sourced by everything else.
  - `start_charybdis_coach.ps1` — starts the bundled coach HTTP server
  - `start_charybdis_helpers.ps1` — starts the AHK helper
  - `apply_mouse_settings.ps1` — Windows mouse config (1:1 pointer speed, no acceleration)
  - `setup_rawaccel.ps1` — Raw Accel integration for trackball acceleration curves
  - `apply_latest_layout.ps1` / `pull_and_apply_layout.ps1` — stage the promoted layout for a manual ZMK Studio paste
- `python/` — serial/USB utilities
  - `coach_beacon_listener.py` — optional serial observer; not launched by default because it does not suppress beacon chords
  - `coach_http_server.py` — stdlib static server with no-cache headers (used by `start_charybdis_coach.ps1` instead of plain `python -m http.server`)
  - `usb_state_monitor.py` — USB connection monitor
- `requirements-runtime.txt` — pinned deps (`keyboard`, `pyserial`) for a `.venv` created by `charybdis.ps1 bootstrap`/`doctor -Repair`
- `release_manifest.json` — promotion provenance and CSV hash; runtime validation checks the bundled files
- `trackball_benchmarks/` — benchmark system for trackball tuning
  - `run_benchmark.ps1 -ProfileName <name>` — run a benchmark
- `runtime/` — live state files (mostly gitignored)
  - `charybdis_state.json` — current layer/app state (read by the coach app)
  - `logs/` — rotated per-component logs (`update`, `supervisor`, `helper`, `beacon`, `coach-server`)
  - `status.json` — last-known launcher status snapshot (`{ok, release, tools, coach, zmk, url}`)
  - `shortcut_usage.jsonl` — usage log; AHK's nominal write target, but check the repo root first (see Shortcut Usage Tracker below)
  - `charybdis_events.jsonl` — state heartbeats; same root-first caveat applies

## Launcher

`charybdis.ps1` is the single entry point — it replaces the old, overlapping
`bootstrap.ps1` / `Start-Charybdis.ps1` / `powershell\update_and_start_charybdis.ps1`
(all deleted; their logic now lives here + in `powershell\lib\Charybdis.Common.ps1`).

```powershell
.\start_charybdis.ps1             # start AHK helper + beacon handling + coach server
.\charybdis.ps1 start               # same stack, through management CLI
.\charybdis.ps1 stop               # stop all three by validated PID-record identity
.\charybdis.ps1 restart             # stop then start
.\charybdis.ps1 status              # health report; add -Json for {ok, release, tools, coach, zmk, url}
.\charybdis.ps1 update               # pull this runtime repo, restart, verify
.\charybdis.ps1 doctor               # venv/deps/git-state/release-manifest/health diagnostics; add -Repair to fix venv/deps
.\charybdis.ps1 install-startup      # create the Scheduled Task that starts the stack ~10s after logon (run once)
.\charybdis.ps1 bootstrap             # fresh-machine clone + first-time setup
```

Key safety properties, since these bit the previous scripts:
- `update` fails loudly on a dirty tracked tools tree instead of silently skipping the pull.
- Every git/node/pip call goes through `Invoke-NativeChecked` (real exit-code checks — `$ErrorActionPreference` alone does not catch native non-zero exit codes).
- Process kills go through PID-record identity (`{pid, exe, commandLine, startTime, release}`), never a bare PID, a `CommandLine` regex match, or "whatever owns the port" — a reused PID or an unrelated process is never killed.
- A named mutex (`Global\CharybdisLauncher`) serializes `start`/`stop`/`restart`/`update` so a manual run, the Scheduled Task, and an AI agent can't race each other.
- `install-startup`'s Scheduled Task action is always `charybdis.ps1 start`, never `update` — startup must succeed with no network; an update check is a separate, explicit step.
- Coach caching is fixed at the HTTP layer (`python/coach_http_server.py` sends `Cache-Control: no-cache`), not by rewriting `index.html`'s cache-buster query string on every run — that rewrite used to dirty the tracked tools tree on every single launch.

## Mouse Settings

Windows pointer speed must be 1:1 (`MouseSensitivity=10`), acceleration OFF. Use `apply_mouse_settings.ps1` to set. Never set `MouseSensitivity=20` (max) — it amplifies low-CPI coarseness.

## Shortcut Usage Tracker

The AHK helper logs Ctrl/Alt/Win combos + F-keys to `runtime/shortcut_usage.jsonl` (never bare letters). Sequence tracking records previous shortcut + gap within 5s.

**Known path drift:** the substantial, real accumulated usage log has been observed living at the repo root (`shortcut_usage.jsonl`, `charybdis_events.jsonl`) rather than under `runtime/` — the `runtime/` copies can be much smaller/staler snapshots. Anything reading these logs should check the repo root first, then fall back to `runtime/` — this is the order `../charybdis-optimizer-v2/pipeline/aggregate_usage.js` already uses (`USAGE_CANDIDATES`), and `runtime/evolved_v2_export/export_and_analyze.py` and `runtime/evolved_v2_export/usage_mismatch_report.py` follow the same order. Which process actually writes the root-level copy on the live Windows host has not been confirmed — treat this as a known open question, not settled behavior.

### Automatic shortcut-gap discovery

`runtime/evolved_v2_export/shortcut_discovery.py` runs automatically from `promote.py` on every promotion. It finds apps with real, regular usage (from the log above) that have zero representation in `../charybdis-coach/data/charybdis_apps.json`/`../charybdis-coach/workflows/`/`../charybdis-coach/data/app_shortcut_reference.json` (same detection `usage_mismatch_report.py` already reports), then searches the open web (DuckDuckGo HTML, no API key) for each one's shortcut docs and generically extracts key-combo/description pairs from whatever HTML tables or definition lists it finds — no per-app hardcoding, works the same for an app never seen before. Results land in `runtime/evolved_v2_export/shortcut_candidates/<exe>.json` with `status: "needs_review"`. It never writes `app_shortcut_reference.json` directly.

Caveats, found the hard way: the search backend rate-limits/anomaly-blocks aggressively on repeated queries from the same IP (`status: "search_blocked"` in the candidate file means "retry later," not "no shortcuts exist" — the script backs off `INTER_APP_DELAY_SECONDS` between apps and just skips writing garbage rather than guessing). Extraction is regex/HTML-structure heuristics, not an LLM read — spot-check a candidate's `shortcuts` against its `source_url` before trusting it.

`runtime/evolved_v2_export/merge_shortcut_candidate.py <exe> --apply` updates the coach source repository during coach/layout development. The runtime serves its published snapshot from `coach/`; refresh that snapshot when intentionally publishing coach data changes. This merge step is deliberately not automatic — a bad shortcut entry here eventually feeds `app_shortcut_scores.json` in `../charybdis-optimizer-v2`, which drives fitness scoring.

### Coach source

The separate `charybdis-coach` repository is used for coach development. This runtime repository contains a self-contained published snapshot under `coach/`; the HTTP server serves that local copy and needs no sibling checkout.

## Optimizer Rules — MANDATORY

1. **NEVER freeze or protect layer access key positions.** Layer keys (coach_*, Toggle Layer, Momentary Layer) must be movable by the optimizer. The algorithm must learn to place them correctly through fitness scoring, not through freezing.
2. **Fix the algorithm, not the data.** When the optimizer produces bad output (wrong layer targets, missing keys, broken access), fix the fitness function, validation, or export code — NEVER manually patch the CSV or apply script.
3. **The verify JSON from ZMK Studio is the source of truth** for what the keyboard actually has. When updating the coach or CSV, diff against the verify JSON, not assumptions.

## Sibling Repos

Sibling repositories are optional and used only for firmware/layout optimization development. The Windows runtime does not clone, pull, or serve them.
- `../charybdis-zmk-config` — ZMK firmware config, keymap, layout CSV, ZMK Studio scripts
- `../charybdis-coach` — Coach source repository for development; runtime serves bundled `coach/`
- `../charybdis-optimizer` — Node.js pipeline + Python DEAP evolutionary layout optimizer
- `../charybdis-optimizer-v2` — Python/CUDA evolutionary layout optimizer (current); `promote.py` reads checkpoints from its `build/` dir
