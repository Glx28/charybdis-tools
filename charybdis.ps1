<#
.SYNOPSIS
    Self-contained runtime launcher: start, stop, restart, status, update,
    doctor, install-startup, bootstrap.

.DESCRIPTION
    Replaces the previous overlapping bootstrap.ps1 / Start-Charybdis.ps1 /
    powershell\update_and_start_charybdis.ps1 with one entry point. See
    powershell\lib\Charybdis.Common.ps1 for the shared safety primitives this
    relies on (checked git commands, PID-record process identity, a launcher
    mutex, rotated component logs, the release manifest).

.PARAMETER Command
    start | stop | restart | status | update | doctor | install-startup | bootstrap

.PARAMETER Json
    Print machine-readable {ok, release, tools, coach, zmk, url} instead of
    formatted text - for AI agents / scripting.

.PARAMETER Repair
    For `doctor`: create/refresh .venv and install requirements-runtime.txt.

.EXAMPLE
    .\charybdis.ps1 update
.EXAMPLE
    .\charybdis.ps1 install-startup
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet("start", "stop", "restart", "status", "update", "doctor", "install-startup", "bootstrap")]
    [string]$Command,

    [string]$RepoRoot = "",
    [int]$Port = 0,
    [switch]$NoBrowser,
    [switch]$Json,
    [switch]$Repair
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path $PSScriptRoot).Path
}

. (Join-Path $RepoRoot "powershell\lib\Charybdis.Common.ps1")
$paths = Get-CharybdisPaths -RepoRoot $RepoRoot

function Get-CurrentRelease {
    if (Test-Path -LiteralPath $paths.ManifestPath) {
        try {
            return (Get-Content -Raw -LiteralPath $paths.ManifestPath | ConvertFrom-Json).release
        } catch { return "" }
    }
    return ""
}

function Get-CoachServerPort {
    param([switch]$UseActive)
    $portStatePath = Join-Path $paths.RuntimeDir "coach_server_port.txt"
    if ($UseActive -and (Test-Path -LiteralPath $portStatePath)) {
        try {
            $active = [int](Get-Content -Raw -LiteralPath $portStatePath)
            if ($active -ge 1 -and $active -le 65535) { return $active }
        } catch { }
    }
    if ($Port -gt 0) { return $Port }
    if (Test-Path -LiteralPath $portStatePath) {
        try {
            $active = [int](Get-Content -Raw -LiteralPath $portStatePath)
            if ($active -ge 1 -and $active -le 65535) { return $active }
        } catch { }
    }
    $helperConfigPath = Join-Path $paths.ZmkDir "config\charybdis_helper.json"
    if (Test-Path -LiteralPath $helperConfigPath) {
        try {
            $helperConfig = Get-Content -Raw -LiteralPath $helperConfigPath | ConvertFrom-Json
            $configured = [int]$helperConfig.coach_server_port
            if ($configured -ge 1 -and $configured -le 65535) { return $configured }
        } catch { }
    }
    return 8765
}

function Print-Result {
    param($Result)
    if ($Json) {
        $Result | ConvertTo-Json -Depth 6
    } else {
        Write-Host ""
        Write-Host ("OK: {0}" -f $Result.ok) -ForegroundColor $(if ($Result.ok) { "Green" } else { "Red" })
        Write-Host "Release: $($Result.release)"
        Write-Host "tools:  $($Result.tools)"
        Write-Host "coach:  $($Result.coach)"
        Write-Host "zmk:    $($Result.zmk)"
        Write-Host "URL:    $($Result.url)"
        if (-not $Result.ok) {
            $lastLog = Get-LastFailedComponentLog -LogsDir $paths.LogsDir
            if ($lastLog) { Write-Host "Last failed component log: $lastLog" -ForegroundColor Yellow }
        }
    }
}

# ---------------------------------------------------------------------------
# start / stop / restart
# ---------------------------------------------------------------------------

function Invoke-Start {
    param([switch]$ForceRestart)
    $release = Get-CurrentRelease
    $releaseState = Test-ReleaseManifest -Paths $paths
    if (-not $releaseState.AllPass) {
        $failed = @($releaseState.Checks.GetEnumerator() | Where-Object { -not $_.Value.pass } | ForEach-Object { $_.Key })
        throw "Local release is inconsistent ($($failed -join ', ')); refusing to start a mixed keyboard/coach layout. Run '.\charybdis.ps1 update' or repair the checked-out branches."
    }
    & (Join-Path $RepoRoot "powershell\start_charybdis_helpers.ps1") -RepoRoot $RepoRoot -Release $release
    $coachArgs = @{ RepoRoot = $RepoRoot; Release = $release }
    if ($Port -gt 0) { $coachArgs['Port'] = $Port }
    if ($NoBrowser) { $coachArgs['NoBrowser'] = $true }
    if ($ForceRestart) { $coachArgs['ForceRestart'] = $true }
    & (Join-Path $RepoRoot "powershell\start_charybdis_coach.ps1") @coachArgs

    $effectivePort = Get-CoachServerPort -UseActive
    $health = Test-ComponentHealth -Paths $paths -Port $effectivePort -Release $release
    $toolsCommit = Get-ShortCommit -Path $paths.ToolsDir
    $coachCommit = "bundled"
    $zmkCommit = "bundled"
    $url = "http://127.0.0.1:$effectivePort/charybdis-coach/"
    $null = Write-StatusFile -Paths $paths -Ok $health.AllPass -Release $release `
        -ToolsCommit $toolsCommit -CoachCommit $coachCommit -ZmkCommit $zmkCommit -Url $url -HealthChecks $health.Checks
}

function Invoke-Stop {
    Write-Host "Stopping Charybdis stack..." -ForegroundColor Cyan
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "charybdis_helper.pid") `
        -ExpectedCommandLineToken (Join-Path $RepoRoot "ahk\charybdis_helpers.ahk")
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "coach_beacon_listener.pid") `
        -ExpectedCommandLineToken (Join-Path $RepoRoot "python\coach_beacon_listener.py")
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "coach_beacon_only.pid") `
        -ExpectedCommandLineToken (Join-Path $RepoRoot "ahk\coach_beacon_only.ahk")
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "charybdis_coach_server.pid") `
        -ExpectedCommandLineToken "coach_http_server.py"
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "supervisor" -Message "Stopped by 'charybdis.ps1 stop'"
    Write-Host "Stopped." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# update
# ---------------------------------------------------------------------------

function Invoke-Update {
    Write-Host "=== Updating the unified runtime repo ===" -ForegroundColor Cyan
    Invoke-NativeChecked -FilePath "git" -ArgumentList @("pull", "--ff-only") -WorkingDirectory $RepoRoot | Out-Null
    $bundle = Test-ReleaseManifest -Paths $paths
    if (-not $bundle.AllPass) { throw "Bundled coach/layout data failed validation. Check the checkout before restarting." }
    Write-Host "`n=== Restarting ===" -ForegroundColor Cyan
    Invoke-Stop
    Start-Sleep -Milliseconds 500
    Invoke-Start -ForceRestart
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "update" -Message "Unified runtime repo updated" -Release (Get-CurrentRelease)
}

# ---------------------------------------------------------------------------
# status / doctor
# ---------------------------------------------------------------------------

function Invoke-Status {
    $release = Get-CurrentRelease
    $effectivePort = Get-CoachServerPort
    $health = Test-ComponentHealth -Paths $paths -Port $effectivePort -Release $release
    $toolsCommit = Get-ShortCommit -Path $paths.ToolsDir
    $coachCommit = "bundled"
    $zmkCommit = "bundled"
    $url = "http://127.0.0.1:$effectivePort/charybdis-coach/"
    $result = Write-StatusFile -Paths $paths -Ok $health.AllPass -Release $release `
        -ToolsCommit $toolsCommit -CoachCommit $coachCommit -ZmkCommit $zmkCommit -Url $url -HealthChecks $health.Checks
    if (-not $Json) {
        Write-Host "`nHealth checks:" -ForegroundColor Cyan
        foreach ($key in $health.Checks.Keys) {
            $c = $health.Checks[$key]
            $color = if ($c.pass) { "Green" } else { "Red" }
            Write-Host ("  {0,-28} {1}" -f $key, $c.pass) -ForegroundColor $color
        }
    }
    Print-Result -Result $result
}

function Invoke-Doctor {
    Write-Host "=== Charybdis doctor ===" -ForegroundColor Cyan

    $prereqs = @{
        git = Get-Command git -ErrorAction SilentlyContinue
        python = Get-Command python -ErrorAction SilentlyContinue
    }
    foreach ($name in $prereqs.Keys) {
        $ok = [bool]$prereqs[$name]
        Write-Host ("  {0,-10} {1}" -f $name, $(if ($ok) { "OK" } else { "MISSING" })) -ForegroundColor $(if ($ok) { "Green" } else { "Red" })
    }

    $venvPython = Get-VenvPython -Paths $paths
    if ($venvPython) {
        Write-Host "  .venv      OK ($venvPython)" -ForegroundColor Green
        $importCheck = Invoke-NativeChecked -FilePath $venvPython -ArgumentList @("-c", "import keyboard, serial") -AllowFailure
        if ($importCheck.Success) {
            Write-Host "  deps       OK (keyboard, pyserial importable)" -ForegroundColor Green
        } else {
            Write-Host "  deps       MISSING/broken: $($importCheck.Output)" -ForegroundColor Red
            if ($Repair) {
                Invoke-NativeChecked -FilePath $venvPython -ArgumentList @("-m", "pip", "install", "-r", (Join-Path $RepoRoot "requirements-runtime.txt")) | Out-Null
            }
        }
    } else {
        Write-Host "  .venv      MISSING" -ForegroundColor Red
        if ($Repair) {
            $sysPython = $prereqs.python.Source
            if (-not $sysPython) { throw "Cannot create .venv: no system python found." }
            Invoke-NativeChecked -FilePath $sysPython -ArgumentList @("-m", "venv", $paths.VenvDir) | Out-Null
            $venvPython = Get-VenvPython -Paths $paths
            Invoke-NativeChecked -FilePath $venvPython -ArgumentList @("-m", "pip", "install", "-r", (Join-Path $RepoRoot "requirements-runtime.txt")) | Out-Null
            Write-Host "  .venv      created + requirements-runtime.txt installed" -ForegroundColor Green
        } else {
            Write-Host "             re-run with -Repair to create it" -ForegroundColor Yellow
        }
    }

    Write-Host "`n--- Unified runtime repo ---" -ForegroundColor Cyan
    $dirty = Get-RepoDirtyState -Path $paths.ToolsDir
    $state = if ($dirty.IsTrackedDirty) { "DIRTY ($($dirty.TrackedFiles.Count) tracked file(s))" } else { "clean" }
    Write-Host ("  {0,-8} {1}" -f "runtime", $state)
    Write-Host "  Coach UI and keyboard data are bundled in this repo."

    Write-Host "`n--- Release manifest ---" -ForegroundColor Cyan
    $manifestResult = Test-ReleaseManifest -Paths $paths
    foreach ($key in $manifestResult.Checks.Keys) {
        $c = $manifestResult.Checks[$key]
        $color = if ($c.pass) { "Green" } else { "Red" }
        Write-Host ("  {0,-28} {1}" -f $key, $c.pass) -ForegroundColor $color
    }

    Write-Host "`n--- Component health (if running) ---" -ForegroundColor Cyan
    $effectivePort = if ($Port -gt 0) { $Port } else { 8765 }
    $health = Test-ComponentHealth -Paths $paths -Port $effectivePort -Release (Get-CurrentRelease)
    foreach ($key in $health.Checks.Keys) {
        $c = $health.Checks[$key]
        $color = if ($c.pass) { "Green" } else { "Red" }
        Write-Host ("  {0,-28} {1}" -f $key, $c.pass) -ForegroundColor $color
    }
}

# ---------------------------------------------------------------------------
# install-startup
# ---------------------------------------------------------------------------

function Invoke-InstallStartup {
    if (-not (Get-Command Register-ScheduledTask -ErrorAction SilentlyContinue)) {
        throw "Register-ScheduledTask is not available (requires Windows PowerShell with the ScheduledTasks module)."
    }

    $scriptPath = Join-Path $RepoRoot "charybdis.ps1"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" start -NoBrowser" `
        -WorkingDirectory $RepoRoot

    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $trigger.Delay = "PT10S"

    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -StartWhenAvailable -DontStopOnIdleEnd `
        -MultipleInstances IgnoreNew `
        -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) `
        -ExecutionTimeLimit ([TimeSpan]::Zero)

    $startup = [Environment]::GetFolderPath("Startup")
    $legacyShortcuts = @(
        (Join-Path $startup "Charybdis Helpers.lnk"),
        (Join-Path $startup "Charybdis Coach.lnk")
    )
    $fallbackShortcut = Join-Path $startup "Charybdis Stack.lnk"
    $scheduledTaskInstalled = $false
    try {
        Register-ScheduledTask -TaskName "CharybdisStack" -Action $action -Trigger $trigger `
            -Principal $principal -Settings $settings -Force -ErrorAction Stop | Out-Null
        $scheduledTaskInstalled = $true
    } catch {
        # Managed and non-admin Windows sessions may deny task registration.
        # Preserve reboot recovery with one unified per-user Startup entry.
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($fallbackShortcut)
        $shortcut.TargetPath = (Get-Command powershell.exe).Source
        $shortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`" start -NoBrowser"
        $shortcut.WorkingDirectory = $RepoRoot
        $shortcut.Description = "Starts the complete Charybdis stack at user logon."
        $shortcut.WindowStyle = 7
        $shortcut.Save()
        Write-Warning "Scheduled Task registration was denied; installed Startup fallback instead. Run install-startup from an elevated PowerShell to enable delayed start and automatic retries."
    }

    foreach ($oldShortcut in $legacyShortcuts) {
        if (Test-Path -LiteralPath $oldShortcut) {
            Remove-Item -LiteralPath $oldShortcut -Force
            Write-Host "Removed superseded Startup shortcut: $oldShortcut" -ForegroundColor DarkGray
        }
    }
    if ($scheduledTaskInstalled) {
        Remove-Item -LiteralPath $fallbackShortcut -Force -ErrorAction SilentlyContinue
        Write-Host "Scheduled Task 'CharybdisStack' installed: runs 'charybdis.ps1 start' ~10s after logon." -ForegroundColor Green
        Write-Host "It never runs 'update' at startup - keyboard/coach must come up even with no network." -ForegroundColor DarkGray
    } else {
        Write-Host "Startup fallback installed: $fallbackShortcut" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# bootstrap
# ---------------------------------------------------------------------------

function Invoke-Bootstrap {
    Write-Host "==== Charybdis Keyboard - Full Setup ====" -ForegroundColor Cyan

    $missing = @()
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { $missing += "Git (https://git-scm.com/download/win)" }
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
        throw "Install prerequisites above, then re-run 'charybdis.ps1 bootstrap'."
    }

    Write-Host "`n--- Coach UI and keyboard runtime data ---" -ForegroundColor Cyan
    $bundle = Test-ReleaseManifest -Paths $paths
    if (-not $bundle.AllPass) { throw "Bundled coach/layout data is incomplete or inconsistent." }
    Write-Host "[OK] Coach UI, beacon layout, and host config are bundled" -ForegroundColor Green

    Write-Host "`n--- Python venv + runtime deps ---" -ForegroundColor Cyan
    $sysPython = (Get-Command python).Source
    if (-not (Test-Path -LiteralPath $paths.VenvDir)) {
        Invoke-NativeChecked -FilePath $sysPython -ArgumentList @("-m", "venv", $paths.VenvDir) | Out-Null
    }
    $venvPython = Get-VenvPython -Paths $paths
    Invoke-NativeChecked -FilePath $venvPython -ArgumentList @("-m", "pip", "install", "-r", (Join-Path $RepoRoot "requirements-runtime.txt")) | Out-Null
    Write-Host "[OK] .venv ready" -ForegroundColor Green

    Write-Host "`n--- Starting stack ---" -ForegroundColor Cyan
    Invoke-Start

    Write-Host "`n==== Setup complete! ====" -ForegroundColor Green
    Write-Host "Run 'charybdis.ps1 install-startup' once to auto-start on every login/reboot." -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

$needsMutex = @("start", "stop", "restart", "update")
$mutex = $null
try {
    if ($Command -in $needsMutex) {
        $mutex = Enter-CharybdisMutex
    }

    switch ($Command) {
        "start" {
            Invoke-Start
            $status = Get-Content -Raw -LiteralPath $paths.StatusPath | ConvertFrom-Json
            Print-Result -Result $status
        }
        "stop" {
            Invoke-Stop
        }
        "restart" {
            Invoke-Stop
            Start-Sleep -Milliseconds 500
            Invoke-Start -ForceRestart
            $status = Get-Content -Raw -LiteralPath $paths.StatusPath | ConvertFrom-Json
            Print-Result -Result $status
        }
        "update" {
            Invoke-Update
            $status = Get-Content -Raw -LiteralPath $paths.StatusPath | ConvertFrom-Json
            Print-Result -Result $status
        }
        "status" {
            Invoke-Status
        }
        "doctor" {
            if ($Json) {
                Invoke-Doctor 6>$null
                Invoke-Status
            } else {
                Invoke-Doctor
            }
        }
        "install-startup" {
            Invoke-InstallStartup
        }
        "bootstrap" {
            Invoke-Bootstrap
        }
    }
} finally {
    if ($mutex) { Exit-CharybdisMutex -Mutex $mutex }
}
