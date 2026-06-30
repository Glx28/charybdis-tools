<#
.SYNOPSIS
    Update charybdis-tools and start the helper + coach.

.DESCRIPTION
    Designed for copy-paste use on Windows machines. Stops running AutoHotkey
    helper/beacon scripts before pulling so Git can replace ahk files, then
    starts the main helper and coach website.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\powershell\update_and_start_charybdis.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [int]$Port = 8765,
    [switch]$SkipPull
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "ahk\charybdis_helpers.ahk"))) {
    throw "RepoRoot does not look like charybdis-tools: $RepoRoot"
}

function Stop-CharybdisAhk {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match "charybdis_helpers\.ahk|coach_beacon_only\.ahk" } |
        ForEach-Object {
            Write-Host "Stopping AutoHotkey process $($_.ProcessId): $($_.CommandLine)" -ForegroundColor Yellow
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
    Start-Sleep -Milliseconds 800
}

Write-Host "Repo: $RepoRoot" -ForegroundColor Cyan
Set-Location $RepoRoot

Stop-CharybdisAhk

if (-not $SkipPull) {
    Write-Host "Updating git repo..." -ForegroundColor Cyan
    git fetch --all --prune
    $dirty = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($dirty)) {
        git pull --ff-only
    } else {
        Write-Host "[KEEP] Local changes present; fetched only, not pulling." -ForegroundColor Yellow
        git status -sb
    }
}

Write-Host "Starting AHK helper..." -ForegroundColor Cyan
& (Join-Path $RepoRoot "powershell\start_charybdis_helpers.ps1") -RepoRoot $RepoRoot

Write-Host "Starting coach..." -ForegroundColor Cyan
& (Join-Path $RepoRoot "powershell\start_charybdis_coach.ps1") -RepoRoot $RepoRoot -Port $Port

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "Coach:     http://127.0.0.1:$Port/charybdis-coach/" -ForegroundColor Green
Write-Host "Usage log: $RepoRoot\runtime\shortcut_usage.jsonl"
Write-Host "State:     $RepoRoot\runtime\charybdis_state.json"
