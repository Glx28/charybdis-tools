"""Standalone checkpoint analyzer — no optimizer modules required.

Reads:
  /home/nos/charybdis/charybdis-optimizer/build/app_shortcut_scores.json
  /home/nos/charybdis/charybdis-optimizer/build/canonical.json
  /home/nos/charybdis/charybdis-optimizer/build/v2_checkpoint_gen*.json

Analyzes mouse-button right-hand bias and arrow-key grouping/order.
"""
import json
import sys
from collections import defaultdict
from pathlib import Path

DEFAULT_BUILD_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/build")
DEFAULT_DATA_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/data")
OUT_DIR = Path("/home/nos/charybdis/charybdis-tools/runtime/evolved_v2_export")

ARROW_KEYS = {"LeftArrow", "RightArrow", "UpArrow", "DownArrow"}
MOUSE_KEYS = {"MB1", "MB2", "MB3", "MB4", "MB5"}
SCROLL_KEYS = {"ScrollUp", "ScrollDown"}


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

    for app_data in data.get("apps", []):
        app_name = app_data.get("name", "unknown")
        for sc_data in app_data.get("shortcuts", []):
            keys = sc_data.get("keys", "")
            if keys in seen_keys:
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
            })
    return positions


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
                label = pos["label"]  # fallback to canonical
                purpose = pos["purpose"]
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
    scroll = {}
    for layer, bs in bindings.items():
        for b in bs:
            lab = b["label"]
            if lab in ARROW_KEYS and lab not in arrow:
                arrow[lab] = (layer, b["x"], b["y"], b["hand"])
            if lab in MOUSE_KEYS and lab not in mouse:
                mouse[lab] = (layer, b["x"], b["y"], b["hand"])
            if lab in SCROLL_KEYS and lab not in scroll:
                scroll[lab] = (layer, b["x"], b["y"], b["hand"])

    return {
        "path": cp_path.name,
        "generation": gen,
        "objectives": obj,
        "total_score": total,
        "arrow": arrow,
        "mouse": mouse,
        "scroll": scroll,
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

    print("=== Scroll Keys ===")
    for k in SCROLL_KEYS:
        if k in result["scroll"]:
            layer, x, y, hand = result["scroll"][k]
            print(f"  {k}: L{layer} ({x},{y}) [{hand}]")
        else:
            print(f"  {k}: NOT FOUND")
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
