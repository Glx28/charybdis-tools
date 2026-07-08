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
from core.norwegian_keys import (
    LITERAL_TO_HID_PARAMETER,
    RAW_COMPLETION_NORWEGIAN,
    canonical_hid_parameter,
    parse_shortcut_keys_norwegian,
)
from evolution.arrow_cluster import analyze_arrows
from evolution.acceptance import _dynamic_mouse_layer_report
from evolution.completion_cluster import analyze_completion_cluster


OPTIMIZER_DATA_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2/data")


def load_checkpoint(path: str):
    cp = json.loads(Path(path).read_text(encoding="utf-8"))
    layout = build_layout(str(OPTIMIZER_DATA_DIR)).clone_with(
        genome=np.array(cp["best_genome"], dtype=np.int32)
    )
    return cp, layout


def load_canonical_layout_data():
    canonical = OPTIMIZER_DATA_DIR / "canonical.json"
    if canonical.exists():
        return json.loads(canonical.read_text(encoding="utf-8"))
    layout_json = OPTIMIZER_DATA_DIR / "layout.json"
    if layout_json.exists():
        return json.loads(layout_json.read_text(encoding="utf-8"))
    raise FileNotFoundError(f"No canonical layout data found in {OPTIMIZER_DATA_DIR}")


def iter_layout_key_data(canonical_data: dict):
    if "layers" in canonical_data:
        for layer_data in canonical_data.get("layers", {}).values():
            for key_data in layer_data.get("keys", {}).values():
                yield key_data
        return
    for section in ("l0_frozen", "l7_frozen"):
        for key_data in canonical_data.get(section, {}).values():
            yield key_data


def valid_hid_parameters(canonical_data: dict):
    """Collect all parameter strings that appear in canonical layout keypress bindings."""
    valid = set()
    for key_data in iter_layout_key_data(canonical_data):
        param = key_data.get("parameter", "")
        if param:
            valid.add(param)
            valid.add(str(param).replace("Keyboard ", ""))
            valid.add(canonical_hid_parameter(param))
        label = key_data.get("label", "")
        if label:
            valid.add(label)
            valid.add(canonical_hid_parameter(label))
    valid.update(LITERAL_TO_HID_PARAMETER.values())
    return valid


def check_completion_cluster(layout):
    report = analyze_completion_cluster(layout)
    return {
        "anchor_layer": report["anchor_layer"],
        "raw_base_present": report["raw_base_keys_present"],
        "raw_base_missing": report["raw_base_keys_missing"],
        "raw_base_layers_used": report["raw_base_layers_used"],
        "raw_base_layers": report["raw_base_layers"],
        "family_layers_used": len(report["all_family_layers"]),
        "family_layers": report["all_family_layers"],
        "compactness_order_score": report["compactness_order_score"],
        "shape_preserved": report["ordered_left_to_right"],
        "pass": report["acceptance_pass"],
    }


def check_duplicates(cp):
    dr = cp.get("duplicate_report", {})
    unsupported = dr.get("unsupported_duplicates", [])
    return {
        "unsupported_duplicates": len(unsupported),
        "pass": len(unsupported) == 0,
    }


def check_mouse_and_scroll(layout):
    fake_scroll = {"ScrollUp", "ScrollDown"}
    fake = []
    scroll_access = []
    dynamic_report = _dynamic_mouse_layer_report(layout)
    for i, sid in enumerate(layout.genome):
        if sid < 0:
            continue
        sc = layout.shortcuts[sid]
        pos = layout.positions[i]
        if sc.keys in fake_scroll:
            fake.append(sc.keys)
        if sc.is_layer_access and ("Scroll" in sc.keys or "scroll" in sc.action.lower()):
            scroll_access.append((sc.keys, int(pos.layer), float(pos.x), float(pos.y), pos.hand, float(pos.effort)))

    avg_scroll_effort = sum(a[5] for a in scroll_access) / len(scroll_access) if scroll_access else 999.0
    best = dynamic_report.get("best_candidate") or {}
    buttons = best.get("button_keys_present", [])
    passes = len(fake) == 0 and bool(dynamic_report.get("acceptance_pass"))
    return {
        "mouse_layer": dynamic_report.get("mouse_layer"),
        "mouse_buttons_found_on_mouse_layer": len(buttons),
        "mouse_buttons_on_mouse_layer": buttons,
        "dynamic_mouse_layer_acceptance": dynamic_report.get("acceptance_pass"),
        "avg_scroll_effort": round(avg_scroll_effort, 3),
        "fake_scroll_keypresses": fake,
        "scroll_mode_access": scroll_access,
        "best_candidate": best,
        "pass": passes,
    }


def check_arrows(layout):
    report = analyze_arrows(layout)
    return {
        "non_frozen_arrows": report["placements"],
        "layers": report["layers"],
        "is_complete_cluster": report["is_complete_cluster"],
        "allowed_cluster_shape": report["allowed_cluster_shape"],
        "allowed_shapes": report["allowed_shapes"],
        "pass": report["acceptance_pass"],
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
    """Verify canonical L7 is frozen in the physical layout.

    L7 content is intentionally frozen and may not be represented by mutable
    genome SIDs in checkpoints.  Do not treat frozen canonical keys as genome
    omissions.
    """
    if "layers" in canonical_data:
        l7 = canonical_data.get("layers", {}).get("7", {}).get("keys", {})
    else:
        l7 = canonical_data.get("l7_frozen", {})
    errors = []
    pos_by_coord = {
        f"{int(pos.x)}:{int(pos.y)}": pos
        for pos in layout.positions
        if int(pos.layer) == 7
    }
    for coord, key_data in l7.items():
        behavior = str(key_data.get("behavior", "")).lower()
        if behavior in ("transparent", "none", "", "mouse") or "mouse" in behavior:
            continue
        pos = pos_by_coord.get(coord)
        if pos is None:
            errors.append(f"L7 {coord} missing physical position")
        elif not pos.is_frozen:
            errors.append(f"L7 {coord} is not frozen")
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
    canonical_data = load_canonical_layout_data()

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
