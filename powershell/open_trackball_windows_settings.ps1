<#
Opens Windows panels used for PMW3610 trackball baseline testing.
#>

Start-Process "control.exe" "main.cpl"
Start-Process "ms-settings:mousetouchpad"

Write-Host "Recommended baseline while testing firmware:" -ForegroundColor Green
Write-Host "  Pointer speed: middle/default"
Write-Host "  Enhance pointer precision: OFF for baseline"
Write-Host "  Scroll inactive windows: ON"
Write-Host "  ClickLock: OFF"
