<parameter name="content">#Requires -Version 5.1
<#
.SYNOPSIS
Adds beacon macro include to charybdis.keymap

.DESCRIPTION
This script automatically adds the beacon macro include to the keymap file
and identifies where you need to replace layer behaviors with beacon macros.

#>

$ErrorActionPreference = "Stop"

$KeymapPath = "vendor/vzhao-zmk-for-charybdis-main-20250226/config/charybdis.keymap"
$BackupPath = "$KeymapPath.BACKUP_BEFORE_BEACONS"
$IncludePath = '#include "../../../../../../firmware/coach_beacon_macros.keymap.dtsi"'

Write-Host "`n=== Beacon Macro Integration Helper ===" -ForegroundColor Cyan

# Step 1: Backup keymap
if (-not (Test-Path $BackupPath)) {
    Write-Host "`n[1/3] Creating backup..." -ForegroundColor Yellow
    Copy-Item $KeymapPath $BackupPath
    Write-Host "✓ Backup saved: $BackupPath" -ForegroundColor Green
} else {
    Write-Host "`n[1/3] Backup already exists: $BackupPath" -ForegroundColor Gray
}

# Step 2: Add include
Write-Host "`n[2/3] Checking for beacon include..." -ForegroundColor Yellow
$content = Get-Content $KeymapPath -Raw

if ($content -match "coach_beacon_macros") {
    Write-Host "✓ Beacon macros already included" -ForegroundColor Green
} else {
    Write-Host "Adding beacon macro include..." -ForegroundColor Gray

    # Find the first "/ {" and add include after it
    $content = $content -replace '(/ \{)', "`$1`n    $IncludePath`n"

    Set-Content $KeymapPath $content -NoNewline -Encoding UTF8
    Write-Host "✓ Include added to keymap" -ForegroundColor Green
}

# Step 3: Find layer bindings to replace
Write-Host "`n[3/3] Finding layer bindings to replace..." -ForegroundColor Yellow

$patterns = @{
    '&mo 1'   = '&coach_l1_hold    (Layer 1 momentary)'
    '&mo 3'   = '&coach_l3_hold    (Layer 3 momentary)'
    '&mo 4'   = '&coach_l4_hold    (Layer 4 momentary)'
    '&to 2'   = '&coach_mouse_lock (Mouse lock to Layer 2)'
    '&to 7'   = '&coach_game_lock  (Game layer lock)'
    '&to 0'   = '&coach_base       (Return to base layer)'
    '&tog 8'  = '&coach_travel_toggle (Travel layer toggle)'
}

$found = @()
$lineNum = 0
foreach ($line in (Get-Content $KeymapPath)) {
    $lineNum++
    foreach ($pattern in $patterns.Keys) {
        if ($line -match [regex]::Escape($pattern)) {
            $found += @{
                Line = $lineNum
                Old = $pattern
                New = ($patterns[$pattern] -split '\s+')[0]
                Description = $patterns[$pattern]
                Content = $line.Trim()
            }
        }
    }
}

if ($found.Count -eq 0) {
    Write-Host "✓ No layer bindings found to replace (either already done or keymap structure different)" -ForegroundColor Green
} else {
    Write-Host "`nFound $($found.Count) layer binding(s) to replace:" -ForegroundColor Cyan
    Write-Host ""

    foreach ($item in $found) {
        Write-Host "  Line $($item.Line): " -NoNewline -ForegroundColor Gray
        Write-Host "$($item.Old) " -NoNewline -ForegroundColor Red
        Write-Host "→ " -NoNewline -ForegroundColor Yellow
        Write-Host "$($item.New)" -ForegroundColor Green
        Write-Host "    $($item.Description)" -ForegroundColor Gray
        Write-Host "    Current: $($item.Content)" -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. Open keymap in editor:" -ForegroundColor White
    Write-Host "   code $KeymapPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Find and replace each binding above" -ForegroundColor White
    Write-Host "   Use Ctrl+H in VS Code for find/replace" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Save the file" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Build firmware:" -ForegroundColor White
    Write-Host "   Push to zmk-config-charybdis-beacons on GitHub, download UF2 from Actions" -ForegroundColor Gray
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Backup: $BackupPath" -ForegroundColor Gray
Write-Host "Keymap: $KeymapPath" -ForegroundColor Gray
Write-Host "Include: $(if ($content -match 'coach_beacon_macros') { '✓ Added' } else { '✗ Not found' })" -ForegroundColor $(if ($content -match 'coach_beacon_macros') { 'Green' } else { 'Red' })
Write-Host "Replacements needed: $($found.Count)" -ForegroundColor Gray
Write-Host ""

if ($found.Count -gt 0) {
    Write-Host "⚠ Manual replacement required - see list above" -ForegroundColor Yellow
} else {
    Write-Host "✓ Ready to build!" -ForegroundColor Green
}
