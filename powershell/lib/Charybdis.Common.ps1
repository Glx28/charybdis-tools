<#
.SYNOPSIS
    Shared functions for the Charybdis launcher (charybdis.ps1) and any
    scripts it calls. Dot-source this file; it defines functions only and
    has no side effects on its own.

.DESCRIPTION
    Consolidates patterns that used to be duplicated (and inconsistently
    checked) across bootstrap.ps1, Start-Charybdis.ps1, and
    powershell\update_and_start_charybdis.ps1:
      - Invoke-NativeChecked: every git/node/pip call gets a real exit-code
        check instead of relying on $ErrorActionPreference, which does not
        catch native non-zero exit codes.
      - Get-RepoDirtyState / Invoke-GitUpdate: a dirty tracked tree fails
        loudly (unless -UseCurrent) instead of silently skipping the pull.
      - PID records: JSON objects (pid, exe, commandLine, startTime, release)
        instead of a bare PID, so nothing kills a reused PID or an unrelated
        process that happens to own a port.
      - Write-ComponentLog: durable, rotated logs instead of output piped to
        $null.
      - A named mutex so start/stop/restart/update/a scheduled task/an AI
        agent can't race each other.
#>

# Deliberately no Set-StrictMode here: this file is dot-sourced into every
# launcher script's scope, and strict mode would then apply retroactively to
# code in this repo's style that wasn't written defensively against it
# (e.g. optional JSON properties read without null-guards, relying on
# PowerShell's normal $null-propagation). Keep behavior consistent with the
# rest of the project's scripts instead of changing semantics repo-wide here.

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

function Get-CharybdisPaths {
    <#
    Resolves the standard set of paths from a charybdis-tools RepoRoot.
    Assumes charybdis-tools, charybdis-coach, and charybdis-zmk-config are
    cloned as siblings (see CLAUDE.md's "Sibling Repos" section).
    #>
    param([Parameter(Mandatory)][string]$RepoRoot)

    $repoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
    $parentDir = (Resolve-Path -LiteralPath (Join-Path $repoRoot "..")).Path
    $runtimeDir = Join-Path $repoRoot "runtime"
    $logsDir = Join-Path $runtimeDir "logs"

    [pscustomobject]@{
        ToolsDir   = $repoRoot
        ParentDir  = $parentDir
        CoachDir   = Join-Path $parentDir "charybdis-coach"
        ZmkDir     = Join-Path $parentDir "charybdis-zmk-config"
        RuntimeDir = $runtimeDir
        LogsDir    = $logsDir
        VenvDir    = Join-Path $repoRoot ".venv"
        ManifestPath = Join-Path $repoRoot "release_manifest.json"
        StatusPath   = Join-Path $runtimeDir "status.json"
    }
}

function Get-VenvPython {
    param([Parameter(Mandatory)]$Paths)
    $exe = Join-Path $Paths.VenvDir "Scripts\python.exe"
    if (Test-Path -LiteralPath $exe) { return $exe }
    return $null
}

# ---------------------------------------------------------------------------
# Native command execution with real exit-code checking
# ---------------------------------------------------------------------------

function Invoke-NativeChecked {
    <#
    Runs a native executable, captures stdout/stderr, and throws (including
    the captured output) if it exits non-zero. $ErrorActionPreference does
    NOT catch native non-zero exit codes by itself on Windows PowerShell 5.1
    -- every git/node/pip invocation in this project must go through this.
    #>
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [string[]]$ArgumentList = @(),
        [string]$WorkingDirectory = $null,
        [switch]$AllowFailure
    )

    $prevDir = $null
    if ($WorkingDirectory) {
        $prevDir = Get-Location
        Set-Location -LiteralPath $WorkingDirectory
    }
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        # Windows PowerShell 5.1 wraps native stderr as ErrorRecord objects.
        # With the launcher's global preference set to Stop, that would throw
        # before we can inspect LASTEXITCODE, even for -AllowFailure probes.
        $ErrorActionPreference = "Continue"
        $output = & $FilePath @ArgumentList 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
        if ($prevDir) { Set-Location -LiteralPath $prevDir.Path }
    }

    if ($exitCode -ne 0 -and -not $AllowFailure) {
        throw "Command failed (exit $exitCode): $FilePath $($ArgumentList -join ' ')`n$output"
    }

    [pscustomobject]@{
        ExitCode = $exitCode
        Output   = $output.Trim()
        Success  = ($exitCode -eq 0)
    }
}

# ---------------------------------------------------------------------------
# Git: dirty-state checking and fail-loud updates
# ---------------------------------------------------------------------------

function Get-RepoDirtyState {
    <#
    Returns tracked vs untracked dirt separately. Untracked cruft (stray run
    exports, __pycache__, etc.) must never block a pull; tracked local edits
    must.
    #>
    param([Parameter(Mandatory)][string]$Path)

    $tracked = Invoke-NativeChecked -FilePath "git" -ArgumentList @("status", "--porcelain", "--untracked-files=no") -WorkingDirectory $Path
    $untracked = Invoke-NativeChecked -FilePath "git" -ArgumentList @("status", "--porcelain", "--untracked-files=normal") -WorkingDirectory $Path

    $trackedLines = @($tracked.Output -split "`n" | Where-Object { $_ -ne "" })
    $untrackedLines = @($untracked.Output -split "`n" | Where-Object { $_ -ne "" -and $trackedLines -notcontains $_ })

    [pscustomobject]@{
        IsTrackedDirty = ($trackedLines.Count -gt 0)
        TrackedFiles   = $trackedLines
        UntrackedCount = $untrackedLines.Count
    }
}

function Invoke-GitUpdate {
    <#
    Fetch + fast-forward pull a repo. Fails loudly (throws, listing the
    dirty files) on tracked local changes unless -UseCurrent is passed, in
    which case it fetches only and proceeds on the current tree. Every git
    call is exit-code checked via Invoke-NativeChecked.
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$RequiredBranch = "",
        [switch]$UseCurrent,
        [switch]$SkipPull
    )

    if (-not (Test-Path -LiteralPath (Join-Path $Path ".git"))) {
        throw "Missing git repo: $Path"
    }

    Invoke-NativeChecked -FilePath "git" -ArgumentList @("fetch", "--all", "--prune") -WorkingDirectory $Path | Out-Null

    if ($RequiredBranch) {
        $branch = (Invoke-NativeChecked -FilePath "git" -ArgumentList @("branch", "--show-current") -WorkingDirectory $Path).Output
        if ($branch -ne $RequiredBranch) {
            $dirty = Get-RepoDirtyState -Path $Path
            if ($dirty.IsTrackedDirty -and -not $UseCurrent) {
                throw "Cannot switch $Path to $RequiredBranch; tracked files are dirty:`n$($dirty.TrackedFiles -join "`n")"
            }
            if (-not $dirty.IsTrackedDirty) {
                Invoke-NativeChecked -FilePath "git" -ArgumentList @("checkout", $RequiredBranch) -WorkingDirectory $Path | Out-Null
            }
        }
    }

    if ($SkipPull) {
        return Get-ShortCommit -Path $Path
    }

    $dirty = Get-RepoDirtyState -Path $Path
    if ($dirty.IsTrackedDirty) {
        if (-not $UseCurrent) {
            throw "Tracked local changes in ${Path}; refusing to pull (would silently run a stale/mixed tree). Dirty files:`n$($dirty.TrackedFiles -join "`n")`nRe-run with -UseCurrent to proceed on the current tree anyway."
        }
        Write-Warning "Tracked local changes in ${Path}; using current tree as-is (-UseCurrent), did not pull."
    } else {
        Invoke-NativeChecked -FilePath "git" -ArgumentList @("pull", "--ff-only") -WorkingDirectory $Path | Out-Null
    }

    Get-ShortCommit -Path $Path
}

function Get-ShortCommit {
    param([Parameter(Mandatory)][string]$Path)
    (Invoke-NativeChecked -FilePath "git" -ArgumentList @("rev-parse", "--short", "HEAD") -WorkingDirectory $Path).Output
}

# ---------------------------------------------------------------------------
# Mutex: prevent concurrent start/stop/restart/update
# ---------------------------------------------------------------------------

function Enter-CharybdisMutex {
    param([int]$TimeoutSeconds = 30)

    $mutex = $null
    try {
        $mutex = New-Object System.Threading.Mutex($false, "Global\CharybdisLauncher")
    } catch {
        # Global\ namespace can be restricted in some session types; fall
        # back to a session-local mutex rather than failing outright.
        $mutex = New-Object System.Threading.Mutex($false, "Local\CharybdisLauncher")
    }

    if (-not $mutex.WaitOne([TimeSpan]::FromSeconds($TimeoutSeconds))) {
        throw "Another Charybdis launcher operation is already in progress (mutex busy after ${TimeoutSeconds}s). If this is stale, close any hung charybdis.ps1 process and retry."
    }
    return $mutex
}

function Exit-CharybdisMutex {
    param($Mutex)
    if ($Mutex) {
        try { $Mutex.ReleaseMutex() } catch { }
        $Mutex.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

function Write-ComponentLog {
    param(
        [Parameter(Mandatory)][string]$LogsDir,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")][string]$Severity = "INFO",
        [string]$Release = "",
        [int]$ProcessId = 0,
        [int]$MaxBytes = 5MB,
        [int]$KeepBackups = 3
    )

    if (-not (Test-Path -LiteralPath $LogsDir)) {
        New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
    }

    $logPath = Join-Path $LogsDir "$Component.log"

    if ((Test-Path -LiteralPath $logPath) -and (Get-Item -LiteralPath $logPath).Length -ge $MaxBytes) {
        for ($i = $KeepBackups; $i -ge 1; $i--) {
            $src = if ($i -eq 1) { $logPath } else { "$logPath.$($i - 1)" }
            $dst = "$logPath.$i"
            if (Test-Path -LiteralPath $src) {
                Move-Item -LiteralPath $src -Destination $dst -Force
            }
        }
    }

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $line = "$timestamp | $Severity | $Component | pid=$ProcessId | release=$Release | $Message"
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
}

function Get-LastFailedComponentLog {
    <#
    Returns the path to the most recently modified log under LogsDir whose
    tail contains an ERROR line, or $null if none. Used to point the user at
    a failure without them having to guess which log to open.
    #>
    param([Parameter(Mandatory)][string]$LogsDir)

    if (-not (Test-Path -LiteralPath $LogsDir)) { return $null }
    Get-ChildItem -LiteralPath $LogsDir -Filter "*.log" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Tail 20 -ErrorAction SilentlyContinue) -match "\| ERROR \|" } |
        Select-Object -First 1 -ExpandProperty FullName
}

function Get-UnresolvedRuntimeErrorLog {
    <#
    Return a runtime component log only when its newest ERROR occurs after its
    newest successful start marker. Historical update/validation failures are
    not runtime health failures, and a component that later restarted cleanly
    must not remain unhealthy forever because an old ERROR is still on disk.
    #>
    param([Parameter(Mandatory)][string]$LogsDir)

    foreach ($component in @("helper", "beacon", "coach-server")) {
        $path = Join-Path $LogsDir "$component.log"
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $lines = @(Get-Content -LiteralPath $path -Tail 200 -ErrorAction SilentlyContinue)
        $lastError = -1
        $lastStart = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "\| ERROR \|") { $lastError = $i }
            if ($lines[$i] -match "\| INFO \|" -and $lines[$i] -match "started") { $lastStart = $i }
        }
        if ($lastError -gt $lastStart) { return $path }
    }
    return $null
}

# ---------------------------------------------------------------------------
# PID records: identity-checked process tracking
# ---------------------------------------------------------------------------

function Write-PidRecord {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$Process,
        [string]$Release = ""
    )
    $cmdLine = ""
    try {
        $cim = Get-CimInstance Win32_Process -Filter "ProcessId = $($Process.Id)" -ErrorAction SilentlyContinue
        if ($cim) { $cmdLine = $cim.CommandLine }
    } catch { }

    $record = [pscustomobject]@{
        pid         = $Process.Id
        exe         = $Process.Path
        commandLine = $cmdLine
        startTime   = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        release     = $Release
    }
    $record | ConvertTo-Json | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Read-PidRecord {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    try {
        return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    } catch {
        return $null
    }
}

function Test-PidRecordAlive {
    <#
    A PID record is only "alive" if a process with that PID exists AND its
    current command line still matches what we recorded -- protects against
    a reused PID belonging to a completely different, unrelated process.
    #>
    param($Record)
    if (-not $Record -or -not $Record.pid) { return $false }
    $proc = Get-Process -Id $Record.pid -ErrorAction SilentlyContinue
    if (-not $proc) { return $false }
    if (-not $Record.commandLine) { return $true }
    try {
        $cim = Get-CimInstance Win32_Process -Filter "ProcessId = $($Record.pid)" -ErrorAction SilentlyContinue
        if (-not $cim) { return $false }
        return $cim.CommandLine -eq $Record.commandLine
    } catch {
        return $false
    }
}

function Stop-ByPidRecord {
    <#
    Stops the process named by a PID-record file, but only after confirming
    its live command line still matches the record -- never kills a reused
    PID or an unrelated process. Removes the record file either way.
    #>
    param([Parameter(Mandatory)][string]$Path)

    $record = Read-PidRecord -Path $Path
    if ($record -and (Test-PidRecordAlive -Record $record)) {
        Stop-Process -Id $record.pid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 200
    }
    Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# Release manifest
# ---------------------------------------------------------------------------

function Get-FileSha256 {
    param([Parameter(Mandatory)][string]$Path)
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Test-ReleaseManifest {
    <#
    Loads release_manifest.json (written by promote.py at promotion time)
    and checks it against the actual current state of all 3 repos: commit
    hashes match HEAD, and the 3 keybindings_explained.csv copies still
    hash-match each other and the manifest. Returns a named-checks object
    with the same "each check has a .pass, aggregate with all()" shape as
    acceptance_check.py, so callers can gate on .AllPass.
    #>
    param([Parameter(Mandatory)]$Paths)

    $checks = [ordered]@{}

    if (-not (Test-Path -LiteralPath $Paths.ManifestPath)) {
        $checks["manifest_exists"] = @{ pass = $false; detail = "No release_manifest.json at $($Paths.ManifestPath)" }
        return [pscustomobject]@{ Checks = $checks; AllPass = $false; Manifest = $null }
    }
    $checks["manifest_exists"] = @{ pass = $true }

    $manifest = Get-Content -Raw -LiteralPath $Paths.ManifestPath | ConvertFrom-Json

    $toolsHead = Get-ShortCommit -Path $Paths.ToolsDir
    $zmkHead = Get-ShortCommit -Path $Paths.ZmkDir
    $coachHead = Get-ShortCommit -Path $Paths.CoachDir

    # charybdis-tools' HEAD is informational only, not a gate: this repo also
    # carries dev tooling/launcher/AHK work unrelated to any promotion, so its
    # commit naturally drifts between promotions without indicating a mixed
    # install. Only zmk-config + charybdis-coach actually serve promoted
    # content and must agree with each other and the CSV hash below.
    $checks["tools_commit_informational"] = @{ pass = $true; expected = $manifest.commits.tools; actual = $toolsHead }
    $checks["zmk_commit_matches"]   = @{ pass = ($zmkHead -eq $manifest.commits.zmk); expected = $manifest.commits.zmk; actual = $zmkHead }
    $checks["coach_commit_matches"] = @{ pass = ($coachHead -eq $manifest.commits.coach); expected = $manifest.commits.coach; actual = $coachHead }

    $zmkCsv = Join-Path $Paths.ZmkDir "layout\keybindings_explained.csv"
    $coachCsv = Join-Path $Paths.CoachDir "data\keybindings_explained.csv"
    if ((Test-Path -LiteralPath $zmkCsv) -and (Test-Path -LiteralPath $coachCsv)) {
        $zmkHash = (Get-FileSha256 $zmkCsv).ToLower()
        $coachHash = (Get-FileSha256 $coachCsv).ToLower()
        $expectedHash = ([string]$manifest.csv_sha256).ToLower()
        $checks["csv_hashes_match"] = @{
            pass = ($zmkHash -eq $coachHash -and $zmkHash -eq $expectedHash)
            zmk = $zmkHash; coach = $coachHash; manifest = $expectedHash
        }
    } else {
        $checks["csv_hashes_match"] = @{ pass = $false; detail = "One or both CSV copies missing" }
    }

    $allPass = -not ($checks.Values | Where-Object { -not $_.pass })
    [pscustomobject]@{ Checks = $checks; AllPass = [bool]$allPass; Manifest = $manifest }
}

# ---------------------------------------------------------------------------
# Component health
# ---------------------------------------------------------------------------

function Test-ComponentHealth {
    <#
    Health beyond "HTTP 200": process identity, heartbeat recency, served
    content actually matching the promoted release. Returns a named-checks
    object like Test-ReleaseManifest.
    #>
    param(
        [Parameter(Mandatory)]$Paths,
        [Parameter(Mandatory)][int]$Port,
        [string]$Release = ""
    )

    $checks = [ordered]@{}

    # A locally reachable stack is still invalid if its promoted repos/CSV do
    # not match the release manifest (the common fresh-clone failure mode is
    # ZMK's default main branch instead of the promoted layout branch).
    $releaseState = Test-ReleaseManifest -Paths $Paths
    $checks["release_manifest_valid"] = @{
        pass = $releaseState.AllPass
        detail = if ($releaseState.AllPass) { "matched" } else { "repo commit or CSV hash mismatch" }
    }

    # AHK helper: process identity, not just "some AutoHotkey.exe is running"
    $ahkProcs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match [regex]::Escape("charybdis_helpers.ahk") }
    $checks["ahk_helper_running"] = @{ pass = [bool]$ahkProcs; detail = if ($ahkProcs) { "PID $($ahkProcs[0].ProcessId)" } else { "not found" } }

    # Python beacon listener: PID record identity match
    $beaconPidPath = Join-Path $Paths.RuntimeDir "coach_beacon_listener.pid"
    $beaconRecord = Read-PidRecord -Path $beaconPidPath
    $beaconAlive = Test-PidRecordAlive -Record $beaconRecord
    $checks["beacon_listener_alive"] = @{ pass = $beaconAlive }

    # Beacon heartbeat recency
    $statePath = Join-Path $Paths.RuntimeDir "charybdis_state.json"
    $heartbeatOk = $false
    $stateParses = $false
    if (Test-Path -LiteralPath $statePath) {
        try {
            $state = Get-Content -Raw -LiteralPath $statePath | ConvertFrom-Json
            $stateParses = $true
            if ($state.updatedAt) {
                $age = ((Get-Date).ToUniversalTime() - [datetime]::Parse($state.updatedAt).ToUniversalTime()).TotalSeconds
                $heartbeatOk = $age -lt 10
            }
        } catch { }
    }
    $checks["state_json_parses"] = @{ pass = $stateParses }
    $checks["beacon_heartbeat_recent"] = @{ pass = $heartbeatOk }

    # HTTP: reachable, contains release identifier, CSV hash matches
    $url = "http://127.0.0.1:$Port/charybdis-coach/index.html"
    $httpOk = $false
    $releaseMatches = $true
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
        $httpOk = $resp.StatusCode -eq 200
        if ($httpOk -and $Release) {
            $releaseMatches = $resp.Content -match [regex]::Escape($Release)
        }
    } catch { }
    $checks["http_reachable"] = @{ pass = $httpOk; url = $url }
    $checks["http_release_matches"] = @{ pass = ($httpOk -and $releaseMatches) }

    # No error written to logs since last start
    $lastFailedLog = Get-UnresolvedRuntimeErrorLog -LogsDir $Paths.LogsDir
    $checks["no_recent_log_errors"] = @{ pass = (-not $lastFailedLog); lastFailedLog = $lastFailedLog }

    $allPass = -not ($checks.Values | Where-Object { -not $_.pass })
    [pscustomobject]@{ Checks = $checks; AllPass = [bool]$allPass }
}

function Write-StatusFile {
    param(
        [Parameter(Mandatory)]$Paths,
        [Parameter(Mandatory)][bool]$Ok,
        [string]$Release = "",
        [string]$ToolsCommit = "",
        [string]$CoachCommit = "",
        [string]$ZmkCommit = "",
        [string]$Url = "",
        $HealthChecks = $null
    )
    $status = [pscustomobject]@{
        ok        = $Ok
        release   = $Release
        tools     = $ToolsCommit
        coach     = $CoachCommit
        zmk       = $ZmkCommit
        url       = $Url
        checkedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        health    = $HealthChecks
    }
    if (-not (Test-Path -LiteralPath $Paths.RuntimeDir)) {
        New-Item -ItemType Directory -Path $Paths.RuntimeDir -Force | Out-Null
    }
    $status | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $Paths.StatusPath -Encoding UTF8
    return $status
}
