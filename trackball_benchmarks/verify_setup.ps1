# Verify Benchmark Setup Script
# This script checks that all required files and tools are in place

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Charybdis Benchmark Setup Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\sondr\splitted_zmk_keyboard\runtime\trackball_benchmarks"
$allGood = $true

# Check folder structure
Write-Host "[1/7] Checking folder structure..." -ForegroundColor Yellow
$requiredFolders = @("tools", "results", "screenshots", "profiles", "notes")
foreach ($folder in $requiredFolders) {
    $path = Join-Path $baseDir $folder
    if (Test-Path $path) {
        Write-Host "      OK: $folder\" -ForegroundColor Green
    } else {
        Write-Host "      MISSING: $folder\" -ForegroundColor Red
        $allGood = $false
    }
}
Write-Host ""

# Check core files
Write-Host "[2/7] Checking core files..." -ForegroundColor Yellow
$coreFiles = @{
    "README.md" = "Benchmark protocol documentation"
    "start_benchmark_session.ps1" = "Session starter script"
    "verify_setup.ps1" = "This verification script"
}

foreach ($file in $coreFiles.Keys) {
    $path = Join-Path $baseDir $file
    if (Test-Path $path) {
        Write-Host "      OK: $file - $($coreFiles[$file])" -ForegroundColor Green
    } else {
        Write-Host "      MISSING: $file - $($coreFiles[$file])" -ForegroundColor Red
        $allGood = $false
    }
}
Write-Host ""

# Check results templates
Write-Host "[3/7] Checking results templates..." -ForegroundColor Yellow
$resultFiles = @{
    "results\trackball_profile_results_template.md" = "Markdown results template"
    "results\trackball_results.csv" = "CSV results tracking file"
}

foreach ($file in $resultFiles.Keys) {
    $path = Join-Path $baseDir $file
    if (Test-Path $path) {
        Write-Host "      OK: $file" -ForegroundColor Green
    } else {
        Write-Host "      MISSING: $file" -ForegroundColor Red
        $allGood = $false
    }
}
Write-Host ""

# Check tools directory
Write-Host "[4/7] Checking tools directory..." -ForegroundColor Yellow
$toolsDir = Join-Path $baseDir "tools"
$toolFiles = @{
    "browser_tests.html" = "Browser-based tests launcher"
    "TOOLS_INSTALLATION_GUIDE.md" = "Tool installation guide"
    "manual_download_checklist.md" = "Manual download checklist"
    "download_benchmark_tools.ps1" = "Automated download script"
}

foreach ($file in $toolFiles.Keys) {
    $path = Join-Path $toolsDir $file
    if (Test-Path $path) {
        Write-Host "      OK: tools\$file" -ForegroundColor Green
    } else {
        Write-Host "      MISSING: tools\$file" -ForegroundColor Red
        $allGood = $false
    }
}
Write-Host ""

# Check for benchmark executables
Write-Host "[5/7] Checking benchmark executables..." -ForegroundColor Yellow
$exeFiles = Get-ChildItem -Path $toolsDir -Filter "*.exe" -ErrorAction SilentlyContinue

if ($exeFiles) {
    foreach ($exe in $exeFiles) {
        $size = $exe.Length
        if ($size -gt 1000) {
            Write-Host "      OK: $($exe.Name) ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host "      WARNING: $($exe.Name) is too small ($size bytes) - may be incomplete" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "      WARNING: No .exe files found in tools directory" -ForegroundColor Yellow
    Write-Host "      ACTION REQUIRED: Download MouseTester.exe and MLMP.exe" -ForegroundColor Yellow
    Write-Host "      See: tools\manual_download_checklist.md" -ForegroundColor Cyan
}
Write-Host ""

# Check browser tests
Write-Host "[6/7] Checking browser tests HTML..." -ForegroundColor Yellow
$browserTestsPath = Join-Path $toolsDir "browser_tests.html"
if (Test-Path $browserTestsPath) {
    $content = Get-Content $browserTestsPath -Raw
    if ($content -match "TestUFO" -and $content -match "Human Benchmark") {
        Write-Host "      OK: browser_tests.html contains expected test links" -ForegroundColor Green
    } else {
        Write-Host "      WARNING: browser_tests.html may be incomplete" -ForegroundColor Yellow
    }
} else {
    Write-Host "      MISSING: browser_tests.html" -ForegroundColor Red
    $allGood = $false
}
Write-Host ""

# Summary
Write-Host "[7/7] Setup Summary..." -ForegroundColor Yellow
Write-Host ""

if ($allGood -and $exeFiles -and ($exeFiles | Where-Object { $_.Length -gt 1000 }).Count -ge 1) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "All required files and tools are in place." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Start your first benchmark session" -ForegroundColor White
    Write-Host "  .\start_benchmark_session.ps1 -ProfileName 'P0-current'" -ForegroundColor Cyan
} elseif ($allGood) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "SETUP MOSTLY COMPLETE" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Core files are in place, but benchmark tools need to be downloaded." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Action required:" -ForegroundColor White
    Write-Host "  1. Review: tools\manual_download_checklist.md" -ForegroundColor Cyan
    Write-Host "  2. Download MouseTester.exe and MLMP.exe" -ForegroundColor Cyan
    Write-Host "  3. Place in tools\ directory" -ForegroundColor Cyan
    Write-Host "  4. Run this script again to verify" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Alternatively, try running:" -ForegroundColor White
    Write-Host "  .\tools\download_benchmark_tools.ps1" -ForegroundColor Cyan
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "SETUP INCOMPLETE" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Some required files are missing. Review errors above." -ForegroundColor Red
}

Write-Host ""
Write-Host "Documentation:" -ForegroundColor White
Write-Host "  - Full protocol: README.md" -ForegroundColor Cyan
Write-Host "  - Tool installation: tools\TOOLS_INSTALLATION_GUIDE.md" -ForegroundColor Cyan
Write-Host "  - Manual downloads: tools\manual_download_checklist.md" -ForegroundColor Cyan
Write-Host ""
