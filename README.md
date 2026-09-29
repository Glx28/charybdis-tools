# Charybdis Tools

> Self-contained Windows runtime for Charybdis: bundled coach UI and layout data, AHK beacon handling, shortcut logging, and one launcher. Firmware and layout optimization remain separate projects.

> **Privacy:** the logger records shortcut, application, layer, timing, and
> mouse workflow metadata. Runtime data stays local and is excluded from Git;
> read [PRIVACY.md](PRIVACY.md) before sharing logs or repository snapshots.

---

## AI Agent Quick Reference

If you are an AI agent reading this repo, here is everything you need to know in one place.

### What This Repo Does
- **AHK logger** (`ahk/charybdis_helpers.ahk`): Captures every shortcut, mouse click, scroll, layer change, and app switch. Writes to `runtime/shortcut_usage.jsonl`.
- **Beacon handler**: AHK catches and suppresses the keyboard's F13-F24 beacon chords, then writes `runtime/charybdis_state.json`. The old Python hook is not launched because it did not suppress input.
- **Coach server**: Serves the bundled `coach/` UI on loopback. Defaults to port 8765, scans the next 99 ports when busy, then records the active port for the tray shortcut.
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

### One-Repo Runtime Refresh

The coach UI, layout CSV, and host config ship inside this repo. Pull once, then start the whole runtime:

```powershell
git pull
pwsh -NoProfile -ExecutionPolicy Bypass -File .\start_charybdis.ps1
```

`start_charybdis.ps1` starts the AHK helper/logger, coach server, and beacon handling. Busy port? Launcher selects a free port and reports its URL. `powershell/start_all_charybdis.ps1` remains as a compatibility wrapper for the old command path. No firmware or optimizer clone needed.

### Prerequisites

Install these prerequisites first:

1. [Git for Windows](https://git-scm.com/download/win)
2. [Python 3.10+](https://www.python.org/downloads/) — for the coach server and optional Python utilities
3. [AutoHotkey v2](https://www.autohotkey.com/) — primary logger + beacon helper

Install those three first; the commands below clone and prepare the runtime repo.

### Directory Layout
```
C:\Users\<user>\charybdis-tools\    # this repo; no sibling runtime repos required
├── coach\                            # bundled browser coach, workflows, and CSV
├── keyboard-data\                    # bundled layout CSV + host config (no firmware)
├── ahk\                              # beacon capture, coach window, and logger
├── python\                           # loopback coach server and optional utilities
└── runtime\                          # local live state/logs; gitignored
```

---

## Copy-Paste Install / Repair / Start Everything

Use this once on a new Windows machine. Install Git for Windows, Python 3.10+, and AutoHotkey v2 first.

`charybdis.ps1 bootstrap` checks these prerequisites and prepares optional Python utilities. Node.js is not required to run the coach.

```powershell
# === CHARYBDIS FULL WINDOWS INSTALL / UPDATE / START ===
# One clone contains the complete runtime.
$Tools = Join-Path $env:USERPROFILE "charybdis-tools"
if (-not (Test-Path (Join-Path $Tools ".git"))) {
    git clone https://github.com/Glx28/charybdis-tools.git $Tools
}
Set-Location $Tools
pwsh -NoProfile -ExecutionPolicy Bypass -File .\charybdis.ps1 bootstrap
pwsh -NoProfile -ExecutionPolicy Bypass -File .\charybdis.ps1 install-startup   # once: reboot recovery
```

`bootstrap` checks bundled files, creates a `.venv` for optional Python utilities, and starts the runtime. Normal startup uses the AHK beacon catcher, not the pass-through Python hook. `install-startup` registers the same stack for logon; if task registration is denied, it installs a current-user Startup shortcut.

---

## Copy-Paste Daily Start / Update

With `install-startup` run once, you normally don't need to run anything after a reboot - the Scheduled Task starts everything. Use these when you want to check on or update the running stack:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\charybdis.ps1 status
git pull                  # update coach + logger + beacon tools together
pwsh -NoProfile -ExecutionPolicy Bypass -File .\start_charybdis.ps1 -Restart
```

`charybdis.ps1 update` is also available; it pulls this repo once and restarts the stack.

---

## What Each Command/Script Does

| Command/Script | Purpose | When to run |
|--------|---------|-------------|
| `start_charybdis.ps1` | Start the AHK helper/logger, beacon handling, and coach server; automatically selects a free port | Daily start |
| `charybdis.ps1 start` / `stop` / `restart` | Start/stop/restart the bundled runtime | Ad hoc, or via the Scheduled Task from `install-startup` |
| `charybdis.ps1 status` | Health report (process identity, heartbeat recency, served release) | Check on the running stack |
| `charybdis.ps1 update` | Pull this repo and restart | After runtime updates |
| `charybdis.ps1 doctor` | Diagnose venv/deps/git-state/release-manifest issues; `-Repair` fixes venv/deps | Something looks wrong |
| `charybdis.ps1 install-startup` | Create the Scheduled Task for reboot recovery | Once, after `bootstrap` |
| `charybdis.ps1 bootstrap` | Prepare optional Python tools and start the runtime | Once, on a new machine |
| `powershell/audit_repository_security.ps1` | Check tracked files for private runtime data, credential files, and high-confidence secret patterns without printing matched values | Before publishing or sharing the repo |
| `powershell/apply_latest_layout.ps1` | Checks promoted layout CSV sync, copies ZMK Studio apply script to clipboard, optionally restarts coach/logger | When applying the current default layout |
| `powershell/setup_rawaccel.ps1` | Installs Raw Accel for trackball acceleration curves | Optional, once |

---

## How Data Flows

1. **Keyboard** sends F13-F24 beacons → **AHK helper** (`charybdis_helpers.ahk`) catches/suppresses them → writes `runtime/charybdis_state.json`
2. **AHK helper** also logs every shortcut, mouse click, scroll, layer change → writes `runtime/shortcut_usage.jsonl`
3. **Coach** (`http://127.0.0.1:<selected-port>/charybdis-coach/`) reads `charybdis_state.json` to show live layer status
4. **Optimizer** (`node pipeline/aggregate_usage.js`) reads `shortcut_usage.jsonl` → produces `build/usage_stats.json`
5. **Optimizer** uses `usage_stats.json` to evolve better keyboard layouts

---

## Files

```
charybdis.ps1                  # Unified launcher - run this, not the scripts below directly
start_charybdis.ps1            # Single-command runtime start/restart

coach/                         # Bundled web coach, workflows, and UI data
keyboard-data/                 # Bundled runtime layout and host configs; no firmware

ahk/
  charybdis_helpers.ahk       # Main helper — beacon detection, shortcut logging, layer tracking
  coach_beacon_only.ahk       # Minimal beacon listener (fallback)

powershell/
  lib/Charybdis.Common.ps1    # Shared functions dot-sourced by everything else
  start_charybdis_coach.ps1   # Start bundled coach server + open browser
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
release_manifest.json          # Bundled layout CSV hash and promotion metadata

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

## Separate Projects

Firmware and optimizer development remain separate. They are not needed to run the host runtime.

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
