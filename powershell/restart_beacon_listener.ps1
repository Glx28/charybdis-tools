<#
Restart only the Python beacon listener (layer thumb sync). Keeps the HTTP coach server running.

Usage:
  powershell -ExecutionPolicy Bypass -File scripts\windows\restart_beacon_listener.ps1
#>
[CmdletBinding()]
param([string]$RepoRoot = "")

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\")).Path
}

$startScript = Join-Path $RepoRoot "scripts\windows\start_charybdis_coach.ps1"
& $startScript -RepoRoot $RepoRoot -NoBrowser
Write-Host "Beacon listener restart attempted. Spam Nav and check runtime\charybdis_beacon.log" -ForegroundColor Cyan