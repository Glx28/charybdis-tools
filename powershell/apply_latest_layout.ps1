<#
.SYNOPSIS
    Stage the current default Charybdis layout for ZMK Studio and refresh local tools.

.DESCRIPTION
    Uses the promoted default layout from the sibling charybdis-zmk-config repo.
    It validates that the ZMK CSV, in-repo coach CSV, and sibling coach CSV match,
    copies apply_every_key.js to the Windows clipboard, and optionally restarts
    the local coach server and AutoHotkey logger/helper so they reload the layout.

.PARAMETER RepoRoot
    Path to charybdis-tools. Defaults to the parent of this script's folder.

.PARAMETER RestartCoach
    Restart/start the local browser coach after staging the layout.

.PARAMETER RestartLogger
    Restart/start the AutoHotkey helper/logger after staging the layout.

.PARAMETER SkipClipboard
    Do not copy apply_every_key.js to the clipboard.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\powershell\apply_latest_layout.ps1 -RestartCoach -RestartLogger
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$RestartCoach,
    [switch]$RestartLogger,
    [switch]$SkipClipboard
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$parentDir = (Resolve-Path (Join-Path $RepoRoot "..")).Path
$zmkRepo = Join-Path $parentDir "charybdis-zmk-config"
$siblingCoachRepo = Join-Path $parentDir "charybdis-coach"

$applyPath = Join-Path $zmkRepo "scripts\zmk-studio\apply_every_key.js"
$verifyPath = Join-Path $zmkRepo "scripts\zmk-studio\verify_every_key.js"
$layoutMetaPath = Join-Path $zmkRepo "layout\final_user_layout_v2.json"
$zmkCsv = Join-Path $zmkRepo "layout\keybindings_explained.csv"
$toolsCoachCsv = Join-Path $RepoRoot "coach\data\keybindings_explained.csv"
$siblingCoachCsv = Join-Path $siblingCoachRepo "data\keybindings_explained.csv"

foreach ($path in @($applyPath, $verifyPath, $layoutMetaPath, $zmkCsv, $toolsCoachCsv, $siblingCoachCsv)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required layout file missing: $path"
    }
}

function Get-FileSha256 {
    param([string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

$zmkHash = Get-FileSha256 $zmkCsv
$toolsCoachHash = Get-FileSha256 $toolsCoachCsv
$siblingCoachHash = Get-FileSha256 $siblingCoachCsv

if ($zmkHash -ne $toolsCoachHash) {
    throw "In-repo coach CSV is not synced with zmk-config layout CSV."
}
if ($zmkHash -ne $siblingCoachHash) {
    throw "Sibling coach CSV is not synced with zmk-config layout CSV."
}

$layoutMeta = Get-Content -Raw -LiteralPath $layoutMetaPath | ConvertFrom-Json
$applyContent = Get-Content -Raw -LiteralPath $applyPath

if (-not $SkipClipboard) {
    Set-Clipboard -Value $applyContent
}

Write-Host ""
Write-Host "=== Charybdis latest layout staged ===" -ForegroundColor Green
Write-Host "Layout: $($layoutMeta.name)"
Write-Host "Run:    $($layoutMeta.source_run)"
Write-Host "Gen:    $($layoutMeta.source_generation) (best gen $($layoutMeta.best_generation))"
if ($layoutMeta.score_summary) {
    Write-Host "Gap:    $($layoutMeta.score_summary.gap)"
}
Write-Host "Apply:  $applyPath"
Write-Host "Verify: $verifyPath"
if (-not $SkipClipboard) {
    Write-Host "Clipboard: apply_every_key.js copied"
}
Write-Host ""

if ($RestartCoach) {
    & (Join-Path $RepoRoot "powershell\start_charybdis_coach.ps1") -RepoRoot $RepoRoot
}

if ($RestartLogger) {
    & (Join-Path $RepoRoot "powershell\start_charybdis_helpers.ps1") -RepoRoot $RepoRoot
}

Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  1. Open ZMK Studio and connect to the keyboard."
Write-Host "  2. Paste the clipboard content into DevTools console and run it."
Write-Host "  3. Save in ZMK Studio."
Write-Host "  4. Run verify_every_key.js from the path above."
