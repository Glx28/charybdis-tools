# Charybdis Trackball Benchmark Session Starter
# This script captures current system state and creates a timestamped session folder
# It does NOT modify any settings

param(
    [string]$ProfileName = "P0-current"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Charybdis Trackball Benchmark Session" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create timestamped session folder
Write-Host "[1/8] Creating session folder..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$sessionFolder = "C:\Users\sondr\splitted_zmk_keyboard\runtime\trackball_benchmarks\results\${ProfileName}_${timestamp}"
New-Item -ItemType Directory -Path $sessionFolder -Force | Out-Null
Write-Host "      Session folder: $sessionFolder" -ForegroundColor Green
Write-Host ""

# Profile name
Write-Host "[2/8] Profile Information..." -ForegroundColor Yellow
Write-Host "      Profile Name: $ProfileName" -ForegroundColor Green
Write-Host "      Timestamp: $timestamp" -ForegroundColor Green
Write-Host ""

# Windows mouse registry values
Write-Host "[3/8] Windows Mouse Registry Settings..." -ForegroundColor Yellow
try {
    $mouseSensitivity = (Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseSensitivity -ErrorAction SilentlyContinue).MouseSensitivity
    $mouseSpeed = (Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseSpeed -ErrorAction SilentlyContinue).MouseSpeed
    $mouseThreshold1 = (Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseThreshold1 -ErrorAction SilentlyContinue).MouseThreshold1
    $mouseThreshold2 = (Get-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseThreshold2 -ErrorAction SilentlyContinue).MouseThreshold2

    Write-Host "      MouseSensitivity: $mouseSensitivity" -ForegroundColor Green
    Write-Host "      MouseSpeed: $mouseSpeed" -ForegroundColor Green
    Write-Host "      Acceleration Tuple: $mouseThreshold1 / $mouseThreshold2 / $mouseSpeed" -ForegroundColor Green
} catch {
    Write-Host "      ERROR reading mouse registry: $_" -ForegroundColor Red
}
Write-Host ""

# SystemParametersInfo mouse speed
Write-Host "[4/8] SystemParametersInfo Mouse Settings..." -ForegroundColor Yellow
try {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class SystemParams {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, ref uint pvParam, uint fWinIni);

    public const uint SPI_GETMOUSESPEED = 0x0070;
}
"@
    $mouseSpeedValue = 0
    [SystemParams]::SystemParametersInfo([SystemParams]::SPI_GETMOUSESPEED, 0, [ref]$mouseSpeedValue, 0) | Out-Null
    Write-Host "      SPI_GETMOUSESPEED: $mouseSpeedValue" -ForegroundColor Green
} catch {
    Write-Host "      ERROR reading SystemParametersInfo: $_" -ForegroundColor Red
}
Write-Host ""

# Display layout
Write-Host "[5/8] Display Layout..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $displayNum = 1
    foreach ($screen in $screens) {
        $primary = if ($screen.Primary) { "(PRIMARY)" } else { "" }
        $bounds = $screen.Bounds
        Write-Host "      DISPLAY${displayNum} ${primary}: $($bounds.X),$($bounds.Y),$($bounds.Width)x$($bounds.Height)" -ForegroundColor Green
        $displayNum++
    }

    # Calculate total span
    $minX = ($screens | ForEach-Object { $_.Bounds.X } | Measure-Object -Minimum).Minimum
    $maxX = ($screens | ForEach-Object { $_.Bounds.X + $_.Bounds.Width } | Measure-Object -Maximum).Maximum
    $totalSpan = $maxX - $minX
    Write-Host "      Total horizontal span: $totalSpan px" -ForegroundColor Green
} catch {
    Write-Host "      ERROR reading display layout: $_" -ForegroundColor Red
}
Write-Host ""

# Running processes
Write-Host "[6/9] Raw Accel Settings..." -ForegroundColor Yellow
$rawAccelSettings = "C:\Program Files\RawAccel\settings.json"
if (Test-Path $rawAccelSettings) {
    try {
        $raJson = Get-Content $rawAccelSettings -Raw | ConvertFrom-Json
        Write-Host "      Sensitivity: x=$($raJson.Sensitivity.x) y=$($raJson.Sensitivity.y)" -ForegroundColor Green
        if ($raJson.Curves -and $raJson.Curves.Count -gt 0) {
            $curve = $raJson.Curves[0]
            $modeNames = @("off","linear","classic","natural","power","motivity")
            $modeName = if ($curve.mode -lt $modeNames.Count) { $modeNames[$curve.mode] } else { $curve.mode }
            Write-Host "      Mode: $modeName" -ForegroundColor Green
            if ($curve.args) {
                Write-Host "      Offset: $($curve.args.offset)  Accel: $($curve.args.acceleration)  Cap: $($curve.args.gainCap)x" -ForegroundColor Green
            }
        }
        Write-Host "      DPI (reported): $($raJson.dpi)" -ForegroundColor Green
        Copy-Item $rawAccelSettings (Join-Path $sessionFolder "rawaccel_snapshot.json") -ErrorAction SilentlyContinue
    } catch {
        Write-Host "      ERROR reading Raw Accel settings: $_" -ForegroundColor Red
    }
} else {
    Write-Host "      Raw Accel not installed" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "[7/9] Relevant Running Processes..." -ForegroundColor Yellow
try {
    $processNames = @("AutoHotkey", "PowerToys", "MouseWithoutBorders", "rawaccel", "writer")
    foreach ($procName in $processNames) {
        $processes = Get-Process -Name "*$procName*" -ErrorAction SilentlyContinue
        if ($processes) {
            foreach ($proc in $processes) {
                Write-Host "      RUNNING: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Green
            }
        } else {
            Write-Host "      NOT RUNNING: $procName" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "      ERROR checking processes: $_" -ForegroundColor Red
}
Write-Host ""

# HID/Mouse/Bluetooth devices
Write-Host "[8/9] Present Mouse/HID/Bluetooth Devices..." -ForegroundColor Yellow
try {
    # Get PnP devices matching relevant patterns
    $devicePatterns = @("*Charybdis*", "*Bluetooth*", "*HID*", "*Mouse*", "*Keyboard*", "*Logitech*", "*Touchpad*", "*Pointing*")
    $foundDevices = @{}

    foreach ($pattern in $devicePatterns) {
        $devices = Get-PnpDevice -FriendlyName $pattern -Status OK -ErrorAction SilentlyContinue
        foreach ($device in $devices) {
            # Avoid duplicates
            if (-not $foundDevices.ContainsKey($device.InstanceId)) {
                $foundDevices[$device.InstanceId] = $device
                $class = $device.Class
                $name = $device.FriendlyName
                Write-Host "      [$class] $name" -ForegroundColor Green
            }
        }
    }

    if ($foundDevices.Count -eq 0) {
        Write-Host "      No matching devices found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "      ERROR enumerating devices: $_" -ForegroundColor Red
}
Write-Host ""

# Save session info to file
Write-Host "[9/9] Saving session info..." -ForegroundColor Yellow
$sessionInfoPath = Join-Path $sessionFolder "session_info.txt"
try {
    @"
Charybdis Trackball Benchmark Session
======================================

Profile: $ProfileName
Timestamp: $timestamp
Session Folder: $sessionFolder

Windows Mouse Settings
----------------------
MouseSensitivity: $mouseSensitivity
MouseSpeed: $mouseSpeed
Acceleration Tuple: $mouseThreshold1 / $mouseThreshold2 / $mouseSpeed
SPI_GETMOUSESPEED: $mouseSpeedValue

Display Layout
--------------
"@ | Out-File -FilePath $sessionInfoPath -Encoding UTF8

    $displayNum = 1
    foreach ($screen in $screens) {
        $primary = if ($screen.Primary) { "(PRIMARY)" } else { "" }
        $bounds = $screen.Bounds
        "DISPLAY${displayNum} ${primary}: $($bounds.X),$($bounds.Y),$($bounds.Width)x$($bounds.Height)" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
        $displayNum++
    }

    "`nTotal horizontal span: $totalSpan px" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8

    "`n`nRaw Accel`n---------" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
if (Test-Path $rawAccelSettings) {
    $raContent = Get-Content $rawAccelSettings -Raw
    "Settings: (see rawaccel_snapshot.json)" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
} else {
    "Not installed" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
}

"`n`nRunning Processes`n-----------------" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
    foreach ($procName in $processNames) {
        $processes = Get-Process -Name "*$procName*" -ErrorAction SilentlyContinue
        if ($processes) {
            foreach ($proc in $processes) {
                "RUNNING: $($proc.ProcessName) (PID: $($proc.Id))" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
            }
        } else {
            "NOT RUNNING: $procName" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
        }
    }

    "`n`nDevices`n--------" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
    foreach ($deviceId in $foundDevices.Keys) {
        $device = $foundDevices[$deviceId]
        "[$($device.Class)] $($device.FriendlyName)" | Out-File -FilePath $sessionInfoPath -Append -Encoding UTF8
    }

    Write-Host "      Session info saved to: $sessionInfoPath" -ForegroundColor Green
} catch {
    Write-Host "      ERROR saving session info: $_" -ForegroundColor Red
}
Write-Host ""

# Copy template to session folder
Write-Host "Copying template to session folder..." -ForegroundColor Yellow
$templatePath = "C:\Users\sondr\splitted_zmk_keyboard\runtime\trackball_benchmarks\results\trackball_profile_results_template.md"
$resultsPath = Join-Path $sessionFolder "${ProfileName}_results.md"
try {
    Copy-Item -Path $templatePath -Destination $resultsPath -Force
    Write-Host "      Results template copied to: $resultsPath" -ForegroundColor Green
} catch {
    Write-Host "      ERROR copying template: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Session setup complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Open results file: $resultsPath" -ForegroundColor White
Write-Host "  2. Run benchmark tests according to protocol" -ForegroundColor White
Write-Host "  3. Save screenshots to: C:\Users\sondr\splitted_zmk_keyboard\runtime\trackball_benchmarks\screenshots\" -ForegroundColor White
Write-Host ""
