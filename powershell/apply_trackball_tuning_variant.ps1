<#
Applies one staged PMW3610 trackball tuning variant to the seller Charybdis
firmware reference repo. This script edits firmware source files but does not
build, flash, or save anything to a keyboard.

Run from the project root:
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\powershell\apply_trackball_tuning_variant.ps1 -Variant cpi-800-400
#>

[CmdletBinding()]
param(
    [ValidateSet(
        "baseline-400-200",
        "cpi-600-300",
        "cpi-800-400",
        "cpi-1000-500",
        "cpi-1200-600",
        "rawaccel-800",
        "rawaccel-1200",
        "rawaccel-1600",
        "smart-on",
        "smart-off",
        "scroll-70",
        "scroll-90",
        "scroll-50",
        "automouse-off",
        "automouse-1000",
        "automouse-1500",
        "automouse-2000",
        "snipe-off",
        "snipe-layer-8"
    )]
    [string]$Variant = "cpi-800-400",

    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

$shieldDir = Join-Path $RepoRoot "vendor\vzhao-zmk-for-charybdis-main-20250226\config\boards\shields\charybdis"
$confPath = Join-Path $shieldDir "charybdis_right.conf"
$overlayPath = Join-Path $shieldDir "charybdis_right.overlay"

if (-not (Test-Path -LiteralPath $confPath)) {
    throw "Missing config file: $confPath"
}
if (-not (Test-Path -LiteralPath $overlayPath)) {
    throw "Missing overlay file: $overlayPath"
}

function Set-ConfigValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $line = "$Name=$Value"
    if ($Text -match "(?m)^#?\s*$([regex]::Escape($Name))=.*$") {
        return [regex]::Replace($Text, "(?m)^#?\s*$([regex]::Escape($Name))=.*$", $line)
    }

    return $Text.TrimEnd() + "`r`n" + $line + "`r`n"
}

function Comment-ConfigValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($Text -match "(?m)^\s*$([regex]::Escape($Name))=.*$") {
        return [regex]::Replace($Text, "(?m)^\s*$([regex]::Escape($Name))=.*$", "# $Name is not set")
    }

    return $Text
}

function Set-CpiPair {
    param(
        [Parameter(Mandatory = $true)][string]$ConfText,
        [Parameter(Mandatory = $true)][int]$Cpi,
        [Parameter(Mandatory = $true)][int]$SnipeCpi
    )

    $ConfText = Set-ConfigValue -Text $ConfText -Name "CONFIG_PMW3610_CPI" -Value $Cpi
    $ConfText = Set-ConfigValue -Text $ConfText -Name "CONFIG_PMW3610_SNIPE_CPI" -Value $SnipeCpi
    return $ConfText
}

function Set-OverlayProperty {
    param(
        [Parameter(Mandatory = $true)][string]$OverlayText,
        [Parameter(Mandatory = $true)][string]$Property,
        [Parameter(Mandatory = $true)][string]$Line
    )

    if ($OverlayText -match "(?m)^\s*//\s*$([regex]::Escape($Property))\s*=.*;$") {
        return [regex]::Replace($OverlayText, "(?m)^\s*//\s*$([regex]::Escape($Property))\s*=.*;$", "        $Line")
    }
    if ($OverlayText -match "(?m)^\s*$([regex]::Escape($Property))\s*=.*;$") {
        return [regex]::Replace($OverlayText, "(?m)^\s*$([regex]::Escape($Property))\s*=.*;$", "        $Line")
    }

    return $OverlayText -replace "(?m)^(\s*scroll-layers\s*=.*;)$", "`$1`r`n        $Line"
}

function Comment-OverlayProperty {
    param(
        [Parameter(Mandatory = $true)][string]$OverlayText,
        [Parameter(Mandatory = $true)][string]$Property,
        [Parameter(Mandatory = $true)][string]$FallbackLine
    )

    if ($OverlayText -match "(?m)^\s*$([regex]::Escape($Property))\s*=.*;$") {
        return [regex]::Replace($OverlayText, "(?m)^\s*$([regex]::Escape($Property))\s*=.*;$", "        //$FallbackLine")
    }
    if ($OverlayText -notmatch "(?m)^\s*//\s*$([regex]::Escape($Property))\s*=.*;$") {
        return $OverlayText -replace "(?m)^(\s*scroll-layers\s*=.*;)$", "`$1`r`n        //$FallbackLine"
    }

    return $OverlayText
}

$conf = Get-Content -Raw -Encoding UTF8 -LiteralPath $confPath
$overlay = Get-Content -Raw -Encoding UTF8 -LiteralPath $overlayPath

switch ($Variant) {
    "baseline-400-200" { $conf = Set-CpiPair -ConfText $conf -Cpi 400 -SnipeCpi 200 }
    "cpi-600-300" { $conf = Set-CpiPair -ConfText $conf -Cpi 600 -SnipeCpi 300 }
    "cpi-800-400" { $conf = Set-CpiPair -ConfText $conf -Cpi 800 -SnipeCpi 400 }
    "cpi-1000-500" { $conf = Set-CpiPair -ConfText $conf -Cpi 1000 -SnipeCpi 500 }
    "cpi-1200-600" { $conf = Set-CpiPair -ConfText $conf -Cpi 1200 -SnipeCpi 600 }
    "smart-on" { $conf = Set-ConfigValue -Text $conf -Name "CONFIG_PMW3610_SMART_ALGORITHM" -Value "y" }
    "smart-off" { $conf = Comment-ConfigValue -Text $conf -Name "CONFIG_PMW3610_SMART_ALGORITHM" }
    "scroll-70" { $conf = Set-ConfigValue -Text $conf -Name "CONFIG_PMW3610_SCROLL_TICK" -Value 70 }
    "scroll-90" { $conf = Set-ConfigValue -Text $conf -Name "CONFIG_PMW3610_SCROLL_TICK" -Value 90 }
    "scroll-50" { $conf = Set-ConfigValue -Text $conf -Name "CONFIG_PMW3610_SCROLL_TICK" -Value 50 }
    "automouse-off" {
        $conf = Comment-ConfigValue -Text $conf -Name "CONFIG_PMW3610_AUTOMOUSE_TIMEOUT_MS"
        $overlay = Comment-OverlayProperty -OverlayText $overlay -Property "automouse-layer" -FallbackLine "automouse-layer = <2>;"
    }
    "automouse-1000" {
        $conf = Set-ConfigValue -Text $conf -Name "CONFIG_PMW3610_AUTOMOUSE_TIMEOUT_MS" -Value 1000
        $overlay = Set-OverlayProperty -OverlayText $overlay -Property "automouse-layer" -Line "automouse-layer = <2>;"
    }
    "automouse-1500" {
        $conf = Set-ConfigValue -Text $conf -Name "CONFIG_PMW3610_AUTOMOUSE_TIMEOUT_MS" -Value 1500
        $overlay = Set-OverlayProperty -OverlayText $overlay -Property "automouse-layer" -Line "automouse-layer = <2>;"
    }
    "automouse-2000" {
        $conf = Set-ConfigValue -Text $conf -Name "CONFIG_PMW3610_AUTOMOUSE_TIMEOUT_MS" -Value 2000
        $overlay = Set-OverlayProperty -OverlayText $overlay -Property "automouse-layer" -Line "automouse-layer = <2>;"
    }
    "snipe-off" {
        $overlay = Comment-OverlayProperty -OverlayText $overlay -Property "snipe-layers" -FallbackLine "snipe-layers = <8>;"
    }
    "snipe-layer-8" {
        $overlay = Set-OverlayProperty -OverlayText $overlay -Property "snipe-layers" -Line "snipe-layers = <8>;"
    }
    "rawaccel-800" {
        $conf = Set-CpiPair -ConfText $conf -Cpi 800 -SnipeCpi 3200
        Write-Host "  Raw Accel mode: CPI 800 (no firmware scaler, accel handled by Raw Accel)" -ForegroundColor Yellow
        Write-Host "  Run: scripts\windows\setup_rawaccel.ps1 -Profile trackball-precise" -ForegroundColor Yellow
    }
    "rawaccel-1200" {
        $conf = Set-CpiPair -ConfText $conf -Cpi 1200 -SnipeCpi 3200
        Write-Host "  Raw Accel mode: CPI 1200 (no firmware scaler, accel handled by Raw Accel)" -ForegroundColor Yellow
        Write-Host "  Run: scripts\windows\setup_rawaccel.ps1 -Profile trackball-balanced" -ForegroundColor Yellow
    }
    "rawaccel-1600" {
        $conf = Set-CpiPair -ConfText $conf -Cpi 1600 -SnipeCpi 3200
        Write-Host "  Raw Accel mode: CPI 1600 (no firmware scaler, accel handled by Raw Accel)" -ForegroundColor Yellow
        Write-Host "  Run: scripts\windows\setup_rawaccel.ps1 -Profile trackball-speed" -ForegroundColor Yellow
    }
}

Set-Content -Encoding utf8NoBOM -NoNewline -LiteralPath $confPath -Value $conf
Set-Content -Encoding utf8NoBOM -NoNewline -LiteralPath $overlayPath -Value $overlay

Write-Host "Applied PMW3610 trackball tuning variant: $Variant" -ForegroundColor Green
Write-Host "Changed files:" -ForegroundColor Cyan
Write-Host "  $confPath"
Write-Host "  $overlayPath"

git -C (Join-Path $RepoRoot "vendor\vzhao-zmk-for-charybdis-main-20250226") diff -- config/boards/shields/charybdis/charybdis_right.conf config/boards/shields/charybdis/charybdis_right.overlay
