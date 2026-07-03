"""Standalone checkpoint analyzer — no optimizer modules required.

Reads:
  /home/nos/charybdis/charybdis-optimizer/build/app_shortcut_scores.json
  /home/nos/charybdis/charybdis-optimizer/build/canonical.json
  /home/nos/charybdis/charybdis-optimizer/build/v2_checkpoint_gen*.json

Analyzes mouse-button effective placement, scroll-mode access, and arrow grouping.
"""
import json
import sys
import os
import subprocess
from collections import defaultdict
from pathlib import Path

DEFAULT_BUILD_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/build")
DEFAULT_DATA_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/data")
OUT_DIR = Path("/home/nos/charybdis/charybdis-tools/runtime/evolved_v2_export")
OPTIMIZER_ROOT = Path("/home/nos/charybdis/charybdis-optimizer-v2")
OPTIMIZER_PYTHON = OPTIMIZER_ROOT / ".venv" / "bin" / "python"

ARROW_KEYS = {"LeftArrow", "RightArrow", "UpArrow", "DownArrow"}
MOUSE_KEYS = {"MB1", "MB2", "MB3", "MB4", "MB5"}
FAKE_DIRECT_KEYS = {"ScrollUp", "ScrollDown", "gg", "gi", "yy", "Ctrl+K S"}
MOUSE_CLICK_BASE_KEYS = {"Click", "Left Click", "Right Click", "Middle Click"}

POSITION_EFFORT = {
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


RAW_KEY_ALIASES = {
    "escape": "escape", "esc": "escape", "delete": "delete", "bksp": "delete",
    "backspace": "delete", "tab": "tab", "space": "spacebar", "spacebar": "spacebar",
    "enter": "returnenter", "return": "returnenter", "return enter": "returnenter",
    "leftshift": "leftshift", "rightshift": "rightshift", "shift": "leftshift",
    "leftcontrol": "leftcontrol", "rightcontrol": "rightcontrol", "ctrl": "leftcontrol",
    "leftalt": "leftalt", "rightalt": "rightalt", "left gui": "leftgui",
    "leftgui": "leftgui", "comma": ",", "comma and lessthan": ",",
    "period": ".", "period and greaterthan": ".", "forwardslash": "/",
    "forwardslash and questionmark": "/", "backslash": "\\",
    "backslash and pipe": "\\", "semicolon": ";", "semicolon and colon": ";",
    "left apos": "'", "left apos and double": "'", "apostrophe": "'",
    "left brace": "[", "right brace": "]",
}
L0_FROZEN_THUMB_RAW_KEYS = {"spacebar", "returnenter"}


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
    import re
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


def _parse_layer_from_behavior(label, behavior, parameter):
    import re
    if parameter:
        if str(parameter).isdigit():
            return int(parameter)
        m = re.search(r"Layer::(\d+)", str(parameter))
        if m:
            return int(m.group(1))
    behavior = str(behavior)
    if "coach_l1_hold" in behavior:
        return 1
    if "coach_l2_hold" in behavior:
        return 2
    if "coach_l3_hold" in behavior:
        return 3
    if "coach_l4_hold" in behavior:
        return 4
    if "coach_travel_toggle" in behavior:
        return 8
    if "coach_travel_off" in behavior or "coach_base" in behavior:
        return 0
    if "coach_game_lock" in behavior:
        return 7
    label = str(label)
    m = re.search(r"\bL(\d+)\b", label)
    if m:
        return int(m.group(1))
    return None


def _is_momentary_access(behavior):
    b = str(behavior).lower()
    if "toggle" in b or "lock" in b or "base" in b or "travel_off" in b:
        return False
    return "hold" in b or "momentary" in b


def _access_shortcut_key(source_layer, target_layer, is_momentary, label):
    import re
    mode = "hold" if is_momentary else "toggle"
    clean = re.sub(r"[^A-Za-z0-9]+", "_", label or f"L{target_layer}").strip("_") or f"L{target_layer}"
    return f"@access:L{source_layer}->L{target_layer}:{mode}:{clean}"


def _is_structural_system_key(label, behavior="", parameter="", action=""):
    text = f"{label} {behavior} {parameter} {action}".lower()
    return "bluetooth" in text or "bt_sel" in text or "output selection" in text or "out_sel" in text


def _is_plain_keypress_shortcut(keys, sc_data):
    clean = str(keys or "").strip()
    category = str(sc_data.get("category", "")).lower()
    action = str(sc_data.get("action", "")).lower()
    behavior = str(sc_data.get("behavior", "")).lower()
    parameter = str(sc_data.get("parameter", "")).lower()
    if _is_structural_system_key(clean, behavior, parameter, action):
        return False
    if clean in FAKE_DIRECT_KEYS:
        return False
    if clean in MOUSE_CLICK_BASE_KEYS or clean.endswith("+Click"):
        return True
    if "vimium" in category and "+" not in clean and len(clean) > 1:
        return False
    if "scroll" in action and clean in {"ScrollUp", "ScrollDown"}:
        return False
    return True


def load_shortcuts(data_dir: Path = DEFAULT_DATA_DIR):
    data = json.loads((data_dir / "app_shortcut_scores.json").read_text(encoding="utf-8"))
    can = json.loads((data_dir / "canonical.json").read_text(encoding="utf-8"))
    shortcuts = []
    seen_keys = set()

    # Base typing keys first (matching core.loader.load_shortcuts)
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

    # Then layer-access capabilities, matching optimizer SID order. Scroll is a
    # trackball mode switch with a layer side effect; it is reported as access,
    # not as ScrollUp/ScrollDown keypresses.
    access_seen = set()
    for layer_id, layer_data in can.get("layers", {}).items():
        if not str(layer_id).strip():
            continue
        source_layer = int(layer_id)
        for key_data in layer_data.get("keys", {}).values():
            behavior = key_data.get("behavior", "")
            parameter = key_data.get("parameter", "")
            label = key_data.get("label", "")
            target_layer = _parse_layer_from_behavior(label, behavior, parameter)
            if target_layer is None or target_layer == source_layer:
                continue
            if target_layer == 0 and "base" not in str(behavior).lower() and "travel_off" not in str(behavior).lower():
                continue
            is_momentary = _is_momentary_access(behavior)
            keys = _access_shortcut_key(source_layer, target_layer, is_momentary, label)
            if keys in access_seen:
                continue
            access_seen.add(keys)
            shortcuts.append({
                "sid": len(shortcuts),
                "keys": keys,
                "action": behavior or ("Momentary Layer" if is_momentary else "Toggle Layer"),
                "app": "Layer Access",
                "importance": 1.0,
                "category": "layer_access",
                "modifiers": [],
                "base_key": label or f"L{target_layer}",
                "is_capability": True,
                "is_l0_only": False,
                "complexity": 1,
                "preferred_hand": "either",
                "is_layer_access": True,
                "access_target_layer": target_layer,
                "access_is_momentary": is_momentary,
            })

    for app_data in data.get("apps", []):
        app_name = app_data.get("name", "unknown")
        for sc_data in app_data.get("shortcuts", []):
            keys = sc_data.get("keys", "")
            if keys in seen_keys:
                continue
            if not _is_plain_keypress_shortcut(keys, sc_data):
                continue
            seen_keys.add(keys)

            base_key = sc_data.get("base_key", "")
            if not base_key:
                parts = keys.replace("+", " ").split()
                base_key = parts[-1] if parts else keys

            modifiers = [part for part in keys.replace("+", " ").split()[:-1]]

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


def load_positions(data_dir: Path = DEFAULT_DATA_DIR):
    can = json.loads((data_dir / "canonical.json").read_text(encoding="utf-8"))
    positions = []
    grid = can.get("physical_grid", {}).get("positions", [])
    layers = can.get("layers", {})

    # Collect every (layer, coord) binding to determine layer per physical position.
    # The canonical.json layout stores keys under layers['N']['keys']['x:y'].
    for layer_id, layer_data in layers.items():
        if not layer_id or not layer_id.strip():
            continue
        layer = int(layer_id)
        for coord, binding in layer_data.get("keys", {}).items():
            x_str, y_str = coord.split(":")
            x, y = int(x_str), int(y_str)
            # Find matching grid entry for hand/finger/row_type
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
                "effort": float(grid_entry.get("effort", POSITION_EFFORT.get((x, y), 5.0))),
            })
    return positions


def load_optimizer_layout_snapshot(data_dir: Path = DEFAULT_DATA_DIR):
    """Use the optimizer loader so SID/order decoding matches export exactly."""
    if not OPTIMIZER_PYTHON.exists():
        return None
    script = r"""
import json
import sys
from core.loader import build_layout
layout = build_layout(sys.argv[1])
canonical = json.load(open(sys.argv[1] + "/canonical.json", encoding="utf-8"))
positions = []
for pos in layout.positions:
    binding = canonical.get("layers", {}).get(str(int(pos.layer)), {}).get("keys", {}).get(f"{int(pos.x)}:{int(pos.y)}", {})
    positions.append({
        "layer": int(pos.layer), "x": int(pos.x), "y": int(pos.y),
        "coord": f"{int(pos.x)}:{int(pos.y)}", "hand": pos.hand,
        "is_thumb": bool(pos.is_thumb), "is_frozen": bool(pos.is_frozen),
        "behavior": binding.get("behavior", ""), "label": binding.get("label", ""),
        "parameter": binding.get("parameter", ""), "modifiers": binding.get("modifiers", []),
        "purpose": binding.get("purpose", ""),
    })
shortcuts = []
for sc in layout.shortcuts:
    shortcuts.append({
        "sid": int(sc.sid), "keys": sc.keys, "action": sc.action, "app": sc.app,
        "importance": float(sc.importance), "category": sc.category,
        "modifiers": list(sc.modifiers), "base_key": sc.base_key,
        "is_l0_only": bool(sc.is_l0_only), "preferred_hand": sc.preferred_hand,
        "is_layer_access": bool(sc.is_layer_access),
        "access_target_layer": int(sc.access_target_layer),
        "access_is_momentary": bool(sc.access_is_momentary),
    })
print(json.dumps({"positions": positions, "shortcuts": shortcuts}))
"""
    result = subprocess.run(
        [str(OPTIMIZER_PYTHON), "-c", script, str(data_dir)],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env={**os.environ, "PYTHONPATH": str(OPTIMIZER_ROOT)},
    )
    return json.loads(result.stdout)


def build_layer_bindings(positions, genome, shortcuts):
    """Map each position to either canonical (frozen/critical) or evolved shortcut."""
    layer_bindings = defaultdict(list)
    CRITICAL_L0 = {(3, 4), (4, 4), (5, 4), (7, 4), (8, 4), (7, 5), (4, 5)}

    for idx, pos in enumerate(positions):
        is_critical = pos["layer"] == 0 and (pos["x"], pos["y"]) in CRITICAL_L0
        if pos["is_frozen"] or is_critical:
            label = pos["label"]
            purpose = pos["purpose"]
        else:
            # Evolved shortcut from genome
            sid = genome[idx] if idx < len(genome) else -1
            if 0 <= sid < len(shortcuts):
                sc = shortcuts[sid]
                label = sc.get("keys", "")
                purpose = sc.get("action", "")
            else:
                # Empty mutable position: do not inherit canonical label, which
                # may contain stale evolved arrow names from a previous run.
                continue
        if not label or label.lower() == "transparent":
            continue
        layer_bindings[pos["layer"]].append({
            "layer": pos["layer"],
            "x": pos["x"],
            "y": pos["y"],
            "hand": pos["hand"],
            "label": label,
            "purpose": purpose,
        })
    return layer_bindings


def analyze_checkpoint(cp_path, shortcuts, positions):
    cp = json.loads(cp_path.read_text(encoding="utf-8"))
    genome = cp.get("best_genome", [])
    gen = cp.get("generation", "?")
    obj = cp.get("best_objectives")
    total = cp.get("best_score") or (sum(obj) if obj else None)

    bindings = build_layer_bindings(positions, genome, shortcuts)

    # Find placements
    arrow = {}
    mouse = {}
    scroll_mode = {}
    for layer, bs in bindings.items():
        for b in bs:
            lab = b["label"]
            arrow_key = lab if lab in ARROW_KEYS else None
            purpose = b.get("purpose", "")
            for candidate in ARROW_KEYS:
                if candidate in purpose:
                    arrow_key = candidate
                    break
            if arrow_key and arrow_key not in arrow:
                arrow[arrow_key] = (layer, b["x"], b["y"], b["hand"])
            if lab in MOUSE_KEYS and lab not in mouse:
                mouse[lab] = (layer, b["x"], b["y"], b["hand"])
            if ("Scroll" in lab or "scroll" in b["purpose"].lower() or lab.startswith("@access:")) and "Scroll" in lab:
                scroll_mode[lab] = (layer, b["x"], b["y"], b["hand"])

    return {
        "path": cp_path.name,
        "generation": gen,
        "objectives": obj,
        "total_score": total,
        "arrow": arrow,
        "mouse": mouse,
        "scroll_mode": scroll_mode,
        "bindings": bindings,
    }


def arrow_order_score(arrow):
    if len(arrow) < 4:
        return 0.0, "incomplete"
    left_x = arrow.get("LeftArrow", (None, 999, 0, None))[1]
    right_x = arrow.get("RightArrow", (None, -999, 0, None))[1]
    up_x = arrow.get("UpArrow", (None, 0, 0, None))[1]
    down_x = arrow.get("DownArrow", (None, 0, 0, None))[1]
    score = 1.0
    notes = []
    if left_x < right_x:
        notes.append("Left<Right OK")
    else:
        score = 0.0
        notes.append("Left>=Right FAIL")
    min_x, max_x = min(left_x, right_x), max(left_x, right_x)
    if not (min_x <= up_x <= max_x):
        score = 0.0
        notes.append("Up outside span FAIL")
    else:
        notes.append("Up inside span OK")
    if not (min_x <= down_x <= max_x):
        score = 0.0
        notes.append("Down outside span FAIL")
    else:
        notes.append("Down inside span OK")
    return score, "; ".join(notes)


def canonical_l7_arrows(data_dir: Path = DEFAULT_DATA_DIR):
    can = json.loads((data_dir / "canonical.json").read_text(encoding="utf-8"))
    l7 = can.get("layers", {}).get("7", {}).get("keys", {})
    arrows = {}
    for coord, binding in l7.items():
        param = binding.get("parameter", "")
        if param in ARROW_KEYS:
            x, y = coord.split(":")
            arrows[param] = (int(x), int(y))
    return arrows


def main():
    build_dir = DEFAULT_BUILD_DIR
    data_dir = DEFAULT_DATA_DIR
    target = None

    def resolve_data_dir(path):
        for parent in [path, *path.parents]:
            candidate = parent / "data"
            if (candidate / "app_shortcut_scores.json").exists() and (candidate / "canonical.json").exists():
                return candidate
        return DEFAULT_DATA_DIR

    if len(sys.argv) > 1:
        arg = Path(sys.argv[1])
        if arg.is_dir():
            build_dir = arg
            data_dir = resolve_data_dir(build_dir)
        else:
            target = arg
            if not target.exists():
                print("Checkpoint not found:", target)
                sys.exit(1)
            build_dir = target.parent
            data_dir = resolve_data_dir(build_dir)

    snapshot = load_optimizer_layout_snapshot(data_dir)
    if snapshot:
        shortcuts = snapshot["shortcuts"]
        positions = snapshot["positions"]
    else:
        shortcuts = load_shortcuts(data_dir)
        positions = load_positions(data_dir)
    if target is None:
        checkpoints = sorted(build_dir.glob("v2_checkpoint_gen*.json"), key=lambda p: p.stat().st_mtime)
        if not checkpoints:
            print("No checkpoints found in", build_dir)
            sys.exit(1)
        target = checkpoints[-1]
    result = analyze_checkpoint(target, shortcuts, positions)

    print(f"Checkpoint: {result['path']}  Generation: {result['generation']}")
    print(f"Objectives: {result['objectives']}")
    print(f"Total score: {result['total_score']}")
    print()

    print("=== Mouse Buttons ===")
    right_count = 0
    for k in MOUSE_KEYS:
        if k in result["mouse"]:
            layer, x, y, hand = result["mouse"][k]
            ok = "OK" if hand == "right" else "FAIL"
            if hand == "right":
                right_count += 1
            print(f"  {k}: L{layer} ({x},{y}) [{hand}] {ok}")
        else:
            print(f"  {k}: NOT FOUND")
    print(f"Right-hand mouse buttons: {right_count}/{len(MOUSE_KEYS)} ({100*right_count/len(MOUSE_KEYS):.0f}%)")
    print()

    print("=== Scroll Mode Access ===")
    if result["scroll_mode"]:
        for k, (layer, x, y, hand) in sorted(result["scroll_mode"].items()):
            print(f"  {k}: L{layer} ({x},{y}) [{hand}]")
    else:
        print("  no scroll-mode access found")
    print("  policy: ScrollUp/ScrollDown are not direct keypress assignments")
    print()

    print("=== Arrow Keys ===")
    for k in ARROW_KEYS:
        if k in result["arrow"]:
            layer, x, y, hand = result["arrow"][k]
            print(f"  {k}: L{layer} ({x},{y}) [{hand}]")
        else:
            print(f"  {k}: NOT FOUND")
    layers_with_arrows = {v[0] for v in result["arrow"].values()}
    print(f"Arrows grouped on same layer: {len(layers_with_arrows) <= 1} (layers: {layers_with_arrows})")
    score, note = arrow_order_score(result["arrow"])
    print(f"Arrow order score: {score:.0%} ({note})")
    print()

    print("=== Canonical L7 Arrow Reference ===")
    l7_arrows = canonical_l7_arrows(data_dir)
    for k in ARROW_KEYS:
        if k in l7_arrows:
            print(f"  {k}: L7 ({l7_arrows[k][0]},{l7_arrows[k][1]})")
        else:
            print(f"  {k}: not in L7")


if __name__ == "__main__":
    main()
