#Requires AutoHotkey v2.0
#SingleInstance Force
; Minimal layer-beacon listener for the web coach. No GUI, no launcher — stays resident.

global ToolsRoot := RegExReplace(A_ScriptDir, "\\[^\\]+$")
global ZmkConfigRoot := ToolsRoot "\..\charybdis-zmk-config"
global RuntimeDir := ToolsRoot "\runtime"
global StatePath := RuntimeDir "\charybdis_state.json"
global EventLogPath := RuntimeDir "\charybdis_events.jsonl"
global BeaconLogPath := RuntimeDir "\charybdis_beacon.log"
global HelperConfigPath := ZmkConfigRoot "\config\charybdis_helper.json"
global LayoutCsvPath := ZmkConfigRoot "\layout\keybindings_explained.csv"

global CurrentCoachLayer := "0"
global LastAction := "Beacon listener ready"
global LastKey := Map("layer", "", "x", "", "y", "", "label", "")
global HeldLayers := []
global LockedLayer := ""
global ToggledLayers := []
global Transport := "usb"
global LastUserAppLabel := ""
global LayoutRows := LoadLayoutRows()

if !DirExist(RuntimeDir) {
    DirCreate(RuntimeDir)
}
LoadTransport()
BeaconLog("AHK beacon listener started")
WriteCoachState(false)
SetTimer(WriteCoachStateHeartbeat, 5000)

WriteCoachStateHeartbeat() {
    WriteCoachState(false)
}

TraySetIcon("shell32.dll", 44)
A_IconTip := "Charybdis beacon listener"
A_TrayMenu.Delete()
A_TrayMenu.Add("Reload", (*) => Reload())
A_TrayMenu.Add("Exit", (*) => ExitApp())

LoadTransport() {
    global Transport, HelperConfigPath
    if !FileExist(HelperConfigPath) {
        return
    }
    text := FileRead(HelperConfigPath, "UTF-8")
    if RegExMatch(text, '"transport"\s*:\s*"(?<v>[^"]+)"', &m) {
        Transport := m["v"]
    }
}

ActiveAppLabel() {
    global LastUserAppLabel
    try {
        title := WinGetTitle("A")
        exe := WinGetProcessName("A")
        if IsIgnoredActiveApp(exe, title) {
            return LastUserAppLabel
        }
        LastUserAppLabel := exe " - " title
        return LastUserAppLabel
    } catch {
        return LastUserAppLabel
    }
}

IsIgnoredActiveApp(exe, title) {
    exeLower := StrLower(String(exe))
    titleLower := StrLower(String(title))
    if exeLower = "" {
        return true
    }
    if InStr(exeLower, "autohotkey") || InStr(titleLower, "charybdis launcher") || InStr(titleLower, "charybdis helpers") {
        return true
    }
    if InStr(titleLower, "charybdis beacon") || InStr(titleLower, "beacon listener") {
        return true
    }
    if InStr(titleLower, "charybdis coach") {
        return true
    }
    return false
}

JsonEscape(value) {
    text := String(value)
    text := StrReplace(text, "\", "\\")
    text := StrReplace(text, '"', '\"')
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
    return "{" .
        '"layer":' JsonStringValue(key.Has("layer") ? key["layer"] : "") "," .
        '"x":' JsonStringValue(key.Has("x") ? key["x"] : "") "," .
        '"y":' JsonStringValue(key.Has("y") ? key["y"] : "") "," .
        '"label":' JsonStringValue(key.Has("label") ? key["label"] : "") .
        "}"
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

HasArrayValue(list, value) {
    for item in list {
        if item = value {
            return true
        }
    }
    return false
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

LayerKeyHint(kind, layer) {
    global LayoutRows
    layer := String(layer)
    behavior := CoachBehaviorForAccess(kind, layer)
    if behavior {
        for row in LayoutRows {
            if row.Has("behavior") && row["behavior"] = behavior {
                return Map(
                    "layer", row.Has("layer") ? row["layer"] : "",
                    "x", row.Has("x") ? row["x"] : "",
                    "y", row.Has("y") ? row["y"] : "",
                    "label", row.Has("visual_label") && row["visual_label"] ? row["visual_label"] : behavior
                )
            }
        }
    }
    return Map()
}

CoachBehaviorForAccess(kind, layer) {
    layer := String(layer)
    if kind = "hold" {
        switch layer {
            case "1": return "coach_l1_hold"
            case "2": return "coach_l2_hold"
            case "3": return "coach_l3_hold"
            case "4": return "coach_l4_hold"
            case "5": return "coach_l5_hold"
            case "6": return "coach_l6_hold"
            case "7": return "coach_l7_hold"
            case "8": return "coach_l8_hold"
            case "9": return "coach_l9_hold"
            case "10": return "coach_l10_hold"
        }
    } else if kind = "lock" {
        switch layer {
            case "2": return "coach_mouse_lock"
            case "7": return "coach_game_lock"
        }
    } else if kind = "toggle" {
        switch layer {
            case "1": return "coach_l1_toggle"
            case "2": return "coach_l2_toggle"
            case "3": return "coach_l3_toggle"
            case "4": return "coach_l4_toggle"
            case "5": return "coach_l5_toggle"
            case "6": return "coach_l6_toggle"
            case "7": return "coach_l7_toggle"
            case "8": return "coach_l8_toggle"
            case "9": return "coach_l9_toggle"
            case "10": return "coach_l10_toggle"
        }
    } else if kind = "base" || kind = "exit" {
        return "coach_base"
    }
    return ""
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

BeaconLog(message) {
    global BeaconLogPath
    line := FormatTime(A_NowUTC, "yyyy-MM-ddTHH:mm:ss") "Z " message "`n"
    try FileAppend(line, BeaconLogPath, "UTF-8")
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

WriteCoachState(logEvent := false) {
    global StatePath, EventLogPath, CurrentCoachLayer, LastAction, LastKey
    global HeldLayers, LockedLayer, ToggledLayers, Transport
    activeLayer := CoachActiveLayer()
    if (HeldLayers.Length = 0 && !LockedLayer && ToggledLayers.Length = 0) {
        CurrentCoachLayer := activeLayer
    }
    timestamp := FormatTime(A_NowUTC, "yyyy-MM-ddTHH:mm:ss") "Z"
    pid := ProcessExist()
    json := "{" .
        '"activeLayer":' JsonStringValue(activeLayer) "," .
        '"displayedLayer":' JsonStringValue(CurrentCoachLayer) "," .
        '"heldLayers":' JsonArrayValue(HeldLayers) "," .
        '"lockedLayer":' JsonStringValue(LockedLayer) "," .
        '"toggledLayers":' JsonArrayValue(ToggledLayers) "," .
        '"lastAction":' JsonStringValue(LastAction) "," .
        '"lastKey":' JsonKeyObject(LastKey) "," .
        '"activeApp":' JsonStringValue(ActiveAppLabel()) "," .
        '"launcherVisible":false,' .
        '"transport":' JsonStringValue(Transport) "," .
        '"beaconAlive":true,' .
        '"beaconSource":"ahk-beacon",' .
        '"beaconPid":' pid "," .
        '"beaconHeartbeatAt":' JsonStringValue(timestamp) "," .
        '"updatedAt":' JsonStringValue(timestamp) .
        "}"
    AtomicWriteText(StatePath, json)
    if logEvent {
        FileAppend(json "`r`n", EventLogPath, "UTF-8")
    }
}

CoachBeacon(kind, layer, direction) {
    global CurrentCoachLayer, HeldLayers, LockedLayer, ToggledLayers, LastKey, LastAction
    layer := String(layer)
    switch kind {
        case "hold":
            if direction = "down" {
                AddUniqueLayer(HeldLayers, layer)
                hint := LayerKeyHint("hold", layer)
                LastKey := hint.Count ? hint : Map("layer", "", "x", "", "y", "", "label", "")
                CurrentCoachLayer := layer
                LastAction := "BLE layer " layer " held"
            } else {
                RemoveLayer(HeldLayers, layer)
                CurrentCoachLayer := CoachActiveLayer()
                LastKey := Map("layer", "", "x", "", "y", "", "label", "")
                LastAction := "BLE layer " layer " released"
            }
        case "lock":
            if layer = "0" || direction = "exit" {
                LockedLayer := ""
                HeldLayers := []
                ToggledLayers := []
                CurrentCoachLayer := "0"
                hint := LayerKeyHint("base", "0")
                LastKey := hint.Count ? hint : Map("layer", "", "x", "", "y", "", "label", "")
                LastAction := "BLE base layer"
            } else {
                HeldLayers := []
                LockedLayer := layer
                hint := LayerKeyHint("lock", layer)
                LastKey := hint.Count ? hint : Map("layer", "", "x", "", "y", "", "label", "")
                CurrentCoachLayer := layer
                LastAction := "BLE layer " layer " locked"
            }
        case "toggle":
            if direction = "off" || HasArrayValue(ToggledLayers, layer) {
                RemoveLayer(ToggledLayers, layer)
                CurrentCoachLayer := CoachActiveLayer()
                LastAction := "BLE layer " layer " toggled off"
            } else {
                AddUniqueLayer(ToggledLayers, layer)
                CurrentCoachLayer := layer
                LastAction := "BLE layer " layer " toggled on"
            }
    }
    BeaconLog(LastAction)
    WriteCoachState(true)
}

^!+F13::CoachBeacon("hold", "1", "down")
^!+F14::CoachBeacon("hold", "1", "up")
^!+F15::CoachBeacon("hold", "2", "down")
^!+F16::CoachBeacon("hold", "2", "up")
^!+F17::CoachBeacon("hold", "3", "down")
^!+F18::CoachBeacon("hold", "3", "up")
^!+F19::CoachBeacon("hold", "4", "down")
^!+F20::CoachBeacon("hold", "4", "up")
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
^!#F20::CoachBeacon("hold", "5", "down")
^!#F21::CoachBeacon("hold", "5", "up")
^!#F22::CoachBeacon("hold", "6", "down")
^!#F23::CoachBeacon("hold", "6", "up")
^+#F13::CoachBeacon("hold", "7", "down")
^+#F14::CoachBeacon("hold", "7", "up")
^+#F15::CoachBeacon("hold", "9", "down")
^+#F16::CoachBeacon("hold", "9", "up")
^+#F17::CoachBeacon("hold", "10", "down")
^+#F18::CoachBeacon("hold", "10", "up")
^!+#F13::CoachBeacon("toggle", "1", "toggle")
^!+#F14::CoachBeacon("toggle", "2", "toggle")
^!+#F15::CoachBeacon("toggle", "3", "toggle")
^!+#F16::CoachBeacon("toggle", "4", "toggle")
^!+#F17::CoachBeacon("toggle", "5", "toggle")
^!+#F18::CoachBeacon("toggle", "6", "toggle")
^!+#F19::CoachBeacon("toggle", "7", "toggle")
^!+#F20::CoachBeacon("toggle", "8", "toggle")
^!+#F21::CoachBeacon("toggle", "9", "toggle")
^!+#F22::CoachBeacon("toggle", "10", "toggle")
