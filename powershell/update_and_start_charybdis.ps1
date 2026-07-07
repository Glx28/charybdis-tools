<#
.SYNOPSIS
    Update all Charybdis runtime repos and restart helper, beacon, and coach.

.DESCRIPTION
    One-command runtime refresh for users and AI agents. By default this script:
    - Pulls charybdis-tools, charybdis-coach, and charybdis-zmk-config.
    - Ensures charybdis-zmk-config is on codex/build-coach-layers-cpi750.
    - Updates coach/index.html cache-busters to the current charybdis-tools commit.
    - Validates coach/app.js and ZMK Studio apply/verify JavaScript.
    - Restarts the AutoHotkey helper/logger, beacon listener, and coach server.
    - Prints commit hashes, PIDs, and the cache-busted coach URL.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\nos\charybdis-tools\powershell\update_and_start_charybdis.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [int]$Port = 8765,
    [switch]$SkipPull,
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "ahk\charybdis_helpers.ahk"))) {
    throw "RepoRoot does not look like charybdis-tools: $RepoRoot"
}

$ParentDir = (Resolve-Path (Join-Path $RepoRoot "..")).Path
$CoachRepo = Join-Path $ParentDir "charybdis-coach"
$ZmkRepo = Join-Path $ParentDir "charybdis-zmk-config"
$RuntimeDir = Join-Path $RepoRoot "runtime"

function Invoke-GitUpdate {
    param(
        [string]$Path,
        [string]$RequiredBranch = ""
    )
    if (-not (Test-Path -LiteralPath (Join-Path $Path ".git"))) {
        throw "Missing git repo: $Path"
    }

    Push-Location $Path
    try {
        if ($RequiredBranch) {
            $branch = (git branch --show-current).Trim()
            if ($branch -ne $RequiredBranch) {
                $trackedDirty = git status --porcelain --untracked-files=no
                if (-not [string]::IsNullOrWhiteSpace($trackedDirty)) {
                    throw "Cannot switch $Path to $RequiredBranch; tracked files are dirty."
                }
                git checkout $RequiredBranch | Out-Null
            }
        }

        if (-not $SkipPull) {
            git fetch --all --prune | Out-Null
            $trackedDirty = git status --porcelain --untracked-files=no
            if ([string]::IsNullOrWhiteSpace($trackedDirty)) {
                git pull --ff-only | Out-Null
            } else {
                Write-Warning "Tracked local changes in $Path; fetched but did not pull."
            }
        }
    } finally {
        Pop-Location
    }
}

function Get-ShortCommit {
    param([string]$Path)
    Push-Location $Path
    try { return (git rev-parse --short HEAD).Trim() }
    finally { Pop-Location }
}

function Update-CoachCacheBuster {
    param(
        [string]$IndexPath,
        [string]$Version
    )
    if (-not (Test-Path -LiteralPath $IndexPath)) {
        throw "Missing coach index: $IndexPath"
    }
    $html = Get-Content -Raw -LiteralPath $IndexPath
    $html = $html -replace 'styles\.css\?v=[^"]+', "styles.css?v=$Version"
    $html = $html -replace 'app\.js\?v=[^"]+', "app.js?v=$Version"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($IndexPath, $html, $utf8NoBom)
}

function Invoke-NodeCheck {
    param([string]$Path)
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        throw "node is required for JavaScript validation."
    }
    & node --check $Path | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "JavaScript syntax check failed: $Path" }
}

function Stop-CharybdisAhk {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match "charybdis_helpers\.ahk|coach_beacon_only\.ahk" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Milliseconds 800
}

function Get-ProcessIdFromFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $value = (Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue | Select-Object -First 1)
    if (-not $value) { return $null }
    $proc = Get-Process -Id ([int]$value) -ErrorAction SilentlyContinue
    if ($proc) { return $proc.Id }
    return $null
}

function Get-AhkHelperPid {
    $helper = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match "charybdis_helpers\.ahk" } |
        Select-Object -First 1
    if ($helper) { return $helper.ProcessId }
    return $null
}

function Test-CoachHttp {
    param([int]$Port)
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/coach/index.html" -UseBasicParsing -TimeoutSec 5
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null

Invoke-GitUpdate -Path $RepoRoot
Invoke-GitUpdate -Path $CoachRepo
Invoke-GitUpdate -Path $ZmkRepo -RequiredBranch "codex/build-coach-layers-cpi750"

$toolsCommit = Get-ShortCommit -Path $RepoRoot
$coachCommit = Get-ShortCommit -Path $CoachRepo
$zmkCommit = Get-ShortCommit -Path $ZmkRepo

Update-CoachCacheBuster -IndexPath (Join-Path $RepoRoot "coach\index.html") -Version $toolsCommit
Invoke-NodeCheck -Path (Join-Path $RepoRoot "coach\app.js")
Invoke-NodeCheck -Path (Join-Path $ZmkRepo "scripts\zmk-studio\apply_every_key.js")
Invoke-NodeCheck -Path (Join-Path $ZmkRepo "scripts\zmk-studio\verify_every_key.js")

Stop-CharybdisAhk

& (Join-Path $RepoRoot "powershell\start_charybdis_helpers.ps1") -RepoRoot $RepoRoot *> $null
& (Join-Path $RepoRoot "powershell\start_charybdis_coach.ps1") -RepoRoot $RepoRoot -Port $Port -NoBrowser *> $null

$deadline = (Get-Date).AddSeconds(8)
while ((Get-Date) -lt $deadline) {
    if (Test-CoachHttp -Port $Port) { break }
    Start-Sleep -Milliseconds 300
}
if (-not (Test-CoachHttp -Port $Port)) {
    throw "Coach HTTP check failed: http://127.0.0.1:$Port/coach/index.html"
}

$helperPid = Get-AhkHelperPid
$beaconPid = Get-ProcessIdFromFile -Path (Join-Path $RuntimeDir "coach_beacon_listener.pid")
if (-not $beaconPid) {
    $beaconPid = Get-ProcessIdFromFile -Path (Join-Path $RuntimeDir "coach_beacon_only.pid")
}
$coachPid = Get-ProcessIdFromFile -Path (Join-Path $RuntimeDir "charybdis_coach_server.pid")
$url = "http://127.0.0.1:$Port/coach/?force=$toolsCommit"

if (-not $NoBrowser) {
    Start-Process $url
}

Write-Host "charybdis-tools: $toolsCommit"
Write-Host "charybdis-coach: $coachCommit"
Write-Host "charybdis-zmk-config: $zmkCommit"
Write-Host "AutoHotkey helper/logger PID: $helperPid"
Write-Host "Beacon listener PID: $beaconPid"
Write-Host "Coach server PID: $coachPid"
Write-Host "Coach URL: $url"
