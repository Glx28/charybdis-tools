"""
USB Serial State Monitor for Charybdis Keyboard

Reads keyboard state from ZMK CDC-ACM serial port and updates
the coach state file for real-time UI updates.

This is the USB-first implementation - Bluetooth beacon version is WIP.
"""

import json
import time
import sys
from pathlib import Path
from datetime import datetime, timezone
import serial
import serial.tools.list_ports

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
STATE_FILE = REPO_ROOT / "runtime" / "charybdis_state.json"
RUNTIME_DIR = REPO_ROOT / "runtime"

# ZMK USB identifiers for Nice!Nano / ZMK devices
ZMK_VID = 0x1D50  # OpenMoko
ZMK_PID = 0x615E  # ZMK

def find_zmk_port():
    """Find the ZMK CDC-ACM serial port"""
    ports = serial.tools.list_ports.comports()
    for port in ports:
        if port.vid == ZMK_VID and port.pid == ZMK_PID:
            return port.device
    return None

def get_current_state():
    """Read current state from file or return default"""
    try:
        if STATE_FILE.exists():
            with open(STATE_FILE, 'r', encoding='utf-8') as f:
                # Remove BOM if present
                content = f.read()
                if content.startswith('\ufeff'):
                    content = content[1:]
                return json.loads(content)
    except:
        pass

    return {
        "activeLayer": "0",
        "displayedLayer": "0",
        "heldLayers": [],
        "lockedLayer": "",
        "toggledLayers": [],
        "lastAction": "USB Connected",
        "lastKey": {"layer": "", "x": "", "y": "", "label": ""},
        "activeApp": "Unknown",
        "launcherVisible": False,
        "transport": "usb",
        "updatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    }

def update_state(changes):
    """Update state file with new changes"""
    state = get_current_state()
    state.update(changes)
    state["updatedAt"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    state["transport"] = "usb"

    RUNTIME_DIR.mkdir(exist_ok=True)
    # Write with BOM for compatibility with existing AHK reader
    with open(STATE_FILE, 'w', encoding='utf-8-sig') as f:
        json.dump(state, f, ensure_ascii=False)

def parse_zmk_console_line(line):
    """
    Parse ZMK console output for layer changes.

    ZMK logs lines like:
    [00:01:23.456,789] <inf> zmk: layer_state_changed: layer 1 activated
    [00:01:24.123,456] <inf> zmk: layer_state_changed: layer 1 deactivated
    """
    changes = {}

    # Simple pattern matching for layer state
    if "layer" in line.lower():
        # Try to extract layer number
        import re

        # Pattern: "layer X activated" or "layer X"
        match = re.search(r'layer[:\s]+(\d+)', line.lower())
        if match:
            layer_num = match.group(1)

            if "deactivate" in line.lower() or "release" in line.lower():
                changes["activeLayer"] = "0"
                changes["displayedLayer"] = "0"
                changes["heldLayers"] = []
                changes["lastAction"] = f"Released Layer {layer_num}"
            elif "activate" in line.lower() or "hold" in line.lower() or "momentary" in line.lower():
                changes["activeLayer"] = layer_num
                changes["displayedLayer"] = layer_num
                changes["heldLayers"] = [int(layer_num)]
                changes["lastAction"] = f"Holding Layer {layer_num}"
            elif "lock" in line.lower() or "to layer" in line.lower():
                changes["activeLayer"] = layer_num
                changes["displayedLayer"] = layer_num
                changes["lockedLayer"] = layer_num
                changes["heldLayers"] = []
                changes["lastAction"] = f"Locked to Layer {layer_num}"
            elif "toggle" in line.lower():
                changes["toggledLayers"] = [int(layer_num)]
                changes["lastAction"] = f"Toggled Layer {layer_num}"

    return changes

def monitor_serial(port_name, verbose=False):
    """Monitor the serial port for keyboard state changes"""
    print(f"Connecting to {port_name}...", file=sys.stderr)

    try:
        ser = serial.Serial(
            port=port_name,
            baudrate=115200,
            timeout=1,
            write_timeout=1
        )

        print(f"Connected to ZMK keyboard on {port_name}", file=sys.stderr)
        print("Monitoring for layer changes... (Ctrl+C to stop)", file=sys.stderr)

        # Initial state
        update_state({"lastAction": "USB Monitor Active", "transport": "usb"})

        buffer = ""
        last_update = time.time()

        while True:
            if ser.in_waiting:
                try:
                    chunk = ser.read(ser.in_waiting).decode('utf-8', errors='ignore')
                    buffer += chunk

                    # Process complete lines
                    while '\n' in buffer:
                        line, buffer = buffer.split('\n', 1)
                        line = line.strip()

                        if verbose and line:
                            print(f"[ZMK] {line}", file=sys.stderr)

                        # Parse for layer changes
                        changes = parse_zmk_console_line(line)
                        if changes:
                            update_state(changes)
                            if verbose:
                                print(f"State updated: {changes}", file=sys.stderr)

                except UnicodeDecodeError:
                    # Ignore binary data
                    pass

            # Periodic heartbeat to show we're alive
            now = time.time()
            if now - last_update > 5:
                update_state({})  # Just update timestamp
                last_update = now

            time.sleep(0.05)  # 50ms polling

    except serial.SerialException as e:
        print(f"Serial error: {e}", file=sys.stderr)
        update_state({"lastAction": "USB Disconnected", "activeLayer": "0", "displayedLayer": "0"})
        return False

    return True

def main():
    verbose = "--verbose" in sys.argv or "-v" in sys.argv

    print("ZMK USB State Monitor", file=sys.stderr)
    print("=" * 40, file=sys.stderr)

    while True:
        port = find_zmk_port()

        if not port:
            print("Waiting for ZMK keyboard (USB)...", file=sys.stderr)
            update_state({
                "lastAction": "Waiting for USB connection",
                "activeLayer": "0",
                "displayedLayer": "0",
                "transport": "usb"
            })
            time.sleep(2)
            continue

        print(f"Found ZMK device at {port}", file=sys.stderr)

        if not monitor_serial(port, verbose=verbose):
            print("Connection lost. Reconnecting...", file=sys.stderr)
            time.sleep(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nMonitor stopped.", file=sys.stderr)
        update_state({"lastAction": "Monitor stopped"})
