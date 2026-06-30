<#
Validates the final Charybdis v1.8 operational layout bundle.

Run from the project root:
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\powershell\validate_layout_bundle.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

function Assert-Path {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing expected path: $Path"
    }
}

function Read-LayoutFromPayload {
    param([Parameter(Mandatory = $true)][string]$Path)

    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
    $match = [regex]::Match(
        $text,
        "window\.CHARYBDIS_FINAL_LAYOUT\s*=\s*(?<json>[\s\S]*?)\r?\n;\s*(?:window\.|/\*)"
    )
    if (-not $match.Success) {
        throw "Could not extract CHARYBDIS_FINAL_LAYOUT from $Path"
    }

    return $match.Groups["json"].Value | ConvertFrom-Json
}

$applyEveryPath = Join-Path $RepoRoot "scripts\zmk-studio\apply_every_key.js"
$applyAllPath = Join-Path $RepoRoot "scripts\zmk-studio\apply_operational_changes.js"
$verifyEveryPath = Join-Path $RepoRoot "scripts\zmk-studio\verify_every_key.js"
$layoutJsonPath = Join-Path $RepoRoot "layout\final_v1_8_operational_full_layout.json"
$layoutCsvPath = Join-Path $RepoRoot "layout\final_v1_8_operational_full_layout.csv"
$expectedCsvPath = Join-Path $RepoRoot "layout\final_v1_8_operational_full_live_verify_expected.csv"
$changeListPath = Join-Path $RepoRoot "layout\final_v1_8_operational_change_list.csv"
$explainedCsvPath = Join-Path $RepoRoot "layout\keybindings_explained.csv"
$explanationPath = Join-Path $RepoRoot "docs\layout.md"
$firmwareHashesPath = Join-Path $RepoRoot "firmware\SHA256SUMS.txt"
$appsConfigPath = Join-Path $RepoRoot "config\charybdis_apps.json"
$helperConfigPath = Join-Path $RepoRoot "config\charybdis_helper.json"
$ahkHelperPath = Join-Path $RepoRoot "scripts\windows\charybdis_helpers.ahk"
$coachStartPath = Join-Path $RepoRoot "scripts\windows\start_charybdis_coach.ps1"
$coachIndexPath = Join-Path $RepoRoot "apps\charybdis-coach\index.html"
$coachStylesPath = Join-Path $RepoRoot "apps\charybdis-coach\styles.css"
$coachAppPath = Join-Path $RepoRoot "apps\charybdis-coach\app.js"
$coachBeaconTemplatePath = Join-Path $RepoRoot "firmware\coach_beacon_macros.keymap.dtsi"

@(
    $applyEveryPath,
    $applyAllPath,
    $verifyEveryPath,
    $layoutJsonPath,
    $layoutCsvPath,
    $expectedCsvPath,
    $changeListPath,
    $explainedCsvPath,
    $explanationPath,
    $firmwareHashesPath,
    $appsConfigPath,
    $helperConfigPath,
    $ahkHelperPath,
    $coachStartPath,
    $coachIndexPath,
    $coachStylesPath,
    $coachAppPath,
    $coachBeaconTemplatePath
) | ForEach-Object { Assert-Path $_ }

$expectedVersion = "final-v1.8-operational-pointer-travel-full-every-key-reapply"
$applyLayout = Read-LayoutFromPayload -Path $applyEveryPath

if ($applyLayout.version -ne $expectedVersion) {
    throw "Unexpected apply layout version: $($applyLayout.version)"
}

if (@($applyLayout.keys).Count -ne 616) {
    throw "Expected 616 keys in apply payload, found $(@($applyLayout.keys).Count)"
}

$layout = Get-Content -Raw -Encoding UTF8 -LiteralPath $layoutJsonPath | ConvertFrom-Json
if (@($layout.keys).Count -ne 616) {
    throw "Expected 616 keys in layout JSON, found $(@($layout.keys).Count)"
}

$layoutRows = @(Import-Csv -LiteralPath $layoutCsvPath)
$expectedRows = @(Import-Csv -LiteralPath $expectedCsvPath)
$explainedRows = @(Import-Csv -LiteralPath $explainedCsvPath)

if ($layoutRows.Count -ne 616) {
    throw "Expected 616 rows in layout CSV, found $($layoutRows.Count)"
}
if ($expectedRows.Count -ne 616) {
    throw "Expected 616 rows in verifier expected CSV, found $($expectedRows.Count)"
}
if ($explainedRows.Count -ne 616) {
    throw "Expected 616 rows in explained keybinding CSV, found $($explainedRows.Count)"
}

$appsConfig = Get-Content -Raw -Encoding UTF8 -LiteralPath $appsConfigPath | ConvertFrom-Json
$helperConfig = Get-Content -Raw -Encoding UTF8 -LiteralPath $helperConfigPath | ConvertFrom-Json

if (-not $appsConfig.apps -or @($appsConfig.apps).Count -lt 1) {
    throw "Expected at least one app entry in $appsConfigPath"
}

foreach ($app in @($appsConfig.apps)) {
    if ([string]::IsNullOrWhiteSpace($app.id)) {
        throw "App config entry is missing id."
    }
    if (-not $app.aliases -or @($app.aliases).Count -lt 1) {
        throw "App config entry '$($app.id)' must define at least one alias."
    }
    if ([string]::IsNullOrWhiteSpace($app.launch)) {
        throw "App config entry '$($app.id)' is missing launch."
    }
    if (-not $app.window_match) {
        throw "App config entry '$($app.id)' is missing window_match."
    }
    if ([string]::IsNullOrWhiteSpace($app.window_match.exe) -and [string]::IsNullOrWhiteSpace($app.window_match.title)) {
        throw "App config entry '$($app.id)' needs window_match.exe or window_match.title."
    }
}

$allowedMonitorModes = @("secondary", "mouse", "primary")
if ($helperConfig.monitor_mode -notin $allowedMonitorModes) {
    throw "helper monitor_mode must be one of: $($allowedMonitorModes -join ', ')"
}
if ($helperConfig.opacity -lt 80 -or $helperConfig.opacity -gt 255) {
    throw "helper opacity must be between 80 and 255."
}
$allowedTransports = @("bluetooth", "usb")
if ($helperConfig.transport -and $helperConfig.transport -notin $allowedTransports) {
    throw "helper transport must be one of: $($allowedTransports -join ', ')"
}
if ($helperConfig.coach_server_port -and ($helperConfig.coach_server_port -lt 1024 -or $helperConfig.coach_server_port -gt 65535)) {
    throw "helper coach_server_port must be between 1024 and 65535."
}

foreach ($firmware in @(
    "firmware\charybdis_left.uf2",
    "firmware\charybdis_right_trackball.uf2",
    "firmware\settings_reset.uf2",
    "firmware\charybdis_right_trackball_ROLLBACK_CPI400_SNIPE200.uf2"
)) {
    Assert-Path (Join-Path $RepoRoot $firmware)
}

Write-Host "Operational v1.8 layout bundle validation passed." -ForegroundColor Green
