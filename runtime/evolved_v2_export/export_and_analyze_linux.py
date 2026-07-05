"""Linux-compatible V2 evolved layout exporter and analyzer.

Reads a v2 checkpoint, merges evolved changes with canonical base, and
generates ZMK Studio scripts, CSV, diff, and metadata.

Does not require the Windows venv or optimizer Python modules.
"""
import json
import os
import re
import csv
import sys
import argparse
import subprocess
from pathlib import Path
from collections import defaultdict, Counter
from datetime import datetime

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
DEFAULT_BUILD_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/build")
DEFAULT_DATA_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/data")
DEFAULT_OUT_DIR = Path("/home/nos/charybdis/charybdis-tools/runtime/evolved_v2_export")
DEFAULT_APPLY_TEMPLATE = Path("/home/nos/charybdis/charybdis-zmk-config/scripts/zmk-studio/apply_every_key.js")
DEFAULT_OPTIMIZER_ROOT = Path("/home/nos/charybdis/charybdis-optimizer-v2")
DEFAULT_OPTIMIZER_PYTHON = DEFAULT_OPTIMIZER_ROOT / ".venv" / "bin" / "python"

# ---------------------------------------------------------------------------
# Modifier mapping for ZMK Studio
# ---------------------------------------------------------------------------
MOD_MAP = {
    "Ctrl": "L Ctrl",
    "Shift": "L Shift",
    "Alt": "L Alt",
    "Win": "L GUI",
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
RAW_KEY_ALIASES = {
    "escape": "escape", "esc": "escape",
    "delete": "delete", "bksp": "delete", "backspace": "delete",
    "tab": "tab",
    "space": "spacebar", "spacebar": "spacebar",
    "enter": "returnenter", "return": "returnenter", "return enter": "returnenter",
    "leftshift": "leftshift", "rightshift": "rightshift", "shift": "leftshift",
    "leftcontrol": "leftcontrol", "rightcontrol": "rightcontrol", "ctrl": "leftcontrol",
    "leftalt": "leftalt", "rightalt": "rightalt", "alt": "leftalt",
    "left gui": "leftgui", "leftgui": "leftgui",
    "comma": ",", "comma and lessthan": ",",
    "period": ".", "period and greaterthan": ".",
    "forwardslash": "/", "forwardslash and questionmark": "/",
    "backslash": "\\", "backslash and pipe": "\\",
    "semicolon": ";", "semicolon and colon": ";",
    "left apos": "'", "left apos and double": "'", "apostrophe": "'",
    "left brace": "[", "right brace": "]",
}

L0_FROZEN_THUMB_RAW_KEYS = {"spacebar", "returnenter"}
LITERAL_TO_HID_PARAMETER = {
    "!": "1 and Bang", "@": "2 and At", "#": "3 and Hash", "$": "4 and Dollar",
    "%": "5 and Percent", "^": "6 and Caret", "&": "7 and Ampersand", "*": "8 and Star",
    "(": "9 and Left Bracket", ")": "0 and Right Bracket",
    "-": "Dash and Underscore", "_": "Dash and Underscore",
    "=": "Equals and Plus", "+": "Equals and Plus",
    "`": "Grave Accent and Tilde", "~": "Grave Accent and Tilde",
    "[": "Left Brace", "]": "Right Brace", "\\": "Backslash and Pipe", "|": "Backslash and Pipe",
    ";": "SemiColon and Colon", ":": "SemiColon and Colon",
    "'": "Left Apos and Double", '"': "Left Apos and Double",
    ",": "Comma and LessThan", "<": "Comma and LessThan",
    ".": "Period and GreaterThan", ">": "Period and GreaterThan",
    "/": "ForwardSlash and QuestionMark", "?": "ForwardSlash and QuestionMark",
}
KEY_TOKEN_ALIASES = {
    "Del": "Delete", "Backspace": "Delete", "BkSp": "Delete",
    "Enter": "Return Enter", "Return": "Return Enter", "Space": "Spacebar", "Esc": "Escape",
    "Page Up": "PageUp", "PgUp": "PageUp", "Page Down": "PageDown", "PgDn": "PageDown",
}
MULTIWORD_BASE_KEYS = (
    "Middle Click",
    "Right Click",
    "Left Click",
    "Page Down", "Page Up", "Return Enter", "Left Brace", "Right Brace",
    "Dash and Underscore", "Equals and Plus", "Grave Accent and Tilde",
    "Backslash and Pipe", "SemiColon and Colon", "Left Apos and Double",
    "Comma and LessThan", "Period and GreaterThan", "ForwardSlash and QuestionMark",
)
NON_EXPORTABLE_SEQUENCE_KEYS = {"Ctrl+K S", "gg", "gi", "yy"}
NON_EXPORTABLE_BASE_KEYS = {"ScrollUp", "ScrollDown", "Pause"}
MOUSE_CLICK_BASE_KEYS = {"Click", "Left Click", "Right Click", "Middle Click"}

COACH_LAYER_ACCESS = {
    ("hold", 1): "coach_l1_hold",
    ("hold", 2): "coach_l2_hold",
    ("hold", 3): "coach_l3_hold",
    ("hold", 4): "coach_l4_hold",
    ("hold", 5): "coach_l5_hold",
    ("hold", 6): "coach_l6_hold",
    ("hold", 7): "coach_l7_hold",
    ("hold", 8): "coach_l8_hold",
    ("hold", 9): "coach_l9_hold",
    ("hold", 10): "coach_l10_hold",
    ("hold", 11): "coach_l11_hold",
    ("toggle", 0): "coach_base",
    ("toggle", 1): "coach_l1_toggle",
    ("toggle", 2): "coach_l2_toggle",
    ("toggle", 3): "coach_l3_toggle",
    ("toggle", 4): "coach_l4_toggle",
    ("toggle", 5): "coach_l5_toggle",
    ("toggle", 6): "coach_l6_toggle",
    ("toggle", 7): "coach_l7_toggle",
    ("toggle", 8): "coach_l8_toggle",
    ("toggle", 9): "coach_l9_toggle",
    ("toggle", 10): "coach_l10_toggle",
    ("to", 0): "coach_base",
    ("to", 2): "coach_mouse_lock",
    ("to", 7): "coach_game_lock",
    ("to", 8): "coach_travel_toggle",
}

COACH_STUDIO_BEHAVIORS = [
    "coach_l1_hold", "coach_l2_hold", "coach_l3_hold", "coach_l4_hold", "coach_l5_hold",
    "coach_l6_hold", "coach_l7_hold", "coach_l8_hold", "coach_l9_hold", "coach_l10_hold", "coach_l11_hold",
    "coach_l1_toggle", "coach_l2_toggle", "coach_l3_toggle", "coach_l4_toggle", "coach_l5_toggle",
    "coach_l6_toggle", "coach_l7_toggle", "coach_l8_toggle", "coach_l9_toggle", "coach_l10_toggle",
    "coach_mouse_lock", "coach_game_lock", "coach_base", "coach_travel_toggle",
    "coach_travel_off", "coach_recover_base",
    "coach_ctrl_click", "coach_shift_click", "coach_alt_click",
]


def canonical_hid_parameter(token):
    value = str(token or "").strip()
    if value.startswith("Keyboard "):
        value = value[len("Keyboard "):].strip()
    if value in KEY_TOKEN_ALIASES:
        return KEY_TOKEN_ALIASES[value]
    if value in LITERAL_TO_HID_PARAMETER:
        return LITERAL_TO_HID_PARAMETER[value]
    return value


def coach_behavior_for_layer_access(action, target):
    # v2 optimizer emits full strings like "Momentary Layer 4" / "Toggle Layer 3"
    action_key = str(action or "").strip().lower()
    if action_key.startswith("scroll mode layer"):
        # All scroll shortcuts export as &mo 11 (L11 is the dedicated scroll mode layer).
        # L11 is listed in scroll-layers in charybdis_right.overlay so PMW3610 activates
        # scroll mode when it is active. L11 is all-transparent, so the current layer's
        # bindings remain visible. This makes every layer's @scroll:LX:hold work correctly
        # without jumping away from the active layer.
        return COACH_LAYER_ACCESS.get(("hold", 11))
    elif action_key.startswith("momentary layer"):
        mode = "hold"
    elif action_key.startswith("toggle layer") or action_key == "return to base":
        mode = "toggle"
    elif action_key.startswith("to layer"):
        mode = "to"
    else:
        return None
    try:
        target_int = int(target)
    except (TypeError, ValueError):
        return None
    return COACH_LAYER_ACCESS.get((mode, target_int))


def _normalize_raw_key_id(value):
    if value is None:
        return None
    clean = str(value).strip()
    if not clean:
        return None
    clean = clean.replace("Keyboard ", "").replace("keyboard ", "")
    clean = clean.split(" and ")[0] if " and " in clean and clean[:1].isdigit() else clean
    lowered = clean.lower().strip()
    if lowered in RAW_KEY_ALIASES:
        return RAW_KEY_ALIASES[lowered]
    if len(clean) == 1:
        return clean.lower()
    if clean.isdigit():
        return clean
    if re.fullmatch(r"f\d{1,2}", lowered):
        return lowered
    return None


def _permanent_l0_raw_keys(canonical_data):
    permanent = {}
    l0_keys = canonical_data.get("layers", {}).get("0", {}).get("keys", {})
    for key_data in l0_keys.values():
        if key_data.get("behavior", "").lower() != "key press":
            continue
        if key_data.get("modifiers"):
            continue
        key_id = _normalize_raw_key_id(key_data.get("parameter", ""))
        if key_id is None:
            key_id = _normalize_raw_key_id(key_data.get("label", ""))
        try:
            y = float(key_data.get("y", 0))
        except (TypeError, ValueError):
            continue
        is_main_l0_key = 0 <= y <= 3
        is_frozen_thumb_exception = key_id in L0_FROZEN_THUMB_RAW_KEYS
        if not is_main_l0_key and not is_frozen_thumb_exception:
            continue
        if key_id is not None:
            permanent[key_id] = key_data.get("label") or key_data.get("parameter") or key_id
    return permanent


def load_shortcuts(data_dir: Path):
    """Load app_shortcut_scores.json and build Shortcut dicts."""
    data = json.loads((data_dir / "app_shortcut_scores.json").read_text(encoding="utf-8"))
    can = json.loads((data_dir / "canonical.json").read_text(encoding="utf-8"))
    shortcuts = []
    seen_keys = set()

    for key_id, label in sorted(_permanent_l0_raw_keys(can).items()):
        shortcuts.append({
            "sid": len(shortcuts),
            "keys": f"_base_{key_id}",
            "action": "Base typing key for the permanent L0 layout.",
            "app": "Base",
            "importance": 0.0,
            "category": "base",
            "modifiers": [],
            "base_key": label,
            "is_l0_only": True,
            "preferred_hand": "either",
        })

    for app_data in data.get("apps", []):
        app_name = app_data.get("name", "unknown")
        for sc_data in app_data.get("shortcuts", []):
            keys = sc_data.get("keys", "")
            if keys in seen_keys:
                continue
            seen_keys.add(keys)

            base_key = canonical_hid_parameter(sc_data.get("base_key", ""))
            if not base_key:
                _, base_key = parse_shortcut_keys(keys)

            modifiers, parsed_base = parse_shortcut_keys(keys)
            if parsed_base:
                base_key = parsed_base

            raw_key_id = _normalize_raw_key_id(base_key) if not modifiers and "+" not in keys else None
            if raw_key_id is not None and raw_key_id in _permanent_l0_raw_keys(can):
                continue

            shortcuts.append({
                "sid": len(shortcuts),
                "keys": keys,
                "action": sc_data.get("action", ""),
                "app": app_name,
                "importance": float(sc_data.get("importance", 5.0)),
                "category": sc_data.get("category", "general"),
                "modifiers": modifiers,
                "base_key": base_key,
                "is_capability": sc_data.get("is_capability", False),
                "is_l0_only": sc_data.get("is_l0_only", False),
                "complexity": int(sc_data.get("complexity", 1)),
                "preferred_hand": sc_data.get("preferred_hand", "either"),
            })
    return shortcuts


def load_positions(data_dir: Path):
    """Load canonical.json and return a flat list of position dicts."""
    can = json.loads((data_dir / "canonical.json").read_text(encoding="utf-8"))
    positions = []
    grid = can.get("physical_grid", {}).get("positions", [])
    layers = can.get("layers", {})

    for layer_id, layer_data in layers.items():
        if not layer_id or not layer_id.strip():
            continue
        layer = int(layer_id)
        for coord, binding in layer_data.get("keys", {}).items():
            x_str, y_str = coord.split(":")
            x, y = int(x_str), int(y_str)
            grid_entry = next(
                (p for p in grid if p.get("x") == x and p.get("y") == y),
                {"hand": "left" if x < 6 else "right", "zone": "unknown", "finger": "unknown", "row_type": "unknown"},
            )
            positions.append({
                "layer": layer,
                "x": x,
                "y": y,
                "coord": coord,
                "hand": grid_entry.get("hand", "left" if x < 6 else "right"),
                "is_thumb": grid_entry.get("zone") == "thumb",
                "is_frozen": binding.get("frozen", False),
                "behavior": binding.get("behavior", ""),
                "label": binding.get("label", ""),
                "parameter": binding.get("parameter", ""),
                "modifiers": binding.get("modifiers", []),
                "purpose": binding.get("purpose", ""),
                "effort": float(grid_entry.get("effort", 0)) if "effort" in grid_entry else _effort_from_xy(x, y),
            })
    return positions


def load_optimizer_layout_snapshot(data_dir: Path):
    """Load positions/shortcuts using the optimizer's own loader when available."""
    if not DEFAULT_OPTIMIZER_PYTHON.exists():
        return None
    script = r"""
import json
import sys
from core.loader import build_layout

layout = build_layout(sys.argv[1])
positions = []
for pos in layout.positions:
    positions.append({
        "layer": int(pos.layer),
        "x": int(pos.x),
        "y": int(pos.y),
        "hand": pos.hand,
        "is_thumb": bool(pos.is_thumb),
        "is_frozen": bool(pos.is_frozen),
        "effort": float(pos.effort),
    })

shortcuts = []
for sc in layout.shortcuts:
    shortcuts.append({
        "sid": int(sc.sid),
        "keys": sc.keys,
        "action": sc.action,
        "app": sc.app,
        "importance": float(sc.importance),
        "category": sc.category,
        "modifiers": list(sc.modifiers),
        "base_key": sc.base_key,
        "is_capability": bool(sc.is_capability),
        "is_l0_only": bool(sc.is_l0_only),
        "complexity": int(sc.complexity),
        "preferred_hand": sc.preferred_hand,
        "is_layer_access": bool(sc.is_layer_access),
        "access_target_layer": int(sc.access_target_layer),
        "access_is_momentary": bool(sc.access_is_momentary),
    })

print(json.dumps({"positions": positions, "shortcuts": shortcuts}))
"""
    result = subprocess.run(
        [str(DEFAULT_OPTIMIZER_PYTHON), "-c", script, str(data_dir)],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env={**os.environ, "PYTHONPATH": str(DEFAULT_OPTIMIZER_ROOT)},
    )
    return json.loads(result.stdout)


def _effort_from_xy(x, y):
    effort = {
        (0, 0): 2.75, (1, 0): 2.0, (2, 0): 2.0, (3, 0): 2.0, (4, 0): 2.0, (5, 0): 2.75,
        (7, 0): 2.75, (8, 0): 2.0, (9, 0): 2.0, (10, 0): 2.0, (11, 0): 2.0, (12, 0): 2.75,
        (0, 1): 1.75, (1, 1): 1.0, (2, 1): 1.0, (3, 1): 1.0, (4, 1): 1.0, (5, 1): 1.75,
        (7, 1): 1.75, (8, 1): 1.0, (9, 1): 1.0, (10, 1): 1.0, (11, 1): 1.0, (12, 1): 1.75,
        (0, 2): 1.25, (1, 2): 0.0, (2, 2): 0.0, (3, 2): 0.0, (4, 2): 0.0, (5, 2): 1.25,
        (7, 2): 1.25, (8, 2): 0.0, (9, 2): 0.0, (10, 2): 0.0, (11, 2): 0.0, (12, 2): 1.25,
        (0, 3): 1.75, (1, 3): 1.0, (2, 3): 1.0, (3, 3): 1.0, (4, 3): 1.0, (5, 3): 1.75,
        (7, 3): 1.75, (8, 3): 1.0, (9, 3): 1.0, (10, 3): 1.0, (11, 3): 1.0, (12, 3): 1.75,
        (3, 4): 1.0, (4, 4): 0.0, (5, 4): 1.0, (7, 4): 1.0, (8, 4): 0.0,
        (4, 5): 1.0, (5, 5): 1.5, (7, 5): 1.5,
    }
    return effort.get((x, y), 5.0)


def parse_shortcut_keys(keys: str):
    """Split 'Ctrl+Shift+T' into modifiers ['Ctrl','Shift'] and base 'T'."""
    if "+" in keys:
        if keys.endswith("+"):
            return [p for p in keys[:-1].split("+") if p], "Equals and Plus"
        parts = keys.split("+")
        return [p for p in parts[:-1] if p], canonical_hid_parameter(parts[-1])

    for base in MULTIWORD_BASE_KEYS:
        suffix = " " + base
        if keys == base:
            return [], canonical_hid_parameter(base)
        if keys.endswith(suffix):
            return [p for p in keys[:-len(suffix)].split() if p], canonical_hid_parameter(base)

    parts = keys.split()
    if not parts:
        return [], keys
    if len(parts) == 1:
        return [], canonical_hid_parameter(parts[0])
    return parts[:-1], canonical_hid_parameter(parts[-1])


def build_param_mapping(canonical_data):
    """Build a label -> parameter mapping from canonical L0 and arrow keys."""
    mapping = {}
    for layer_id, layer_data in canonical_data.get("layers", {}).items():
        for coord, binding in layer_data.get("keys", {}).items():
            label = binding.get("label", "")
            param = binding.get("parameter", "")
            behavior = binding.get("behavior", "")
            if label and param and behavior == "Key Press":
                mapping[label] = param
                # Also map by base-looking parameter
                if param:
                    mapping[param] = param
    # Common explicit overrides
    mapping.update({
        "Left": "LeftArrow", "Right": "RightArrow", "Up": "UpArrow", "Down": "DownArrow",
        "LeftArrow": "LeftArrow", "RightArrow": "RightArrow", "UpArrow": "UpArrow", "DownArrow": "DownArrow",
        "Enter": "Return Enter", "Return": "Return Enter",
        "BkSp": "Delete", "Backspace": "Delete",
        "Space": "Spacebar", "Spacebar": "Spacebar",
        "Esc": "Escape", "Escape": "Escape",
        "Tab": "Tab",
    })
    return mapping


def base_to_zmk_parameter(base_key, param_mapping):
    """Map a shortcut base key to a ZMK Studio parameter string."""
    base_key = canonical_hid_parameter(base_key)
    if base_key in {"Click", "Left Click"}:
        return "MB1"
    if base_key == "Right Click":
        return "MB2"
    if base_key == "Middle Click":
        return "MB3"
    if base_key in param_mapping:
        return param_mapping[base_key]
    if base_key.startswith("F") and base_key[1:].isdigit():
        return f"F{base_key[1:]}"
    if len(base_key) == 1 and base_key.isalpha():
        return base_key.upper()
    if len(base_key) == 1:
        return base_key
    if base_key.startswith("MB") and base_key[2:].isdigit():
        return base_key  # Mouse buttons keep MB1..MB5
    return base_key


def is_studio_unsupported_shortcut(base_key):
    if base_key in MOUSE_CLICK_BASE_KEYS or base_key in {"Page Up", "Page Down"}:
        return False
    if base_key in NON_EXPORTABLE_BASE_KEYS:
        return True
    if re.fullmatch(r"[a-z]{2,}", base_key or ""):
        return True
    if re.fullmatch(r"[A-Za-z]+(?:\s+[A-Za-z]+)+", base_key or ""):
        return True
    return False


def fix_effective_binding(effective):
    behavior = effective.get("behavior", "")
    parameter = str(effective.get("parameter", "") or "")
    label = str(effective.get("label", "") or "")
    text = " ".join(str(effective.get(k, "") or "") for k in ("label", "parameter", "purpose", "usage_notes"))

    if behavior == "Mouse Key Press" and (not parameter or parameter == "default_transform"):
        match = re.search(r"\bMB[1-5]\b", text, re.IGNORECASE)
        if match:
            effective["parameter"] = match.group(0).upper()
        else:
            label_map = {
                "click": "MB1",
                "left click": "MB1",
                "right click": "MB2",
                "middle click": "MB3",
                "back": "MB4",
                "forward": "MB5",
            }
            effective["parameter"] = label_map.get(label.lower().strip(), parameter)

    return effective


def build_merged_layout(checkpoint_path: Path, positions, shortcuts, canonical_data):
    """Merge canonical base with evolved overrides."""
    cp = json.loads(checkpoint_path.read_text(encoding="utf-8"))
    genome = cp.get("best_genome", cp.get("best_exact", {}).get("genome", []))

    param_mapping = build_param_mapping(canonical_data)
    can_bindings = {}
    for layer_id, layer_data in canonical_data.get("layers", {}).items():
        if not layer_id or not layer_id.strip():
            continue
        for coord, binding in layer_data.get("keys", {}).items():
            can_bindings[(int(layer_id), coord)] = binding

    CRITICAL_L0 = {
        (4, 4): "spacebar",
        (7, 5): "return enter",
        (3, 4): "coach_l1_hold",
        (7, 4): "coach_l4_hold",
        (8, 4): "coach_l3_hold",
    }

    merged = []
    changes = []

    for idx, pos in enumerate(positions):
        coord = f"{int(pos['x'])}:{int(pos['y'])}"
        key = (pos["layer"], coord)
        can_binding = can_bindings.get(key, {})
        # A position is "critical" only when a canonical binding actually exists for it.
        # In v2, CRITICAL_L0 positions are mutable if not in l0_frozen — fall through to
        # evolved handling when can_binding is empty.
        is_critical = pos["layer"] == 0 and (pos["x"], pos["y"]) in CRITICAL_L0 and bool(can_binding)

        if is_critical or pos["is_frozen"]:
            effective = dict(can_binding) if can_binding else {
                "x": pos["x"], "y": pos["y"], "label": "transparent",
                "behavior": "Transparent", "parameter": "", "modifiers": [],
                "purpose": "", "usage_notes": "",
            }
            source = "canonical (frozen/critical)"
        else:
            sid = genome[idx] if idx < len(genome) else -1
            if 0 <= sid < len(shortcuts):
                sc = shortcuts[sid]
                # Base typing keys should keep their canonical binding
                if sc["keys"].startswith("_base_") and can_binding:
                    effective = dict(can_binding)
                    source = "canonical (base key)"
                elif sc.get("is_layer_access"):
                    behavior = sc.get("action", "")
                    target = int(sc.get("access_target_layer", -1))
                    coach_behavior = coach_behavior_for_layer_access(behavior, target)
                    if coach_behavior:
                        behavior = coach_behavior
                        parameter = ""
                    else:
                        parameter = f"Layer::{target}" if target >= 0 else ""
                    effective = {
                        "x": pos["x"], "y": pos["y"],
                        "label": sc.get("base_key") or sc["keys"],
                        "behavior": behavior,
                        "parameter": parameter,
                        "modifiers": [],
                        "purpose": f"Dynamic layer access: {sc['keys']}",
                        "usage_notes": f"Target layer {target}",
                    }
                    source = "evolved"
                else:
                    mods, base = parse_shortcut_keys(sc["keys"])
                    # Multi-stroke chords (e.g. "Ctrl+K Ctrl+F") produce invalid modifier
                    # tokens like "K Ctrl" that cannot be emitted as a single ZMK key press.
                    VALID_PRE_MAP_MODS = {
                        "Ctrl", "Shift", "Alt", "Win",
                        "L Ctrl", "R Ctrl", "L Shift", "R Shift",
                        "L Alt", "R Alt", "L GUI", "R GUI",
                    }
                    if sc["keys"] in NON_EXPORTABLE_SEQUENCE_KEYS:
                        effective = {
                            "x": pos["x"], "y": pos["y"], "label": "transparent",
                            "behavior": "Transparent", "parameter": "", "modifiers": [],
                            "purpose": f"skipped: non-exportable sequence {sc['keys']!r}",
                            "usage_notes": "",
                        }
                        source = "transparent"
                    elif base in NON_EXPORTABLE_BASE_KEYS:
                        effective = {
                            "x": pos["x"], "y": pos["y"], "label": "transparent",
                            "behavior": "Transparent", "parameter": "", "modifiers": [],
                            "purpose": f"skipped: non-exportable key {sc['keys']!r}",
                            "usage_notes": "",
                        }
                        source = "transparent"
                    elif any(m not in VALID_PRE_MAP_MODS for m in mods):
                        effective = {
                            "x": pos["x"], "y": pos["y"], "label": "transparent",
                            "behavior": "Transparent", "parameter": "", "modifiers": [],
                            "purpose": f"skipped: multi-stroke chord {sc['keys']!r}",
                            "usage_notes": "",
                        }
                        source = "transparent"
                    else:
                        zmk_mods = [MOD_MAP.get(m, m) for m in mods]
                        click_macro = None
                        if base in {"Click", "Left Click"}:
                            mod_set = set(zmk_mods)
                            if mod_set == {"L Ctrl"}:
                                click_macro = "coach_ctrl_click"
                            elif mod_set == {"L Shift"}:
                                click_macro = "coach_shift_click"
                            elif mod_set == {"L Alt"}:
                                click_macro = "coach_alt_click"

                        is_mouse_button = (base.startswith("MB") and base[2:].isdigit()) or base in MOUSE_CLICK_BASE_KEYS
                        behavior = click_macro or ("Mouse Key Press" if is_mouse_button else "Key Press")
                        param = "" if click_macro else base_to_zmk_parameter(base, param_mapping)
                        export_mods = [] if click_macro else zmk_mods
                        effective = {
                            "x": pos["x"], "y": pos["y"],
                            "label": sc["keys"],
                            "behavior": behavior,
                            "parameter": param,
                            "modifiers": export_mods,
                            "purpose": sc["action"] or f"Evolved: {sc['keys']}",
                            "usage_notes": f"App: {sc['app']}, importance={sc['importance']}",
                        }
                        source = "evolved"
            else:
                effective = {
                    "x": pos["x"], "y": pos["y"], "label": "transparent",
                    "behavior": "Transparent", "parameter": "", "modifiers": [],
                    "purpose": "", "usage_notes": "",
                }
                source = "transparent"

        effective = fix_effective_binding(effective)

        # Detect changes from canonical
        can_label = can_binding.get("label", "") if can_binding else "transparent"
        evolved_label = effective.get("label", "")
        if effective.get("behavior", "").lower() == "transparent":
            evolved_label = "transparent"
        if evolved_label.lower() != can_label.lower() and evolved_label != can_label:
            changes.append({
                "layer": pos["layer"],
                "x": int(pos["x"]),
                "y": int(pos["y"]),
                "coord": coord,
                "hand": pos["hand"],
                "effort": pos["effort"],
                "from_label": can_label,
                "to_label": evolved_label,
                "to_behavior": effective.get("behavior", ""),
                "to_parameter": effective.get("parameter", ""),
                "to_modifiers": effective.get("modifiers", []),
            })

        merged.append({
            "layer": pos["layer"],
            "coord": coord,
            "x": int(pos["x"]),
            "y": int(pos["y"]),
            "source": source,
            **effective,
        })

    return merged, changes, cp


def studio_apply_parameter(binding):
    """Return the parameter form expected by the proven ZMK Studio applier."""
    behavior = binding.get("behavior", "")
    parameter = str(binding.get("parameter", "") or "").strip()
    if not parameter or behavior != "Key Press":
        return parameter
    if parameter.startswith("Keyboard ") or parameter.startswith("Keypad "):
        return parameter

    explicit = {
        "Escape": "Keyboard Escape",
        "Esc": "Keyboard Escape",
        "Tab": "Keyboard Tab",
        "Delete": "Keyboard Delete",
        "Backspace": "Keyboard Delete",
        "Return Enter": "Keyboard Return Enter",
        "Enter": "Keyboard Return Enter",
        "Spacebar": "Keyboard Spacebar",
        "Space": "Keyboard Spacebar",
        "Shift": "Keyboard LeftShift",
        "Ctrl": "Keyboard LeftControl",
        "Control": "Keyboard LeftControl",
        "Alt": "Keyboard LeftAlt",
        "GUI": "Keyboard Left GUI",
        "Win": "Keyboard Left GUI",
        "LeftShift": "Keyboard LeftShift",
        "RightShift": "Keyboard RightShift",
        "LeftCtrl": "Keyboard LeftControl",
        "LeftControl": "Keyboard LeftControl",
        "RightCtrl": "Keyboard RightControl",
        "RightControl": "Keyboard RightControl",
        "LeftAlt": "Keyboard LeftAlt",
        "RightAlt": "Keyboard RightAlt",
        "LeftGUI": "Keyboard Left GUI",
        "Left GUI": "Keyboard Left GUI",
        "RightGUI": "Keyboard Right GUI",
        "Right GUI": "Keyboard Right GUI",
        "LeftArrow": "Keyboard LeftArrow",
        "RightArrow": "Keyboard RightArrow",
        "UpArrow": "Keyboard UpArrow",
        "DownArrow": "Keyboard DownArrow",
        "PageUp": "Keyboard PageUp",
        "PageDown": "Keyboard PageDown",
        "Page Up": "Keyboard PageUp",
        "Page Down": "Keyboard PageDown",
        "PgUp": "Keyboard PageUp",
        "PgDn": "Keyboard PageDown",
        "Home": "Keyboard Home",
        "End": "Keyboard End",
        "Insert": "Keyboard Insert",
        "Del": "Keyboard Delete",
        "PrintScreen": "Keyboard PrintScreen and SysReq",
        "!": "Keyboard 1 and Bang",
        "@": "Keyboard 2 and At",
        "#": "Keyboard 3 and Hash",
        "$": "Keyboard 4 and Dollar",
        "%": "Keyboard 5 and Percent",
        "^": "Keyboard 6 and Caret",
        "&": "Keyboard 7 and Ampersand",
        "*": "Keyboard 8 and Star",
        "(": "Keyboard 9 and Left Bracket",
        ")": "Keyboard 0 and Right Bracket",
        "Grave Accent and Tilde": "Keyboard Grave Accent and Tilde",
        "`": "Keyboard Grave Accent and Tilde",
        "~": "Keyboard Grave Accent and Tilde",
        "Left Brace": "Keyboard Left Brace",
        "[": "Keyboard Left Brace",
        "Right Brace": "Keyboard Right Brace",
        "]": "Keyboard Right Brace",
        "Backslash and Pipe": "Keyboard Backslash and Pipe",
        "\\": "Keyboard Backslash and Pipe",
        "SemiColon and Colon": "Keyboard SemiColon and Colon",
        ";": "Keyboard SemiColon and Colon",
        "Left Apos and Double": "Keyboard Left Apos and Double",
        "'": "Keyboard Left Apos and Double",
        "Comma and LessThan": "Keyboard Comma and LessThan",
        ",": "Keyboard Comma and LessThan",
        "<": "Keyboard Comma and LessThan",
        "Period and GreaterThan": "Keyboard Period and GreaterThan",
        ".": "Keyboard Period and GreaterThan",
        ">": "Keyboard Period and GreaterThan",
        "ForwardSlash and QuestionMark": "Keyboard ForwardSlash and QuestionMark",
        "/": "Keyboard ForwardSlash and QuestionMark",
        "?": "Keyboard ForwardSlash and QuestionMark",
        "Dash and Underscore": "Keyboard Dash and Underscore",
        "-": "Keyboard Dash and Underscore",
        "Equals and Plus": "Keyboard Equals and Plus",
        "=": "Keyboard Equals and Plus",
        "+": "Keyboard Equals and Plus",
    }
    if parameter in explicit:
        return explicit[parameter]
    if re.fullmatch(r"[A-Z]", parameter):
        return f"Keyboard {parameter}"
    if re.fullmatch(r"F\d{1,2}", parameter):
        return f"Keyboard {parameter}"
    if re.fullmatch(r"\d and .+", parameter):
        # Norwegian numpad shifted variants use the Keypad namespace in ZMK Studio.
        numpad_shifted = {
            "0 and Insert": "Keypad 0 and Insert",
            "1 and End": "Keypad 1 and End",
            "2 and DownArrow": "Keypad 2 and DownArrow",
            "3 and PageDn": "Keypad 3 and PageDn",
            "4 and LeftArrow": "Keypad 4 and LeftArrow",
            "5": "Keypad 5",
            "6 and RightArrow": "Keypad 6 and RightArrow",
            "7 and Home": "Keypad 7 and Home",
            "8 and UpArrow": "Keypad 8 and UpArrow",
            "9 and PageUp": "Keypad 9 and PageUp",
            "Period and Delete": "Keypad Period and Delete",
        }
        if parameter in numpad_shifted:
            return numpad_shifted[parameter]
        return f"Keyboard {parameter}"
    return parameter


def generate_apply_js(merged_bindings, template_path=DEFAULT_APPLY_TEMPLATE, version="evolved-v2"):
    apply_keys = list(merged_bindings)
    keys = []
    for b in apply_keys:
        item = {
            "layer": int(b["layer"]),
            "x": int(b["x"]),
            "y": int(b["y"]),
            "behavior": b.get("behavior", ""),
            "parameter": studio_apply_parameter(b),
            "modifiers": b.get("modifiers", []),
            "label": b.get("label", ""),
            "rationale": f"{b.get('source', 'generated')}: {b.get('purpose', '')}".strip(),
            "optimizer_changed": b.get("source") == "evolved",
            "apply_batch": True,
        }
        keys.append(item)

    layers = sorted({k["layer"] for k in keys})
    layout = {
        "project": "Charybdis Optimizer V2 Layout",
        "version": version,
        "keyCount": len(keys),
        "layers": layers,
        "keys": keys,
    }

    template = template_path.read_text(encoding="utf-8")
    start_marker = "window.CHARYBDIS_FINAL_LAYOUT = "
    end_marker = "\nwindow.CHARYBDIS_MODE = "
    start = template.find(start_marker)
    end = template.find(end_marker, start)
    if start < 0 or end < 0:
        raise RuntimeError(f"Could not splice ZMK Studio apply template: {template_path}")

    prefix = f"""/*
Charybdis optimizer layout - {version}
{len(keys)} keys across layers {layers}.
Generated by /home/nos/charybdis/charybdis-tools/runtime/evolved_v2_export/export_and_analyze_linux.py
Uses the proven ZMK Studio applier template from {template_path}.
Self-contained: paste this one file in ZMK Studio console. It will ask before applying and it will not click Save.
*/

"""
    suffix = template[end:]
    suffix = re.sub(
        r'console\.log\("Applying " \+ window\.CHARYBDIS_FINAL_LAYOUT\.keyCount \+ " keys across layers \[[^\]]*\]\.\.\."\);',
        'console.log("Applying " + window.CHARYBDIS_FINAL_LAYOUT.keyCount + " keys across layers " + JSON.stringify(window.CHARYBDIS_FINAL_LAYOUT.layers || []) + "...");',
        suffix,
        count=1,
    )
    _plannedkeys_new = """  function plannedKeys() {
    return getLayout().keys
      .filter((item) => item && Number.isInteger(Number(item.layer)))
      .filter((item) => Number(item.layer) !== 7)
      .filter((item) => !APPLY_ONLY_BATCH || item.apply_batch === true || MODE === "oneKeyTest");
  }"""
    if _plannedkeys_new not in suffix:
        suffix = suffix.replace(
            """  function plannedKeys() {
    return getLayout().keys
      .filter((item) => item && Number.isInteger(Number(item.layer)))
      .filter((item) => !APPLY_ONLY_BATCH || item.apply_batch === true || MODE === "oneKeyTest");
  }""",
            _plannedkeys_new,
        )
    full_supported = (
        'const supported = new Set(["Key Press", "Mouse Key Press", "Momentary Layer", '
        '"To Layer", "Toggle Layer", "Bluetooth", "Output Selection", "Studio Unlock", '
        '"Reset", "Bootloader", "Transparent", "None", '
        + ", ".join(json.dumps(item) for item in COACH_STUDIO_BEHAVIORS)
        + "]);"
    )
    if 'const supported = new Set(["Key Press"' not in suffix or full_supported not in suffix:
        suffix = re.sub(r'const supported = new Set\(\[[^\]]*\]\);', full_supported, suffix, count=1)
    _layermatch_new = """    const aliases = new Set([text, upper]);

    const layerMatch = text.match(/^Layer::(\\d+)$/i) || text.match(/^Layer\\s+(\\d+)$/i);
    if (layerMatch) {
      aliases.add(layerMatch[1]);
      aliases.add(`Layer ${layerMatch[1]}`);
    }"""
    if "const layerMatch = text.match" not in suffix:
        suffix = suffix.replace(
            """    const aliases = new Set([text, upper]);""",
            _layermatch_new,
            1,
        )
    _mousemod_new = """    if (!selectWorked) {
      console.warn(`No exact visible select option matched parameter "${item.parameter}". Trying visible text input/combobox. Verify manually before saving.`);
      await setTextParameter(item.parameter);
    }

    if (item.behavior === "Mouse Key Press") {
      await setImplicitModifiers(item.modifiers || []);
    }"""
    if "await setImplicitModifiers(item.modifiers || [])" not in suffix:
        suffix = suffix.replace(
            """    if (!selectWorked) {
      console.warn(`No exact visible select option matched parameter "${item.parameter}". Trying visible text input/combobox. Verify manually before saving.`);
      await setTextParameter(item.parameter);
    }""",
            _mousemod_new,
        )
    if "(Layer 7 skipped)" not in suffix:
        suffix = suffix.replace(
            """const confirmed = window.confirm(`Apply ${modeItems.length} planned changes ${APPLY_LAYER_INDEX === "all" ? "across multiple layers" : `to layer ${APPLY_LAYER_INDEX}`}? This will NOT save.`);""",
            """const confirmed = window.confirm(`Apply ${modeItems.length} planned changes (Layer 7 skipped) ${APPLY_LAYER_INDEX === "all" ? "across multiple layers" : `to layer ${APPLY_LAYER_INDEX}`}? This will NOT save.`);"""
        )
    if "let applied = 0;" not in suffix:
        suffix = suffix.replace(
            """    for (const item of modeItems) {
      console.log("Applying", item);
      await applyItem(item);
    }
    console.warn("Layer apply complete. This script did NOT save. Verify in the UI before saving manually.");""",
            """    let applied = 0;
    let failed = 0;
    for (const item of modeItems) {
      console.log("Applying", item);
      try {
        await applyItem(item);
        applied++;
      } catch (error) {
        failed++;
        window._CHARYBDIS_APPLY_ERRORS.push({ item, error: String(error?.message || error) });
        console.error("Failed but continuing", item, error);
      }
    }
    console.warn(`Layer apply complete. Attempted ${modeItems.length}; completed ${applied}; failed ${failed}. This script did NOT save. Verify in the UI before saving manually.`);"""
        )
    return prefix + "window._CHARYBDIS_APPLY_ERRORS = [];\n" + start_marker + json.dumps(layout, indent=2) + ";\n" + suffix.lstrip()


def generate_verify_js(merged_bindings):
    def escape_template_literal(value):
        return (
            str(value)
            .replace("\\", "\\\\")
            .replace("`", "\\`")
            .replace("${", "\\${")
        )

    csv_lines = ['"layer","x","y","label","behavior","parameter","modifiers"']
    for b in merged_bindings:
        if b.get("behavior", "").lower() == "transparent":
            continue
        mods = "+".join(b.get("modifiers", []))
        csv_lines.append(f'"{b["layer"]}","{b["x"]}","{b["y"]}","{b.get("label", "")}","{b.get("behavior", "")}","{b.get("parameter", "")}","{mods}"')
    expected_csv = escape_template_literal("\n".join(csv_lines))

    return f"""// ZMK Studio verify script for evolved V2 layout
window.CHARYBDIS_VERSION = "evolved-v2";

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const qa = (selector, root = document) => Array.from(root.querySelectorAll(selector));

function clean(value) {{
  return String(value ?? "").replace(/\\s+/g, " ").trim();
}}

function visible(el) {{
  return Boolean(el && el.offsetParent !== null);
}}

function findLayerButton(layer) {{
  const layerList = document.querySelector('[aria-label="Keymap Layer"]');
  return layerList?.querySelector(`[role="option"][data-key="${{layer}}"]`)
    || qa('[role="option"]', layerList || document).find((el) => clean(el.textContent) === String(layer));
}}

function selectedLayer() {{
  const selected = document.querySelector('[aria-label="Keymap Layer"] [role="option"][aria-selected="true"]');
  return clean(selected?.textContent || "");
}}

async function selectLayer(layer) {{
  if (selectedLayer() === String(layer)) return true;
  const el = findLayerButton(layer);
  if (!el) return false;
  el.scrollIntoView({{ block: "center", inline: "center" }});
  el.click();
  await sleep(650);
  return selectedLayer() === String(layer);
}}

function findKeyElement(x, y) {{
  const holder = document.querySelector(`[x="${{x}}"][y="${{y}}"]`);
  return holder?.querySelector("button") || holder;
}}

async function selectKey(x, y) {{
  const el = findKeyElement(x, y);
  if (!el) return false;
  const button = el.closest("button") || el;
  button.scrollIntoView({{ block: "center", inline: "center" }});
  button.click();
  await sleep(250);
  return true;
}}

function visibleSelects() {{
  return qa("select").filter(visible);
}}

function visibleInputs() {{
  return qa("input").filter(visible);
}}

function isBehaviorSelect(select) {{
  return [...select.options].some((o) => clean(o.textContent) === "Key Press")
    && [...select.options].some((o) => clean(o.textContent) === "Transparent");
}}

function isZoomSelect(select) {{
  return [...select.options].some((o) => clean(o.textContent) === "Auto")
    && [...select.options].some((o) => clean(o.textContent) === "100%");
}}

function isDefaultTransformSelect(select) {{
  return [...select.options].some((o) => clean(o.textContent) === "default_transform")
    && select.options.length <= 3;
}}

function readCurrent() {{
  const selects = visibleSelects();
  const behaviorSelect = selects.find(isBehaviorSelect);
  const behavior = behaviorSelect ? clean(behaviorSelect.options[behaviorSelect.selectedIndex]?.textContent) : "";

  const textValues = visibleInputs()
    .filter((input) => input.type === "text" || input.getAttribute("role") === "combobox")
    .map((input) => clean(input.value))
    .filter(Boolean);

  const selectValues = selects
    .filter((select) => select !== behaviorSelect && !isBehaviorSelect(select) && !isZoomSelect(select) && !isDefaultTransformSelect(select))
    .map((select) => clean(select.options[select.selectedIndex]?.textContent))
    .filter(Boolean);

  let parameter = textValues[0] || selectValues[0] || "";
  if (behavior === "Bluetooth" && (parameter === "Select Profile" || parameter === "Disconnect Profile")) {{
    const number = visibleInputs().find((input) => input.type === "number");
    if (number && clean(number.value)) parameter = `BT_SEL ${{clean(number.value)}}`;
  }}

  const modifiers = visibleInputs()
    .filter((input) => input.type === "checkbox" && input.checked)
    .map((input) => clean(input.closest("label")?.textContent || input.parentElement?.textContent || ""))
    .filter(Boolean);

  return {{ behavior, parameter, modifiers }};
}}

function normalizeParameter(value) {{
  let text = clean(value);
  if (!text) return "";
  text = text.replace(/^Keyboard\\s+/i, "");
  text = text.replace(/^Layer::/i, "");
  text = text.replace(/^Layer\\s+/i, "");
  text = text.replace(/^Keypad\\s+/i, "Keypad ");
  text = text.replace(/\\bPage Up\\b/i, "PageUp");
  text = text.replace(/\\bPage Down\\b/i, "PageDown");
  text = text.replace(/\\bPageDn\\b/i, "PageDown");
  text = text.replace(/\\bReturn Enter\\b/i, "ReturnEnter");
  if (/^Shift$/i.test(text)) text = "LeftShift";
  text = text.replace(/\\bLeftControl\\b/i, "LeftCtrl");
  text = text.replace(/\\bLeftShift\\b/i, "LeftShift");
  text = text.replace(/\\bLeftAlt\\b/i, "LeftAlt");
  text = text.replace(/\\bLeft GUI\\b/i, "LeftGUI");
  return text.toUpperCase().replace(/[^A-Z0-9]+/g, "");
}}

function normalizeModifier(value) {{
  const compact = clean(value).toUpperCase().replace(/[^A-Z0-9]+/g, "");
  const aliases = {{
    LCTRL: "LCTRL", LEFTCTRL: "LCTRL", LEFTCONTROL: "LCTRL",
    LSHIFT: "LSHIFT", LEFTSHIFT: "LSHIFT",
    LALT: "LALT", LEFTALT: "LALT",
    LGUI: "LGUI", LEFTGUI: "LGUI", WIN: "LGUI", WINDOWS: "LGUI",
    RCTRL: "RCTRL", RIGHTCTRL: "RCTRL", RIGHTCONTROL: "RCTRL",
    RSHIFT: "RSHIFT", RIGHTSHIFT: "RSHIFT",
    RALT: "RALT", RIGHTALT: "RALT",
    RGUI: "RGUI", RIGHTGUI: "RGUI"
  }};
  return aliases[compact] || compact;
}}

function normalizeModifiers(value) {{
  if (Array.isArray(value)) return value.map(normalizeModifier).filter(Boolean).sort().join("+");
  return clean(value).split("+").map(normalizeModifier).filter(Boolean).sort().join("+");
}}

const EXPECTED_CSV = `{expected_csv}`;

function parseExpected() {{
  const lines = EXPECTED_CSV.trim().split('\\n');
  function parseCsvLine(line) {{
    const values = [];
    let value = "";
    let quoted = false;
    for (let i = 0; i < line.length; i++) {{
      const ch = line[i];
      const next = line[i + 1];
      if (ch === '"') {{
        if (quoted && next === '"') {{
          value += '"';
          i++;
        }} else {{
          quoted = !quoted;
        }}
      }} else if (ch === "," && !quoted) {{
        values.push(value.trim());
        value = "";
      }} else {{
        value += ch;
      }}
    }}
    values.push(value.trim());
    return values;
  }}

  const headers = parseCsvLine(lines[0]).map(h => h.trim());
  const out = [];
  for (let i = 1; i < lines.length; i++) {{
    const parts = parseCsvLine(lines[i]);
    const obj = {{}};
    for (let j = 0; j < headers.length; j++) obj[headers[j]] = parts[j] || '';
    out.push(obj);
  }}
  return out;
}}

async function runVerify() {{
  const expected = parseExpected().filter((exp) => Number(exp.layer) !== 7);
  let pass = 0, fail = 0, errors = [];
  let currentLayer = null;
  for (const exp of expected) {{
    const layer = parseInt(exp.layer);
    const x = parseInt(exp.x);
    const y = parseInt(exp.y);

    if (currentLayer !== layer) {{
      const switched = await selectLayer(layer);
      if (!switched) {{
        fail++;
        errors.push({{layer, x, y, expected: exp, error: `could not switch to layer ${{layer}}; selected=${{selectedLayer()}}`}});
        continue;
      }}
      currentLayer = layer;
      console.log(`Verifying layer ${{layer}}...`);
    }}

    const found = await selectKey(x, y);
    if (!found) {{
      fail++;
      errors.push({{layer, x, y, expected: exp, error: 'key not found'}});
      continue;
    }}

    const actual = readCurrent();
    const bMatch = clean(actual.behavior).toLowerCase() === clean(exp.behavior).toLowerCase();
    const pMatch = normalizeParameter(actual.parameter) === normalizeParameter(exp.parameter);
    const mMatch = normalizeModifiers(actual.modifiers) === normalizeModifiers(exp.modifiers);

    if (bMatch && pMatch && mMatch) {{
      pass++;
    }} else {{
      fail++;
      const issues = [];
      if (!bMatch) issues.push(`behavior expected "${{exp.behavior}}" got "${{actual.behavior}}"`);
      if (!pMatch) issues.push(`parameter expected "${{exp.parameter}}" got "${{actual.parameter}}"`);
      if (!mMatch) issues.push(`modifiers expected "${{exp.modifiers}}" got "${{actual.modifiers.join('+')}}"`);
      errors.push({{layer, x, y, expected: exp, actual, issues}});
      console.warn(`FAIL L${{layer}} x${{x}} y${{y}} ${{exp.label || ""}}: ${{issues.join("; ")}}`);
    }}
  }}
  console.log('Verify result: ' + pass + ' pass, ' + fail + ' fail (' + (pass/(pass+fail)*100).toFixed(1) + '%)');
  window._CHARYBDIS_VERIFY_RESULT = {{pass, fail, errors}};
  if (errors.length) {{
    console.table(errors.slice(0, 50).map((err) => ({{
      pos: `L${{err.layer}} x${{err.x}} y${{err.y}}`,
      label: err.expected?.label || "",
      issues: err.issues?.join("; ") || err.error || ""
    }})));
    console.warn(`Stored full error list in window._CHARYBDIS_VERIFY_RESULT.errors (${{errors.length}} entries).`);
  }}
}}

runVerify();
"""


def generate_csv(merged_bindings, out_path: Path):
    with open(out_path, "w", newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["layer", "x", "y", "visual_label", "behavior", "parameter", "modifiers", "purpose", "usage_notes", "source"])
        for b in merged_bindings:
            writer.writerow([
                b["layer"], b["x"], b["y"],
                b.get("label", "transparent"),
                b.get("behavior", "Transparent"),
                b.get("parameter", ""),
                "+".join(b.get("modifiers", [])),
                b.get("purpose", ""),
                b.get("usage_notes", ""),
                b.get("source", ""),
            ])


def generate_diff(merged_bindings, changes, out_path: Path, checkpoint_name: str, generation: int):
    with open(out_path, "w", encoding='utf-8') as f:
        f.write("Charybdis V2 Evolved Layout Diff\n")
        f.write(f"Source: {checkpoint_name}\n")
        f.write(f"Generation: {generation}\n")
        f.write("=" * 60 + "\n\n")
        by_layer = defaultdict(list)
        for c in changes:
            by_layer[c["layer"]].append(c)
        for layer in sorted(by_layer.keys()):
            f.write(f"--- Layer {layer} ---\n")
            for c in sorted(by_layer[layer], key=lambda x: (x["y"], x["x"])):
                mods = " + ".join(c["to_modifiers"]) if c["to_modifiers"] else ""
                f.write(f"  ({c['x']},{c['y']}) [{c['hand']}] {c['from_label']} -> {c['to_label']}")
                if mods:
                    f.write(f"  [{mods}]")
                f.write(f"  effort={c['effort']:.1f}\n")
            f.write("\n")


def main():
    parser = argparse.ArgumentParser(description="Linux V2 evolved layout exporter")
    parser.add_argument("--build-dir", type=Path, default=DEFAULT_BUILD_DIR)
    parser.add_argument("--data-dir", type=Path, default=DEFAULT_DATA_DIR)
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR)
    parser.add_argument("--checkpoint", type=Path, default=None, help="Specific checkpoint; defaults to latest by mtime")
    parser.add_argument("--prefix", type=str, default="evolved", help="Output filename prefix")
    args = parser.parse_args()

    build_dir = args.build_dir
    data_dir = args.data_dir
    out_dir = args.out_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    if args.checkpoint:
        cp_path = args.checkpoint
        build_dir = cp_path.parent
    else:
        checkpoints = sorted(build_dir.glob("v2_checkpoint_gen*.json"), key=lambda p: p.stat().st_mtime)
        if not checkpoints:
            print("No checkpoints found in", build_dir)
            sys.exit(1)
        cp_path = checkpoints[-1]

    print(f"Using checkpoint: {cp_path.name}")

    optimizer_snapshot = load_optimizer_layout_snapshot(data_dir)
    if optimizer_snapshot:
        shortcuts = optimizer_snapshot["shortcuts"]
        positions = optimizer_snapshot["positions"]
        print(f"Loaded optimizer layout snapshot: {len(positions)} positions, {len(shortcuts)} shortcuts")
    else:
        shortcuts = load_shortcuts(data_dir)
        positions = load_positions(data_dir)
        print(f"Loaded standalone layout snapshot: {len(positions)} positions, {len(shortcuts)} shortcuts")
    canonical_path = data_dir / "canonical.json"
    if canonical_path.exists():
        canonical = json.loads(canonical_path.read_text(encoding="utf-8"))
    else:
        # Synthesize canonical from layout.json (v2 optimizer stores frozen bindings there)
        layout_json = json.loads((data_dir / "layout.json").read_text(encoding="utf-8"))
        canonical = {
            "layers": {
                "0": {"keys": layout_json.get("l0_frozen", {})},
                "7": {"keys": layout_json.get("l7_frozen", {})},
            }
        }
        print("Synthesized canonical from layout.json (l0_frozen + l7_frozen)")

    merged, changes, cp = build_merged_layout(cp_path, positions, shortcuts, canonical)
    generation = cp.get("generation", "unknown")

    print(f"Merged layout: {len(merged)} bindings")
    print(f"Changes from canonical: {len(changes)}")

    prefix = args.prefix

    # Apply script
    apply_js = generate_apply_js(merged)
    (out_dir / f"{prefix}_apply.js").write_text(apply_js, encoding="utf-8")
    print(f"Saved {out_dir / f'{prefix}_apply.js'}")

    # Verify script
    verify_js = generate_verify_js(merged)
    (out_dir / f"{prefix}_verify.js").write_text(verify_js, encoding="utf-8")
    print(f"Saved {out_dir / f'{prefix}_verify.js'}")

    # CSV
    generate_csv(merged, out_dir / f"{prefix}_keybindings_explained.csv")
    print(f"Saved {out_dir / f'{prefix}_keybindings_explained.csv'}")

    # Diff
    generate_diff(merged, changes, out_dir / f"{prefix}_diff.txt", cp_path.name, generation)
    print(f"Saved {out_dir / f'{prefix}_diff.txt'}")

    # Metadata
    selected = {
        "mode": "feasible",
        "source": cp_path.name,
        "generation": generation,
        "change_count": len(changes),
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }
    (out_dir / "selected_candidate.json").write_text(json.dumps(selected, indent=2), encoding="utf-8")
    (out_dir / "evolved_changes.json").write_text(json.dumps(changes, indent=2), encoding="utf-8")
    print(f"Saved selected_candidate.json and evolved_changes.json")


if __name__ == "__main__":
    main()
