<#
.SYNOPSIS
    One-command setup for Charybdis keyboard tools on a fresh Windows machine.

.DESCRIPTION
    Clones all 4 repos, installs dependencies, applies mouse settings, and starts
    the coach + beacon system. Run from any directory — repos are cloned next to each other.

    Prerequisites (install manually first):
      - Git          https://git-scm.com/download/win
      - Node.js LTS  https://nodejs.org/
      - Python 3.10+ https://www.python.org/downloads/
      - AutoHotkey v2 https://www.autohotkey.com/

.PARAMETER SkipClone
    Skip cloning repos (use if already cloned).

.PARAMETER IncludeOptimizer
    Also install Python deps for the evolutionary optimizer (DEAP, numpy, torch).

.EXAMPLE
    # Fresh install — clone everything and start
    powershell -ExecutionPolicy Bypass -File bootstrap.ps1

    # Already cloned, just install deps and start
    powershell -ExecutionPolicy Bypass -File bootstrap.ps1 -SkipClone

    # Include optimizer deps (for the main dev machine)
    powershell -ExecutionPolicy Bypass -File bootstrap.ps1 -IncludeOptimizer
#>
param(
    [switch]$SkipClone,
    [switch]$IncludeOptimizer
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "  Charybdis Keyboard — Full Setup"     -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# --- Check prerequisites ---
$missing = @()
if (-not (Get-Command git -ErrorAction SilentlyContinue))    { $missing += "Git (https://git-scm.com/download/win)" }
if (-not (Get-Command node -ErrorAction SilentlyContinue))   { $missing += "Node.js LTS (https://nodejs.org/)" }
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { $missing += "Python 3.10+ (https://www.python.org/downloads/)" }

$ahkPath = @(
    "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey.exe",
    "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe",
    "${env:LocalAppData}\Programs\AutoHotkey\v2\AutoHotkey.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $ahkPath) { $missing += "AutoHotkey v2 (https://www.autohotkey.com/)" }

if ($missing.Count -gt 0) {
    Write-Host "Missing prerequisites:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host "`nInstall these first, then re-run this script." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Git:    $(git --version)" -ForegroundColor Green
Write-Host "[OK] Node:   $(node --version)" -ForegroundColor Green
Write-Host "[OK] Python: $(python --version 2>&1)" -ForegroundColor Green
Write-Host "[OK] AHK:    $ahkPath" -ForegroundColor Green

# --- Clone repos ---
if (-not $SkipClone) {
    Write-Host "`n--- Cloning repositories ---" -ForegroundColor Cyan

    $repos = @{
        "charybdis-zmk-config" = "https://github.com/Glx28/zmk-config-charybdis-beacons.git"
        "charybdis-optimizer"  = "https://github.com/Glx28/charybdis-optimizer.git"
        "charybdis-coach"      = "https://github.com/Glx28/charybdis-coach.git"
        "charybdis-tools"      = "https://github.com/Glx28/charybdis-tools.git"
    }

    foreach ($name in $repos.Keys) {
        $dest = Join-Path $root $name
        if (Test-Path $dest) {
            Write-Host "[SKIP] $name already exists" -ForegroundColor Yellow
        } else {
            Write-Host "Cloning $name..."
            git clone $repos[$name] $dest
            Write-Host "[OK] $name" -ForegroundColor Green
        }
    }
}

# --- Install Python deps for optimizer ---
if ($IncludeOptimizer) {
    Write-Host "`n--- Installing optimizer Python dependencies ---" -ForegroundColor Cyan
    $reqFile = Join-Path $root "charybdis-optimizer\evolve\requirements.txt"
    if (Test-Path $reqFile) {
        python -m pip install -r $reqFile
        Write-Host "[OK] Optimizer deps installed" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] requirements.txt not found" -ForegroundColor Yellow
    }
}

# --- Apply mouse settings ---
Write-Host "`n--- Applying mouse settings (1:1 pointer, no acceleration) ---" -ForegroundColor Cyan
$mouseScript = Join-Path $root "charybdis-tools\powershell\apply_mouse_settings.ps1"
if (Test-Path $mouseScript) {
    powershell -ExecutionPolicy Bypass -File $mouseScript
    Write-Host "[OK] Mouse settings applied" -ForegroundColor Green
} else {
    Write-Host "[SKIP] apply_mouse_settings.ps1 not found" -ForegroundColor Yellow
}

# --- Start coach + beacon ---
Write-Host "`n--- Starting coach + beacon ---" -ForegroundColor Cyan
$coachScript = Join-Path $root "charybdis-tools\powershell\start_charybdis_coach.ps1"
if (Test-Path $coachScript) {
    powershell -ExecutionPolicy Bypass -File $coachScript
    Write-Host "[OK] Coach + beacon started" -ForegroundColor Green
} else {
    Write-Host "[SKIP] start_charybdis_coach.ps1 not found" -ForegroundColor Yellow
}

# --- Start AHK helper ---
Write-Host "`n--- Starting AHK helper + creating Startup shortcut ---" -ForegroundColor Cyan
$helperScript = Join-Path $root "charybdis-tools\powershell\start_charybdis_helpers.ps1"
if (Test-Path $helperScript) {
    powershell -ExecutionPolicy Bypass -File $helperScript
    Write-Host "[OK] AHK helper running (auto-starts on login)" -ForegroundColor Green
} else {
    Write-Host "[SKIP] start_charybdis_helpers.ps1 not found" -ForegroundColor Yellow
}

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "`nCoach:  http://127.0.0.1:8765/"
Write-Host "Helper: Running in background (auto-starts on login)"
Write-Host "`nTo start everything after a reboot:"
Write-Host "  powershell -ExecutionPolicy Bypass -File charybdis-tools\powershell\start_charybdis_coach.ps1" -ForegroundColor DarkGray
Write-Host "  (AHK helper auto-starts via Windows Startup shortcut)`n" -ForegroundColor DarkGray
