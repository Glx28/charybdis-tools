<#
Start and validate the Charybdis AutoHotkey v2 helper.

Run from the repo root:
  powershell -ExecutionPolicy Bypass -File .\powershell\start_charybdis_helpers.ps1

This script:
- Finds AutoHotkey v2 even when it is not in PATH (supports classic and UX variants).
- Validates charybdis_helpers.ahk with AutoHotkey's /Validate mode.
- Starts the helper and writes an identity-checked JSON PID record.
- Startup registration is owned by `charybdis.ps1 install-startup`.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [string]$Release = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

. (Join-Path $RepoRoot "powershell\lib\Charybdis.Common.ps1")
$paths = Get-CharybdisPaths -RepoRoot $RepoRoot
$pidPath = Join-Path $paths.RuntimeDir "charybdis_helper.pid"

$helperPath = Join-Path $RepoRoot "ahk\charybdis_helpers.ahk"
if (-not (Test-Path -LiteralPath $helperPath)) {
    throw "Helper script not found: $helperPath"
}

$candidateAhk = @(
    (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey64.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\UX\AutoHotkeyUX.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\AutoHotkeyUX.exe"),
    "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
    "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe",
    "C:\Program Files\AutoHotkey\AutoHotkey.exe",
    "C:\Program Files\AutoHotkey\UX\AutoHotkeyUX.exe"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

if (-not $candidateAhk) {
    throw "AutoHotkey v2 executable not found. Install AutoHotkey v2, then rerun this script."
}

$ahkPath = $candidateAhk[0]
Write-Host "Using AutoHotkey: $ahkPath" -ForegroundColor Green

$validate = Start-Process -FilePath $ahkPath -ArgumentList @("/Validate", $helperPath) -Wait -PassThru -WindowStyle Hidden
if ($validate.ExitCode -ne 0) {
    throw "AutoHotkey validation failed with exit code $($validate.ExitCode)."
}
Write-Host "AutoHotkey validation passed." -ForegroundColor Green

Stop-ByPidRecord -Path $pidPath -ExpectedCommandLineToken $helperPath

$started = Start-Process -FilePath $ahkPath -ArgumentList @("`"$helperPath`"") `
    -WorkingDirectory (Split-Path -Parent $helperPath) -PassThru
Start-Sleep -Milliseconds 600

$running = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessId -eq $started.Id -or ($_.CommandLine -and $_.CommandLine.Contains($helperPath)) } |
    Select-Object -First 1

if ($running) {
    $proc = Get-Process -Id $running.ProcessId -ErrorAction Stop
    Write-PidRecord -Path $pidPath -Process $proc -Release $Release
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "helper" `
        -Message "AutoHotkey helper started" -Release $Release -ProcessId $proc.Id
    Write-Host "Charybdis AutoHotkey helper is running." -ForegroundColor Green
    $proc | Select-Object Id, ProcessName, Path | Format-Table -AutoSize
} else {
    Write-ComponentLog -LogsDir $paths.LogsDir -Component "helper" `
        -Message "AutoHotkey launch completed but helper process was not found" -Severity "ERROR" -Release $Release
    throw "AutoHotkey launch completed, but no process matching $helperPath was found."
}
