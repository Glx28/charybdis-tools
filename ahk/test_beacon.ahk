#Requires AutoHotkey v2.0
; Quick test to verify beacon detection

; Simulate Layer 1 hold beacon
Send "^!+{F13}"
Sleep 500

; Simulate Layer 1 release beacon
Send "^!+{F14}"
Sleep 500

MsgBox "Sent Layer 1 hold and release beacons. Check charybdis_state.json for updates."
