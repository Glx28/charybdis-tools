<#
.SYNOPSIS
    One-command start for the entire Charybdis stack.

.DESCRIPTION
    Pulls all three repos (tools, coach, zmk-config), kills stale processes,
    starts the AHK helper, beacon listener, and coach server, then runs
    health checks.

.PARAMETER Port
    HTTP server port. Defaults to 8765.

.PARAMETER SkipPull
    Skip git pull (useful for offline work).

.PARAMETER NoBrowser
    Skip opening the browser.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Start-Charybdis.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [int]$Port = 0,
    [switch]$SkipPull,
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Resolve repo root
# ---------------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path $PSScriptRoot).Path
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "ahk\charybdis_helpers.ahk"))) {
    throw "RepoRoot does not look like charybdis-tools: $RepoRoot"
}

$parentDir = (Resolve-Path (Join-Path $RepoRoot "..")).Path

# ---------------------------------------------------------------------------
# Helper: auto-detect remote branch
# ---------------------------------------------------------------------------
function Get-RemoteBranch($path) {
    $branches = git -C $path branch -r 2>$null
    $main = $branches | Where-Object { $_ -match 'origin/main\s*$' }
    if ($main) { return "main" }
    $master = $branches | Where-Object { $_ -match 'origin/master\s*$' }
    if ($master) { return "master" }
    $first = $branches | Where-Object { $_ -match 'origin/(\S+)' }
    if ($first) { return ($first -replace '.*origin/(\S+).*', '$1') }
    return $null
}

# ---------------------------------------------------------------------------
# Helper: pull a repo
# ---------------------------------------------------------------------------
function Update-Repo($name, $path) {
    Write-Host "[$name] $path" -ForegroundColor Cyan
    if (-not (Test-Path -LiteralPath (Join-Path $path ".git"))) {
        Write-Warning "  Not a git repo -- skipped."
        return
    }
    git -C $path fetch --all --prune 2>$null | Out-Null
    $branch = Get-RemoteBranch $path
    if (-not $branch) {
        Write-Warning "  Could not detect remote branch -- fetched only."
        return
    }
    $dirty = git -C $path status --porcelain
    if ([string]::IsNullOrWhiteSpace($dirty)) {
        $current = git -C $path rev-parse --abbrev-ref HEAD
        if ($current -eq $branch) {
            git -C $path pull --ff-only origin $branch 2>$null | Out-Null
        } else {
            git -C $path checkout $branch 2>$null | Out-Null
            git -C $path pull --ff-only origin $branch 2>$null | Out-Null
        }
    } else {
        Write-Warning "  Local changes present; fetched only, not pulling."
    }
    $short = git -C $path rev-parse --short HEAD
    Write-Host "  -> $short ($branch)" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 1. Pull all repos
# ---------------------------------------------------------------------------
if (-not $SkipPull) {
    Write-Host ""
    Write-Host "=== Updating Repos ===" -ForegroundColor Cyan
    Update-Repo "tools"     $RepoRoot
    Update-Repo "coach"     (Join-Path $parentDir "charybdis-coach")
    Update-Repo "zmk-config" (Join-Path $parentDir "charybdis-zmk-config")
}

# ---------------------------------------------------------------------------
# 2. Kill stale processes
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=== Stopping old processes ===" -ForegroundColor Cyan

function Stop-ByPidFile($pidPath) {
    if (Test-Path -LiteralPath $pidPath) {
        $id = Get-Content -LiteralPath $pidPath -ErrorAction SilentlyContinue
        if ($id) {
            Stop-Process -Id $id -Force -ErrorAction SilentlyContinue
            Write-Host "  Stopped PID $id (from $pidPath)" -ForegroundColor DarkGray
        }
        Remove-Item -LiteralPath $pidPath -Force -ErrorAction SilentlyContinue
    }
}

$runtimeDir = Join-Path $RepoRoot "runtime"
Stop-ByPidFile (Join-Path $runtimeDir "charybdis_coach_server.pid")
Stop-ByPidFile (Join-Path $runtimeDir "coach_beacon_listener.pid")
Stop-ByPidFile (Join-Path $runtimeDir "coach_beacon_only.pid")

# Also nuke any python http.server on our port
foreach ($conn in Get-NetTCPConnection -LocalPort 8765 -State Listen -ErrorAction SilentlyContinue) {
    Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
    Write-Host "  Killed process on port 8765 (PID $($conn.OwningProcess))" -ForegroundColor DarkGray
}

# Stop old AHK scripts so Git can replace ahk files
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match "charybdis_helpers\.ahk|coach_beacon_only\.ahk" } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped AutoHotkey PID $($_.ProcessId)" -ForegroundColor DarkGray
    }

Start-Sleep -Milliseconds 800

# ---------------------------------------------------------------------------
# 3. Start AHK helper
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=== Starting AHK Helper ===" -ForegroundColor Cyan
& (Join-Path $RepoRoot "powershell\start_charybdis_helpers.ps1") -RepoRoot $RepoRoot

# ---------------------------------------------------------------------------
# 4. Start Coach + Beacon
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=== Starting Coach Server ===" -ForegroundColor Cyan
$coachArgs = @{ RepoRoot = $RepoRoot; Port = $Port }
if ($NoBrowser) { $coachArgs['NoBrowser'] = $true }
& (Join-Path $RepoRoot "powershell\start_charybdis_coach.ps1") @coachArgs

# ---------------------------------------------------------------------------
# 5. Final summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=== CHARYBDIS STACK READY ===" -ForegroundColor Cyan
Write-Host "Coach:     http://127.0.0.1:$Port/coach/" -ForegroundColor Green
Write-Host "State:     $RepoRoot\runtime\charybdis_state.json" -ForegroundColor Green
Write-Host "Usage log: $RepoRoot\runtime\shortcut_usage.jsonl" -ForegroundColor Green
