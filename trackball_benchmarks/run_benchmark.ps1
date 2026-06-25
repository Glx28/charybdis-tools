# Interactive Benchmark Runner
# Guides you through all tests, logs results to txt file

param(
    [Parameter(Mandatory=$true)]
    [string]$ProfileName
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Trackball Benchmark Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Profile: $ProfileName" -ForegroundColor Yellow
Write-Host ""

# Find or create session folder
$resultsDir = Join-Path $scriptDir "results"
$sessionPattern = "${ProfileName}_*"
$sessionFolder = Get-ChildItem -Path $resultsDir -Filter $sessionPattern -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $sessionFolder) {
    Write-Host "Creating new session for $ProfileName..." -ForegroundColor Yellow
    $startScript = Join-Path $scriptDir "start_benchmark_session.ps1"
    & $startScript -ProfileName $ProfileName
    $sessionFolder = Get-ChildItem -Path $resultsDir -Filter $sessionPattern -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

if (-not $sessionFolder) {
    Write-Host "ERROR: Could not create session folder." -ForegroundColor Red
    exit 1
}

Write-Host "Session folder: $($sessionFolder.Name)" -ForegroundColor Green
Write-Host ""

# Results file
$resultsFile = Join-Path $sessionFolder.FullName "benchmark_results.txt"

# Start results file
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
@"
TRACKBALL BENCHMARK RESULTS
===========================
Profile: $ProfileName
Date: $timestamp

CONFIG:
(see session_info.txt for full system state)

"@ | Set-Content $resultsFile

# Capture Raw Accel state if installed
$rawAccelSettings = "C:\Program Files\RawAccel\settings.json"
if (Test-Path $rawAccelSettings) {
    $raJson = Get-Content $rawAccelSettings -Raw | ConvertFrom-Json
    $raSens = if ($raJson.Sensitivity) { "x=$($raJson.Sensitivity.x) y=$($raJson.Sensitivity.y)" } else { "n/a" }
    $raMode = if ($raJson.Curves -and $raJson.Curves.Count -gt 0) { $raJson.Curves[0].mode } else { "off" }
    $raDpi = if ($raJson.dpi) { $raJson.dpi } else { "n/a" }
    @"

RAW ACCEL:
Sensitivity: $raSens
Mode: $raMode
DPI (reported): $raDpi
Full settings: see rawaccel_snapshot.json in session folder

"@ | Add-Content $resultsFile
    Copy-Item $rawAccelSettings (Join-Path $sessionFolder.FullName "rawaccel_snapshot.json") -ErrorAction SilentlyContinue
} else {
    @"

RAW ACCEL: Not installed

"@ | Add-Content $resultsFile
}

Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "- Use same browser (100% zoom)" -ForegroundColor White
Write-Host "- Use same monitor" -ForegroundColor White
Write-Host "- Use same sitting position" -ForegroundColor White
Write-Host "- Warm up 3 minutes before starting" -ForegroundColor White
Write-Host ""

$warmup = Read-Host "Ready to start? (Press Enter after 3-min warmup)"

# TEST R1 - TestUFO Mouse Poll Rate (1 run)
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST R1 - TestUFO Mouse Poll Rate" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Link: https://testufo.com/mouserate" -ForegroundColor Yellow
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor White
Write-Host "1. Open the link above" -ForegroundColor Gray
Write-Host "2. Click the test area" -ForegroundColor Gray
Write-Host "3. Move trackball VERY FAST in circles for 10 seconds" -ForegroundColor Gray
Write-Host "4. Note the peak Hz shown" -ForegroundColor Gray
Write-Host ""
Write-Host "Expected result for 125_SW polling: 110-125 Hz" -ForegroundColor Yellow
Write-Host ""

$r1_1 = Read-Host "Peak Hz"

@"

R1 - TestUFO Mouse Poll Rate
-----------------------------
Peak Hz: $r1_1

"@ | Add-Content $resultsFile

Write-Host "R1 logged" -ForegroundColor Green

# TEST A1 - Aim Trainer (3 runs)
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST A1 - Aim Trainer (3 runs)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Link: https://humanbenchmark.com/tests/aim" -ForegroundColor Yellow
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor White
Write-Host "1. Open the link above" -ForegroundColor Gray
Write-Host "2. Start the test" -ForegroundColor Gray
Write-Host "3. Click all 30 targets as fast as possible" -ForegroundColor Gray
Write-Host "4. Note the average ms/target shown" -ForegroundColor Gray
Write-Host "5. Repeat 3 times" -ForegroundColor Gray
Write-Host ""
Write-Host "What it measures: Target acquisition speed (lower is better)" -ForegroundColor Yellow
Write-Host ""

$a1_1 = Read-Host "Run 1 average ms/target"
$a1_2 = Read-Host "Run 2 average ms/target"
$a1_3 = Read-Host "Run 3 average ms/target"

@"

A1 - Aim Trainer
----------------
Run 1: $a1_1 ms/target
Run 2: $a1_2 ms/target
Run 3: $a1_3 ms/target

"@ | Add-Content $resultsFile

Write-Host "A1 logged" -ForegroundColor Green

# TEST A2 - MouseAccuracy Classic (3 runs)
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST A2 - MouseAccuracy Classic (CRITICAL)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Link: https://mouseaccuracy.com/classic/" -ForegroundColor Yellow
Write-Host ""
Write-Host "SETTINGS:" -ForegroundColor White
Write-Host "- Target Size: TINY" -ForegroundColor Yellow
Write-Host "- Target Spawn Speed: Normal" -ForegroundColor Yellow
Write-Host "- Duration: 30s (if available)" -ForegroundColor Yellow
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor White
Write-Host "1. Open the link above" -ForegroundColor Gray
Write-Host "2. Set Target Size to TINY" -ForegroundColor Gray
Write-Host "3. Set Spawn Speed to Normal" -ForegroundColor Gray
Write-Host "4. Start the test" -ForegroundColor Gray
Write-Host "5. Click targets accurately" -ForegroundColor Gray
Write-Host "6. Note: Score, Targets Clicked, Misclicks" -ForegroundColor Gray
Write-Host "7. Repeat 3 times" -ForegroundColor Gray
Write-Host ""
Write-Host "What it measures: Tiny-target precision (higher score, lower misclicks is better)" -ForegroundColor Yellow
Write-Host "This is the MOST IMPORTANT test for your overshoot problem" -ForegroundColor Red
Write-Host ""
Write-Host "For each run, enter: score targets misclicks (space-separated)" -ForegroundColor White
Write-Host "Example: 125 42 3" -ForegroundColor Gray
Write-Host ""

$a2_1 = Read-Host "Run 1"
$a2_2 = Read-Host "Run 2"
$a2_3 = Read-Host "Run 3"

@"

A2 - MouseAccuracy Classic (Tiny Targets, 30s)
-----------------------------------------------
Run 1: $a2_1
Run 2: $a2_2
Run 3: $a2_3

"@ | Add-Content $resultsFile

Write-Host "A2 logged" -ForegroundColor Green

# TEST P1 - Mouse Precision Movement (3 runs)
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST P1 - Mouse Precision Movement (3 runs)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Link: https://mousetest.online/precision-movement/" -ForegroundColor Yellow
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor White
Write-Host "1. Open the link above" -ForegroundColor Gray
Write-Host "2. Place cursor at left side of dashed line" -ForegroundColor Gray
Write-Host "3. Trace the line left-to-right in ONE SMOOTH movement" -ForegroundColor Gray
Write-Host "4. Do NOT stop and correct repeatedly" -ForegroundColor Gray
Write-Host "5. Do NOT rush" -ForegroundColor Gray
Write-Host "6. Note: Points Collected, Avg Jitter px, Max Jitter px, Precision Score %" -ForegroundColor Gray
Write-Host "7. Repeat 3 times" -ForegroundColor Gray
Write-Host ""
Write-Host "What it measures: Straight-line path cleanliness (higher precision, lower jitter is better)" -ForegroundColor Yellow
Write-Host ""
Write-Host "For each run, enter: points avgJitter maxJitter precision% (space-separated)" -ForegroundColor White
Write-Host "Example: 57 3.81 9.45 98.1%" -ForegroundColor Gray
Write-Host ""

$p1_1 = Read-Host "Run 1"
$p1_2 = Read-Host "Run 2"
$p1_3 = Read-Host "Run 3"

@"

P1 - Mouse Precision Movement
------------------------------
Run 1: $p1_1
Run 2: $p1_2
Run 3: $p1_3

"@ | Add-Content $resultsFile

Write-Host "P1 logged" -ForegroundColor Green

# TEST P2 - XbitLabs Path Follow (3 runs)
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST P2 - XbitLabs Path Follow (3 runs)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Link: https://www.xbitlabs.com/mouse-accuracy-test/" -ForegroundColor Yellow
Write-Host ""
Write-Host "SETTINGS:" -ForegroundColor White
Write-Host "- Mode: Path Follow" -ForegroundColor Yellow
Write-Host "- Difficulty: Medium" -ForegroundColor Yellow
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor White
Write-Host "1. Select Path Follow mode" -ForegroundColor Gray
Write-Host "2. Set difficulty to Medium" -ForegroundColor Gray
Write-Host "3. Complete the test" -ForegroundColor Gray
Write-Host "4. Note: Deviation px and Stage (e.g. 2/5)" -ForegroundColor Gray
Write-Host "5. Repeat 3 times" -ForegroundColor Gray
Write-Host ""
Write-Host "What it measures: Curved path following accuracy" -ForegroundColor Yellow
Write-Host ""
Write-Host "For each run, enter: deviation_px stage (space-separated)" -ForegroundColor White
Write-Host "Example: 3.1 2/5" -ForegroundColor Gray
Write-Host ""

$p2_1 = Read-Host "Run 1"
$p2_2 = Read-Host "Run 2"
$p2_3 = Read-Host "Run 3"

@"

P2 - XbitLabs Path Follow (Medium)
------------------------------------
Run 1: $p2_1
Run 2: $p2_2
Run 3: $p2_3

"@ | Add-Content $resultsFile

Write-Host "P2 logged" -ForegroundColor Green

# Done
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "BENCHMARK COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Results saved to:" -ForegroundColor White
Write-Host "  $resultsFile" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Paste this file to AI for analysis" -ForegroundColor Cyan
Write-Host "  2. AI will suggest firmware changes" -ForegroundColor Cyan
Write-Host "  3. Build and flash new firmware" -ForegroundColor Cyan
Write-Host "  4. Run this script again with new profile name" -ForegroundColor Cyan
Write-Host "  5. AI will compare and recommend next iteration" -ForegroundColor Cyan
Write-Host ""
