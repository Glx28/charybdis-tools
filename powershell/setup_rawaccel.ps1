<#
Raw Accel setup & profile manager for Charybdis trackball.

Installs Raw Accel (if needed), applies trackball-optimized acceleration profiles.
Profiles use Natural (sigmoid) curve: precise at slow speeds, accelerated at fast.

Run:
  powershell -ExecutionPolicy Bypass -File scripts\windows\setup_rawaccel.ps1 [-Profile <name>] [-Install]

Profiles:
  trackball-precise   — Conservative: slow=pixel-perfect, fast=moderate accel (start here)
  trackball-balanced  — Medium: wider accel range, good for mixed use
  trackball-speed     — Aggressive: strong accel for 3-monitor travel, still precise at slow
  off                 — Disable acceleration (1:1 passthrough)

Requires Raw Accel installed: https://github.com/RawAccelOfficial/rawaccel/releases
#>

[CmdletBinding()]
param(
    [ValidateSet("trackball-precise", "trackball-balanced", "trackball-speed", "off")]
    [string]$Profile = "trackball-precise",

    [switch]$Install,

    [switch]$ListProfiles
)

$ErrorActionPreference = "Stop"
$rawAccelDir = "C:\Program Files\RawAccel"
$settingsPath = Join-Path $rawAccelDir "settings.json"
$profilesDir = Join-Path $PSScriptRoot "rawaccel_profiles"

# ── Profile definitions ──────────────────────────────────────────────────────
# Each profile targets: slow trackball = precision, fast trackball = travel
# CPI should be set to 800-1600 in firmware when using these (more raw data for the curve)
#
# Raw Accel "Natural" mode (sigmoid): smooth S-curve transition
#   - Offset: speed below which NO accel applies (precision deadzone)
#   - Acceleration: how aggressively the curve ramps
#   - Cap Output: maximum sensitivity multiplier
#   - Sensitivity: base multiplier applied before accel curve

$profiles = @{
    "trackball-precise" = @{
        Description = "Conservative: pixel-perfect slow, moderate fast accel"
        DPI = 800
        Settings = @{
            sensMult        = 0.6      # base slower than 1:1 for fine control
            accelMode       = "natural"
            offset          = 3.0      # counts/ms below this = no accel (precision zone)
            acceleration    = 0.15     # gentle ramp
            capOutput       = 2.5      # max 2.5x base speed
            capInput        = 0        # no input cap
            growthRate      = 1.0
            motivity        = 1.5
            decayRate       = 0.1
            combineMags     = $true
            wholeVsPerPoll  = $true
        }
    }
    "trackball-balanced" = @{
        Description = "Balanced: precise slow, good travel speed"
        DPI = 1200
        Settings = @{
            sensMult        = 0.5
            accelMode       = "natural"
            offset          = 2.0
            acceleration    = 0.25
            capOutput       = 3.5
            capInput        = 0
            growthRate      = 1.0
            motivity        = 1.5
            decayRate       = 0.1
            combineMags     = $true
            wholeVsPerPoll  = $true
        }
    }
    "trackball-speed" = @{
        Description = "Aggressive: strong accel for 3-monitor travel"
        DPI = 1600
        Settings = @{
            sensMult        = 0.4
            accelMode       = "natural"
            offset          = 1.5
            acceleration    = 0.4
            capOutput       = 5.0
            capInput        = 0
            growthRate      = 1.0
            motivity        = 1.5
            decayRate       = 0.1
            combineMags     = $true
            wholeVsPerPoll  = $true
        }
    }
    "off" = @{
        Description = "Acceleration disabled (1:1 passthrough)"
        DPI = 400
        Settings = @{
            sensMult        = 1.0
            accelMode       = "off"
            offset          = 0
            acceleration    = 0
            capOutput       = 0
            capInput        = 0
            growthRate      = 1.0
            motivity        = 1.5
            decayRate       = 0.1
            combineMags     = $true
            wholeVsPerPoll  = $true
        }
    }
}

# ── List profiles ─────────────────────────────────────────────────────────────
if ($ListProfiles) {
    Write-Host "`nAvailable Raw Accel Profiles:" -ForegroundColor Cyan
    Write-Host "-----------------------------" -ForegroundColor DarkGray
    foreach ($name in ($profiles.Keys | Sort-Object)) {
        $p = $profiles[$name]
        $s = $p.Settings
        Write-Host "  $name" -ForegroundColor Yellow -NoNewline
        Write-Host " - $($p.Description)" -ForegroundColor White
        if ($s.accelMode -ne "off") {
            Write-Host "    DPI=$($p.DPI)  sens=$($s.sensMult)  offset=$($s.offset)  accel=$($s.acceleration)  cap=$($s.capOutput)x" -ForegroundColor Gray
        }
    }
    Write-Host ""
    return
}

# ── Install helper ────────────────────────────────────────────────────────────
if ($Install) {
    Write-Host "Raw Accel Installation Guide" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Download latest release:" -ForegroundColor White
    Write-Host "   https://github.com/RawAccelOfficial/rawaccel/releases" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Extract the ZIP to C:\Program Files\RawAccel\" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Run 'installer.exe' AS ADMINISTRATOR" -ForegroundColor White
    Write-Host "   This installs the kernel-level mouse driver" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Reboot when prompted" -ForegroundColor White
    Write-Host ""
    Write-Host "5. Run 'rawaccel.exe' to open the GUI (optional, for visual curve tuning)" -ForegroundColor White
    Write-Host ""
    Write-Host "6. Then run this script again without -Install to apply a trackball profile:" -ForegroundColor White
    Write-Host "   .\setup_rawaccel.ps1 -Profile trackball-precise" -ForegroundColor Yellow
    Write-Host ""

    $openBrowser = Read-Host "Open the download page in browser? (y/n)"
    if ($openBrowser -eq 'y') {
        Start-Process "https://github.com/RawAccelOfficial/rawaccel/releases"
    }
    return
}

# ── Check Raw Accel is installed ──────────────────────────────────────────────
if (-not (Test-Path $rawAccelDir)) {
    Write-Host "ERROR: Raw Accel not found at $rawAccelDir" -ForegroundColor Red
    Write-Host "Run with -Install flag for setup instructions:" -ForegroundColor Yellow
    Write-Host "  .\setup_rawaccel.ps1 -Install" -ForegroundColor Yellow
    exit 1
}

# ── Build Raw Accel settings JSON ─────────────────────────────────────────────
$prof = $profiles[$Profile]
$s = $prof.Settings

Write-Host "Applying Raw Accel profile: $Profile" -ForegroundColor Cyan
Write-Host "  $($prof.Description)" -ForegroundColor White
Write-Host "  Recommended firmware CPI: $($prof.DPI)" -ForegroundColor Yellow
Write-Host ""

# Map accel mode to Raw Accel's numeric enum
$modeMap = @{
    "off"     = 0
    "linear"  = 1
    "classic" = 2
    "natural" = 3
    "power"   = 4
    "motivity"= 5
}
$modeNum = $modeMap[$s.accelMode]

$settingsJson = @{
    "Sensitivity" = @{
        "x" = $s.sensMult
        "y" = $s.sensMult
    }
    "Rotation" = 0
    "Curves" = @(
        @{
            "mode" = $modeNum
            "args" = @{
                "acceleration" = $s.acceleration
                "scale" = 1.0
                "limit" = $s.capOutput
                "exponent" = 0.4
                "midpoint" = 5.0
                "offset" = $s.offset
                "cap" = @{ "x" = $s.capInput; "y" = $s.capInput }
                "capMode" = $(if ($s.capOutput -gt 0) { 1 } else { 0 })
                "gainCap" = $s.capOutput
                "speedCap" = $s.capInput
                "growthRate" = $s.growthRate
                "motivity" = $s.motivity
                "decayRate" = $s.decayRate
            }
        }
    )
    "combineMagnitudes" = $s.combineMags
    "wholeVsPerPollInput" = $s.wholeVsPerPoll
    "dpi" = $prof.DPI
} | ConvertTo-Json -Depth 5

# ── Save profile copy to project ─────────────────────────────────────────────
if (-not (Test-Path $profilesDir)) {
    New-Item -ItemType Directory -Path $profilesDir -Force | Out-Null
}

$profileBackup = Join-Path $profilesDir "$Profile.json"
$settingsJson | Set-Content -Path $profileBackup -Encoding UTF8
Write-Host "Profile saved to: $profileBackup" -ForegroundColor Green

# ── Apply to Raw Accel ────────────────────────────────────────────────────────
if (Test-Path $settingsPath) {
    $backupPath = Join-Path $rawAccelDir "settings_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Copy-Item -Path $settingsPath -Destination $backupPath
    Write-Host "Previous settings backed up to: $backupPath" -ForegroundColor DarkGray
}

$settingsJson | Set-Content -Path $settingsPath -Encoding UTF8
Write-Host "Settings written to: $settingsPath" -ForegroundColor Green
Write-Host ""

# ── Also ensure Windows mouse is at 1:1 ──────────────────────────────────────
Write-Host "Ensuring Windows mouse settings are at 1:1..." -ForegroundColor White
& (Join-Path $PSScriptRoot "apply_mouse_settings.ps1")
Write-Host ""

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  Raw Accel profile '$Profile' applied!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT - Firmware CPI change needed:" -ForegroundColor Yellow
Write-Host "  Set CONFIG_PMW3610_CPI=$($prof.DPI) in charybdis_right.conf" -ForegroundColor Yellow
if ($Profile -ne "off") {
    Write-Host "  Remove or set zip_xy_scaler to 1 1 (Raw Accel handles scaling now)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "To tune visually: open rawaccel.exe in $rawAccelDir" -ForegroundColor Cyan
Write-Host "To benchmark: run_benchmark.ps1 -ProfileName 'RA-$Profile'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Curve behavior:" -ForegroundColor White
if ($s.accelMode -eq "off") {
    Write-Host "  All speeds: 1:1 passthrough (no acceleration)" -ForegroundColor Gray
} else {
    Write-Host "  Slow trackball (< $($s.offset) counts/ms): $($s.sensMult)x sensitivity (precision)" -ForegroundColor Gray
    Write-Host "  Fast trackball: ramps up to $($s.capOutput)x via $($s.accelMode) curve" -ForegroundColor Gray
    $effMax = [math]::Round($s.sensMult * $s.capOutput, 1)
    Write-Host "  Effective range: $($s.sensMult)x to ${effMax}x" -ForegroundColor Gray
}
Write-Host ""
