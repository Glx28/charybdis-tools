<#
.SYNOPSIS
    Pull the latest charybdis-zmk-config layout and stage it for applying in ZMK Studio.

.DESCRIPTION
    Runs the unified cross-repo update/release gate, then copies the current
    apply_every_key.js content to the clipboard so it can be pasted straight
    into the ZMK Studio devtools console. Prints the matching verify script path.

.PARAMETER RepoRoot
    Path to charybdis-tools. Defaults to the parent of this script's folder.

.PARAMETER SkipPull
    Skip the git pull and just re-copy the current apply script to clipboard.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\powershell\pull_and_apply_layout.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [switch]$SkipPull
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$parentDir = (Resolve-Path (Join-Path $RepoRoot "..")).Path
$zmkRepo = Join-Path $parentDir "charybdis-zmk-config"

if (-not (Test-Path -LiteralPath (Join-Path $zmkRepo "scripts\zmk-studio\apply_every_key.js"))) {
    throw "Sibling repo not found or missing scripts\zmk-studio\apply_every_key.js: $zmkRepo"
}

$applyPath = Join-Path $zmkRepo "scripts\zmk-studio\apply_every_key.js"
$verifyPath = Join-Path $zmkRepo "scripts\zmk-studio\verify_every_key.js"

if (-not $SkipPull) {
    & (Join-Path $RepoRoot "charybdis.ps1") update -NoBrowser
} else {
    . (Join-Path $RepoRoot "powershell\lib\Charybdis.Common.ps1")
    $paths = Get-CharybdisPaths -RepoRoot $RepoRoot
    $release = Test-ReleaseManifest -Paths $paths
    if (-not $release.AllPass) {
        throw "Current layout does not match release_manifest.json; refusing to stage a mixed layout."
    }
}

$applyContent = Get-Content -Raw -LiteralPath $applyPath
Set-Clipboard -Value $applyContent

Write-Host ""
Write-Host "=== Layout apply script copied to clipboard ===" -ForegroundColor Green
Write-Host "Apply:  $applyPath"
Write-Host "Verify: $verifyPath"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open ZMK Studio and connect to the keyboard."
Write-Host "  2. Open devtools console (F12) and paste (Ctrl+V), then Enter."
Write-Host "  3. Confirm the apply prompt. It will not click Save for you."
Write-Host "  4. Save in ZMK Studio, then paste verify_every_key.js to confirm."
