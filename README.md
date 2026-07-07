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

After a layout/default update, future agents should use the single refresh script instead of manually pulling repos, editing cache-busters, and restarting processes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\nos\charybdis-tools\powershell\update_and_start_charybdis.ps1
```

It pulls `charybdis-tools`, `../charybdis-coach`, and `../charybdis-zmk-config`, ensures the ZMK repo is on `codex/build-coach-layers-cpi750`, refreshes the coach app cache-buster from the current tools commit, validates JavaScript, restarts the helper/logger, beacon listener, and coach server, then prints only commit hashes, PIDs, and the coach URL.

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

Use this on a new Windows machine, or on an existing machine when you want to repair/update all Charybdis host-side tooling. It is intentionally large: the goal is copy-paste and done, not small clean commands.

Copy-paste the whole block into **PowerShell as Administrator**. It installs missing prerequisites, clones or updates sibling repos, applies mouse settings, validates/starts the AHK logger, creates the Windows Startup shortcut, starts the beacon listener, starts the coach website, and opens the browser.

```powershell
# === CHARYBDIS FULL WINDOWS INSTALL / UPDATE / START ===
# Run in elevated PowerShell: right-click PowerShell -> Run as Administrator.
# Safe to rerun. Existing repos are updated; missing repos are cloned.
$ErrorActionPreference = "Stop"

$Parent = Join-Path $env:USERPROFILE "charybdis"
$Tools = Join-Path $Parent "charybdis-tools"
$Runtime = Join-Path $Tools "runtime"
$Port = 8765

function Write-Step($Text) {
    Write-Host ""
    Write-Host "=== $Text ===" -ForegroundColor Cyan
}

function Refresh-Path {
    $MachinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$MachinePath;$UserPath"
}

function Ensure-Command($Name, $WingetId, $FriendlyName) {
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Host "[OK] $FriendlyName already available" -ForegroundColor Green
        return
    }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "$FriendlyName is missing and winget is not available. Install $FriendlyName manually, then rerun this block."
    }
    Write-Host "[INSTALL] $FriendlyName via winget" -ForegroundColor Yellow
    winget install --id $WingetId --exact --accept-source-agreements --accept-package-agreements
    Refresh-Path
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$FriendlyName was installed but is not visible in this PowerShell session. Close PowerShell, reopen as Administrator, and rerun this block."
    }
}

function Ensure-GitRepo($Url, $Path, $Branch = "master") {
    $Name = Split-Path -Leaf $Path
    if (Test-Path (Join-Path $Path ".git")) {
        Write-Host "[UPDATE] $Name" -ForegroundColor Cyan
        Push-Location $Path
        try {
            git fetch --all --prune
            $LocalChanges = git status --porcelain
            if ([string]::IsNullOrWhiteSpace($LocalChanges)) {
                git checkout $Branch 2>$null
                git pull --ff-only
            } else {
                Write-Host "[KEEP] $Name has local changes; fetched only, no pull/rebase attempted." -ForegroundColor Yellow
                git status -sb
            }
        } finally {
            Pop-Location
        }
        return
    }
    if (Test-Path $Path) {
        Write-Host "[SKIP] $Path exists but is not a git repo. Move it aside or clone manually." -ForegroundColor Yellow
        return
    }
    Write-Host "[CLONE] $Name" -ForegroundColor Cyan
    git clone $Url $Path
}

Write-Step "Install prerequisites if missing"
Ensure-Command git Git.Git "Git for Windows"
Ensure-Command python Python.Python.3.12 "Python"

if (-not (
    (Test-Path "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe") -or
    (Test-Path "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey.exe") -or
    (Test-Path "$env:LOCALAPPDATA\Programs\AutoHotkey\UX\AutoHotkeyUX.exe") -or
    (Test-Path "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe") -or
    (Test-Path "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe") -or
    (Test-Path "$env:ProgramFiles\AutoHotkey\UX\AutoHotkeyUX.exe")
)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "AutoHotkey v2 is missing and winget is not available. Install AutoHotkey v2 manually, then rerun this block."
    }
    Write-Host "[INSTALL] AutoHotkey v2 via winget" -ForegroundColor Yellow
    winget install --id AutoHotkey.AutoHotkey --exact --accept-source-agreements --accept-package-agreements
    Refresh-Path
} else {
    Write-Host "[OK] AutoHotkey already installed" -ForegroundColor Green
}

Write-Step "Clone or update repos"
New-Item -ItemType Directory -Force -Path $Parent | Out-Null
Ensure-GitRepo "https://github.com/Glx28/charybdis-tools.git" "$Parent\charybdis-tools" "master"
Ensure-GitRepo "https://github.com/Glx28/zmk-config-charybdis-beacons.git" "$Parent\charybdis-zmk-config" "master"
Ensure-GitRepo "https://github.com/Glx28/charybdis-coach.git" "$Parent\charybdis-coach" "master"
Ensure-GitRepo "https://github.com/Glx28/charybdis-optimizer.git" "$Parent\charybdis-optimizer" "master"
Ensure-GitRepo "https://github.com/Glx28/charybdis-optimizer-v2.git" "$Parent\charybdis-optimizer-v2" "master"

Write-Step "Install Python packages used by tools"
python -m pip install --upgrade pip
python -m pip install --upgrade keyboard numpy pandas scipy deap pyyaml

Write-Step "Create runtime folder and apply mouse settings"
New-Item -ItemType Directory -Force -Path $Runtime | Out-Null
Set-Location $Tools
PowerShell -NoProfile -ExecutionPolicy Bypass -File ".\powershell\apply_mouse_settings.ps1"

Write-Step "Start AHK helper: logger + BLE beacon receiver + startup shortcut"
PowerShell -NoProfile -ExecutionPolicy Bypass -File ".\powershell\start_charybdis_helpers.ps1" -RepoRoot $Tools

Write-Step "Start coach website + beacon listener fallback"
PowerShell -NoProfile -ExecutionPolicy Bypass -File ".\powershell\start_charybdis_coach.ps1" -RepoRoot $Tools -Port $Port

Write-Step "Verify generated runtime files"
$StateFile = Join-Path $Runtime "charybdis_state.json"
$UsageLog = Join-Path $Runtime "shortcut_usage.jsonl"
$EventLog = Join-Path $Runtime "charybdis_events.jsonl"
Write-Host "Coach:      http://127.0.0.1:$Port/charybdis-coach/" -ForegroundColor Green
Write-Host "Tools repo: $Tools" -ForegroundColor Green
Write-Host "State:      $StateFile"
Write-Host "Usage log:  $UsageLog"
Write-Host "Event log:  $EventLog"
if (Test-Path $StateFile) { Write-Host "[OK] State file exists" -ForegroundColor Green } else { Write-Host "[WAIT] State file will appear after helper/beacon heartbeat" -ForegroundColor Yellow }
if (Test-Path $UsageLog) { Write-Host "[OK] Usage log exists" -ForegroundColor Green } else { Write-Host "[WAIT] Usage log appears after first logged shortcut or flush interval" -ForegroundColor Yellow }

Write-Host ""
Write-Host "DONE. The helper is installed in Startup and should run after reboot." -ForegroundColor Green
```

---

## Copy-Paste Daily Start / Update

Use this after reboot or when you want to update the tools without reinstalling prerequisites. Normal PowerShell is enough.

If you are already inside `charybdis-tools`, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\powershell\update_and_start_charybdis.ps1
```

This script stops the running AHK helper first, then pulls, then restarts the helper and coach. Stopping AHK first matters because Windows locks `ahk\charybdis_helpers.ahk` while it is running.

---

## What Each Script Does

| Script | Purpose | When to run |
|--------|---------|-------------|
| `powershell/start_charybdis_helpers.ps1` | Starts `ahk/charybdis_helpers.ahk`, creates Windows Startup shortcut | After install + after every reboot |
| `powershell/start_charybdis_coach.ps1` | Starts Python HTTP server (port 8765) + beacon listener + opens browser | After install + after every reboot |
| `powershell/apply_latest_layout.ps1` | Checks promoted layout CSV sync, copies ZMK Studio apply script to clipboard, optionally restarts coach/logger | When applying the current default layout |
| `powershell/apply_mouse_settings.ps1` | Sets Windows pointer speed to 1:1, disables acceleration | Once after install |
| `powershell/setup_rawaccel.ps1` | Installs Raw Accel for trackball acceleration curves | Optional, once |
| `powershell/validate_layout_bundle.ps1` | Validates layout CSV consistency across all repos | After layout changes |

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
ahk/
  charybdis_helpers.ahk       # Main helper — beacon detection, shortcut logging, layer tracking
  coach_beacon_only.ahk       # Minimal beacon listener (fallback)

powershell/
  start_charybdis_coach.ps1   # Start coach server + beacon listener + open browser
  start_charybdis_helpers.ps1  # Start AHK helper + create Startup shortcut
  apply_mouse_settings.ps1     # Set 1:1 pointer speed, disable acceleration
  setup_rawaccel.ps1           # Raw Accel integration for acceleration curves
  validate_layout_bundle.ps1     # Validate layout data consistency across repos

python/
  coach_beacon_listener.py     # HID beacon listener (alternative to AHK)
  usb_state_monitor.py         # USB connection monitor

trackball_benchmarks/
  start_benchmark_session.ps1  # Benchmark trackball tuning profiles
  run_benchmark.ps1

runtime/                       # Live state (gitignored, created at runtime)
  charybdis_state.json         # Current layer/app (read by coach for live display)
  shortcut_usage.jsonl         # Every shortcut logged (consumed by optimizer)
  charybdis_events.jsonl       # State heartbeats
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
