<#
.SYNOPSIS
    Start the Charybdis coach server and Python beacon listener.

.DESCRIPTION
    Serves only the coach UI and its live state file through a restricted
    loopback HTTP server. Processes are tracked with identity-checked JSON
    PID records.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [int]$Port = 0,
    [switch]$NoBrowser,
    [string]$Release = "",
    [switch]$ForceRestart
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

. (Join-Path $RepoRoot "powershell\lib\Charybdis.Common.ps1")
$paths = Get-CharybdisPaths -RepoRoot $RepoRoot

$configPath = Join-Path $paths.ZmkDir "config\charybdis_helper.json"
$config = @{
    coach_server_port = 8765
    coach_open_browser_on_start = $true
}
if (Test-Path -LiteralPath $configPath) {
    try {
        $loaded = Get-Content -Raw -Encoding UTF8 -LiteralPath $configPath | ConvertFrom-Json
        if ($loaded.coach_server_port) { $config.coach_server_port = [int]$loaded.coach_server_port }
        if ($null -ne $loaded.coach_open_browser_on_start) {
            $config.coach_open_browser_on_start = [bool]$loaded.coach_open_browser_on_start
        }
    } catch {
        Write-Warning "Could not parse $configPath; using launcher defaults."
    }
}
$portWasExplicit = $Port -gt 0
if ($Port -le 0) { $Port = $config.coach_server_port }

$coachIndex = Join-Path $paths.CoachDir "index.html"
$beaconScript = Join-Path $RepoRoot "python\coach_beacon_listener.py"
$serverScript = Join-Path $RepoRoot "python\coach_http_server.py"
$statePath = Join-Path $paths.RuntimeDir "charybdis_state.json"
$beaconPidPath = Join-Path $paths.RuntimeDir "coach_beacon_listener.pid"
$serverPidPath = Join-Path $paths.RuntimeDir "charybdis_coach_server.pid"
$portStatePath = Join-Path $paths.RuntimeDir "coach_server_port.txt"

if (-not $portWasExplicit -and (Test-Path -LiteralPath $portStatePath)) {
    try {
        $savedPort = [int](Get-Content -Raw -LiteralPath $portStatePath)
        if ($savedPort -ge 1 -and $savedPort -le 65535) { $Port = $savedPort }
    } catch { }
}

foreach ($required in @($coachIndex, $beaconScript, $serverScript)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required coach runtime file missing: $required" }
}
New-Item -ItemType Directory -Path $paths.RuntimeDir -Force | Out-Null
New-Item -ItemType Directory -Path $paths.LogsDir -Force | Out-Null

function Get-RuntimePython {
    $venv = Get-VenvPython -Paths $paths
    if ($venv) { return $venv }
    foreach ($name in @("python", "python3", "py")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    return $null
}

function Test-CoachHttp {
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/charybdis-coach/index.html" `
            -UseBasicParsing -TimeoutSec 3
        if ($response.StatusCode -ne 200) { return $false }
        if ($Release -and $response.Headers["X-Charybdis-Release"] -ne $Release) { return $false }
        return $true
    } catch { return $false }
}

function Test-CoachPortAvailable {
    param([Parameter(Mandatory)][int]$Candidate)
    if ($Candidate -lt 1 -or $Candidate -gt 65535) { return $false }
    $listener = Get-NetTCPConnection -LocalPort $Candidate -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($listener) { return $false }

    $probe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Candidate)
    try {
        $probe.Start()
        return $true
    } catch [System.Net.Sockets.SocketException] {
        return $false
    } finally {
        $probe.Stop()
    }
}

function Find-AvailableCoachPort {
    param([Parameter(Mandatory)][int]$PreferredPort)
    if ($PreferredPort -lt 1 -or $PreferredPort -gt 65535) {
        throw "Coach port must be between 1 and 65535; received $PreferredPort."
    }
    $lastPort = [Math]::Min(65535, $PreferredPort + 99)
    for ($candidate = $PreferredPort; $candidate -le $lastPort; $candidate++) {
        if (Test-CoachPortAvailable -Candidate $candidate) { return $candidate }
    }
    throw "No available coach port found from $PreferredPort through $lastPort."
}

function Save-CoachPortState {
    param([Parameter(Mandatory)][int]$ActivePort)
    $temporaryPath = "$portStatePath.$([Guid]::NewGuid().ToString('N')).tmp"
    [System.IO.File]::WriteAllText($temporaryPath, [string]$ActivePort, [System.Text.Encoding]::ASCII)
    Move-Item -LiteralPath $temporaryPath -Destination $portStatePath -Force
}

function Test-BeaconHeartbeat {
    param([datetime]$NotBeforeUtc)
    if (-not (Test-Path -LiteralPath $statePath)) { return $false }
    try {
        $state = Get-Content -Raw -LiteralPath $statePath | ConvertFrom-Json
        $stamp = if ($state.beaconHeartbeatAt) { $state.beaconHeartbeatAt } else { $state.updatedAt }
        if (-not $stamp) { return $false }
        return ((ConvertTo-UtcDateTime $stamp) -ge $NotBeforeUtc)
    } catch { return $false }
}

$python = Get-RuntimePython
if (-not $python) { throw "Python was not found. Run '.\charybdis.ps1 bootstrap' or install Python 3.10+." }

$importArgs = if ((Split-Path -Leaf $python) -ieq "py.exe") { @("-3", "-c", "import keyboard, serial") } else { @("-c", "import keyboard, serial") }
$importResult = Invoke-NativeChecked -FilePath $python -ArgumentList $importArgs -AllowFailure
if (-not $importResult.Success) {
    throw "Runtime Python dependencies are missing. Run '.\charybdis.ps1 doctor -Repair'.`n$($importResult.Output)"
}

if ($ForceRestart) {
    Stop-ByPidRecord -Path $beaconPidPath -ExpectedCommandLineToken $beaconScript
    Stop-ByPidRecord -Path $serverPidPath -ExpectedCommandLineToken "coach_http_server.py"
}

# Upgrade legacy bare-PID records even on a normal start. Without this, an old
# server from the pre-unified launcher can keep the port occupied forever.
if ((Test-Path -LiteralPath $beaconPidPath) -and -not (Read-PidRecord -Path $beaconPidPath)) {
    Stop-ByPidRecord -Path $beaconPidPath -ExpectedCommandLineToken $beaconScript
}
if ((Test-Path -LiteralPath $serverPidPath) -and -not (Read-PidRecord -Path $serverPidPath)) {
    Stop-ByPidRecord -Path $serverPidPath -ExpectedCommandLineToken "coach_http_server.py"
}

$beaconRecord = Read-PidRecord -Path $beaconPidPath
if (-not (Test-PidRecordAlive -Record $beaconRecord)) {
    Remove-Item -LiteralPath $beaconPidPath -Force -ErrorAction SilentlyContinue
    $beaconStdout = Join-Path $paths.LogsDir "beacon.stdout.log"
    $beaconStderr = Join-Path $paths.LogsDir "beacon.stderr.log"
    $beaconArgs = if ((Split-Path -Leaf $python) -ieq "py.exe") { @("-3", $beaconScript) } else { @($beaconScript) }
    $beaconStartedAt = (Get-Date).ToUniversalTime().AddSeconds(-1)
    $beacon = Start-Process -FilePath $python -ArgumentList $beaconArgs -WorkingDirectory $RepoRoot `
        -WindowStyle Hidden -RedirectStandardOutput $beaconStdout -RedirectStandardError $beaconStderr -PassThru
    Write-PidRecord -Path $beaconPidPath -Process $beacon -Release $Release
    $deadline = (Get-Date).AddSeconds(8)
    while ((Get-Date) -lt $deadline -and (Get-Process -Id $beacon.Id -ErrorAction SilentlyContinue)) {
        if (Test-BeaconHeartbeat -NotBeforeUtc $beaconStartedAt) { break }
        Start-Sleep -Milliseconds 300
    }
    if (-not (Get-Process -Id $beacon.Id -ErrorAction SilentlyContinue)) {
        Write-ComponentLog -LogsDir $paths.LogsDir -Component "beacon" -Message "Beacon listener exited during startup; see $beaconStderr" -Severity "ERROR" -Release $Release
        throw "Beacon listener exited during startup. See $beaconStderr"
    }
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "beacon" -Message "Beacon listener started" -Release $Release -ProcessId $beacon.Id
}

$serverRecord = Read-PidRecord -Path $serverPidPath
$serverAlive = Test-PidRecordAlive -Record $serverRecord
if (-not $serverAlive) {
    Remove-Item -LiteralPath $serverPidPath -Force -ErrorAction SilentlyContinue
    $preferredPort = $Port
    $Port = Find-AvailableCoachPort -PreferredPort $preferredPort
    if ($Port -ne $preferredPort) {
        $message = "Preferred coach port $preferredPort is busy; using $Port instead."
        Write-Host $message -ForegroundColor Yellow
        Write-ComponentLog -LogsDir $paths.LogsDir -Component "coach-server" -Message $message -Release $Release
    }
    $serverStdout = Join-Path $paths.LogsDir "coach-server.stdout.log"
    $serverStderr = Join-Path $paths.LogsDir "coach-server.stderr.log"
    $serverArgs = @($serverScript, "$Port", "--bind", "127.0.0.1", "--coach-dir", $paths.CoachDir, "--state-file", $statePath)
    if ($Release) { $serverArgs += @("--release", $Release) }
    if ((Split-Path -Leaf $python) -ieq "py.exe") { $serverArgs = @("-3") + $serverArgs }
    $server = Start-Process -FilePath $python -ArgumentList $serverArgs -WorkingDirectory $RepoRoot `
        -WindowStyle Hidden -RedirectStandardOutput $serverStdout -RedirectStandardError $serverStderr -PassThru
    Write-PidRecord -Path $serverPidPath -Process $server -Release $Release
    $deadline = (Get-Date).AddSeconds(8)
    while ((Get-Date) -lt $deadline -and -not (Test-CoachHttp)) { Start-Sleep -Milliseconds 250 }
    if (-not (Test-CoachHttp)) {
        Stop-ByPidRecord -Path $serverPidPath
        Write-ComponentLog -LogsDir $paths.LogsDir -Component "coach-server" -Message "Coach HTTP health check failed; see $serverStderr" -Severity "ERROR" -Release $Release
        throw "Coach server did not become healthy at http://127.0.0.1:$Port/charybdis-coach/. See $serverStderr"
    }
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "coach-server" -Message "Coach server started" -Release $Release -ProcessId $server.Id
} elseif (-not (Test-CoachHttp)) {
    throw "The recorded coach server is running but does not serve the expected release. Run restart."
}

Save-CoachPortState -ActivePort $Port
$url = "http://127.0.0.1:$Port/charybdis-coach/"
if (-not $NoBrowser -and $config.coach_open_browser_on_start) { Start-Process $url }
Write-Host "Coach server and beacon listener are healthy: $url" -ForegroundColor Green
