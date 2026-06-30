<#
Capture layer-beacon activity for N seconds while you spam thumb / layer keys.

Usage (from repo root):
  powershell -ExecutionPolicy Bypass -File scripts\windows\capture_layer_beacons.ps1 -Seconds 10
#>
[CmdletBinding()]
param(
    [int]$Seconds = 10,
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Continue"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
}

$runtime = Join-Path $RepoRoot "runtime"
$stateFile = Join-Path $runtime "charybdis_state.json"
$eventFile = Join-Path $runtime "charybdis_events.jsonl"
$beaconLog = Join-Path $runtime "charybdis_beacon.log"
$outFile = Join-Path $runtime ("layer_capture_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

function Read-TailLines {
    param([string]$Path, [int]$Count = 5)
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    return @(Get-Content -LiteralPath $Path -Tail $Count -ErrorAction SilentlyContinue)
}

function Get-ListenerStatus {
    $pidPath = Join-Path $runtime "coach_beacon_listener.pid"
    $listenerPid = $null
    if (Test-Path -LiteralPath $pidPath) {
        $listenerPid = Get-Content -LiteralPath $pidPath -ErrorAction SilentlyContinue
    }
    $alive = $false
    $cmd = ""
    if ($listenerPid) {
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$listenerPid" -ErrorAction SilentlyContinue
        if ($proc -and ($proc.CommandLine -match "coach_beacon_listener")) {
            $alive = $true
            $cmd = $proc.CommandLine
        }
    }
    return [pscustomobject]@{ Pid = $listenerPid; Alive = $alive; CommandLine = $cmd }
}

$listener = Get-ListenerStatus
$eventStart = if (Test-Path $eventFile) { (Get-Item $eventFile).Length } else { 0 }
$beaconStart = if (Test-Path $beaconLog) { (Get-Item $beaconLog).Length } else { 0 }
$stateStart = if (Test-Path $stateFile) { (Get-Content -Raw -LiteralPath $stateFile) } else { "" }

$header = @(
    "=== Charybdis layer beacon capture ===",
    "Started: $(Get-Date -Format o)",
    "Duration: ${Seconds}s",
    "Repo: $RepoRoot",
    "",
    "BEFORE:",
    "  Listener PID: $($listener.Pid) alive=$($listener.Alive)",
    "  Listener CMD: $($listener.CommandLine)",
    "  State file: $stateFile",
    "  Event log:  $eventFile",
    "  Beacon log: $beaconLog",
    "",
    ">>> SPAM layer thumb keys now (Nav/Mouse/Window/System, single + double tap) <<<",
    ""
)
$header | Set-Content -LiteralPath $outFile -Encoding UTF8

Write-Host ($header -join "`n") -ForegroundColor Cyan
Write-Host "Capturing for $Seconds seconds..." -ForegroundColor Yellow

Start-Sleep -Seconds $Seconds

$listenerAfter = Get-ListenerStatus
$stateEnd = if (Test-Path $stateFile) { (Get-Content -Raw -LiteralPath $stateFile) } else { "" }

$newEvents = @()
if (Test-Path $eventFile) {
    $stream = [System.IO.File]::Open($eventFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $stream.Seek($eventStart, [System.IO.SeekOrigin]::Begin) | Out-Null
        $reader = New-Object System.IO.StreamReader($stream)
        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if ($line) { $newEvents += $line }
        }
    } finally {
        $reader.Dispose()
        $stream.Dispose()
    }
}

$newBeacon = @()
if (Test-Path $beaconLog) {
    $stream = [System.IO.File]::Open($beaconLog, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $stream.Seek($beaconStart, [System.IO.SeekOrigin]::Begin) | Out-Null
        $reader = New-Object System.IO.StreamReader($stream)
        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if ($line) { $newBeacon += $line }
        }
    } finally {
        $reader.Dispose()
        $stream.Dispose()
    }
}

$footer = @(
    "",
    "AFTER:",
    "  Listener PID: $($listenerAfter.Pid) alive=$($listenerAfter.Alive)",
    "  Listener CMD: $($listenerAfter.CommandLine)",
    "  New beacon log lines: $($newBeacon.Count)",
    "  New event log lines: $($newEvents.Count)",
    "",
    "--- Beacon log (new) ---"
)
if ($newBeacon.Count) { $footer += $newBeacon } else { $footer += "(none)" }
$footer += ""
$footer += "--- Event log (new) ---"
if ($newEvents.Count) { $footer += $newEvents } else { $footer += "(none)" }
$footer += ""
$footer += "--- State before ---"
$footer += if ($stateStart) { $stateStart.Trim() } else { "(missing)" }
$footer += ""
$footer += "--- State after ---"
$footer += if ($stateEnd) { $stateEnd.Trim() } else { "(missing)" }
$footer += ""
$footer += "Ended: $(Get-Date -Format o)"

Add-Content -LiteralPath $outFile -Value ($footer -join "`n") -Encoding UTF8

Write-Host ""
Write-Host "Capture saved: $outFile" -ForegroundColor Green
Write-Host "New beacon lines: $($newBeacon.Count) | New event lines: $($newEvents.Count)" -ForegroundColor $(if ($newEvents.Count -gt 0) { "Green" } else { "Red" })
if ($newEvents.Count -eq 0) {
    Write-Host "No beacons detected. Check: listener running, coach_* keys in ZMK Studio (not plain Momentary Layer), firmware with beacon macros flashed." -ForegroundColor Yellow
}