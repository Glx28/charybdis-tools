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

### Prerequisites (must be installed first)
1. [Git for Windows](https://git-scm.com/download/win)
2. [Python 3.10+](https://www.python.org/downloads/) — for the optimizer and coach server
3. [AutoHotkey v2](https://www.autohotkey.com/) — the AHK helper is the primary beacon + logging layer

> **Note:** The Python beacon listener (optional, AHK is preferred) requires the `keyboard` package, which needs **administrator privileges** to install. If you see a warning, run `python -m pip install keyboard` in an elevated PowerShell. The AHK beacon listener does not need this.

### Directory Layout (all repos share the same parent)
```
C:\Users\<user>\                     # parent directory
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

## One-Command Installation (Windows)

Copy-paste this entire block into an **elevated PowerShell** window (Run as Administrator). It clones all repos, installs dependencies, applies mouse settings, and starts the tools.

```powershell
# === CHARYBDIS FULL INSTALL ===
# Run this in an elevated PowerShell window (right-click → Run as Administrator)
$ErrorActionPreference = "Stop"
$parent = "C:\Users\$env:USERNAME"
Set-Location $parent

# 1. Clone all 4 repos (skips if already present)
$repos = @(
    @("https://github.com/Glx28/charybdis-tools.git",          "charybdis-tools"),
    @("https://github.com/Glx28/zmk-config-charybdis-beacons.git", "charybdis-zmk-config"),
    @("https://github.com/Glx28/charybdis-coach.git",          "charybdis-coach"),
    @("https://github.com/Glx28/charybdis-optimizer.git",     "charybdis-optimizer")
)
foreach ($r in $repos) {
    $url = $r[0]; $name = $r[1]
    if (Test-Path "$parent\$name\.git") {
        Write-Host "[SKIP] $name already cloned" -ForegroundColor Green
    } else {
        Write-Host "[CLONE] $name ..." -ForegroundColor Cyan
        git clone $url $name
    }
}

# 2. Install Python dependencies for optimizer v1
Write-Host "[DEPS] Installing Python packages..." -ForegroundColor Cyan
python -m pip install numpy pandas scipy deap 2>$null | Out-Null

# 3. Apply mouse settings (1:1 pointer speed, no accel)
Write-Host "[CONFIG] Applying mouse settings..." -ForegroundColor Cyan
Set-Location "$parent\charybdis-tools"
.\powershell\apply_mouse_settings.ps1

# 4. Start AHK helper (with Startup shortcut so it survives reboots)
Write-Host "[START] AHK helper..." -ForegroundColor Cyan
.\powershell\start_charybdis_helpers.ps1

# 5. Start Coach server + open browser
Write-Host "[START] Coach server..." -ForegroundColor Cyan
.\powershell\start_charybdis_coach.ps1

Write-Host "" 
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "AHK helper is running. Coach is at http://127.0.0.1:8765/charybdis-coach/"
Write-Host "All repos are in $parent"
Write-Host ""
Write-Host "NOTE: The Python beacon listener requires the 'keyboard' package." -ForegroundColor Yellow
Write-Host "If you see a warning about it, run this in an elevated PowerShell:"
Write-Host "  python -m pip install keyboard" -ForegroundColor White
Write-Host "The AHK beacon listener (recommended) does not need this package."
```

---

## One-Command Startup After Reboot

Copy-paste this entire block into **PowerShell** after every PC restart. It starts the AHK helper and the coach server (no admin needed for this step).

```powershell
# === CHARYBDIS START AFTER REBOOT ===
$ErrorActionPreference = "Stop"
$parent = "C:\Users\$env:USERNAME"
Set-Location "$parent\charybdis-tools"

# 1. Start AHK helper (if not already running)
$ahk = Get-Process AutoHotkey64 -ErrorAction SilentlyContinue
if (-not $ahk) {
    Write-Host "[START] AHK helper..." -ForegroundColor Cyan
    .\powershell\start_charybdis_helpers.ps1
} else {
    Write-Host "[SKIP] AHK already running (PID $($ahk.Id))" -ForegroundColor Green
}

# 2. Start Coach server + beacon listener + open browser
Write-Host "[START] Coach server..." -ForegroundColor Cyan
.\powershell\start_charybdis_coach.ps1

Write-Host "" 
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "AHK helper: RUNNING"
Write-Host "Coach:      http://127.0.0.1:8765/charybdis-coach/"
Write-Host "State file: $parent\charybdis-tools\runtime\charybdis_state.json"
Write-Host "Usage log:  $parent\charybdis-tools\runtime\shortcut_usage.jsonl"
```

---

## What Each Script Does

| Script | Purpose | When to run |
|--------|---------|-------------|
| `powershell/start_charybdis_helpers.ps1` | Starts `ahk/charybdis_helpers.ahk`, creates Windows Startup shortcut | After install + after every reboot |
| `powershell/start_charybdis_coach.ps1` | Starts Python HTTP server (port 8765) + beacon listener + opens browser | After install + after every reboot |
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
