<#
Start and validate the Charybdis AutoHotkey v2 helper.

Run from the repo root:
  powershell -ExecutionPolicy Bypass -File .\scripts\windows\start_charybdis_helpers.ps1

This script:
- Finds AutoHotkey v2 even when it is not in PATH.
- Validates charybdis_helpers.ahk with AutoHotkey's /Validate mode.
- Creates/refreshes the Windows Startup shortcut.
- Starts the helper. The AHK file uses #SingleInstance Force, so this reloads
  the existing helper instance safely.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
}

$helperPath = Join-Path $RepoRoot "scripts\windows\charybdis_helpers.ahk"
if (-not (Test-Path -LiteralPath $helperPath)) {
    throw "Helper script not found: $helperPath"
}

$appsConfigPath = Join-Path $RepoRoot "config\charybdis_apps.json"
$helperConfigPath = Join-Path $RepoRoot "config\charybdis_helper.json"
foreach ($path in @($appsConfigPath, $helperConfigPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Config file not found: $path"
    }
    Get-Content -Raw -Encoding UTF8 -LiteralPath $path | ConvertFrom-Json | Out-Null
}
Write-Host "Helper JSON config validation passed." -ForegroundColor Green

$candidateAhk = @(
    (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey64.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\AutoHotkey\v2\AutoHotkey.exe"),
    "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
    "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe",
    "C:\Program Files\AutoHotkey\AutoHotkey.exe"
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

$startup = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startup "Charybdis Helpers.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $ahkPath
$shortcut.Arguments = '"' + $helperPath + '"'
$shortcut.WorkingDirectory = Split-Path -Parent $helperPath
$shortcut.Description = "Starts the Charybdis AutoHotkey v2 helper layer at login."
$shortcut.Save()
Write-Host "Startup shortcut refreshed: $shortcutPath" -ForegroundColor Green

Start-Process -FilePath $ahkPath -ArgumentList @($helperPath) -WorkingDirectory (Split-Path -Parent $helperPath)
Start-Sleep -Milliseconds 600

$running = Get-Process | Where-Object {
    $_.ProcessName -like "AutoHotkey*" -and $_.Path -eq $ahkPath
}

if ($running) {
    Write-Host "Charybdis AutoHotkey helper is running." -ForegroundColor Green
    $running | Select-Object Id, ProcessName, Path | Format-Table -AutoSize
} else {
    Write-Host "WARNING: AutoHotkey launch command completed, but no matching process was found." -ForegroundColor Yellow
}
