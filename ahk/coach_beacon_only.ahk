#Requires AutoHotkey v2.0
#SingleInstance Force
; Minimal layer-beacon listener for the web coach. No GUI, no launcher — stays resident.

global RepoRoot := RegExReplace(A_ScriptDir, "\\scripts\\windows$")
global RuntimeDir := RepoRoot "\runtime"
global StatePath := RuntimeDir "\charybdis_state.json"
global EventLogPath := RuntimeDir "\charybdis_events.jsonl"
global BeaconLogPath := RuntimeDir "\charybdis_beacon.log"
global HelperConfigPath := RepoRoot "\config\charybdis_helper.json"

global CurrentCoachLayer := "0"
global LastAction := "Beacon listener ready"
global LastKey := Map("layer", "", "x", "", "y", "", "label", "")
global HeldLayers := []
global LockedLayer := ""
global ToggledLayers := []
global Transport := "usb"

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
    try {
        return WinGetProcessName("A") " - " WinGetTitle("A")
    } catch {
        return ""
    }
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
    }
    return Map()
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
        '"beaconPid":' A_PID "," .
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