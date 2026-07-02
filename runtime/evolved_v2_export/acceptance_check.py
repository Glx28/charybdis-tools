"""Acceptance contract checker for an evolved Charybdis layout checkpoint.

Reads a v2 checkpoint JSON and reports pass/fail for the goal acceptance
criteria.  Does not require the checkpoint to match the current optimizer
shortcut list exactly; it rebuilds the layout from the current data files.
"""
import json
import sys
from pathlib import Path

import numpy as np


class NumpyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        if isinstance(obj, np.floating):
            return float(obj)
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        return super().default(obj)

sys.path.insert(0, str(Path("/home/nos/charybdis/charybdis-optimizer-v2")))
from core.loader import build_layout
from core.norwegian_keys import RAW_COMPLETION_NORWEGIAN, parse_shortcut_keys_norwegian


OPTIMIZER_DATA_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/data")


def load_checkpoint(path: str):
    cp = json.loads(Path(path).read_text(encoding="utf-8"))
    layout = build_layout(str(OPTIMIZER_DATA_DIR)).clone_with(
        genome=np.array(cp["best_genome"], dtype=np.int32)
    )
    return cp, layout


def valid_hid_parameters(canonical_data: dict):
    """Collect all parameter strings that appear in canonical.json keypress bindings."""
    valid = set()
    for layer_data in canonical_data.get("layers", {}).values():
        for key_data in layer_data.get("keys", {}).values():
            param = key_data.get("parameter", "")
            if param:
                valid.add(param)
            label = key_data.get("label", "")
            if label:
                valid.add(label)
    return valid


def check_completion_cluster(layout):
    family = set(RAW_COMPLETION_NORWEGIAN)
    base_by_layer = {}
    all_layers = set()
    for i, sid in enumerate(layout.genome):
        if sid < 0:
            continue
        sc = layout.shortcuts[sid]
        if sc.base_key not in family:
            continue
        pos = layout.positions[i]
        if pos.layer == 7 or pos.is_frozen:
            continue
        all_layers.add(pos.layer)
        if sc.modifiers:
            continue
        base_by_layer.setdefault(pos.layer, []).append(
            (sc.base_key, float(pos.x), float(pos.y))
        )

    anchor_layer = None
    best_unique = -1
    for layer, items in base_by_layer.items():
        unique = len({k for k, _, _ in items})
        if unique > best_unique:
            best_unique = unique
            anchor_layer = layer

    present = set()
    if anchor_layer is not None:
        present = {k for k, _, _ in base_by_layer[anchor_layer]}
    missing = family - present

    ordered = True
    compactness = 0.0
    if anchor_layer is not None:
        items = base_by_layer[anchor_layer]
        xs = [x for _, x, _ in items]
        ys = [y for _, _, y in items]
        if xs:
            x_span = max(xs) - min(xs)
            y_span = max(ys) - min(ys)
            inversions = 0
            order_map = {k: i for i, k in enumerate(RAW_COMPLETION_NORWEGIAN)}
            sorted_by_x = sorted(items, key=lambda t: t[1])
            for i in range(len(sorted_by_x)):
                for j in range(i + 1, len(sorted_by_x)):
                    if order_map[sorted_by_x[i][0]] > order_map[sorted_by_x[j][0]]:
                        inversions += 1
            compactness = (
                len(items) * 10.0
                - x_span * 1.5
                - max(0.0, y_span - 1.0) * 4.0
                - inversions * 5.0
            )
            # Loose left-to-right check: allow a few out-of-order pairs.
            ordered = inversions <= 1

    raw_base_layers = len(base_by_layer)
    family_layers = len(all_layers)

    return {
        "anchor_layer": anchor_layer,
        "raw_base_present": sorted(present),
        "raw_base_missing": sorted(missing),
        "raw_base_layers_used": raw_base_layers,
        "family_layers_used": family_layers,
        "compactness_order_score": round(compactness, 3),
        "ordered_left_to_right": ordered,
        "pass": (
            family_layers <= 2
            and raw_base_layers == 1
            and len(missing) == 0
            and compactness > 0
        ),
    }


def check_duplicates(cp):
    dr = cp.get("duplicate_report", {})
    unsupported = dr.get("unsupported_duplicates", [])
    return {
        "unsupported_duplicates": len(unsupported),
        "pass": len(unsupported) == 0,
    }


def check_mouse_and_scroll(layout):
    mouse_keys = {"MB1", "MB2", "MB3", "MB4", "MB5"}
    fake_scroll = {"ScrollUp", "ScrollDown"}
    mouse = {}
    fake = []
    scroll_access = []
    for i, sid in enumerate(layout.genome):
        if sid < 0:
            continue
        sc = layout.shortcuts[sid]
        pos = layout.positions[i]
        if sc.keys in mouse_keys:
            mouse[sc.keys] = (int(pos.layer), float(pos.x), float(pos.y), pos.hand, float(pos.effort))
        if sc.keys in fake_scroll:
            fake.append(sc.keys)
        if sc.is_layer_access and ("Scroll" in sc.keys or "scroll" in sc.action.lower()):
            scroll_access.append((sc.keys, int(pos.layer), float(pos.x), float(pos.y), pos.hand, float(pos.effort)))

    right_mouse = sum(1 for v in mouse.values() if v[3] == "right")
    avg_mouse_effort = sum(v[4] for v in mouse.values()) / len(mouse) if mouse else 999.0
    avg_scroll_effort = sum(a[5] for a in scroll_access) / len(scroll_access) if scroll_access else 999.0
    # The layout should not fake scroll keypresses, must expose all five mouse
    # buttons, and both mouse buttons and scroll-mode access should have low
    # effective access cost.  Handedness is reported but not hard-required.
    passes = (
        len(fake) == 0
        and len(mouse) == 5
        and avg_mouse_effort <= 1.6
        and len(scroll_access) > 0
        and avg_scroll_effort <= 1.6
    )
    return {
        "mouse_buttons_found": len(mouse),
        "right_hand_mouse": f"{right_mouse}/{len(mouse)}",
        "avg_mouse_effort": round(avg_mouse_effort, 3),
        "avg_scroll_effort": round(avg_scroll_effort, 3),
        "fake_scroll_keypresses": fake,
        "scroll_mode_access": scroll_access,
        "pass": passes,
    }


def check_arrows(layout):
    arrow_keys = {"LeftArrow", "RightArrow", "UpArrow", "DownArrow"}
    arrows = {}
    for i, sid in enumerate(layout.genome):
        if sid < 0:
            continue
        sc = layout.shortcuts[sid]
        if sc.base_key in arrow_keys and not sc.modifiers:
            pos = layout.positions[i]
            if not pos.is_frozen:
                arrows[sc.base_key] = (int(pos.layer), float(pos.x), float(pos.y))
    layers = {v[0] for v in arrows.values()}
    # Complete cluster: exactly one of each arrow on a single non-L7 layer and
    # ordered (left < right, up above down, up/down centered over left/right).
    complete = False
    if len(arrows) == 4 and len(layers) == 1:
        left = arrows.get("LeftArrow")
        right = arrows.get("RightArrow")
        up = arrows.get("UpArrow")
        down = arrows.get("DownArrow")
        if left and right and up and down:
            ordered = left[1] < right[1] and up[2] < down[2]
            centered = (
                min(left[1], right[1]) <= up[1] <= max(left[1], right[1])
                and min(left[1], right[1]) <= down[1] <= max(left[1], right[1])
            )
            complete = ordered and centered
    return {
        "non_frozen_arrows": arrows,
        "pass": len(arrows) == 0 or complete,
    }


def check_win_s(layout):
    for i, sid in enumerate(layout.genome):
        if sid < 0:
            continue
        sc = layout.shortcuts[sid]
        if sc.keys == "Win+S":
            pos = layout.positions[i]
            return {
                "found": True,
                "layer": int(pos.layer),
                "x": float(pos.x),
                "y": float(pos.y),
                "hand": pos.hand,
                "importance": float(sc.importance),
                "pass": True,
            }
    return {"found": False, "pass": False}


def check_l7_frozen(layout, canonical_data: dict):
    """Verify that frozen L7 keys are still present in the genome."""
    l7 = canonical_data.get("layers", {}).get("7", {}).get("keys", {})
    errors = []
    for coord, key_data in l7.items():
        behavior = str(key_data.get("behavior", "")).lower()
        if behavior in ("transparent", "none", "", "mouse") or "mouse" in behavior:
            continue
        x, y = (int(v) for v in coord.split(":"))
        for pos in layout.positions:
            if pos.layer == 7 and pos.x == x and pos.y == y:
                sid = int(layout.genome[pos.gene_idx])
                if sid < 0:
                    errors.append(f"L7 {coord} empty")
                else:
                    sc = layout.shortcuts[sid]
                    if not sc.keys:
                        errors.append(f"L7 {coord} has empty shortcut")
                break
    return {"frozen_l7_errors": errors, "pass": len(errors) == 0}


def check_bad_literals(layout, canonical_data: dict):
    valid = valid_hid_parameters(canonical_data)
    # Also accept canonical HID names from parse_shortcut_keys_norwegian outputs.
    valid.update({
        "Escape", "Tab", "LeftShift", "RightShift", "LeftControl", "RightControl",
        "LeftAlt", "RightAlt", "LeftGui", "Spacebar", "Return Enter", "Delete",
        "Home", "End", "PageUp", "PageDown", "LeftArrow", "RightArrow", "UpArrow",
        "DownArrow", "Insert", "PrintScreen", "Pause", "Menu", "Shift",
    })
    # F-keys are valid ZMK keycodes.
    valid.update({f"F{i}" for i in range(1, 25)})
    bad = []
    for i, sid in enumerate(layout.genome):
        if sid < 0:
            continue
        sc = layout.shortcuts[sid]
        if sc.is_layer_access or sc.is_l0_only or sc.keys.startswith("_base_"):
            continue
        # Skip mouse buttons and special capabilities
        if sc.keys in {"MB1", "MB2", "MB3", "MB4", "MB5"}:
            continue
        _, base = parse_shortcut_keys_norwegian(sc.keys)
        if not base:
            # Some shortcuts (e.g. sequences) may not parse; ignore.
            continue
        if base not in valid:
            bad.append({"sid": sid, "keys": sc.keys, "base": base})
    return {"bad_literal_count": len(bad), "examples": bad[:10], "pass": len(bad) == 0}


def main():
    if len(sys.argv) < 2:
        print("Usage: acceptance_check.py <checkpoint.json>")
        sys.exit(1)
    cp_path = sys.argv[1]
    cp, layout = load_checkpoint(cp_path)
    canonical_data = json.loads(Path("/home/nos/charybdis/charybdis-optimizer-v2/data/canonical.json").read_text(encoding="utf-8"))

    results = {
        "checkpoint": Path(cp_path).name,
        "generation": cp.get("generation"),
        "total_score": cp.get("best_exact", {}).get("total_score"),
        "completion_cluster": check_completion_cluster(layout),
        "duplicates": check_duplicates(cp),
        "mouse_scroll": check_mouse_and_scroll(layout),
        "arrows": check_arrows(layout),
        "win_s": check_win_s(layout),
        "l7_frozen": check_l7_frozen(layout, canonical_data),
        "bad_literals": check_bad_literals(layout, canonical_data),
    }

    all_pass = all(r["pass"] for r in results.values() if isinstance(r, dict) and "pass" in r)
    results["ALL_ACCEPTANCE_CHECKS_PASS"] = all_pass

    print(json.dumps(results, indent=2, cls=NumpyEncoder))
    sys.exit(0 if all_pass else 1)


if __name__ == "__main__":
    main()
