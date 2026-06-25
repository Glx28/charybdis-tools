<#
Apply optimal Windows mouse settings for Charybdis trackball.
Settings: MouseSensitivity=10 (1:1), acceleration OFF, thresholds=0.
Run: powershell -ExecutionPolicy Bypass -File scripts\windows\apply_mouse_settings.ps1
Requires logoff or SystemParametersInfo call to take effect immediately.
#>

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class MouseSettings {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uAction, uint uParam, IntPtr lpvParam, uint fWinIni);

    // SPI_SETMOUSESPEED = 0x0071
    // SPI_SETMOUSE = 0x0004
    // SPIF_UPDATEINIFILE | SPIF_SENDCHANGE = 0x03

    public static void SetMouseSpeed(int speed) {
        SystemParametersInfo(0x0071, 0, (IntPtr)speed, 0x03);
    }

    public static void DisableAcceleration() {
        int[] mouseParams = new int[] { 0, 0, 0 }; // threshold1, threshold2, acceleration
        IntPtr ptr = Marshal.AllocHGlobal(12);
        Marshal.Copy(mouseParams, 0, ptr, 3);
        SystemParametersInfo(0x0004, 0, ptr, 0x03);
        Marshal.FreeHGlobal(ptr);
    }
}
"@

# Set registry values
Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSensitivity' -Value '10'
Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseSpeed' -Value '0'
Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold1' -Value '0'
Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name 'MouseThreshold2' -Value '0'

# Apply immediately via SystemParametersInfo (no logoff needed)
[MouseSettings]::SetMouseSpeed(10)
[MouseSettings]::DisableAcceleration()

# Verify
$mouse = Get-ItemProperty 'HKCU:\Control Panel\Mouse'
Write-Host "Applied:" -ForegroundColor Green
Write-Host "  MouseSensitivity = $($mouse.MouseSensitivity) (target: 10 = 1:1)"
Write-Host "  MouseSpeed       = $($mouse.MouseSpeed) (target: 0 = acceleration OFF)"
Write-Host "  MouseThreshold1  = $($mouse.MouseThreshold1) (target: 0)"
Write-Host "  MouseThreshold2  = $($mouse.MouseThreshold2) (target: 0)"
Write-Host ""
Write-Host "Settings applied immediately via SystemParametersInfo. No logoff needed." -ForegroundColor Cyan
