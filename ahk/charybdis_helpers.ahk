#Requires AutoHotkey v2.0
#SingleInstance Force
; Charybdis desktop coach, launcher, and contextual helper keys.
;
; Windows only sees emitted HID keys, not the raw ZMK layer/coordinate state.
; This helper therefore infers the active context from known hotkeys, active
; windows, and F13-F24 helper keys.

global RepoRoot := ResolveRepoRoot()
global LayoutCsvPath := RepoRoot "\layout\keybindings_explained.csv"
global AppsConfigPath := RepoRoot "\config\charybdis_apps.json"
global HelperConfigPath := RepoRoot "\config\charybdis_helper.json"
global RuntimeDir := RepoRoot "\runtime"
global StatePath := RuntimeDir "\charybdis_state.json"
global EventLogPath := RuntimeDir "\charybdis_events.jsonl"
global ShortcutLogPath := RuntimeDir "\shortcut_usage.jsonl"
global LastShortcutKeys := ""
global LastShortcutTime := 0

; ── Usage logger globals ──
global EventBuffer := []
global FLUSH_INTERVAL := 5000
global MAX_LOG_SIZE := 50 * 1024 * 1024
global LOG_RETENTION_DAYS := 7
global LastMouseButton := ""
global LastMouseTime := 0
global LastMouseCount := 0
global LastMouseModifier := ""
global LastScrollDir := ""
global LastScrollTime := 0
global LastScrollTicks := 0
global LastRepeatKey := ""
global LastRepeatTime := 0
global RepeatCount := 0
global FunctionalKeyDownTime := Map()
global ModifierDownTime := Map()
global ModifierComboFired := false
global LastFocusApp := ""
global LastFocusTime := 0
global LayerSessionStart := 0
global LayerSessionKeys := []
global LayerSessionLayer := ""
global SpaceCount := 0
global BackspaceCount := 0
global EnterCount := 0

global DebugMode := false
global CoachVisible := false
global CoachFullscreen := false
global LauncherVisible := false
global CurrentCoachLayer := "0"
global LastAction := "Loaded"
global LastKey := Map("layer", "", "x", "", "y", "", "label", "")
global HeldLayers := []
global LockedLayer := ""
global ToggledLayers := []
global AppEntries := []
global LayoutRows := []
global HelperConfig := Map(
    "show_coach_on_start", true,
    "monitor_mode", "secondary",
    "opacity", 255,
    "compact", false,
    "start_fullscreen", false,
    "coach_app_enabled", true,
    "coach_beacons_enabled", true,
    "transport", "bluetooth"
)

global CoachGui := ""
global CoachTitle := ""
global CoachContext := ""
global CoachGrid := ""
global CoachLegend := ""
global LauncherGui := ""
global LauncherEdit := ""
global LauncherHint := ""

EnsureRuntime()
LoadEverything()
BuildTrayMenu()
CreateCoachGui()
CreateLauncherGui()
WriteCoachState()

TraySetIcon("shell32.dll", 44)
A_IconTip := "Charybdis helpers active"
ShowNotice("Charybdis helpers loaded", "Coach, launcher, and F13-F24 helpers are active.")

if HelperConfig["show_coach_on_start"] {
    ShowCoach()
}

SetTimer(UpdateCoachContext, 1000)
SetTimer(FlushEventBuffer, FLUSH_INTERVAL)
SetTimer(FlushPendingRepeat, 2500)
RotateLogIfNeeded()
RegisterAllHooks()
BufferEvent(Map("type", "startup", "keys", "logger_init", "app", "charybdis_helpers", "layer", "0"))
LastFocusApp := ""
try LastFocusApp := WinGetProcessName("A")
LastFocusTime := A_TickCount

LoadEverything() {
    global HelperConfig, AppEntries, LayoutRows, DebugMode
    HelperConfig := LoadHelperConfig()
    DebugMode := HelperConfig["debug_on_start"]
    AppEntries := LoadAppConfig()
    LayoutRows := LoadLayoutRows()
}

EnsureRuntime() {
    global RuntimeDir
    if !DirExist(RuntimeDir) {
        DirCreate(RuntimeDir)
    }
}

ResolveRepoRoot() {
    ; Script lives in <repo>\ahk\, so go up one level
    return RegExReplace(A_ScriptDir, "\\ahk$", "")
}

BuildTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Show / Hide Coach", (*) => ToggleCoach())
    A_TrayMenu.Add("Fullscreen Coach", (*) => ToggleCoachFullscreen())
    A_TrayMenu.Add("Open Web Coach", (*) => OpenCoachApp())
    A_TrayMenu.Add("Open Launcher", (*) => ShowLauncher())
    A_TrayMenu.Add("Reload Layout + Config", (*) => ReloadConfig())
    A_TrayMenu.Add("Toggle Debug Mode", (*) => ToggleDebug())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Coach Layer 0 Base", (*) => SetCoachLayer("0"))
    A_TrayMenu.Add("Coach Layer 1 Nav/Edit", (*) => SetCoachLayer("1"))
    A_TrayMenu.Add("Coach Layer 2 Mouse", (*) => SetCoachLayer("2"))
    A_TrayMenu.Add("Coach Layer 3 Windows", (*) => SetCoachLayer("3"))
    A_TrayMenu.Add("Coach Layer 4 Helpers", (*) => SetCoachLayer("4"))
    A_TrayMenu.Add("Coach Layer 7 Game", (*) => SetCoachLayer("7"))
    A_TrayMenu.Add("Coach Layer 8 Travel", (*) => SetCoachLayer("8"))
    A_TrayMenu.Add()
    A_TrayMenu.Add("Open App Config", (*) => Run("notepad.exe `"" AppsConfigPath "`""))
    A_TrayMenu.Add("Open Helper Config", (*) => Run("notepad.exe `"" HelperConfigPath "`""))
    A_TrayMenu.Add("Open Layout CSV", (*) => Run("notepad.exe `"" LayoutCsvPath "`""))
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit", (*) => ExitApp())
}

OpenCoachApp() {
    global HelperConfig
    port := HelperConfig.Has("coach_server_port") ? HelperConfig["coach_server_port"] : 8765
    Run("http://127.0.0.1:" port "/apps/charybdis-coach/")
    TouchAction("Open web coach")
}

ReloadConfig() {
    LoadEverything()
    UpdateCoachGrid()
    TouchAction("Reloaded layout/config")
    ShowNotice("Charybdis helpers", "Layout and config reloaded.")
}

ToggleDebug() {
    global DebugMode
    DebugMode := !DebugMode
    TouchAction(DebugMode ? "Debug mode ON" : "Debug mode OFF")
    ShowNotice("Charybdis debug", DebugMode ? "Debug mode ON - actions are previewed only." : "Debug mode OFF - actions are live.")
}

ShowNotice(title, message, seconds := 3) {
    TrayTip(message, title, 1)
    SetTimer(() => TrayTip(), -seconds * 1000)
}

TouchAction(name) {
    global LastAction
    LastAction := name
    UpdateCoachContext()
    WriteCoachState(true)
}

DoAction(name, action) {
    global DebugMode
    TouchAction(name)
    if DebugMode {
        ShowNotice("Charybdis debug", name, 2)
        return
    }
    action.Call()
}

SendSafe(name, keys) {
    DoAction(name, () => Send(keys))
    LogShortcutUsage(keys, name)
}

SendTextSafe(name, text) {
    DoAction(name, () => SendText(text))
}

RunSafe(name, target) {
    DoAction(name, () => Run(target))
}

LoadHelperConfig() {
    global HelperConfigPath
    cfg := Map("show_coach_on_start", true, "monitor_mode", "secondary", "opacity", 255, "compact", false, "start_fullscreen", false, "debug_on_start", false)
    if !FileExist(HelperConfigPath) {
        return cfg
    }
    text := FileRead(HelperConfigPath, "UTF-8")
    cfg["show_coach_on_start"] := JsonBool(text, "show_coach_on_start", cfg["show_coach_on_start"])
    cfg["compact"] := JsonBool(text, "compact", cfg["compact"])
    cfg["monitor_mode"] := JsonString(text, "monitor_mode", cfg["monitor_mode"])
    cfg["opacity"] := JsonNumber(text, "opacity", cfg["opacity"])
    cfg["debug_on_start"] := JsonBool(text, "debug_on_start", false)
    cfg["start_fullscreen"] := JsonBool(text, "start_fullscreen", false)
    cfg["coach_app_enabled"] := JsonBool(text, "coach_app_enabled", true)
    cfg["coach_beacons_enabled"] := JsonBool(text, "coach_beacons_enabled", true)
    cfg["coach_server_port"] := JsonNumber(text, "coach_server_port", 8765)
    cfg["coach_open_browser_on_start"] := JsonBool(text, "coach_open_browser_on_start", true)
    cfg["coach_default_view"] := JsonString(text, "coach_default_view", "layer")
    cfg["transport"] := JsonString(text, "transport", "bluetooth")
    return cfg
}

LoadAppConfig() {
    global AppsConfigPath
    entries := []
    if !FileExist(AppsConfigPath) {
        return entries
    }

    text := FileRead(AppsConfigPath, "UTF-8")
    pos := 1
    pattern := 's)\{\s*"id"\s*:\s*"(?<id>[^"]+)"(?<body>.*?)(?=\R\s*\},?\R\s*\{|\R\s*\}\s*\]\s*\})'
    while RegExMatch(text, pattern, &m, pos) {
        block := m[0] "`n}"
        entry := Map()
        entry["id"] := m["id"]
        entry["aliases"] := JsonArray(block, "aliases")
        entry["launch"] := JsonString(block, "launch", "")
        entry["new_instance"] := JsonString(block, "new_instance", "")
        entry["notes"] := JsonString(block, "notes", "")
        entry["exe"] := JsonNestedString(block, "window_match", "exe", "")
        entry["title"] := JsonNestedString(block, "window_match", "title", "")
        if entry["aliases"].Length && entry["launch"] {
            entries.Push(entry)
        }
        pos := m.Pos(0) + m.Len(0)
    }
    return entries
}

JsonString(text, key, defaultValue := "") {
    if RegExMatch(text, '"' key '"\s*:\s*"((?:\\.|[^"\\])*)"', &m) {
        return JsonUnescape(m[1])
    }
    return defaultValue
}

JsonNestedString(text, objectKey, key, defaultValue := "") {
    if RegExMatch(text, 's)"' objectKey '"\s*:\s*\{(?<body>.*?)\}', &m) {
        return JsonString(m["body"], key, defaultValue)
    }
    return defaultValue
}

JsonNumber(text, key, defaultValue := 0) {
    if RegExMatch(text, '"' key '"\s*:\s*([0-9]+)', &m) {
        return Integer(m[1])
    }
    return defaultValue
}

JsonBool(text, key, defaultValue := false) {
    if RegExMatch(text, '"' key '"\s*:\s*(true|false)', &m) {
        return m[1] = "true"
    }
    return defaultValue
}

JsonArray(text, key) {
    values := []
    if RegExMatch(text, 's)"' key '"\s*:\s*\[(?<body>.*?)\]', &m) {
        body := m["body"]
        pos := 1
        while RegExMatch(body, '"((?:\\.|[^"\\])*)"', &item, pos) {
            values.Push(JsonUnescape(item[1]))
            pos := item.Pos(0) + item.Len(0)
        }
    }
    return values
}

JsonEscape(value) {
    text := String(value)
    text := StrReplace(text, "\", "\\")
    text := StrReplace(text, '"', '\"')
    text := StrReplace(text, "`r", "\r")
    text := StrReplace(text, "`n", "\n")
    text := StrReplace(text, "`t", "\t")
    return text
}

JsonStringValue(value) {
    return '"' JsonEscape(value) '"'
}

JsonArrayValue(items) {
    text := "["
    for item in items {
        text .= (A_Index > 1 ? "," : "") JsonStringValue(item)
    }
    return text "]"
}

JsonKeyObject(key) {
    if !IsObject(key) {
        return "{}"
    }
    return "{" .
        '"layer":' JsonStringValue(key.Has("layer") ? key["layer"] : "") "," .
        '"x":' JsonStringValue(key.Has("x") ? key["x"] : "") "," .
        '"y":' JsonStringValue(key.Has("y") ? key["y"] : "") "," .
        '"label":' JsonStringValue(key.Has("label") ? key["label"] : "") .
        "}"
}

WriteCoachState(logEvent := false) {
    global StatePath, EventLogPath, CurrentCoachLayer, LastAction, LastKey, HeldLayers, LockedLayer, ToggledLayers, LauncherVisible, HelperConfig
    try {
    EnsureRuntime()
    activeApp := ""
    activeLayer := "0"
    try activeApp := ActiveAppLabel()
    try activeLayer := CoachActiveLayer()
    ; At rest the coach view must match the real keyboard layer, not a stale tray default.
    if (HeldLayers.Length = 0 && !LockedLayer && ToggledLayers.Length = 0) {
        CurrentCoachLayer := activeLayer
    }
    timestamp := FormatTime(A_NowUTC, "yyyy-MM-ddTHH:mm:ss") "Z"
    pid := ProcessExist()
    transportVal := ""
    try transportVal := HelperConfig.Has("transport") ? HelperConfig["transport"] : "bluetooth"
    catch
        transportVal := "bluetooth"
    json := "{" .
        '"activeLayer":' JsonStringValue(activeLayer) "," .
        '"displayedLayer":' JsonStringValue(CurrentCoachLayer) "," .
        '"heldLayers":' JsonArrayValue(HeldLayers) "," .
        '"lockedLayer":' JsonStringValue(LockedLayer) "," .
        '"toggledLayers":' JsonArrayValue(ToggledLayers) "," .
        '"lastAction":' JsonStringValue(LastAction) "," .
        '"lastKey":' JsonKeyObject(LastKey) "," .
        '"activeApp":' JsonStringValue(activeApp) "," .
        '"launcherVisible":' (LauncherVisible ? "true" : "false") "," .
        '"transport":' JsonStringValue(transportVal) "," .
        '"beaconAlive":true,' .
        '"beaconSource":"ahk",' .
        '"beaconPid":' pid "," .
        '"beaconHeartbeatAt":' JsonStringValue(timestamp) "," .
        '"updatedAt":' JsonStringValue(timestamp) .
        "}"

    AtomicWriteText(StatePath, json)
    if logEvent {
        try FileAppend(json "`r`n", EventLogPath, "UTF-8")
    }
    } catch as err {
        ; Silently ignore state-write errors to prevent abort dialogs
    }
}

LogShortcutUsage(shortcutKeys, name := "") {
    global LastShortcutKeys, LastShortcutTime, ModifierComboFired
    try {
    if (shortcutKeys = "")
        return
    ModifierComboFired := true
    hasCtrl := InStr(shortcutKeys, "Ctrl") || InStr(shortcutKeys, "^")
    hasAlt := InStr(shortcutKeys, "Alt") || InStr(shortcutKeys, "!")
    hasWin := InStr(shortcutKeys, "Win") || InStr(shortcutKeys, "#")
    isFKey := RegExMatch(shortcutKeys, "^F\d+$")
    if (!hasCtrl && !hasAlt && !hasWin && !isFKey)
        return

    activeApp := ""
    try activeApp := WinGetProcessName("A")
    activeLayer := "0"
    try activeLayer := CoachActiveLayer()

    evt := Map("type", "shortcut", "keys", shortcutKeys, "app", activeApp, "layer", activeLayer)
    if name
        evt["name"] := name

    now := A_TickCount
    if (LastShortcutKeys != "" && (now - LastShortcutTime) < 5000) {
        evt["prev"] := LastShortcutKeys
        evt["gap_ms"] := now - LastShortcutTime
    }
    LastShortcutKeys := shortcutKeys
    LastShortcutTime := now

    BufferEvent(evt)
    } catch {
    }
}

; ── Batch write infrastructure ──

BufferEvent(eventMap) {
    global EventBuffer
    eventMap["ts"] := FormatTime(A_NowUTC, "yyyy-MM-ddTHH:mm:ss") "Z"
    EventBuffer.Push(eventMap)
}

FlushEventBuffer() {
    global EventBuffer, ShortcutLogPath, RuntimeDir
    FlushTypingCounters()
    if !EventBuffer.Length
        return
    try {
        RotateLogIfNeeded()
        text := ""
        for evt in EventBuffer {
            text .= MapToJson(evt) "`r`n"
        }
        FileAppend(text, ShortcutLogPath, "UTF-8")
        EventBuffer := []
    } catch as e {
        try FileAppend("FlushEventBuffer error: " e.Message "`n", RuntimeDir "\hook_debug.log", "UTF-8")
    }
}

RotateLogIfNeeded() {
    global ShortcutLogPath, MAX_LOG_SIZE, LOG_RETENTION_DAYS, RuntimeDir
    if !FileExist(ShortcutLogPath)
        return
    try {
        size := FileGetSize(ShortcutLogPath)
        if size < MAX_LOG_SIZE
            return
        dateSuffix := FormatTime(A_NowUTC, "yyyyMMdd_HHmmss")
        rotated := RuntimeDir "\shortcut_usage_" dateSuffix ".jsonl"
        FileMove(ShortcutLogPath, rotated)
    } catch {
    }
    try {
        cutoff := DateAdd(A_NowUTC, -LOG_RETENTION_DAYS, "Days")
        loop files RuntimeDir "\shortcut_usage_*.jsonl" {
            if A_LoopFileTimeModified < cutoff
                FileDelete(A_LoopFilePath)
        }
    } catch {
    }
}

MapToJson(m) {
    text := "{"
    first := true
    for k, v in m {
        if !first
            text .= ","
        first := false
        if v is Array {
            text .= JsonStringValue(k) ":" JsonArrayValue(v)
        } else if v is Integer || v is Float {
            text .= JsonStringValue(k) ":" v
        } else {
            text .= JsonStringValue(k) ":" JsonStringValue(String(v))
        }
    }
    return text "}"
}

; ── Generic hotkey registration ──

RegisterAllHooks() {
    errors := ""
    registered := 0
    ; Modifier + letter/number hooks (replace hardcoded hotkeys)
    letters := "abcdefghijklmnopqrstuvwxyz"
    Loop Parse, letters {
        for prefix in ["~^", "~^+", "~!", "~!+", "~#", "~#+", "~^!", "~^!+"] {
            try {
                Hotkey prefix A_LoopField, LogHotkeyCallback
                registered++
            } catch as e {
                errors .= prefix A_LoopField ": " e.Message "`n"
            }
        }
    }
    numbers := "0123456789"
    Loop Parse, numbers {
        for prefix in ["~^", "~^+", "~!", "~#"] {
            try {
                Hotkey prefix A_LoopField, LogHotkeyCallback
                registered++
            } catch as e {
                errors .= prefix A_LoopField ": " e.Message "`n"
            }
        }
    }
    ; Modifier + punctuation/special keys
    for key in ["/", "\", "[", "]", "``", "-", "=", ",", ".", ";", "'"] {
        for prefix in ["~^", "~^+", "~!"] {
            try {
                Hotkey prefix key, LogHotkeyCallback
                registered++
            } catch as e {
                errors .= prefix key ": " e.Message "`n"
            }
        }
    }
    ; Modifier + navigation/editing keys
    for key in ["Left", "Right", "Up", "Down", "Home", "End", "PgUp", "PgDn", "Delete", "Insert", "Tab", "Enter", "Space", "Backspace"] {
        for prefix in ["~^", "~^+", "~!", "~!+", "~#", "~#+", "~+"] {
            try {
                Hotkey prefix key, LogHotkeyCallback
                registered++
            } catch as e {
                errors .= prefix key ": " e.Message "`n"
            }
        }
    }
    ; F1-F12 with modifiers (skip F13-F24 to avoid beacon conflicts)
    Loop 12 {
        fkey := "F" A_Index
        for prefix in ["~", "~^", "~!", "~+", "~^+", "~!+"] {
            try {
                Hotkey prefix fkey, LogHotkeyCallback
                registered++
            } catch as e {
                errors .= prefix fkey ": " e.Message "`n"
            }
        }
    }
    ; Bare functional keys (no modifier) — Space/Backspace/Enter aggregated via typing counters
    for key in ["Escape", "Enter", "Tab", "Backspace", "Delete", "Home", "End", "PgUp", "PgDn", "Insert", "PrintScreen", "Space"] {
        try {
            Hotkey "~" key, LogFunctionalCallback
            registered++
        } catch as e {
            errors .= "~" key ": " e.Message "`n"
        }
    }
    ; Shift+functional keys (not typing)
    for key in ["Escape", "Enter", "Tab", "Backspace", "Delete", "Home", "End", "PgUp", "PgDn", "Insert", "Space", "Left", "Right", "Up", "Down"] {
        try {
            Hotkey "~+" key, LogShiftFunctionalCallback
            registered++
        } catch as e {
            errors .= "~+" key ": " e.Message "`n"
        }
    }
    ; Bare arrow keys
    for key in ["Up", "Down", "Left", "Right"] {
        try {
            Hotkey "~" key, LogFunctionalCallback
            registered++
        } catch as e {
            errors .= "~" key ": " e.Message "`n"
        }
    }
    ; Key-up hooks for hold duration detection on functional keys
    for key in ["Escape", "Enter", "Tab", "Backspace", "Delete", "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right"] {
        try {
            Hotkey "~" key " Up", FunctionalKeyUpCallback
            registered++
        } catch as e {
            errors .= "~" key " Up: " e.Message "`n"
        }
    }
    ; Mouse buttons
    for key in ["LButton", "RButton", "MButton", "XButton1", "XButton2"] {
        try {
            Hotkey "~" key, LogMouseCallback
            registered++
        } catch as e {
            errors .= "~" key ": " e.Message "`n"
        }
    }
    ; Scroll
    for key in ["WheelUp", "WheelDown", "WheelLeft", "WheelRight"] {
        try {
            Hotkey "~" key, LogScrollCallback
            registered++
        } catch as e {
            errors .= "~" key ": " e.Message "`n"
        }
    }
    ; System shortcuts
    for key in ["~!Tab", "~#Tab", "~^+Escape", "~#;", "~#."] {
        try {
            Hotkey key, LogHotkeyCallback
            registered++
        } catch as e {
            errors .= key ": " e.Message "`n"
        }
    }
    ; Modifier up events for modifier-tap detection
    for key in ["~Alt Up", "~Ctrl Up", "~LWin Up"] {
        try {
            Hotkey key, ModifierUpCallback
            registered++
        } catch as e {
            errors .= key ": " e.Message "`n"
        }
    }
    ; Modifier down events
    for key in ["~Alt", "~Ctrl", "~LWin"] {
        try {
            Hotkey key, ModifierDownCallback
            registered++
        } catch as e {
            errors .= key ": " e.Message "`n"
        }
    }
    ; Log registration results
    try FileAppend("Registered " registered " hooks`n" (errors ? "Errors:`n" errors : "No errors") "`n", RuntimeDir "\hook_debug.log", "UTF-8")
}

ParseHotkeyName(hk) {
    name := hk
    name := StrReplace(name, "~", "")
    parts := []
    i := 1
    while i <= StrLen(name) {
        ch := SubStr(name, i, 1)
        if ch = "^" {
            parts.Push("Ctrl")
            i++
        } else if ch = "!" {
            parts.Push("Alt")
            i++
        } else if ch = "#" {
            parts.Push("Win")
            i++
        } else if ch = "+" {
            parts.Push("Shift")
            i++
        } else {
            break
        }
    }
    rest := SubStr(name, i)
    if StrLen(rest) = 1
        rest := StrUpper(rest)
    parts.Push(rest)
    return JoinList(parts, "+")
}

LogHotkeyCallback(hotkeyName) {
    global ModifierComboFired
    try {
        ModifierComboFired := true
        keys := ParseHotkeyName(hotkeyName)
        layer := "0"
        try layer := CoachActiveLayer()
        evtType := layer != "0" ? "layer_key" : "shortcut"
        LogEventWithRepeatAndSequence(evtType, keys, layer)
    } catch as e {
        try FileAppend("LogHotkeyCallback error: " hotkeyName " - " e.Message "`n", RuntimeDir "\hook_debug.log", "UTF-8")
    }
}

LogFunctionalCallback(hotkeyName) {
    global ModifierComboFired, FunctionalKeyDownTime, SpaceCount, BackspaceCount, EnterCount
    try {
        keys := ParseHotkeyName(hotkeyName)
        layer := "0"
        try layer := CoachActiveLayer()
        if layer != "0" {
            ModifierComboFired := true
            LogEventWithRepeatAndSequence("layer_key", keys, layer)
            return
        }
        ; Aggregate high-frequency typing keys — flush as batch counts
        if keys = "Space" {
            SpaceCount++
            return
        }
        if keys = "Backspace" {
            BackspaceCount++
            return
        }
        if keys = "Enter" {
            EnterCount++
            return
        }
        FunctionalKeyDownTime[keys] := A_TickCount
        LogEventWithRepeatAndSequence("functional", keys, layer)
    } catch as e {
        try FileAppend("LogFunctionalCallback error: " hotkeyName " - " e.Message "`n", RuntimeDir "\hook_debug.log", "UTF-8")
    }
}

FlushTypingCounters() {
    global SpaceCount, BackspaceCount, EnterCount
    activeApp := ""
    try activeApp := WinGetProcessName("A")
    if SpaceCount > 0 {
        BufferEvent(Map("type", "typing_counter", "keys", "Space", "count", SpaceCount, "app", activeApp, "layer", "0"))
        SpaceCount := 0
    }
    if BackspaceCount > 0 {
        BufferEvent(Map("type", "typing_counter", "keys", "Backspace", "count", BackspaceCount, "app", activeApp, "layer", "0"))
        BackspaceCount := 0
    }
    if EnterCount > 0 {
        BufferEvent(Map("type", "typing_counter", "keys", "Enter", "count", EnterCount, "app", activeApp, "layer", "0"))
        EnterCount := 0
    }
}

LogShiftFunctionalCallback(hotkeyName) {
    global ModifierComboFired
    ModifierComboFired := true
    keys := ParseHotkeyName(hotkeyName)
    layer := "0"
    try layer := CoachActiveLayer()
    evtType := layer != "0" ? "layer_key" : "shortcut"
    LogEventWithRepeatAndSequence(evtType, keys, layer)
}

FunctionalKeyUpCallback(hotkeyName) {
    global FunctionalKeyDownTime
    rawName := StrReplace(hotkeyName, "~", "")
    rawName := StrReplace(rawName, " Up", "")
    if !FunctionalKeyDownTime.Has(rawName)
        return
    elapsed := A_TickCount - FunctionalKeyDownTime[rawName]
    FunctionalKeyDownTime.Delete(rawName)
    if elapsed >= 500 {
        activeApp := ""
        try activeApp := WinGetProcessName("A")
        layer := "0"
        try layer := CoachActiveLayer()
        evt := Map("type", "functional", "keys", rawName, "app", activeApp, "layer", layer, "held_ms", elapsed)
        BufferEvent(evt)
    }
}

LogEventWithRepeatAndSequence(evtType, keys, layer) {
    global LastRepeatKey, LastRepeatTime, RepeatCount, LastShortcutKeys, LastShortcutTime, LayerSessionKeys
    now := A_TickCount

    ; Track keys pressed during layer session
    if layer != "0" && LayerSessionKeys is Array {
        LayerSessionKeys.Push(keys)
    }

    ; Repeat aggregation (only for shortcuts, not bare functional keys)
    if evtType = "shortcut" || evtType = "layer_key" {
        if keys = LastRepeatKey && (now - LastRepeatTime) < 2000 {
            RepeatCount++
            LastRepeatTime := now
            return
        }
        if RepeatCount > 1 {
            FlushRepeatEvent()
        }
        LastRepeatKey := keys
        LastRepeatTime := now
        RepeatCount := 1
    }

    activeApp := ""
    try activeApp := WinGetProcessName("A")
    evt := Map("type", evtType, "keys", keys, "app", activeApp, "layer", layer)

    ; Sequence tracking
    if LastShortcutKeys != "" && (now - LastShortcutTime) < 5000 {
        evt["prev"] := LastShortcutKeys
        evt["gap_ms"] := now - LastShortcutTime
    }
    LastShortcutKeys := keys
    LastShortcutTime := now

    BufferEvent(evt)
}

FlushRepeatEvent() {
    global LastRepeatKey, RepeatCount, LastShortcutKeys, LastShortcutTime
    if RepeatCount <= 1 || LastRepeatKey = ""
        return
    activeApp := ""
    try activeApp := WinGetProcessName("A")
    layer := "0"
    try layer := CoachActiveLayer()
    evt := Map("type", "shortcut", "keys", LastRepeatKey, "app", activeApp, "layer", layer, "repeat_count", RepeatCount)
    BufferEvent(evt)
    RepeatCount := 0
}

FlushPendingRepeat() {
    global RepeatCount
    if RepeatCount > 1
        FlushRepeatEvent()
}

; ── Mouse callbacks ──

LogMouseCallback(hotkeyName) {
    global LastMouseButton, LastMouseTime, LastMouseCount, LastMouseModifier, ModifierComboFired
    ModifierComboFired := true
    buttonMap := Map("LButton", "MB1", "RButton", "MB2", "MButton", "MB3", "XButton1", "MB4", "XButton2", "MB5")
    rawName := StrReplace(hotkeyName, "~", "")
    button := buttonMap.Has(rawName) ? buttonMap[rawName] : rawName
    modifier := ""
    if GetKeyState("Ctrl", "P")
        modifier .= "Ctrl"
    if GetKeyState("Shift", "P")
        modifier .= (modifier ? "+" : "") "Shift"
    if GetKeyState("Alt", "P")
        modifier .= (modifier ? "+" : "") "Alt"
    now := A_TickCount
    if button = LastMouseButton && (now - LastMouseTime) < 500 && modifier = LastMouseModifier {
        LastMouseCount++
        LastMouseTime := now
    } else {
        FlushPendingMouse()
        LastMouseButton := button
        LastMouseTime := now
        LastMouseCount := 1
        LastMouseModifier := modifier
    }
    SetTimer(FlushPendingMouse, -600)
}

FlushPendingMouse() {
    global LastMouseButton, LastMouseCount, LastMouseModifier, LayerSessionKeys
    if LastMouseButton = ""
        return
    activeApp := ""
    try activeApp := WinGetProcessName("A")
    layer := "0"
    try layer := CoachActiveLayer()
    evt := Map("type", "mouse", "button", LastMouseButton, "app", activeApp, "layer", layer, "count", LastMouseCount)
    if LastMouseModifier
        evt["modifier"] := LastMouseModifier
    if layer != "0" && LayerSessionKeys is Array
        LayerSessionKeys.Push(LastMouseButton)
    BufferEvent(evt)
    LastMouseButton := ""
    LastMouseCount := 0
    LastMouseModifier := ""
}

; ── Scroll callbacks ──

LogScrollCallback(hotkeyName) {
    global LastScrollDir, LastScrollTime, LastScrollTicks, ModifierComboFired
    ModifierComboFired := true
    rawName := StrReplace(hotkeyName, "~", "")
    dirMap := Map("WheelUp", "up", "WheelDown", "down", "WheelLeft", "left", "WheelRight", "right")
    dir := dirMap.Has(rawName) ? dirMap[rawName] : rawName
    now := A_TickCount
    if dir = LastScrollDir && (now - LastScrollTime) < 300 {
        LastScrollTicks++
        LastScrollTime := now
    } else {
        FlushPendingScroll()
        LastScrollDir := dir
        LastScrollTime := now
        LastScrollTicks := 1
    }
    SetTimer(FlushPendingScroll, -400)
}

FlushPendingScroll() {
    global LastScrollDir, LastScrollTicks
    if LastScrollDir = ""
        return
    activeApp := ""
    try activeApp := WinGetProcessName("A")
    layer := "0"
    try layer := CoachActiveLayer()
    modifier := ""
    if GetKeyState("Ctrl", "P")
        modifier := "Ctrl"
    evt := Map("type", "scroll", "direction", LastScrollDir, "ticks", LastScrollTicks, "app", activeApp, "layer", layer)
    if modifier
        evt["modifier"] := modifier
    BufferEvent(evt)
    LastScrollDir := ""
    LastScrollTicks := 0
}

; ── Modifier tap detection ──

ModifierDownCallback(hotkeyName) {
    global ModifierDownTime, ModifierComboFired
    rawName := StrReplace(hotkeyName, "~", "")
    ModifierDownTime[rawName] := A_TickCount
    ModifierComboFired := false
}

ModifierUpCallback(hotkeyName) {
    global ModifierDownTime, ModifierComboFired
    rawName := StrReplace(hotkeyName, "~", "")
    rawName := StrReplace(rawName, " Up", "")
    if !ModifierDownTime.Has(rawName)
        return
    elapsed := A_TickCount - ModifierDownTime[rawName]
    ModifierDownTime.Delete(rawName)
    if elapsed < 500 && !ModifierComboFired {
        activeApp := ""
        try activeApp := WinGetProcessName("A")
        layer := "0"
        try layer := CoachActiveLayer()
        evt := Map("type", "modifier_tap", "key", rawName, "app", activeApp, "layer", layer)
        BufferEvent(evt)
    }
}

; ── App focus tracking ──

TrackAppFocus() {
    global LastFocusApp, LastFocusTime
    activeApp := ""
    try activeApp := WinGetProcessName("A")
    if activeApp = "" || activeApp = LastFocusApp
        return
    now := A_TickCount
    if LastFocusApp != "" && LastFocusTime > 0 {
        duration := now - LastFocusTime
        evt := Map("type", "app_focus", "app", activeApp, "prev_app", LastFocusApp, "prev_duration_ms", duration)
        BufferEvent(evt)
    }
    LastFocusApp := activeApp
    LastFocusTime := now
}

; ── Layer session tracking ──

StartLayerSession(layer) {
    global LayerSessionStart, LayerSessionKeys, LayerSessionLayer
    LayerSessionStart := A_TickCount
    LayerSessionKeys := []
    LayerSessionLayer := layer
}

EndLayerSession() {
    global LayerSessionStart, LayerSessionKeys, LayerSessionLayer
    if LayerSessionStart = 0 || LayerSessionLayer = ""
        return
    duration := A_TickCount - LayerSessionStart
    if duration < 50
        return
    activeApp := ""
    try activeApp := WinGetProcessName("A")
    evt := Map("type", "layer_session", "layer", LayerSessionLayer, "duration_ms", duration, "keys_pressed", LayerSessionKeys, "app", activeApp)
    BufferEvent(evt)
    LayerSessionStart := 0
    LayerSessionKeys := []
    LayerSessionLayer := ""
}

AtomicWriteText(path, text) {
    tmpPath := path ".tmp"
    loop 8 {
        try {
            if FileExist(tmpPath) {
                FileDelete(tmpPath)
            }
            FileAppend(text, tmpPath, "UTF-8")
            FileMove(tmpPath, path, true)
            return
        } catch {
            if A_Index = 8 {
                throw
            }
            Sleep 25
        }
    }
}

FileDeleteSafe(path) {
    try {
        if FileExist(path) {
            FileDelete(path)
        }
    }
}

CoachActiveLayer() {
    global HeldLayers, LockedLayer, ToggledLayers
    if HasArrayValue(ToggledLayers, "8") {
        return "8"
    }
    if LockedLayer {
        return LockedLayer
    }
    if HeldLayers.Length {
        return HeldLayers[HeldLayers.Length]
    }
    return "0"
}

AddUniqueLayer(list, layer) {
    if !HasArrayValue(list, layer) {
        list.Push(layer)
    }
}

RemoveLayer(list, layer) {
    index := list.Length
    while index >= 1 {
        if list[index] = layer {
            list.RemoveAt(index)
        }
        index -= 1
    }
}

HasArrayValue(list, value) {
    for item in list {
        if item = value {
            return true
        }
    }
    return false
}

LayerKeyHint(kind, layer) {
    layer := String(layer)
    if kind = "hold" {
        switch layer {
            case "1": return Map("layer", "0", "x", "3", "y", "4", "label", "Nav")
            case "2": return Map("layer", "0", "x", "5", "y", "5", "label", "Mouse")
            case "3": return Map("layer", "0", "x", "8", "y", "4", "label", "Window")
            case "4": return Map("layer", "0", "x", "7", "y", "4", "label", "System")
            case "8": return Map("layer", "3", "x", "11", "y", "2", "label", "Speed")
        }
    } else if kind = "lock" {
        switch layer {
            case "2": return Map("layer", "3", "x", "10", "y", "2", "label", "Mouse Lock")
            case "7": return Map("layer", "1", "x", "0", "y", "1", "label", "Game")
        }
    } else if kind = "toggle" {
        switch layer {
            case "6": return Map("layer", "2", "x", "12", "y", "2", "label", "Scroll")
            case "8": return Map("layer", "3", "x", "11", "y", "2", "label", "Speed")
        }
    } else if kind = "base" {
        return Map("layer", "2", "x", "7", "y", "4", "label", "Base")
    } else if kind = "exit" {
        switch layer {
            case "7": return Map("layer", "7", "x", "7", "y", "4", "label", "Exit Base")
            case "8": return Map("layer", "8", "x", "7", "y", "4", "label", "Exit Travel")
        }
    }
    return Map()
}

CoachBeacon(kind, layer, direction, label := "") {
    global CurrentCoachLayer, HeldLayers, LockedLayer, ToggledLayers, LastKey, HelperConfig
    if HelperConfig.Has("coach_beacons_enabled") && !HelperConfig["coach_beacons_enabled"] {
        return
    }

    layer := String(layer)
    switch kind {
        case "hold":
            if direction = "down" {
                AddUniqueLayer(HeldLayers, layer)
                hint := LayerKeyHint("hold", layer)
                if hint.Count {
                    LastKey := hint
                } else {
                    LastKey := Map("layer", "", "x", "", "y", "", "label", "")
                }
                CurrentCoachLayer := layer
                StartLayerSession(layer)
                TouchAction("BLE layer " layer " held")
            } else {
                EndLayerSession()
                RemoveLayer(HeldLayers, layer)
                CurrentCoachLayer := CoachActiveLayer()
                TouchAction("BLE layer " layer " released")
            }
        case "lock":
            if layer = "0" || direction = "exit" {
                EndLayerSession()
                exiting := LockedLayer != "" ? LockedLayer : CoachActiveLayer()
                LockedLayer := ""
                HeldLayers := []
                ToggledLayers := []
                hint := LayerKeyHint("exit", exiting)
                if !hint.Count {
                    hint := LayerKeyHint("base", "0")
                }
                LastKey := hint.Count ? hint : Map("layer", "", "x", "", "y", "", "label", "")
                CurrentCoachLayer := "0"
                TouchAction("BLE base layer")
            } else {
                HeldLayers := []
                LockedLayer := layer
                hint := LayerKeyHint("lock", layer)
                LastKey := hint.Count ? hint : Map("layer", "", "x", "", "y", "", "label", "")
                CurrentCoachLayer := layer
                StartLayerSession(layer)
                TouchAction("BLE layer " layer " locked")
            }
        case "toggle":
            if direction = "off" || HasArrayValue(ToggledLayers, layer) {
                EndLayerSession()
                RemoveLayer(ToggledLayers, layer)
                CurrentCoachLayer := CoachActiveLayer()
                if direction = "off" {
                    hint := LayerKeyHint("exit", layer)
                    if hint.Count {
                        LastKey := hint
                    }
                }
                TouchAction("BLE layer " layer " toggled off")
            } else {
                AddUniqueLayer(ToggledLayers, layer)
                CurrentCoachLayer := layer
                StartLayerSession(layer)
                TouchAction("BLE layer " layer " toggled on")
            }
        case "key":
            LastKey := Map("layer", layer, "x", "", "y", "", "label", label)
            TouchAction(label ? label : "BLE helper key")
    }
    WriteCoachState(true)
}

JsonUnescape(value) {
    value := StrReplace(value, '\"', '"')
    value := StrReplace(value, "\\", "\")
    return value
}

LoadLayoutRows() {
    global LayoutCsvPath
    rows := []
    if !FileExist(LayoutCsvPath) {
        return rows
    }
    lines := StrSplit(FileRead(LayoutCsvPath, "UTF-8"), "`n", "`r")
    if lines.Length < 2 {
        return rows
    }
    headers := ParseCsvLine(lines[1])
    Loop lines.Length - 1 {
        line := lines[A_Index + 1]
        if Trim(line) = "" {
            continue
        }
        values := ParseCsvLine(line)
        row := Map()
        for i, header in headers {
            row[header] := i <= values.Length ? values[i] : ""
        }
        rows.Push(row)
    }
    return rows
}

ParseCsvLine(line) {
    out := []
    cur := ""
    quoted := false
    i := 1
    while i <= StrLen(line) {
        ch := SubStr(line, i, 1)
        next := SubStr(line, i + 1, 1)
        if ch = '"' && quoted && next = '"' {
            cur .= '"'
            i += 1
        } else if ch = '"' {
            quoted := !quoted
        } else if ch = "," && !quoted {
            out.Push(cur)
            cur := ""
        } else {
            cur .= ch
        }
        i += 1
    }
    out.Push(cur)
    return out
}

CreateCoachGui() {
    global CoachGui, CoachTitle, CoachContext, CoachGrid, CoachLegend
    CoachGui := Gui("+AlwaysOnTop +Resize +MaximizeBox", "Charybdis Coach")
    CoachGui.BackColor := "0B0F14"
    CoachGui.MarginX := 24
    CoachGui.MarginY := 20
    CoachGui.SetFont("s16 cF4F7FB Bold", "Segoe UI")
    CoachTitle := CoachGui.AddText("w1180 h36", "")
    CoachGui.SetFont("s11 cB8C4D4", "Segoe UI")
    CoachContext := CoachGui.AddText("w1180 h54", "")
    CoachGui.SetFont("s14 cEAF2F8", "Cascadia Mono")
    CoachGrid := CoachGui.AddText("w1180 h385", "")
    CoachGui.SetFont("s10 cB8C4D4", "Segoe UI")
    CoachLegend := CoachGui.AddText("w1180 h94", "")
    CoachGui.OnEvent("Size", CoachGuiSize)
    UpdateCoachGrid()
}

ToggleCoach() {
    global CoachVisible
    if CoachVisible {
        HideCoach()
    } else {
        ShowCoach()
    }
}

ShowCoach() {
    global CoachGui, CoachVisible, CoachFullscreen, HelperConfig
    if HelperConfig["start_fullscreen"] {
        CoachFullscreen := true
    }
    if CoachFullscreen {
        mon := CoachMonitor()
        MonitorGetWorkArea(mon, &l, &t, &r, &b)
        CoachGui.Show("NoActivate x" l " y" t " w" (r - l) " h" (b - t))
    } else {
        pos := CoachPosition(1240, HelperConfig["compact"] ? 430 : 650)
        CoachGui.Show("NoActivate x" pos["x"] " y" pos["y"] " w" pos["w"] " h" pos["h"])
    }
    ApplyCoachOpacity()
    CoachVisible := true
    UpdateCoachGrid()
}

HideCoach() {
    global CoachGui, CoachVisible
    CoachGui.Hide()
    CoachVisible := false
}

CoachPosition(width, height) {
    mon := CoachMonitor()
    MonitorGetWorkArea(mon, &l, &t, &r, &b)
    return Map("x", l + 24, "y", t + 24, "w", Min(width, r - l - 48), "h", Min(height, b - t - 48))
}

CoachMonitor() {
    global HelperConfig
    count := MonitorGetCount()
    if HelperConfig["monitor_mode"] = "mouse" {
        return GetMouseMonitor()
    }
    if HelperConfig["monitor_mode"] = "secondary" && count > 1 {
        return 2
    }
    return 1
}

ToggleCoachFullscreen() {
    global CoachFullscreen
    CoachFullscreen := !CoachFullscreen
    ShowCoach()
    TouchAction(CoachFullscreen ? "Coach fullscreen" : "Coach windowed")
}

ApplyCoachOpacity() {
    global CoachGui, HelperConfig
    opacity := HelperConfig["opacity"]
    if opacity >= 255 {
        try WinSetTransparent("Off", "ahk_id " CoachGui.Hwnd)
    } else {
        WinSetTransparent(opacity, "ahk_id " CoachGui.Hwnd)
    }
}

CoachGuiSize(guiObj, minMax, width, height) {
    global CoachTitle, CoachContext, CoachGrid, CoachLegend
    if !IsObject(CoachGrid) || width < 400 || height < 260 {
        return
    }
    innerW := width - 48
    gridH := Max(170, height - 220)
    CoachTitle.Move(, , innerW, 38)
    CoachContext.Move(, , innerW, 58)
    CoachGrid.Move(, , innerW, gridH)
    CoachLegend.Move(, , innerW, 96)
}

SetCoachLayer(layer) {
    global CurrentCoachLayer
    CurrentCoachLayer := layer
    TouchAction("Coach Layer " layer)
    UpdateCoachGrid()
    if !CoachVisible {
        ShowCoach()
    }
}

UpdateCoachContext() {
    global CoachContext, LastAction
    TrackAppFocus()
    if !IsObject(CoachContext) {
        WriteCoachState(false)
        return
    }
    app := ActiveAppLabel()
    CoachContext.Text := "Active app: " app "`nLast action: " LastAction
    WriteCoachState(false)
}

UpdateCoachGrid() {
    global CoachTitle, CoachGrid, CoachLegend, CurrentCoachLayer, LayoutRows
    if !IsObject(CoachGrid) {
        return
    }
    role := LayerRole(CurrentCoachLayer)
    CoachTitle.Text := "Charybdis Coach - Layer " CurrentCoachLayer " - " role
    CoachGrid.Text := RenderLayerGrid(CurrentCoachLayer)
    CoachLegend.Text := "Thumb anchors: L1/Nav x3 y4 | Space x4 y4 | Mouse x5 y5 | L4/System x7 y4 | L3/Window x8 y4 | Enter x7 y5`n" .
        "Launcher: Ctrl+Alt+Space.  Force new app: Shift+Enter or !prefix.  PowerToys: Win+Alt+Space (default)."
    UpdateCoachContext()
}

LayerRole(layer) {
    switch layer {
        case "0": return "Base typing and thumb access"
        case "1": return "Navigation, editing, function keys"
        case "2": return "Mouse lock and button layer"
        case "3": return "Window, app, language, mouse/game/travel control"
        case "4": return "Language, host, system, F13-F24 helpers"
        case "7": return "RPG/game layer"
        case "8": return "Pointer-travel overlay exits"
        default: return "Reserved / transparent"
    }
}

RenderLayerGrid(layer) {
    global LayoutRows
    cells := Map()
    for row in LayoutRows {
        if row["layer"] != layer {
            continue
        }
        label := CoachCellLabel(row)
        cells[row["x"] ":" row["y"]] := PadCell(label, 10)
    }

    text := "       x0         x1         x2         x3         x4         x5             x7         x8         x9         x10        x11        x12`r`n"
    Loop 6 {
        y := A_Index - 1
        text .= "y" y "  "
        for x in [0, 1, 2, 3, 4, 5] {
            text .= cells.Has(String(x) ":" String(y)) ? cells[String(x) ":" String(y)] : PadCell("", 10)
        }
        text .= "   "
        for x in [7, 8, 9, 10, 11, 12] {
            text .= cells.Has(String(x) ":" String(y)) ? cells[String(x) ":" String(y)] : PadCell("", 10)
        }
        text .= "`r`n"
    }
    return text
}

CoachCellLabel(row) {
    label := row["visual_label"]
    behavior := row["behavior"]
    parameter := row["parameter"]
    modifiers := row["modifiers"]

    if behavior = "Transparent" {
        return "."
    }
    if InStr(behavior, "Layer") {
        return LayerIcon(label, parameter)
    }
    if behavior = "Mouse Key Press" {
        return "M:" RegExReplace(parameter, "^select:", "")
    }
    if behavior = "Bluetooth" {
        return "BT " parameter
    }
    if behavior = "Output Selection" {
        return "OUT"
    }
    if label {
        if modifiers {
            return ShortModifier(modifiers) "+" label
        }
        return label
    }
    return behavior
}

LayerIcon(label, parameter) {
    if InStr(parameter, "Layer::1") {
        return "NAV"
    }
    if InStr(parameter, "Layer::2") {
        return "MOUSE"
    }
    if InStr(parameter, "Layer::3") {
        return "WIN"
    }
    if InStr(parameter, "Layer::4") {
        return "SYS"
    }
    if InStr(parameter, "Layer::7") {
        return "GAME"
    }
    if InStr(parameter, "Layer::8") {
        return "TRAVEL"
    }
    return label ? label : "LAYER"
}

ShortModifier(modifiers) {
    text := modifiers
    text := StrReplace(text, "L Ctrl", "C")
    text := StrReplace(text, "L Shift", "S")
    text := StrReplace(text, "L Alt", "A")
    text := StrReplace(text, "L GUI", "W")
    text := StrReplace(text, "+", "")
    return text
}

PadCell(text, width) {
    clean := SubStr(RegExReplace(text, "\s+", " "), 1, width - 1)
    while StrLen(clean) < width {
        clean .= " "
    }
    return clean
}

ActiveAppLabel() {
    try {
        title := WinGetTitle("A")
        exe := WinGetProcessName("A")
        return exe " - " SubStr(title, 1, 70)
    } catch {
        return "Unknown"
    }
}

CreateLauncherGui() {
    global LauncherGui, LauncherEdit, LauncherHint
    LauncherGui := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox", "Charybdis Launcher")
    LauncherGui.BackColor := "11161C"
    LauncherGui.SetFont("s11 cF2F4F8", "Segoe UI")
    LauncherGui.AddText("w560", "Type an app alias, then Enter. Shift+Enter or !prefix forces a new instance.")
    LauncherEdit := LauncherGui.AddEdit("w560 h30")
    LauncherGui.SetFont("s9 cAAB4C0", "Segoe UI")
    LauncherHint := LauncherGui.AddText("w560 h64", LauncherHelpText())
    LauncherEdit.OnEvent("Change", (*) => UpdateLauncherHint())
}

LauncherHelpText(prefix := "") {
    global AppEntries
    names := []
    for app in AppEntries {
        if app["aliases"].Length {
            names.Push(app["aliases"][1])
        }
    }
    joined := names.Length ? JoinList(names, ", ") : "No apps loaded"
    return (prefix ? prefix "`n" : "") "Aliases: " joined
}

UpdateLauncherHint() {
    global LauncherEdit, LauncherHint
    query := Trim(LauncherEdit.Value)
    app := FindAppByQuery(query)
    if IsObject(app) {
        LauncherHint.Text := app["id"] ": " app["notes"]
    } else {
        LauncherHint.Text := LauncherHelpText(query ? "No exact alias for '" query "'." : "")
    }
}

ShowLauncher() {
    global LauncherGui, LauncherEdit, LauncherVisible
    TouchAction("Launcher")
    mon := GetMouseMonitor()
    MonitorGetWorkArea(mon, &l, &t, &r, &b)
    x := l + Round((r - l - 600) / 2)
    y := t + 90
    LauncherEdit.Value := ""
    UpdateLauncherHint()
    LauncherGui.Show("x" x " y" y " w600 h150")
    LauncherEdit.Focus()
    LauncherVisible := true
    WriteCoachState(true)
}

HideLauncher() {
    global LauncherGui, LauncherVisible
    LauncherGui.Hide()
    LauncherVisible := false
    WriteCoachState(true)
}

SubmitLauncher(forceNew := false) {
    global LauncherEdit
    query := Trim(LauncherEdit.Value)
    if query = "" {
        HideLauncher()
        return
    }
    if SubStr(query, 1, 1) = "!" {
        forceNew := true
        query := Trim(SubStr(query, 2))
    }
    HideLauncher()
    LaunchOrMoveApp(query, forceNew)
}

LaunchOrMoveApp(query, forceNew := false) {
    global DebugMode
    app := FindAppByQuery(query)
    if !IsObject(app) {
        TouchAction("Launcher: no alias " query)
        ShowNotice("Charybdis launcher", "No app alias: " query)
        return
    }

    actionName := "Launcher: " app["id"] (forceNew ? " new" : "")
    TouchAction(actionName)
    if DebugMode {
        ShowNotice("Charybdis debug", actionName, 2)
        return
    }

    hwnd := forceNew ? 0 : FindAppWindow(app)
    if hwnd {
        ActivateAndMove(hwnd)
        return
    }

    command := forceNew && app["new_instance"] ? app["new_instance"] : app["launch"]
    try {
        Run(command)
    } catch as err {
        ShowNotice("Charybdis launcher", "Launch failed: " app["id"])
        return
    }

    deadline := A_TickCount + 9000
    while A_TickCount < deadline {
        Sleep(250)
        hwnd := FindAppWindow(app)
        if hwnd {
            ActivateAndMove(hwnd)
            return
        }
    }
    ShowNotice("Charybdis launcher", "Launched " app["id"] ", but no matching window was found yet.")
}

FindAppByQuery(query) {
    global AppEntries
    q := StrLower(Trim(query))
    if q = "" {
        return ""
    }
    for app in AppEntries {
        for alias in app["aliases"] {
            if StrLower(alias) = q {
                return app
            }
        }
    }
    for app in AppEntries {
        for alias in app["aliases"] {
            if InStr(StrLower(alias), q) = 1 {
                return app
            }
        }
    }
    return ""
}

FindAppWindow(app) {
    if app["exe"] {
        for hwnd in WinGetList("ahk_exe " app["exe"]) {
            if IsUsableWindow(hwnd) {
                return hwnd
            }
        }
    }
    if app["title"] {
        for hwnd in WinGetList(app["title"]) {
            if IsUsableWindow(hwnd) {
                return hwnd
            }
        }
    }
    return 0
}

IsUsableWindow(hwnd) {
    try {
        style := WinGetStyle("ahk_id " hwnd)
        title := WinGetTitle("ahk_id " hwnd)
        return title != "" && (style & 0x10000000)
    } catch {
        return false
    }
}

ActivateAndMove(hwnd) {
    MoveWindowToMouseMonitor(hwnd)
    WinActivate("ahk_id " hwnd)
}

MoveWindowToMouseMonitor(hwnd) {
    mon := GetMouseMonitor()
    MonitorGetWorkArea(mon, &l, &t, &r, &b)
    try {
        state := WinGetMinMax("ahk_id " hwnd)
        if state != 0 {
            WinRestore("ahk_id " hwnd)
            Sleep(100)
        }
        WinGetPos(, , &w, &h, "ahk_id " hwnd)
        w := Min(Max(w, 900), r - l - 80)
        h := Min(Max(h, 650), b - t - 80)
        WinMove(l + 40, t + 40, w, h, "ahk_id " hwnd)
        if state = 1 {
            WinMaximize("ahk_id " hwnd)
        }
    } catch {
        ; Some elevated or special windows reject movement. Activation still helps.
    }
}

GetMouseMonitor() {
    MouseGetPos(&mx, &my)
    count := MonitorGetCount()
    Loop count {
        MonitorGetWorkArea(A_Index, &l, &t, &r, &b)
        if mx >= l && mx <= r && my >= t && my <= b {
            return A_Index
        }
    }
    return 1
}

JoinList(items, separator) {
    text := ""
    for item in items {
        text .= (text ? separator : "") item
    }
    return text
}

; =========
; Global control hotkeys
; =========
^!+F12::ToggleDebug()
^!+c::ToggleCoach()
^!+F11::ToggleCoachFullscreen()
^!+r::ReloadConfig()

; Alt+Space freed for PowerToys Command Palette (Win+Alt+Space default).
; AHK launcher moved to Ctrl+Alt+Space to avoid conflict.
^!Space::ShowLauncher()

; =========
; Bluetooth HID coach beacons
; =========
; Firmware-side macros can emit these rare chords over BLE. AutoHotkey swallows
; them and updates runtime\charybdis_state.json for the web coach.
; Debounce: "up" beacons are delayed 300ms — if a "down" for the same layer
; arrives within that window, the release is cancelled (spurious key-repeat).
global PendingRelease := Map()

DebouncedHoldUp(layer) {
    global PendingRelease
    PendingRelease[layer] := A_TickCount
    layerCopy := layer
    SetTimer(() => FinishRelease(layerCopy), -300)
}

FinishRelease(layer) {
    global PendingRelease
    if PendingRelease.Has(layer) && (A_TickCount - PendingRelease[layer]) >= 280 {
        PendingRelease.Delete(layer)
        CoachBeacon("hold", layer, "up")
    }
}

DebouncedHoldDown(layer) {
    global PendingRelease
    if PendingRelease.Has(layer) {
        PendingRelease.Delete(layer)
    }
    CoachBeacon("hold", layer, "down")
}

^!+F13::DebouncedHoldDown("1")
^!+F14::DebouncedHoldUp("1")
^!+F15::DebouncedHoldDown("2")
^!+F16::DebouncedHoldUp("2")
^!+F17::DebouncedHoldDown("3")
^!+F18::DebouncedHoldUp("3")
^!+F19::DebouncedHoldDown("4")
^!+F20::DebouncedHoldUp("4")
^!+F21::CoachBeacon("lock", "2", "enter")
^!+F22::CoachBeacon("lock", "0", "exit")
^!+F23::CoachBeacon("lock", "7", "enter")
^!+F24::CoachBeacon("lock", "0", "exit")
^!#F13::CoachBeacon("toggle", "8", "toggle")
^!#F14::CoachBeacon("toggle", "8", "off")
^!#F15::CoachBeacon("lock", "0", "exit")
^!#F16::CoachBeacon("hold", "8", "down")
^!#F17::CoachBeacon("hold", "8", "up")
^!#F18::CoachBeacon("toggle", "6", "toggle")
^!#F19::CoachBeacon("toggle", "6", "off")

#HotIf LauncherVisible
Enter::SubmitLauncher(false)
+Enter::SubmitLauncher(true)
Esc::HideLauncher()
#HotIf

; Norwegian ø/æ/å are direct on base layer (L0 11,2 / 12,2 / 12,1) via Windows Norwegian layout.
; F13-F15 are spare L4 macro keys — do not inject Norwegian letters here (conflicts with beacon chords).

; =========
; Input helpers
; =========
F16::SendSafe("Windows input switch", "#{Space}")
F17::SendSafe("Chinese/Pinyin IME toggle", "^{Space}")
F18::SendSafe("Japanese / next input method", "#{Space}")

; =========
; Optional global launch helpers
; =========
!F19::LaunchOrMoveApp("code", false)
!F20::RunSafe("Open PowerToys settings", "ms-settings:powertoys")
!F21::LaunchOrMoveApp("outlook", false)
!F22::LaunchOrMoveApp("teams", false)
!F23::LaunchOrMoveApp("edge", false)
!F24::LaunchOrMoveApp("m-files", false)

; =========
; VS Code
; =========
#HotIf WinActive("ahk_exe Code.exe")
F19::SendSafe("VS Code Quick Open", "^p")
F20::SendSafe("VS Code Command Palette", "^+p")
F21::SendSafe("VS Code Toggle Terminal", "^``")
F22::SendSafe("VS Code Toggle Sidebar", "^b")
F23::SendSafe("VS Code Explorer", "^+e")
F24::SendSafe("VS Code Search", "^+f")
#HotIf

; =========
; Edge + Vimium + Proton Pass
; =========
#HotIf WinActive("ahk_exe msedge.exe")
F19::SendSafe("Edge address bar", "^l")
F20::SendSafe("Edge search tabs", "^+a")
F21::SendSafe("Edge reopen closed tab", "^+t")
F22::SendSafe("Edge favorites", "^+o")
F23::SendSafe("Proton Pass helper", "^+y")
F24::SendSafe("Edge downloads", "^j")
#HotIf

; =========
; Excel
; =========
#HotIf WinActive("ahk_exe EXCEL.EXE")
F19::SendSafe("Excel edit cell", "{F2}")
F20::SendSafe("Excel repeat / absolute reference", "{F4}")
F21::SendSafe("Excel toggle filters", "^+l")
F22::SendSafe("Excel AutoSum", "!=")
F23::SendSafe("Excel previous sheet", "^{PgUp}")
F24::SendSafe("Excel next sheet", "^{PgDn}")
#HotIf

; =========
; Outlook
; =========
#HotIf WinActive("ahk_exe OUTLOOK.EXE") || WinActive("ahk_exe olk.exe") || WinActive("Outlook")
F19::SendSafe("Outlook new item", "^n")
F20::SendSafe("Outlook reply", "^r")
F21::SendSafe("Outlook reply all", "^+r")
F22::SendSafe("Outlook forward", "^f")
F23::SendSafe("Outlook search", "^e")
F24::SendSafe("Outlook mail view", "^1")
#HotIf

; =========
; Teams
; =========
#HotIf WinActive("ahk_exe ms-teams.exe") || WinActive("ahk_exe Teams.exe") || WinActive("Microsoft Teams")
F19::SendSafe("Teams search", "^e")
F20::SendSafe("Teams mute toggle", "^+m")
F21::SendSafe("Teams camera toggle", "^+o")
F22::SendSafe("Teams share tray", "^+e")
F23::SendSafe("Teams raise hand", "^+k")
F24::SendSafe("Teams open settings", "^,")
#HotIf

; =========
; M-Files
; =========
#HotIf WinActive("M-Files") || WinActive("ahk_exe MFStatus.exe") || WinActive("ahk_exe MFClient.exe")
F19::SendSafe("M-Files search", "^f")
F20::SendSafe("M-Files refresh", "{F5}")
F21::SendSafe("M-Files properties", "!{Enter}")
F22::SendSafe("M-Files back", "!{Left}")
F23::SendSafe("M-Files forward", "!{Right}")
F24::SendSafe("M-Files focus address/search", "^l")
#HotIf

; =========
; Generic fallback
; =========
#HotIf
F19::SendSafe("Generic app search", "^f")
F20::SendSafe("Generic command/menu search", "^+p")
F21::SendSafe("Generic clipboard history", "#v")
F22::SendSafe("Generic snipping tool", "#+s")
F23::SendSafe("Generic PowerToys Run", "#!{Space}")
F24::SendSafe("Generic refresh", "{F5}")

; Passive shortcut observer replaced by RegisterAllHooks() dynamic registration.
