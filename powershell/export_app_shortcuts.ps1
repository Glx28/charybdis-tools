#requires -Version 5.1
<#
.SYNOPSIS
    Discovers keyboard shortcuts for apps actually used on this Windows PC.

.DESCRIPTION
    Hybrid discovery:
      - Reads configured shortcuts from PowerToys settings.
      - Reads the AutoHotkey usage log to weight shortcuts by real use.
      - Ships curated templates for apps seen in user logs (VS Code, Terminal,
        Discord, Kimi/Codex/Claude CLI, Edge, Steam, Stremio).
    Exports a structured JSON that can be merged into the optimizer corpus.

.PARAMETER OutFile
    Path to write the discovered shortcuts JSON.

.PARAMETER Interactive
    Show an interactive review menu before exporting.
#>
[CmdletBinding()]
param(
    [string]$OutFile = "$env:USERPROFILE\charybdis-tools\runtime\discovered_shortcuts.json",
    [switch]$Interactive
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function New-Shortcut {
    param($Keys, $Action, $Category = 'general', $Frequency = 'medium', $Importance = 5.0, $Aliases = @())
    $sc = @{
        keys       = $Keys
        action     = $Action
        category   = $Category
        frequency  = $Frequency
        importance = $Importance
    }
    if ($Aliases) { $sc.aliases = @($Aliases) }
    return $sc
}

function Write-AppShortcuts {
    param($AppId, $AppName, $ExeNames, [array]$Shortcuts)
    return @{
        id            = $AppId
        name          = $AppName
        exeNames      = @($ExeNames)
        source        = 'discovered'
        shortcutCount = $Shortcuts.Count
        shortcuts     = @($Shortcuts)
    }
}

function Import-JsonNoBom {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    # Skip UTF-8 BOM if present
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $bytes = $bytes[3..($bytes.Length - 1)]
    }
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    return $text | ConvertFrom-Json
}

function Test-ProcessRunning {
    param([string[]]$ExeNames)
    foreach ($exe in $ExeNames) {
        $proc = Get-Process | Where-Object { $_.ProcessName -ieq ($exe -replace '\.exe$','') } | Select-Object -First 1
        if ($proc) { return $true }
    }
    return $false
}

function Test-Installed {
    param([string[]]$DisplayNameMatches)
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($path in $paths) {
        $items = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
        foreach ($item in $items) {
            foreach ($match in $DisplayNameMatches) {
                if ($item.DisplayName -like $match) { return $true }
            }
        }
    }
    return $false
}

# ---------------------------------------------------------------------------
# 1. Usage log — weight shortcuts by actual use.
# ---------------------------------------------------------------------------
function Get-UsageWeights {
    $logPath = "$env:USERPROFILE\charybdis-tools\runtime\shortcut_usage.jsonl"
    $weights = @{}
    if (-not (Test-Path $logPath)) { return $weights }

    Get-Content $logPath -Encoding UTF8 | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_)) { return }
        try {
            $line = $_ | ConvertFrom-Json
            $combo = $line.combo
            if (-not $combo) { return }
            if (-not $weights[$combo]) { $weights[$combo] = @{ count = 0; apps = @{} } }
            $weights[$combo].count++
            $app = $line.app
            if ($app) { $weights[$combo].apps[$app] = ($weights[$combo].apps[$app] + 1) }
        } catch { }
    }
    return $weights
}

function Apply-UsageWeight {
    param([array]$Shortcuts, [hashtable]$UsageWeights)
    foreach ($sc in $Shortcuts) {
        $combo = $sc.keys
        $usage = $UsageWeights[$combo]
        if (-not $usage) { continue }
        $count = $usage.count
        if ($count -gt 500)      { $sc.frequency = 'constant'; $sc.importance = [math]::Min(10.0, 5.0 + [math]::Log($count, 10) * 2) }
        elseif ($count -gt 100)  { $sc.frequency = 'high';     $sc.importance = [math]::Min(9.0, 5.0 + [math]::Log($count, 10) * 2) }
        elseif ($count -gt 20)   { $sc.frequency = 'medium';   $sc.importance = [math]::Min(7.0, 5.0 + [math]::Log($count, 10) * 2) }
        elseif ($count -gt 0)    { $sc.frequency = 'low';      $sc.importance = [math]::Min(5.5, 5.0 + [math]::Log($count + 1, 10)) }
        $topApps = ($usage.apps.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 3 | ForEach-Object { $_.Key }) -join ', '
        $sc.action = "$($sc.action) (used $count times: $topApps)"
    }
    return $Shortcuts
}

# ---------------------------------------------------------------------------
# 2. PowerToys — read configured activation shortcuts.
# ---------------------------------------------------------------------------
function Get-PowerToysShortcuts {
    $ptLocal = "$env:LOCALAPPDATA\Microsoft\PowerToys"
    if (-not (Test-Path $ptLocal)) { return @() }

    $shortcuts = [System.Collections.Generic.List[object]]::new()

    function Read-ModuleShortcut {
        param($Module, $SettingPath, $Property = 'activation_shortcut')
        $path = Join-Path (Join-Path $ptLocal $Module) $SettingPath
        if (-not (Test-Path $path)) { return $null }
        try {
            $json = Import-JsonNoBom -Path $path
            $sc = $json.$Property
            if ($sc -and ($sc -is [string]) -and $sc -ne 'None') { return $sc }
            if ($sc -and $sc.Keys) {
                $parts = @()
                if ($sc.win)   { $parts += 'Win' }
                if ($sc.ctrl)  { $parts += 'Ctrl' }
                if ($sc.alt)   { $parts += 'Alt' }
                if ($sc.shift) { $parts += 'Shift' }
                if ($sc.key)   { $parts += $sc.key }
                return $parts -join '+'
            }
        } catch { }
        return $null
    }

    $moduleMap = @(
        @{ Module = 'PowerToys Run';        Path = 'powerlauncher\settings.json';        Action = 'PowerToys Run launcher';                       Frequency = 'constant'; Importance = 10.0; Aliases = @('launcher','run launcher','powertoys run') },
        @{ Module = 'Command Palette';      Path = 'CmdPal\settings.json';               Action = 'PowerToys Command Palette (CmdPal)';           Frequency = 'high';     Importance = 9.0;  Aliases = @('command palette','cmdpal','palette') },
        @{ Module = 'Color Picker';         Path = 'ColorPicker\settings.json';          Action = 'Color Picker';                                 Frequency = 'medium';   Importance = 6.0;  Aliases = @('color picker','eyedropper') },
        @{ Module = 'TextExtractor';        Path = 'TextExtractor\settings.json';        Action = 'Text Extractor (OCR)';                         Frequency = 'medium';   Importance = 6.0;  Aliases = @('text extractor','ocr') },
        @{ Module = 'AdvancedPaste';        Path = 'AdvancedPaste\settings.json';        Action = 'Advanced Paste';                               Frequency = 'medium';   Importance = 6.0;  Aliases = @('advanced paste') },
        @{ Module = 'Peek';                 Path = 'Peek\settings.json';                 Action = 'Peek (quick file preview)';                    Frequency = 'medium';   Importance = 5.0;  Aliases = @('peek','preview') },
        @{ Module = 'FancyZones';           Path = 'fancyzones\settings.json';            Action = 'FancyZones editor';                            Frequency = 'low';      Importance = 5.0;  Aliases = @('fancyzones','zones') },
        @{ Module = 'MousePointerCrosshairs'; Path = 'MousePointerCrosshairs\settings.json'; Action = 'Mouse Pointer Crosshairs';                   Frequency = 'low';      Importance = 3.0;  Aliases = @('crosshairs') },
        @{ Module = 'MouseHighlighter';     Path = 'MouseHighlighter\settings.json';      Action = 'Mouse Highlighter';                            Frequency = 'low';      Importance = 3.0;  Aliases = @('mouse highlighter') },
        @{ Module = 'FindMyMouse';          Path = 'FindMyMouse\settings.json';           Action = 'Find My Mouse';                                Frequency = 'low';      Importance = 3.0;  Aliases = @('find my mouse') },
        @{ Module = 'NewPlus';              Path = 'NewPlus\settings.json';               Action = 'New+ (create files/folders from template)';    Frequency = 'low';      Importance = 4.0;  Aliases = @('new plus','new+') },
        @{ Module = 'VideoConference';      Path = 'VideoConference\settings.json';       Action = 'Video Conference Mute';                        Frequency = 'low';      Importance = 3.0;  Aliases = @('video conference mute') },
        @{ Module = 'Workspaces';           Path = 'Workspaces\settings.json';            Action = 'Workspaces (save/restore window sets)';        Frequency = 'low';      Importance = 4.0;  Aliases = @('workspaces') },
        @{ Module = 'ScreenRuler';          Path = 'ScreenRuler\settings.json';           Action = 'Screen Ruler';                                 Frequency = 'low';      Importance = 3.0;  Aliases = @('screen ruler','ruler') }
    )

    foreach ($m in $moduleMap) {
        $keys = Read-ModuleShortcut -Module $m.Module -SettingPath $m.Path
        if (-not $keys) { continue }
        if ($keys -eq 'None') { continue }
        $shortcuts.Add((New-Shortcut -Keys $keys -Action $m.Action -Category 'System Shortcuts' -Frequency $m.Frequency -Importance $m.Importance -Aliases $m.Aliases))
    }
    return $shortcuts
}

# ---------------------------------------------------------------------------
# 3. Curated templates for apps seen in user logs.
# ---------------------------------------------------------------------------
$templates = @{
    vscode = @{
        id = 'vscode'
        name = 'Visual Studio Code'
        exeNames = @('code.exe', 'code - insiders.exe')
        shortcuts = @(
            (New-Shortcut -Keys 'Ctrl+P' -Action 'Quick Open - go to file' -Category 'Navigation' -Frequency 'high' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+Shift+P' -Action 'Command Palette' -Category 'Navigation' -Frequency 'constant' -Importance 10.0 -Aliases @('command palette','cmdpal')),
            (New-Shortcut -Keys 'Ctrl+Shift+F' -Action 'Search across files' -Category 'Search' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+`' -Action 'Toggle integrated terminal' -Category 'Terminal' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+B' -Action 'Toggle sidebar' -Category 'View' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+/' -Action 'Toggle line comment' -Category 'Editing' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+D' -Action 'Select next occurrence' -Category 'Editing' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'F5' -Action 'Start debugging' -Category 'Debug' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Shift+F5' -Action 'Stop debugging' -Category 'Debug' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'F9' -Action 'Toggle breakpoint' -Category 'Debug' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+Shift+K' -Action 'Delete line' -Category 'Editing' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Alt+Up' -Action 'Move line up' -Category 'Editing' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'Alt+Down' -Action 'Move line down' -Category 'Editing' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'Ctrl+Shift+L' -Action 'Select all occurrences' -Category 'Editing' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'Ctrl+Shift+O' -Action 'Go to symbol in file' -Category 'Navigation' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'F12' -Action 'Go to definition' -Category 'Navigation' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+W' -Action 'Close editor tab' -Category 'Tabs' -Frequency 'high' -Importance 6.0),
            (New-Shortcut -Keys 'Ctrl+Shift+T' -Action 'Reopen closed tab' -Category 'Tabs' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+Tab' -Action 'Next editor tab' -Category 'Tabs' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+N' -Action 'New file' -Category 'File' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+S' -Action 'Save file' -Category 'File' -Frequency 'constant' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+Z' -Action 'Undo' -Category 'Editing' -Frequency 'constant' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+Shift+Z' -Action 'Redo' -Category 'Editing' -Frequency 'high' -Importance 7.0)
        )
    }
    terminal = @{
        id = 'terminal'
        name = 'Windows Terminal / PowerShell'
        exeNames = @('windowsterminal.exe', 'powershell.exe', 'pwsh.exe', 'wt.exe')
        shortcuts = @(
            (New-Shortcut -Keys 'Ctrl+Shift+T' -Action 'New tab' -Category 'Tabs' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+Shift+W' -Action 'Close tab' -Category 'Tabs' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+Tab' -Action 'Next tab' -Category 'Tabs' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+Shift+Tab' -Action 'Previous tab' -Category 'Tabs' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+Shift+C' -Action 'Copy' -Category 'Terminal' -Frequency 'constant' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+Shift+V' -Action 'Paste' -Category 'Terminal' -Frequency 'constant' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+Shift+F' -Action 'Find' -Category 'Terminal' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+L' -Action 'Clear screen' -Category 'Terminal' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+R' -Action 'Reverse search history' -Category 'Terminal' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Alt+Shift+D' -Action 'Split pane' -Category 'Panes' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Alt+Shift+-' -Action 'Split pane horizontal' -Category 'Panes' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'Alt+Shift++' -Action 'Split pane vertical' -Category 'Panes' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'Ctrl++' -Action 'Zoom in' -Category 'View' -Frequency 'low' -Importance 3.0),
            (New-Shortcut -Keys 'Ctrl+-' -Action 'Zoom out' -Category 'View' -Frequency 'low' -Importance 3.0)
        )
    }
    discord = @{
        id = 'discord'
        name = 'Discord'
        exeNames = @('discord.exe')
        shortcuts = @(
            (New-Shortcut -Keys 'Ctrl+K' -Action 'Quick switcher' -Category 'Navigation' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+Shift+M' -Action 'Toggle mute' -Category 'Voice' -Frequency 'constant' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+Shift+D' -Action 'Toggle deafen' -Category 'Voice' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Alt+Up' -Action 'Previous channel' -Category 'Navigation' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Alt+Down' -Action 'Next channel' -Category 'Navigation' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+E' -Action 'Search' -Category 'Navigation' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Shift+Enter' -Action 'New line' -Category 'Messaging' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+R' -Action 'Reply to message' -Category 'Messaging' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+F' -Action 'Search in channel' -Category 'Messaging' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+U' -Action 'Toggle member list' -Category 'Navigation' -Frequency 'low' -Importance 4.0)
        )
    }
    kimi_cli = @{
        id = 'kimi_cli'
        name = 'Kimi CLI'
        exeNames = @('kimi.exe')
        shortcuts = @(
            (New-Shortcut -Keys 'Enter' -Action 'Submit prompt' -Category 'Input' -Frequency 'constant' -Importance 9.0),
            (New-Shortcut -Keys 'Shift+Enter' -Action 'Insert newline' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Shift+Tab' -Action 'Toggle plan mode' -Category 'Mode' -Frequency 'high' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+X' -Action 'Switch agent/shell mode' -Category 'Mode' -Frequency 'medium' -Importance 6.0),
            (New-Shortcut -Keys 'Ctrl+E' -Action 'Expand plan/prompt fullscreen' -Category 'View' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+S' -Action 'Inject message into turn' -Category 'Session' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+C' -Action 'Cancel / exit' -Category 'Session' -Frequency 'high' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+R' -Action 'Reverse search history' -Category 'History' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys '/' -Action 'Slash commands' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys '@' -Action 'Mention file/context' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys '!' -Action 'Run shell command inline' -Category 'Input' -Frequency 'medium' -Importance 5.0)
        )
    }
    codex_cli = @{
        id = 'codex_cli'
        name = 'Codex CLI'
        exeNames = @('codex.exe')
        shortcuts = @(
            (New-Shortcut -Keys 'Enter' -Action 'Submit prompt' -Category 'Input' -Frequency 'constant' -Importance 9.0),
            (New-Shortcut -Keys 'Shift+Enter' -Action 'Insert newline' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Escape' -Action 'Interrupt active task' -Category 'Session' -Frequency 'high' -Importance 9.0),
            (New-Shortcut -Keys 'Ctrl+C' -Action 'Cancel current turn' -Category 'Session' -Frequency 'high' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+R' -Action 'Search prompt history' -Category 'History' -Frequency 'medium' -Importance 6.0),
            (New-Shortcut -Keys 'Ctrl+O' -Action 'Copy latest output' -Category 'Output' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'Tab' -Action 'Queue follow-up' -Category 'Input' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys '/' -Action 'Slash commands' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys '@' -Action 'Add files to prompt' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys '!' -Action 'Run shell command' -Category 'Input' -Frequency 'medium' -Importance 5.0)
        )
    }
    claude_code_cli = @{
        id = 'claude_code_cli'
        name = 'Claude Code CLI'
        exeNames = @('claude.exe')
        shortcuts = @(
            (New-Shortcut -Keys 'Enter' -Action 'Submit prompt' -Category 'Input' -Frequency 'constant' -Importance 9.0),
            (New-Shortcut -Keys 'Shift+Enter' -Action 'Insert newline' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Escape' -Action 'Interrupt / close dialog' -Category 'Session' -Frequency 'high' -Importance 9.0),
            (New-Shortcut -Keys 'Ctrl+C' -Action 'Interrupt running op; 2nd press exits' -Category 'Session' -Frequency 'high' -Importance 8.0),
            (New-Shortcut -Keys 'Shift+Tab' -Action 'Cycle permission modes' -Category 'Mode' -Frequency 'high' -Importance 9.0),
            (New-Shortcut -Keys 'Ctrl+O' -Action 'Toggle transcript view' -Category 'View' -Frequency 'medium' -Importance 6.0),
            (New-Shortcut -Keys 'Ctrl+R' -Action 'Reverse search history' -Category 'History' -Frequency 'medium' -Importance 6.0),
            (New-Shortcut -Keys '/' -Action 'Slash command / skill menu' -Category 'Input' -Frequency 'high' -Importance 8.0),
            (New-Shortcut -Keys '@' -Action 'Mention file path' -Category 'Input' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys '!' -Action 'Enter shell mode' -Category 'Input' -Frequency 'medium' -Importance 5.0)
        )
    }
    browser = @{
        id = 'browser'
        name = 'Browser (Chrome/Edge)'
        exeNames = @('chrome.exe', 'msedge.exe')
        shortcuts = @(
            (New-Shortcut -Keys 'Ctrl+T' -Action 'New tab' -Category 'Tabs' -Frequency 'constant' -Importance 9.0),
            (New-Shortcut -Keys 'Ctrl+Shift+T' -Action 'Reopen closed tab' -Category 'Tabs' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+W' -Action 'Close tab' -Category 'Tabs' -Frequency 'constant' -Importance 8.0),
            (New-Shortcut -Keys 'Ctrl+Tab' -Action 'Next tab' -Category 'Tabs' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+Shift+Tab' -Action 'Previous tab' -Category 'Tabs' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+L' -Action 'Focus address bar' -Category 'Navigation' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+K' -Action 'Focus address bar search' -Category 'Navigation' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+D' -Action 'Bookmark page' -Category 'Bookmarks' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+H' -Action 'History' -Category 'History' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+J' -Action 'Downloads' -Category 'Downloads' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl+F' -Action 'Find on page' -Category 'Search' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+R' -Action 'Reload' -Category 'Navigation' -Frequency 'high' -Importance 7.0),
            (New-Shortcut -Keys 'Ctrl+Shift+R' -Action 'Hard reload' -Category 'Navigation' -Frequency 'medium' -Importance 5.0),
            (New-Shortcut -Keys 'Ctrl++' -Action 'Zoom in' -Category 'View' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'Ctrl+-' -Action 'Zoom out' -Category 'View' -Frequency 'low' -Importance 4.0),
            (New-Shortcut -Keys 'F12' -Action 'DevTools' -Category 'Dev' -Frequency 'medium' -Importance 5.0)
        )
    }
}

# ---------------------------------------------------------------------------
# 3b. Windows 11 / OS shortcuts — authoritative static list.
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
# 4. Build export.
# ---------------------------------------------------------------------------
$usageWeights = Get-UsageWeights
$discoveredApps = [System.Collections.Generic.List[object]]::new()

# PowerToys (auto-discovered)
$pt = Get-PowerToysShortcuts
if ($pt.Count -gt 0) {
    $pt = Apply-UsageWeight -Shortcuts $pt -UsageWeights $usageWeights
    $discoveredApps.Add((Write-AppShortcuts -AppId 'powertoys' -AppName 'PowerToys' -ExeNames @('powertoys.exe', 'PowerToys.PowerOCR.exe') -Shortcuts $pt))
}

# Windows / OS shortcuts
$windows = Apply-UsageWeight -Shortcuts (Get-WindowsShortcuts) -UsageWeights $usageWeights
$discoveredApps.Add((Write-AppShortcuts -AppId 'windows' -AppName 'Windows 11' -ExeNames @('explorer.exe', 'searchhost.exe', 'startmenuexperiencehost.exe', 'shellexperiencehost.exe') -Shortcuts $windows))

# Map template ids to registry display-name patterns
$installPatterns = @{
    vscode            = @('*Visual Studio Code*', '*VS Code*')
    terminal          = @('*Windows Terminal*')
    discord           = @('*Discord*')
    kimi_cli          = @('*Kimi*')
    codex_cli         = @('*Codex*')
    claude_code_cli   = @('*Claude*')
    browser           = @('*Microsoft Edge*', '*Google Chrome*')
}

# Templates for apps seen in user logs
foreach ($key in $templates.Keys) {
    $t = $templates[$key]
    $patterns = $installPatterns[$key]
    $installed = if ($patterns) { Test-Installed -DisplayNameMatches $patterns } else { $false }
    $running = Test-ProcessRunning -ExeNames $t.exeNames
    if (-not $installed -and -not $running) { continue }
    $shortcuts = Apply-UsageWeight -Shortcuts $t.shortcuts -UsageWeights $usageWeights
    $discoveredApps.Add((Write-AppShortcuts -AppId $t.id -AppName $t.name -ExeNames $t.exeNames -Shortcuts $shortcuts))
}

# Usage-detected shortcuts as a separate app (catches anything the templates missed)
$usageShortcuts = [System.Collections.Generic.List[object]]::new()
foreach ($combo in ($usageWeights.Keys | Sort-Object)) {
    $info = $usageWeights[$combo]
    # Skip bare single letters and very short strings
    if ($combo -match '^[a-zA-Z0-9]$') { continue }
    # Skip if already covered by a template/PowerToys/Windows
    $already = $false
    foreach ($app in $discoveredApps) {
        if ($app.shortcuts.keys -contains $combo) { $already = $true; break }
    }
    if ($already) { continue }
    $freq = if ($info.count -gt 500) { 'constant' } elseif ($info.count -gt 100) { 'high' } elseif ($info.count -gt 20) { 'medium' } else { 'low' }
    $imp = [math]::Min(10.0, 5.0 + [math]::Log($info.count + 1, 10) * 2)
    $topApps = ($info.apps.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 3 | ForEach-Object { $_.Key }) -join ', '
    $usageShortcuts.Add((New-Shortcut -Keys $combo -Action "Used $($info.count) times ($topApps)" -Category 'Usage Detected' -Frequency $freq -Importance $imp))
}
if ($usageShortcuts.Count -gt 0) {
    $discoveredApps.Add((Write-AppShortcuts -AppId 'usage_detected' -AppName 'Usage Detected' -ExeNames @() -Shortcuts $usageShortcuts))
}

# Installed app inventory (informational)
$installedApps = [System.Collections.Generic.List[object]]::new()
$registryPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
foreach ($path in $registryPaths) {
    Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | ForEach-Object {
        $installedApps.Add(@{
            name            = $_.DisplayName
            publisher       = $_.Publisher
            version         = $_.DisplayVersion
            installLocation = $_.InstallLocation
        })
    }
}

$output = @{
    generatedAt       = (Get-Date -Format 'o')
    machine           = $env:COMPUTERNAME
    discoveredApps    = $discoveredApps
    installedAppCount = $installedApps.Count
    installedApps     = @($installedApps | Sort-Object name | Select-Object -First 200)
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

# Write UTF-8 without BOM for clean downstream parsing
$jsonText = $output | ConvertTo-Json -Depth 10
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, $jsonText, $utf8NoBom)

Write-Host "Wrote discovered shortcuts to $OutFile"
Write-Host "Next: run python/merge_shortcut_export.py to merge into the canonical corpus."
