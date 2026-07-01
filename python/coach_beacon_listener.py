"""
Charybdis coach beacon listener (Python / USB+BLE).

Swallows rare HID beacon chords (Ctrl+Alt+Shift/Win + F13-F24) emitted by
coach_* ZMK macros and writes runtime/charybdis_state.json for the web coach.

Use when AutoHotkey v2 is not installed. Requires admin on Windows for global hooks.
"""

from __future__ import annotations

import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

TOOLS_ROOT = Path(__file__).resolve().parent.parent
STATE_FILE = TOOLS_ROOT / "runtime" / "charybdis_state.json"
EVENT_LOG = TOOLS_ROOT / "runtime" / "charybdis_events.jsonl"
BEACON_LOG = TOOLS_ROOT / "runtime" / "charybdis_beacon.log"

# Maps beacon events to the physical key that triggers them (for coach highlight).
LAYER_KEY_HINTS: dict[tuple[str, str], dict[str, str]] = {
    ("hold", "1"): {"layer": "0", "x": "3", "y": "4", "label": "Nav"},
    ("hold", "2"): {"layer": "0", "x": "5", "y": "5", "label": "Mouse"},
    ("hold", "3"): {"layer": "0", "x": "8", "y": "4", "label": "Window"},
    ("hold", "4"): {"layer": "0", "x": "7", "y": "4", "label": "System"},
    ("hold", "5"): {"layer": "3", "x": "4", "y": "5", "label": "Layer 5"},
    ("hold", "6"): {"layer": "0", "x": "5", "y": "4", "label": "Layer 6"},
    ("hold", "8"): {"layer": "3", "x": "11", "y": "2", "label": "Speed"},
    ("lock", "2"): {"layer": "3", "x": "10", "y": "2", "label": "Mouse Lock"},
    ("lock", "7"): {"layer": "1", "x": "0", "y": "1", "label": "Game"},
    ("toggle", "5"): {"layer": "3", "x": "4", "y": "5", "label": "Layer 5"},
    ("toggle", "6"): {"layer": "2", "x": "12", "y": "2", "label": "Scroll"},
    ("toggle", "8"): {"layer": "3", "x": "11", "y": "2", "label": "Speed"},
    ("toggle", "9"): {"layer": "0", "x": "4", "y": "5", "label": "Layer 9"},
    ("toggle", "10"): {"layer": "6", "x": "7", "y": "4", "label": "Layer 10"},
    ("base", "0"): {"layer": "2", "x": "7", "y": "4", "label": "Base"},
    ("exit", "7"): {"layer": "7", "x": "7", "y": "4", "label": "Exit Base"},
    ("exit", "8"): {"layer": "8", "x": "7", "y": "4", "label": "Exit Travel"},
}


class CoachState:
    def __init__(self) -> None:
        import os

        self.held_layers: list[str] = []
        self.locked_layer = ""
        self.toggled_layers: list[str] = []
        self.displayed_layer = "0"
        self.last_action = "Beacon listener ready"
        self.last_key: dict[str, str] = {"layer": "", "x": "", "y": "", "label": ""}
        self.transport = "usb"
        self.beacon_pid = os.getpid()
        self.beacon_started_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    def active_layer(self) -> str:
        if "8" in self.toggled_layers:
            return "8"
        if self.locked_layer:
            return self.locked_layer
        if self.held_layers:
            return self.held_layers[-1]
        if self.toggled_layers:
            return self.toggled_layers[-1]
        return "0"

    def add_unique(self, items: list[str], value: str) -> None:
        if value not in items:
            items.append(value)

    def remove_value(self, items: list[str], value: str) -> None:
        while value in items:
            items.remove(value)

    def set_key_hint(self, kind: str, layer: str) -> None:
        hint = LAYER_KEY_HINTS.get((kind, layer))
        if hint:
            self.last_key = dict(hint)
        else:
            self.last_key = {"layer": "", "x": "", "y": "", "label": ""}

    def on_hold(self, layer: str, direction: str) -> None:
        layer = str(layer)
        if direction == "down":
            self.add_unique(self.held_layers, layer)
            self.last_action = f"Layer {layer} held"
            self.set_key_hint("hold", layer)
            self.displayed_layer = layer
        else:
            self.remove_value(self.held_layers, layer)
            self.displayed_layer = self.active_layer()
            self.last_action = f"Layer {layer} released"
            self.last_key = {"layer": "", "x": "", "y": "", "label": ""}

    def on_lock(self, layer: str, direction: str) -> None:
        layer = str(layer)
        if layer == "0" or direction == "exit":
            exiting = self.locked_layer or self.active_layer()
            self.locked_layer = ""
            self.held_layers = []
            self.toggled_layers = []
            self.displayed_layer = "0"
            self.last_action = "Base layer"
            hint = LAYER_KEY_HINTS.get(("exit", exiting)) or LAYER_KEY_HINTS.get(("base", "0"))
            self.last_key = dict(hint) if hint else {"layer": "", "x": "", "y": "", "label": ""}
        else:
            self.held_layers = []
            self.locked_layer = layer
            self.displayed_layer = layer
            self.last_action = f"Layer {layer} locked"
            self.set_key_hint("lock", layer)

    def on_toggle(self, layer: str, direction: str) -> None:
        layer = str(layer)
        if direction == "off" or layer in self.toggled_layers:
            self.remove_value(self.toggled_layers, layer)
            self.displayed_layer = self.active_layer()
            self.last_action = f"Layer {layer} toggled off"
            hint = LAYER_KEY_HINTS.get(("exit", layer)) if direction == "off" else None
            self.last_key = dict(hint) if hint else {"layer": "", "x": "", "y": "", "label": ""}
        else:
            self.add_unique(self.toggled_layers, layer)
            self.displayed_layer = layer
            self.last_action = f"Layer {layer} toggled on"
            self.set_key_hint("toggle", layer)

    def log(self, message: str) -> None:
        STATE_FILE.parent.mkdir(exist_ok=True)
        line = f"{datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')} {message}\n"
        with BEACON_LOG.open("a", encoding="utf-8") as fh:
            fh.write(line)

    def heartbeat(self) -> None:
        # Refresh updatedAt so the coach knows the listener is alive (do not clear held/locked state).
        self.write(False)

    def write(self, log_event: bool = True) -> None:
        STATE_FILE.parent.mkdir(exist_ok=True)
        import os

        now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        payload = {
            "activeLayer": self.active_layer(),
            "displayedLayer": self.displayed_layer,
            "heldLayers": list(self.held_layers),
            "lockedLayer": self.locked_layer,
            "toggledLayers": list(self.toggled_layers),
            "lastAction": self.last_action,
            "lastKey": dict(self.last_key),
            "activeApp": "Charybdis beacon listener",
            "launcherVisible": False,
            "transport": self.transport,
            "beaconAlive": True,
            "beaconSource": "python",
            "beaconPid": self.beacon_pid,
            "beaconStartedAt": self.beacon_started_at,
            "beaconHeartbeatAt": now,
            "updatedAt": now,
        }
        text = json.dumps(payload, ensure_ascii=False)
        tmp = STATE_FILE.with_suffix(STATE_FILE.suffix + ".tmp")
        for attempt in range(8):
            try:
                tmp.write_text(text, encoding="utf-8")
                os.replace(tmp, STATE_FILE)
                break
            except OSError:
                if attempt == 7:
                    raise
                time.sleep(0.025)
        if log_event:
            with EVENT_LOG.open("a", encoding="utf-8") as fh:
                fh.write(text + "\n")
            self.log(self.last_action)


def register_beacons(state: CoachState) -> None:
    import keyboard

    MOD_SCANCODES: dict[str, int] = {29: "ctrl", 42: "shift", 56: "alt"}
    WIN_SCANCODES: set[int] = set()
    for sc in keyboard.key_to_scan_codes("left windows", False):
        WIN_SCANCODES.add(sc)
    for sc in keyboard.key_to_scan_codes("right windows", False):
        WIN_SCANCODES.add(sc)

    # F13=100 .. F24=111
    CTRL_ALT_SHIFT: dict[int, object] = {
        100: lambda: state.on_hold("1", "down"),
        101: lambda: state.on_hold("1", "up"),
        102: lambda: state.on_hold("2", "down"),
        103: lambda: state.on_hold("2", "up"),
        104: lambda: state.on_hold("3", "down"),
        105: lambda: state.on_hold("3", "up"),
        106: lambda: state.on_hold("4", "down"),
        107: lambda: state.on_hold("4", "up"),
        108: lambda: state.on_lock("2", "enter"),
        109: lambda: state.on_lock("0", "exit"),
        110: lambda: state.on_lock("7", "enter"),
        111: lambda: state.on_lock("0", "exit"),
    }
    CTRL_ALT_WIN: dict[int, object] = {
        100: lambda: state.on_toggle("8", "toggle"),
        101: lambda: state.on_toggle("8", "off"),
        102: lambda: state.on_lock("0", "exit"),
        103: lambda: state.on_hold("8", "down"),
        104: lambda: state.on_hold("8", "up"),
        105: lambda: state.on_toggle("6", "toggle"),
        106: lambda: state.on_toggle("6", "off"),
        107: lambda: state.on_hold("5", "down"),
        108: lambda: state.on_hold("5", "up"),
        109: lambda: state.on_hold("6", "down"),
        110: lambda: state.on_hold("6", "up"),
    }
    CTRL_ALT_SHIFT_WIN: dict[int, object] = {
        100: lambda: state.on_toggle("5", "toggle"),
        101: lambda: state.on_toggle("6", "toggle"),
        102: lambda: state.on_toggle("9", "toggle"),
        103: lambda: state.on_toggle("10", "toggle"),
    }

    mods: dict[str, bool] = {"ctrl": False, "shift": False, "alt": False, "win": False}

    def on_event(event: keyboard.KeyboardEvent) -> None:
        sc = event.scan_code
        down = event.event_type == keyboard.KEY_DOWN

        mod = MOD_SCANCODES.get(sc)
        if mod:
            mods[mod] = down
            return
        if sc in WIN_SCANCODES:
            mods["win"] = down
            return

        if not down or sc < 100 or sc > 111:
            return

        fn = None
        if mods["ctrl"] and mods["alt"] and mods["shift"] and not mods["win"]:
            fn = CTRL_ALT_SHIFT.get(sc)
        elif mods["ctrl"] and mods["alt"] and mods["win"] and not mods["shift"]:
            fn = CTRL_ALT_WIN.get(sc)
        elif mods["ctrl"] and mods["alt"] and mods["shift"] and mods["win"]:
            fn = CTRL_ALT_SHIFT_WIN.get(sc)

        if fn:
            fn()
            state.write(True)

    keyboard.hook(on_event)


def main() -> int:
    try:
        import keyboard
    except ImportError:
        print("Missing dependency: pip install keyboard", file=sys.stderr)
        return 1

    state = CoachState()
    state.write(False)
    state.log("Python beacon listener started")
    register_beacons(state)
    print("Charybdis beacon listener active. Press coach layer keys on the keyboard.", file=sys.stderr)
    print(f"State file: {STATE_FILE}", file=sys.stderr)
    print(f"Beacon log: {BEACON_LOG}", file=sys.stderr)

    def pump_heartbeat() -> None:
        while True:
            time.sleep(5)
            state.heartbeat()

    import threading

    threading.Thread(target=pump_heartbeat, daemon=True).start()
    keyboard.wait()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("\nBeacon listener stopped.", file=sys.stderr)
