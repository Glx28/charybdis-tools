#requires -Version 5.1
<#
.SYNOPSIS
    Discovers keyboard shortcuts for apps installed on this Windows PC.

.DESCRIPTION
    Reads actual configured shortcuts from installed apps where possible
    (PowerToys, VS Code, Windows Terminal), combines them with built-in
    Windows/OS shortcuts and the local AutoHotkey usage log, and exports a
    structured JSON file. That file can be merged back into the canonical
    shortcut corpus in charybdis-optimizer-v2/data/shortcuts_source/.

.PARAMETER OutFile
    Path to write the discovered shortcuts JSON. Defaults to
    $env:USERPROFILE\charybdis-tools\runtime\discovered_shortcuts.json.

.PARAMETER Interactive
    Show an interactive review menu before exporting.

.EXAMPLE
    .\powershell\export_app_shortcuts.ps1
    .\powershell\export_app_shortcuts.ps1 -OutFile C:\temp\my_shortcuts.json
#>
[CmdletBinding()]
param(
    [string]$OutFile = "$env:USERPROFILE\charybdis-tools\runtime\discovered_shortcuts.json",
    [switch]$Interactive
)

$ErrorActionPreference = 'Stop'

function Write-AppShortcuts {
    param($AppId, $AppName, $ExeNames, [array]$Shortcuts)
    return @{
        id           = $AppId
        name         = $AppName
        exeNames     = @($ExeNames)
        source       = 'discovered'
        shortcutCount = $Shortcuts.Count
        shortcuts    = @($Shortcuts)
    }
}

function New-Shortcut {
    param($Keys, $Action, $Category = 'general', $Frequency = 'medium', $Importance = 5.0)
    return @{
        keys       = $Keys
        action     = $Action
        category   = $Category
        frequency  = $Frequency
        importance = $Importance
    }
}

# ---------------------------------------------------------------------------
# 1. PowerToys — read configured activation shortcuts from JSON settings.
# ---------------------------------------------------------------------------
function Get-PowerToysShortcuts {
    $ptLocal = "$env:LOCALAPPDATA\Microsoft\PowerToys"
    if (-not (Test-Path $ptLocal)) { return @() }

    $shortcuts = [System.Collections.Generic.List[object]]::new()

    # Helper to read a module's settings and extract the activation shortcut.
    function Read-ModuleShortcut {
        param($Module, $SettingPath, $Property = 'activation_shortcut')
        $path = Join-Path $ptLocal $Module $SettingPath
        if (Test-Path $path) {
            try {
                $json = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
                $sc = $json.$Property
                if ($sc -and ($sc -is [string]) -and $sc -ne 'None') {
                    return $sc
                }
                if ($sc -and $sc.Keys) {
                    $win = if ($sc.win) { 'Win+' } else { '' }
                    $ctrl = if ($sc.ctrl) { 'Ctrl+' } else { '' }
                    $alt = if ($sc.alt) { 'Alt+' } else { '' }
                    $shift = if ($sc.shift) { 'Shift+' } else { '' }
                    $key = $sc.key
                    if ($key) {
                        return "${win}${ctrl}${alt}${shift}${key}" -replace '\+$'
                    }
                }
            } catch { }
        }
        return $null
    }

    # Known PowerToys modules and their default shortcuts.
    $moduleMap = @(
        @{ Module = 'PowerToys Run';      Path = 'powerlauncher\settings.json';         Action = 'PowerToys Run launcher';                       Default = 'Alt+Space' },
        @{ Module = 'Command Palette';    Path = 'CmdPal\settings.json';                Action = 'PowerToys Command Palette (CmdPal)';           Default = 'Win+Alt+Space' },
        @{ Module = 'Color Picker';       Path = 'ColorPicker\settings.json';           Action = 'Color Picker';                                   Default = 'Win+Shift+C' },
        @{ Module = 'TextExtractor';      Path = 'TextExtractor\settings.json';         Action = 'Text Extractor (OCR)';                         Default = 'Win+Shift+T' },
        @{ Module = 'AdvancedPaste';      Path = 'AdvancedPaste\settings.json';         Action = 'Advanced Paste';                                 Default = 'Win+Shift+V' },
        @{ Module = 'Peek';               Path = 'Peek\settings.json';                  Action = 'Peek (quick file preview)';                      Default = 'Ctrl+Space' },
        @{ Module = 'FancyZones';         Path = 'fancyzones\settings.json';            Action = 'FancyZones editor';                              Default = 'Win+`' },
        @{ Module = 'MousePointerCrosshairs'; Path = 'MousePointerCrosshairs\settings.json'; Action = 'Mouse Pointer Crosshairs';                    Default = 'Win+Shift+O' },
        @{ Module = 'MouseHighlighter';   Path = 'MouseHighlighter\settings.json';      Action = 'Mouse Highlighter';                              Default = 'Win+Shift+D' },
        @{ Module = 'FindMyMouse';        Path = 'FindMyMouse\settings.json';           Action = 'Find My Mouse';                                  Default = 'Win+Shift+M' },
        @{ Module = 'NewPlus';            Path = 'NewPlus\settings.json';               Action = 'New+ (create from template)';                    Default = 'Win+Shift+N' },
        @{ Module = 'VideoConference';    Path = 'VideoConference\settings.json';       Action = 'Video Conference Mute';                          Default = 'Win+Shift+Q' },
        @{ Module = 'Workspaces';         Path = 'Workspaces\settings.json';            Action = 'Workspaces (save/restore window sets)';          Default = 'Win+Ctrl+`' },
        @{ Module = 'ScreenRuler';        Path = 'ScreenRuler\settings.json';           Action = 'Screen Ruler';                                   Default = 'Win+Shift+R' }
    )

    foreach ($m in $moduleMap) {
        $keys = Read-ModuleShortcut -Module $m.Module -SettingPath $m.Path
        if (-not $keys) { $keys = $m.Default }
        if ($keys -and $keys -ne 'None') {
            $shortcuts.Add((New-Shortcut -Keys $keys -Action $m.Action -Category 'System Shortcuts' -Frequency 'medium' -Importance 5.0))
        }
    }

    return $shortcuts
}

# ---------------------------------------------------------------------------
# 2. VS Code — read user and default keybindings.
# ---------------------------------------------------------------------------
function Get-VSCodeShortcuts {
    $shortcuts = [System.Collections.Generic.List[object]]::new()
    $kbPaths = @(
        "$env:APPDATA\Code\User\keybindings.json"
        "$env:APPDATA\Code - Insiders\User\keybindings.json"
    )
    foreach ($path in $kbPaths) {
        if (-not (Test-Path $path)) { continue }
        try {
            $json = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($entry in $json) {
                if (-not $entry.key) { continue }
                $cmd = $entry.command
                if (-not $cmd) { continue }
                # Skip chords and complex sequences for now.
                if ($entry.key -match '\s') { continue }
                $shortcuts.Add((New-Shortcut -Keys $entry.key -Action $cmd -Category 'Editor' -Frequency 'medium' -Importance 5.0))
            }
        } catch { }
    }
    return $shortcuts
}

# ---------------------------------------------------------------------------
# 3. Windows Terminal — read actions from settings.json.
# ---------------------------------------------------------------------------
function Get-WindowsTerminalShortcuts {
    $shortcuts = [System.Collections.Generic.List[object]]::new()
    $wtSettings = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )
    foreach ($path in $wtSettings) {
        if (-not (Test-Path $path)) { continue }
        try {
            $json = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
            $actions = $json.actions
            if (-not $actions) { continue }
            foreach ($a in $actions) {
                $keys = $a.keys
                $cmd = $a.command
                if (-not $keys -or -not $cmd) { continue }
                $shortcuts.Add((New-Shortcut -Keys $keys -Action $cmd -Category 'Terminal Actions' -Frequency 'medium' -Importance 4.0))
            }
        } catch { }
    }
    return $shortcuts
}

# ---------------------------------------------------------------------------
# 4. Windows 11 / OS shortcuts — authoritative static list.
# ---------------------------------------------------------------------------
function Get-WindowsShortcuts {
    return @(
        (New-Shortcut -Keys 'Win+S'       -Action 'Windows Search'                  -Category 'System Shortcuts' -Frequency 'constant' -Importance 10.0),
        (New-Shortcut -Keys 'Win+E'       -Action 'Open File Explorer'              -Category 'System Shortcuts' -Frequency 'high'     -Importance 8.0),
        (New-Shortcut -Keys 'Win+R'       -Action 'Run dialog'                      -Category 'System Shortcuts' -Frequency 'medium'   -Importance 6.0),
        (New-Shortcut -Keys 'Win+I'       -Action 'Open Settings'                   -Category 'System Shortcuts' -Frequency 'medium'   -Importance 6.0),
        (New-Shortcut -Keys 'Win+L'       -Action 'Lock PC'                         -Category 'System Shortcuts' -Frequency 'medium'   -Importance 6.0),
        (New-Shortcut -Keys 'Win+D'       -Action 'Show desktop'                    -Category 'System Shortcuts' -Frequency 'high'     -Importance 7.0),
        (New-Shortcut -Keys 'Win+V'       -Action 'Clipboard history'               -Category 'System Shortcuts' -Frequency 'high'     -Importance 7.0),
        (New-Shortcut -Keys 'Win+Shift+S' -Action 'Screenshot (Snipping Tool)'      -Category 'System Shortcuts' -Frequency 'high'     -Importance 8.0),
        (New-Shortcut -Keys 'Win+Tab'      -Action 'Task View / virtual desktops'    -Category 'Window Management' -Frequency 'medium'  -Importance 6.0),
        (New-Shortcut -Keys 'Alt+Tab'      -Action 'Switch apps'                     -Category 'Window Management' -Frequency 'constant' -Importance 9.0),
        (New-Shortcut -Keys 'Alt+F4'       -Action 'Close window'                    -Category 'Window Management' -Frequency 'high'     -Importance 7.0),
        (New-Shortcut -Keys 'Ctrl+Shift+Esc' -Action 'Task Manager'                  -Category 'System Shortcuts' -Frequency 'medium'   -Importance 6.0),
        (New-Shortcut -Keys 'Win+.'        -Action 'Emoji picker'                    -Category 'System Shortcuts' -Frequency 'medium'   -Importance 5.0),
        (New-Shortcut -Keys 'Win+;'        -Action 'Emoji picker (alt)'              -Category 'System Shortcuts' -Frequency 'medium'   -Importance 5.0),
        (New-Shortcut -Keys 'Win+Left'     -Action 'Snap window left'                -Category 'Window Management' -Frequency 'medium'  -Importance 5.0),
        (New-Shortcut -Keys 'Win+Right'    -Action 'Snap window right'               -Category 'Window Management' -Frequency 'medium'  -Importance 5.0),
        (New-Shortcut -Keys 'Win+Up'       -Action 'Maximize window'                 -Category 'Window Management' -Frequency 'medium'  -Importance 5.0),
        (New-Shortcut -Keys 'Win+Down'     -Action 'Minimize / restore window'       -Category 'Window Management' -Frequency 'medium'  -Importance 5.0),
        (New-Shortcut -Keys 'Win+Ctrl+D'   -Action 'New virtual desktop'             -Category 'Window Management' -Frequency 'low'     -Importance 4.0),
        (New-Shortcut -Keys 'Win+Ctrl+Left' -Action 'Previous virtual desktop'       -Category 'Window Management' -Frequency 'low'     -Importance 4.0),
        (New-Shortcut -Keys 'Win+Ctrl+Right' -Action 'Next virtual desktop'          -Category 'Window Management' -Frequency 'low'     -Importance 4.0),
        (New-Shortcut -Keys 'Win+Shift+Left' -Action 'Move window to left monitor'    -Category 'Window Management' -Frequency 'low'     -Importance 4.0),
        (New-Shortcut -Keys 'Win+Shift+Right' -Action 'Move window to right monitor'  -Category 'Window Management' -Frequency 'low'     -Importance 4.0)
    )
}

# ---------------------------------------------------------------------------
# 5. AutoHotkey usage log — discover shortcuts actually pressed.
# ---------------------------------------------------------------------------
function Get-UsageShortcuts {
    $logPath = "$env:USERPROFILE\charybdis-tools\runtime\shortcut_usage.jsonl"
    if (-not (Test-Path $logPath)) { return @() }

    $counts = @{}
    Get-Content $logPath -Encoding UTF8 | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_)) { return }
        try {
            $line = $_ | ConvertFrom-Json
            $combo = $line.combo
            $app = $line.app
            if (-not $combo) { return }
            if (-not $counts[$combo]) { $counts[$combo] = @{ count = 0; apps = @{} } }
            $counts[$combo].count++
            if ($app) { $counts[$combo].apps[$app] = ($counts[$combo].apps[$app] + 1) }
        } catch { }
    }

    $shortcuts = [System.Collections.Generic.List[object]]::new()
    foreach ($combo in $counts.Keys | Sort-Object) {
        $info = $counts[$combo]
        $appList = ($info.apps.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 3 | ForEach-Object { $_.Key }) -join ', '
        $freq = if ($info.count -gt 100) { 'high' } elseif ($info.count -gt 20) { 'medium' } else { 'low' }
        $imp = [math]::Min(10.0, 5.0 + [math]::Log($info.count + 1, 10) * 2)
        $shortcuts.Add((New-Shortcut -Keys $combo -Action "Used $info.count times ($appList)" -Category 'Usage Detected' -Frequency $freq -Importance $imp))
    }
    return $shortcuts
}

# ---------------------------------------------------------------------------
# 6. Detect installed apps from Add/Remove Programs and Start Menu.
# ---------------------------------------------------------------------------
function Get-InstalledApps {
    $apps = [System.Collections.Generic.List[object]]::new()
    $registryPaths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($path in $registryPaths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | ForEach-Object {
            $apps.Add(@{
                name         = $_.DisplayName
                publisher    = $_.Publisher
                version      = $_.DisplayVersion
                installLocation = $_.InstallLocation
            })
        }
    }
    return $apps
}

# ---------------------------------------------------------------------------
# Build the export.
# ---------------------------------------------------------------------------
$discoveredApps = [System.Collections.Generic.List[object]]::new()

$pt = Get-PowerToysShortcuts
if ($pt.Count -gt 0) {
    $discoveredApps.Add((Write-AppShortcuts -AppId 'powertoys' -AppName 'PowerToys' -ExeNames @('powertoys.exe') -Shortcuts $pt))
}

$code = Get-VSCodeShortcuts
if ($code.Count -gt 0) {
    $discoveredApps.Add((Write-AppShortcuts -AppId 'vscode' -AppName 'Visual Studio Code' -ExeNames @('code.exe', 'code - insiders.exe') -Shortcuts $code))
}

$wt = Get-WindowsTerminalShortcuts
if ($wt.Count -gt 0) {
    $discoveredApps.Add((Write-AppShortcuts -AppId 'terminal' -AppName 'Windows Terminal / PowerShell' -ExeNames @('windowsterminal.exe', 'wt.exe') -Shortcuts $wt))
}

$windows = Get-WindowsShortcuts
$discoveredApps.Add((Write-AppShortcuts -AppId 'windows' -AppName 'Windows 11' -ExeNames @('explorer.exe', 'searchhost.exe', 'startmenuexperiencehost.exe') -Shortcuts $windows))

$usage = Get-UsageShortcuts
if ($usage.Count -gt 0) {
    $discoveredApps.Add((Write-AppShortcuts -AppId 'usage_detected' -AppName 'Usage Detected' -ExeNames @() -Shortcuts $usage))
}

$installed = Get-InstalledApps

$output = @{
    generatedAt     = (Get-Date -Format 'o')
    machine         = $env:COMPUTERNAME
    discoveredApps  = $discoveredApps
    installedAppCount = $installed.Count
    installedApps   = @($installed | Sort-Object name | Select-Object -First 200)
}

if ($Interactive) {
    Write-Host "Discovered $($discoveredApps.Count) app shortcut sets."
    foreach ($app in $discoveredApps) {
        Write-Host "`n$($app.name): $($app.shortcutCount) shortcuts"
        $app.shortcuts | Select-Object -First 10 | ForEach-Object { Write-Host "  $($_.keys) -> $($_.action)" }
        if ($app.shortcutCount -gt 10) { Write-Host "  ... and $($app.shortcutCount - 10) more" }
    }
    $confirm = Read-Host "`nExport to $OutFile? [Y/n]"
    if ($confirm -and $confirm -notmatch '^[Yy]') { return }
}

$dir = Split-Path $OutFile
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$output | ConvertTo-Json -Depth 10 | Set-Content -Path $OutFile -Encoding UTF8
Write-Host "Wrote discovered shortcuts to $OutFile"
Write-Host "Next: run python/merge_shortcut_export.py to merge into the canonical corpus."
