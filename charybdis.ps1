<#
.SYNOPSIS
    Unified Charybdis launcher: start, stop, restart, status, update, doctor,
    install-startup, bootstrap.

.DESCRIPTION
    Replaces the previous overlapping bootstrap.ps1 / Start-Charybdis.ps1 /
    powershell\update_and_start_charybdis.ps1 with one entry point. See
    powershell\lib\Charybdis.Common.ps1 for the shared safety primitives this
    relies on (checked git commands, PID-record process identity, a launcher
    mutex, rotated component logs, the release manifest).

.PARAMETER Command
    start | stop | restart | status | update | doctor | install-startup | bootstrap

.PARAMETER UseCurrent
    For `update`: proceed on a dirty tracked tools tree instead of failing.

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
    [switch]$UseCurrent,
    [switch]$Json,
    [switch]$Repair,
    [switch]$SkipClone,
    [switch]$IncludeOptimizer
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
    & (Join-Path $RepoRoot "powershell\start_charybdis_helpers.ps1") -RepoRoot $RepoRoot -Release $release
    $coachArgs = @{ RepoRoot = $RepoRoot; Release = $release }
    if ($Port -gt 0) { $coachArgs['Port'] = $Port }
    if ($NoBrowser) { $coachArgs['NoBrowser'] = $true }
    if ($ForceRestart) { $coachArgs['ForceRestart'] = $true }
    & (Join-Path $RepoRoot "powershell\start_charybdis_coach.ps1") @coachArgs

    $effectivePort = if ($Port -gt 0) { $Port } else { 8765 }
    $health = Test-ComponentHealth -Paths $paths -Port $effectivePort -Release $release
    $toolsCommit = Get-ShortCommit -Path $paths.ToolsDir
    $coachCommit = Get-ShortCommit -Path $paths.CoachDir
    $zmkCommit = Get-ShortCommit -Path $paths.ZmkDir
    $url = "http://127.0.0.1:$effectivePort/charybdis-coach/"
    $null = Write-StatusFile -Paths $paths -Ok $health.AllPass -Release $release `
        -ToolsCommit $toolsCommit -CoachCommit $coachCommit -ZmkCommit $zmkCommit -Url $url -HealthChecks $health.Checks
}

function Invoke-Stop {
    Write-Host "Stopping Charybdis stack..." -ForegroundColor Cyan
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "charybdis_helper.pid")
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "coach_beacon_listener.pid")
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "coach_beacon_only.pid")
    Stop-ByPidRecord -Path (Join-Path $paths.RuntimeDir "charybdis_coach_server.pid")
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "supervisor" -Message "Stopped by 'charybdis.ps1 stop'"
    Write-Host "Stopped." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# update
# ---------------------------------------------------------------------------

function Invoke-Update {
    Write-Host "=== Updating repos ===" -ForegroundColor Cyan
    $toolsCommit = Invoke-GitUpdate -Path $paths.ToolsDir -UseCurrent:$UseCurrent
    $coachCommit = Invoke-GitUpdate -Path $paths.CoachDir -UseCurrent:$UseCurrent
    $zmkCommit = Invoke-GitUpdate -Path $paths.ZmkDir -RequiredBranch "codex/build-coach-layers-cpi750" -UseCurrent:$UseCurrent
    Write-Host "  tools: $toolsCommit"
    Write-Host "  coach: $coachCommit"
    Write-Host "  zmk:   $zmkCommit"

    Write-Host "`n=== Validating release ===" -ForegroundColor Cyan
    $python = Get-VenvPython -Paths $paths
    if (-not $python) {
        $cmd = Get-Command python -ErrorAction SilentlyContinue
        if ($cmd) { $python = $cmd.Source }
    }
    if ($python) {
        $checkScript = Join-Path $RepoRoot "runtime\evolved_v2_export\release_check.py"
        $output = & $python $checkScript 2>&1
        Write-Host $output
        if ($LASTEXITCODE -ne 0) {
            Write-ComponentLog -LogsDir $paths.LogsDir -Component "update" -Message "release_check.py failed (exit $LASTEXITCODE)" -Severity "ERROR" -Release (Get-CurrentRelease)
            throw "Release validation failed - refusing to restart onto a mixed/invalid release. See output above."
        }
    } else {
        Write-Warning "No Python found; skipping release_check.py validation."
    }

    Write-Host "`n=== Restarting ===" -ForegroundColor Cyan
    Invoke-Stop
    Start-Sleep -Milliseconds 500
    Invoke-Start -ForceRestart
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "update" -Message "Update complete" -Release (Get-CurrentRelease)
}

# ---------------------------------------------------------------------------
# status / doctor
# ---------------------------------------------------------------------------

function Invoke-Status {
    $release = Get-CurrentRelease
    $effectivePort = if ($Port -gt 0) { $Port } else { 8765 }
    $health = Test-ComponentHealth -Paths $paths -Port $effectivePort -Release $release
    $toolsCommit = Get-ShortCommit -Path $paths.ToolsDir
    $coachCommit = Get-ShortCommit -Path $paths.CoachDir
    $zmkCommit = Get-ShortCommit -Path $paths.ZmkDir
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
        node = Get-Command node -ErrorAction SilentlyContinue
        python = Get-Command python -ErrorAction SilentlyContinue
    }
    foreach ($name in $prereqs.Keys) {
        $ok = [bool]$prereqs[$name]
        Write-Host ("  {0,-10} {1}" -f $name, $(if ($ok) { "OK" } else { "MISSING" })) -ForegroundColor $(if ($ok) { "Green" } else { "Red" })
    }

    $venvPython = Get-VenvPython -Paths $paths
    if ($venvPython) {
        Write-Host "  .venv      OK ($venvPython)" -ForegroundColor Green
        $importCheck = & $venvPython -c "import keyboard, serial" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  deps       OK (keyboard, pyserial importable)" -ForegroundColor Green
        } else {
            Write-Host "  deps       MISSING/broken: $importCheck" -ForegroundColor Red
            if ($Repair) {
                & $venvPython -m pip install -r (Join-Path $RepoRoot "requirements-runtime.txt")
            }
        }
    } else {
        Write-Host "  .venv      MISSING" -ForegroundColor Red
        if ($Repair) {
            $sysPython = $prereqs.python.Source
            if (-not $sysPython) { throw "Cannot create .venv: no system python found." }
            & $sysPython -m venv $paths.VenvDir
            $venvPython = Get-VenvPython -Paths $paths
            & $venvPython -m pip install -r (Join-Path $RepoRoot "requirements-runtime.txt")
            Write-Host "  .venv      created + requirements-runtime.txt installed" -ForegroundColor Green
        } else {
            Write-Host "             re-run with -Repair to create it" -ForegroundColor Yellow
        }
    }

    Write-Host "`n--- Git state ---" -ForegroundColor Cyan
    foreach ($pair in @(@("tools", $paths.ToolsDir), @("coach", $paths.CoachDir), @("zmk", $paths.ZmkDir))) {
        $dirty = Get-RepoDirtyState -Path $pair[1]
        $state = if ($dirty.IsTrackedDirty) { "DIRTY ($($dirty.TrackedFiles.Count) tracked file(s))" } else { "clean" }
        Write-Host ("  {0,-8} {1}" -f $pair[0], $state)
    }

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

    # Superseded by the Scheduled Task below - remove the old AHK-only
    # Startup-folder shortcut if start_charybdis_helpers.ps1 created one
    # previously, so the helper doesn't launch twice on login.
    $oldShortcut = Join-Path ([Environment]::GetFolderPath("Startup")) "Charybdis Helpers.lnk"
    if (Test-Path -LiteralPath $oldShortcut) {
        Remove-Item -LiteralPath $oldShortcut -Force
        Write-Host "Removed superseded Startup shortcut: $oldShortcut" -ForegroundColor DarkGray
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

    Register-ScheduledTask -TaskName "CharybdisStack" -Action $action -Trigger $trigger `
        -Principal $principal -Settings $settings -Force | Out-Null

    Write-Host "Scheduled Task 'CharybdisStack' installed: runs 'charybdis.ps1 start' ~10s after logon." -ForegroundColor Green
    Write-Host "It never runs 'update' at startup - keyboard/coach must come up even with no network." -ForegroundColor DarkGray
}

# ---------------------------------------------------------------------------
# bootstrap
# ---------------------------------------------------------------------------

function Invoke-Bootstrap {
    Write-Host "==== Charybdis Keyboard - Full Setup ====" -ForegroundColor Cyan

    $missing = @()
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { $missing += "Git (https://git-scm.com/download/win)" }
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) { $missing += "Node.js LTS (https://nodejs.org/)" }
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

    if (-not $SkipClone) {
        Write-Host "`n--- Cloning repositories ---" -ForegroundColor Cyan
        $repos = @{
            "charybdis-zmk-config" = "https://github.com/Glx28/zmk-config-charybdis-beacons.git"
            "charybdis-coach"      = "https://github.com/Glx28/charybdis-coach.git"
        }
        if ($IncludeOptimizer) {
            $repos["charybdis-optimizer"] = "https://github.com/Glx28/charybdis-optimizer.git"
        }
        foreach ($name in $repos.Keys) {
            $dest = Join-Path $paths.ParentDir $name
            if (Test-Path $dest) {
                Write-Host "[SKIP] $name already exists" -ForegroundColor Yellow
            } else {
                Invoke-NativeChecked -FilePath "git" -ArgumentList @("clone", $repos[$name], $dest) | Out-Null
                Write-Host "[OK] $name" -ForegroundColor Green
            }
        }
    }

    Write-Host "`n--- Python venv + runtime deps ---" -ForegroundColor Cyan
    $sysPython = (Get-Command python).Source
    if (-not (Test-Path -LiteralPath $paths.VenvDir)) {
        & $sysPython -m venv $paths.VenvDir
    }
    $venvPython = Get-VenvPython -Paths $paths
    & $venvPython -m pip install -r (Join-Path $RepoRoot "requirements-runtime.txt")
    Write-Host "[OK] .venv ready" -ForegroundColor Green

    Write-Host "`n--- Mouse settings (1:1 pointer, no acceleration) ---" -ForegroundColor Cyan
    $mouseScript = Join-Path $RepoRoot "powershell\apply_mouse_settings.ps1"
    if (Test-Path $mouseScript) {
        & $mouseScript
        Write-Host "[OK] Mouse settings applied" -ForegroundColor Green
    }

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
