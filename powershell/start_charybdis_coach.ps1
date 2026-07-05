<#
.SYNOPSIS
    Start the Charybdis web coach with live layer monitoring.

.DESCRIPTION
    Starts a local HTTP server serving the coach web UI, and optionally
    starts a layer beacon listener. On a fresh machine, the coach UI
    works immediately; layer beacons require the charybdis-zmk-config
    sibling repo for full config.

.PARAMETER RepoRoot
    Path to the charybdis-tools repo. Defaults to the script's parent directory.

.PARAMETER Port
    HTTP server port. Defaults to 8765 (or reads from charybdis_helper.json if present).

.PARAMETER NoBrowser
    Skip opening the browser.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\powershell\start_charybdis_coach.ps1

.EXAMPLE
    .\powershell\start_charybdis_coach.ps1 -Port 8080 -NoBrowser
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [int]$Port = 0,
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$parentDir = (Resolve-Path (Join-Path $RepoRoot "..")).Path
$coachDir = Join-Path $RepoRoot "coach"
$helperConfigPath = Join-Path $parentDir "charybdis-zmk-config\config\charybdis_helper.json"
$coachIndexPath = Join-Path $coachDir "index.html"
$runtimeDir = Join-Path $RepoRoot "runtime"
$pidPath = Join-Path $runtimeDir "charybdis_coach_server.pid"
$ahkScript = Join-Path $RepoRoot "ahk\coach_beacon_only.ahk"
$ahkPidPath = Join-Path $runtimeDir "coach_beacon_only.pid"

if (-not (Test-Path -LiteralPath $runtimeDir)) {
    New-Item -ItemType Directory -Path $runtimeDir | Out-Null
}

# -- Config: optional, with graceful defaults --
$helperConfig = @{
    coach_server_port = 8765
    coach_open_browser_on_start = $true
    coach_beacons_enabled = $true
}

if (Test-Path -LiteralPath $helperConfigPath) {
    try {
        $json = Get-Content -Raw -Encoding UTF8 -LiteralPath $helperConfigPath | ConvertFrom-Json
        if ($json.coach_server_port) { $helperConfig.coach_server_port = [int]$json.coach_server_port }
        if ($null -ne $json.coach_open_browser_on_start) { $helperConfig.coach_open_browser_on_start = [bool]$json.coach_open_browser_on_start }
        if ($null -ne $json.coach_beacons_enabled) { $helperConfig.coach_beacons_enabled = [bool]$json.coach_beacons_enabled }
    } catch {
        Write-Warning "Could not parse $helperConfigPath -- using defaults."
    }
} else {
    Write-Warning "Missing sibling repo: charybdis-zmk-config"
    Write-Warning "  The coach UI will still work, but custom config (port, opacity, etc.) is not loaded."
    Write-Warning "  To get full config, clone: https://github.com/Glx28/zmk-config-charybdis-beacons"
}

if ($Port -le 0) {
    $Port = $helperConfig.coach_server_port
}

# -- Coach app: required, but with helpful error if missing --
if (-not (Test-Path -LiteralPath $coachIndexPath)) {
    Write-Error @"

MISSING COACH APP
=================
The coach web UI was not found at:
  $coachIndexPath

The coach web UI should be at:
  $coachIndexPath

Fix: ensure the coach folder exists inside charybdis-tools:
  charybdis-tools  +-- coach\            <-- must exist
"@
    exit 1
}

# -- Helper functions --
function Test-LocalPort {
    param([int]$Port)
    try {
        $client = [Net.Sockets.TcpClient]::new()
        $task = $client.ConnectAsync("127.0.0.1", $Port)
        if (-not $task.Wait(250)) {
            $client.Dispose()
            return $false
        }
        $connected = $client.Connected
        $client.Dispose()
        return $connected
    } catch {
        return $false
    }
}

function Test-CoachHttp {
    param([int]$Port, [int]$TimeoutSec = 3)
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/coach/index.html" -UseBasicParsing -TimeoutSec $TimeoutSec
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Stop-CoachServer {
    param([string]$PidPath, [int]$Port)
    if (Test-Path -LiteralPath $PidPath) {
        $procId = Get-Content -LiteralPath $PidPath -ErrorAction SilentlyContinue
        if ($procId) {
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        }
        Remove-Item -LiteralPath $PidPath -Force -ErrorAction SilentlyContinue
    }
    foreach ($conn in Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) {
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Milliseconds 300
}

function Find-Python {
    foreach ($name in @("python", "python3", "py")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    return $null
}

function Stop-CoachBeaconListener {
    param([string]$PidPath)
    if (-not (Test-Path -LiteralPath $PidPath)) { return }
    $procId = Get-Content -LiteralPath $PidPath -ErrorAction SilentlyContinue
    if ($procId) { Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $PidPath -Force -ErrorAction SilentlyContinue
}

function Get-BeaconListenerProcess {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match "coach_beacon_listener\.py" }
}

function Stop-AllBeaconListeners {
    foreach ($proc in Get-BeaconListenerProcess) {
        Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
    }
}

function Test-BeaconHeartbeat {
    param([string]$StateFile, [datetime]$NotBeforeUtc)
    if (-not (Test-Path -LiteralPath $StateFile)) { return $false }
    try {
        $state = Get-Content -Raw -LiteralPath $StateFile | ConvertFrom-Json
        if (-not $state.updatedAt) { return $false }
        $updated = [datetime]::Parse($state.updatedAt).ToUniversalTime()
        return $updated -ge $NotBeforeUtc
    } catch { return $false }
}

function Start-PythonBeaconListener {
    param([string]$PythonExe, [string]$ScriptPath, [string]$PidPath, [string]$WorkingDir)
    $stderrLog = Join-Path $WorkingDir "runtime\coach_beacon_stderr.log"
    try {
        & $PythonExe -m pip install --quiet keyboard 2>&1 | Out-Null
    } catch {
        Write-Warning "Could not install 'keyboard' package. Beacon listener may fail."
        Write-Warning "  Fix: run 'python -m pip install keyboard' in an elevated PowerShell."
    }
    Stop-AllBeaconListeners
    $startedAtUtc = (Get-Date).ToUniversalTime()
    $scriptArg = (Resolve-Path -LiteralPath $ScriptPath).Path
    $proc = Start-Process -FilePath $PythonExe -ArgumentList @($scriptArg) -WorkingDirectory $WorkingDir -WindowStyle Hidden -RedirectStandardError $stderrLog -PassThru
    Set-Content -LiteralPath $PidPath -Value $proc.Id -Encoding ASCII
    $deadline = (Get-Date).AddSeconds(8)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 500
        $alive = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
        if (-not $alive) { break }
        if (Test-BeaconHeartbeat -StateFile (Join-Path $WorkingDir "runtime\charybdis_state.json") -NotBeforeUtc $startedAtUtc) { return $proc }
    }
    if (Get-Process -Id $proc.Id -ErrorAction SilentlyContinue) {
        Write-Warning "Beacon listener PID $($proc.Id) is running but heartbeat not confirmed yet."
        return $proc
    }
    if (Test-Path -LiteralPath $stderrLog) {
        Write-Warning "Beacon listener exited. See $stderrLog"
        Get-Content -LiteralPath $stderrLog -Tail 8 -ErrorAction SilentlyContinue | ForEach-Object { Write-Warning $_ }
    }
    Remove-Item -LiteralPath $PidPath -Force -ErrorAction SilentlyContinue
    return $null
}

function Start-AhkBeaconListener {
    param([string]$ScriptPath, [string]$PidPath, [string]$WorkingDir)
    $ahkCmd = Get-Command "AutoHotkey64.exe" -ErrorAction SilentlyContinue
    $ahkFromPath = if ($ahkCmd) { $ahkCmd.Source } else { $null }
    if (-not $ahkFromPath) {
        $ahkCmd = Get-Command "AutoHotkey.exe" -ErrorAction SilentlyContinue
        $ahkFromPath = if ($ahkCmd) { $ahkCmd.Source } else { $null }
    }
    if (-not $ahkFromPath) {
        $ahkCmd = Get-Command "AutoHotkeyUX.exe" -ErrorAction SilentlyContinue
        $ahkFromPath = if ($ahkCmd) { $ahkCmd.Source } else { $null }
    }
    $ahkCandidates = @(
        $ahkFromPath,
        "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey.exe",
        "$env:LocalAppData\Programs\AutoHotkey\UX\AutoHotkeyUX.exe",
        "$env:LocalAppData\Programs\AutoHotkey\AutoHotkeyUX.exe",
        "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe",
        "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey.exe",
        "${env:ProgramFiles}\AutoHotkey\UX\AutoHotkeyUX.exe"
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    $ahkExe = $ahkCandidates | Select-Object -First 1
    if (-not $ahkExe) { return $null }
    $proc = Start-Process -FilePath $ahkExe -ArgumentList @("`"$ScriptPath`"") -WorkingDirectory $WorkingDir -WindowStyle Minimized -PassThru
    Set-Content -LiteralPath $PidPath -Value $proc.Id -Encoding ASCII
    Start-Sleep -Milliseconds 900
    if (Get-Process -Id $proc.Id -ErrorAction SilentlyContinue) { return $proc }
    Remove-Item -LiteralPath $PidPath -Force -ErrorAction SilentlyContinue
    return $null
}

# -- Clean up old listeners --
$beaconScript = Join-Path $RepoRoot "python\coach_beacon_listener.py"
$beaconPidPath = Join-Path $runtimeDir "coach_beacon_listener.pid"
Stop-CoachBeaconListener -PidPath $beaconPidPath
Stop-AllBeaconListeners
if (Test-Path $ahkPidPath) {
    $oldAhkPid = Get-Content $ahkPidPath -ErrorAction SilentlyContinue
    if ($oldAhkPid) { Stop-Process -Id $oldAhkPid -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $ahkPidPath -Force -ErrorAction SilentlyContinue
}

# -- Start beacon listener --
$beaconRunning = $false
$ahkRunning = $false
$python = Find-Python

if ($python -and (Test-Path -LiteralPath $beaconScript)) {
    $beaconProc = Start-PythonBeaconListener -PythonExe $python -ScriptPath $beaconScript -PidPath $beaconPidPath -WorkingDir $RepoRoot
    if ($beaconProc) {
        $beaconRunning = $true
        Write-Host "Python beacon listener started (PID $($beaconProc.Id))" -ForegroundColor Green
    }
}
if (-not $beaconRunning -and (Test-Path -LiteralPath $ahkScript)) {
    $ahkProc = Start-AhkBeaconListener -ScriptPath $ahkScript -PidPath $ahkPidPath -WorkingDir $RepoRoot
    if ($ahkProc) {
        $ahkRunning = $true
        $beaconRunning = $true
        Write-Host "AHK beacon listener started (PID $($ahkProc.Id))" -ForegroundColor Green
    }
}
if (-not $beaconRunning) {
    Write-Warning "No layer beacon listener is running. Thumb keys will not sync until you re-run this script."
}

# -- Start or confirm HTTP server --
$serverReady = $false
if (Test-LocalPort -Port $Port) {
    if (Test-CoachHttp -Port $Port) {
        Write-Host "Coach server already listening on http://127.0.0.1:$Port" -ForegroundColor Green
        $serverReady = $true
    } else {
        Write-Warning "Port $Port is open but coach data is not being served. Restarting server..."
        Stop-CoachServer -PidPath $pidPath -Port $Port
    }
}

if (-not $serverReady) {
    $python = Find-Python
    if (-not $python) {
        throw "Python was not found. Install Python or start a static server from the repo root on port $Port."
    }
    $name = Split-Path -Leaf $python
    if ($name -ieq "py.exe" -or $name -ieq "py") {
        $arguments = @("-3", "-m", "http.server", "$Port", "--bind", "127.0.0.1")
    } else {
        $arguments = @("-m", "http.server", "$Port", "--bind", "127.0.0.1")
    }
    $server = Start-Process -FilePath $python -ArgumentList $arguments -WorkingDirectory $RepoRoot -WindowStyle Hidden -PassThru
    Set-Content -LiteralPath $pidPath -Value $server.Id -Encoding ASCII
    $deadline = (Get-Date).AddSeconds(8)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 300
        if (Test-CoachHttp -Port $Port) { $serverReady = $true; break }
    }
    if (-not $serverReady) { throw "Coach server did not start on http://127.0.0.1:$Port" }
    Write-Host "Coach server started on http://127.0.0.1:$Port (PID $($server.Id))." -ForegroundColor Green
}

# -- Open browser --
$coachDirName = Split-Path -Leaf $coachDir
$url = "http://127.0.0.1:$Port/$coachDirName/"
if (-not $NoBrowser -and $helperConfig.coach_open_browser_on_start) {
    if (-not (Test-CoachHttp -Port $Port)) { throw "Coach data is not reachable at $url" }
    Start-Process $url
}

Write-Host ""
Write-Host "Charybdis Coach Started!" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Web UI: $url" -ForegroundColor Green
Write-Host ""
if ($beaconRunning -and -not $ahkRunning) {
    Write-Host "Layer sync: Python beacon listener" -ForegroundColor Yellow
} elseif ($ahkRunning) {
    Write-Host "Layer sync: AHK beacon listener (tray icon)" -ForegroundColor Yellow
} else {
    Write-Warning "No beacon listener running -- layer thumb keys will not sync live."
}
Write-Host "Beacon log: $(Join-Path $runtimeDir 'beacon_debug.log')" -ForegroundColor DarkGray
Write-Host "Event log:  $(Join-Path $runtimeDir 'charybdis_events.jsonl')" -ForegroundColor DarkGray
