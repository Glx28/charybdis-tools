<#
.SYNOPSIS
    Pull the latest Charybdis layout/logger/website and start everything on Windows.

.DESCRIPTION
    1. git pull charybdis-tools and charybdis-coach
    2. Start the AutoHotkey helper (shortcut usage logger + beacon listener)
    3. Start the coach HTTP server + beacon listener and open the browser

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\powershell\pull_and_run_latest.ps1
#>
[CmdletBinding()]
param(
    [string]$ToolsRepoRoot = "",
    [string]$CoachRepoRoot = "",
    [int]$CoachPort = 0,
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ToolsRepoRoot)) {
    $ToolsRepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}
if ([string]::IsNullOrWhiteSpace($CoachRepoRoot)) {
    $CoachRepoRoot = Join-Path (Split-Path -Parent $ToolsRepoRoot) "charybdis-coach"
}

function Invoke-GitPull($repoPath, $name) {
    if (-not (Test-Path -LiteralPath $repoPath)) {
        throw "$name repo not found at: $repoPath"
    }
    Write-Host "`n=== Pulling $name ===" -ForegroundColor Cyan
    Push-Location $repoPath
    try {
        git pull
        if ($LASTEXITCODE -ne 0) { throw "git pull failed in $repoPath" }
    } finally {
        Pop-Location
    }
}

Invoke-GitPull -repoPath $ToolsRepoRoot -name "charybdis-tools"
Invoke-GitPull -repoPath $CoachRepoRoot -name "charybdis-coach"

Write-Host "`n=== Starting AutoHotkey helper (logger) ===" -ForegroundColor Cyan
$helpersScript = Join-Path $ToolsRepoRoot "powershell\start_charybdis_helpers.ps1"
& powershell -ExecutionPolicy Bypass -File "$helpersScript" -RepoRoot $ToolsRepoRoot

Write-Host "`n=== Starting coach website ===" -ForegroundColor Cyan
$coachScript = Join-Path $ToolsRepoRoot "powershell\start_charybdis_coach.ps1"
$coachArgs = @("-ExecutionPolicy", "Bypass", "-File", "$coachScript", "-RepoRoot", $ToolsRepoRoot)
if ($CoachPort -gt 0) { $coachArgs += @("-Port", $CoachPort) }
if ($NoBrowser) { $coachArgs += "-NoBrowser" }
& powershell @coachArgs

Write-Host "`n=== All done ===" -ForegroundColor Green
