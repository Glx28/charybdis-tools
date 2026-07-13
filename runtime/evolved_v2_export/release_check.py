"""Validate the currently-deployed Charybdis release against
release_manifest.json before a launcher restarts anything.

Reuses acceptance_check.py's named-checks-dict + all(...) + sys.exit(0/1)
pattern, and promote.py's EXPECTED_KEYS/per-layer constants, but works
purely off already-promoted files (CSV, apply/verify JS, git commits) - it
does not touch the optimizer checkpoint or its numpy/DEAP dependencies, so it
stays cheap enough to run on every `charybdis.ps1 update`/`doctor`.

Usage: release_check.py  (reads release_manifest.json at the tools repo root)
Exit code 0 = all checks pass, 1 = at least one failed. Prints a JSON report
either way.
"""
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
from collections import Counter
from pathlib import Path

TOOLS_DIR = Path(__file__).resolve().parent.parent.parent
ZMK_DIR = TOOLS_DIR.parent / "charybdis-zmk-config"
COACH_DIR = TOOLS_DIR.parent / "charybdis-coach"
MANIFEST_PATH = TOOLS_DIR / "release_manifest.json"

EXPECTED_KEYS = 616
EXPECTED_PER_LAYER = 56
REQUIRED_BEHAVIOR_PREFIXES = ("coach_l1_", "coach_l2_", "coach_base")


def git_head(path: Path) -> str:
    r = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=path, capture_output=True, text=True)
    return r.stdout.strip()


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_manifest_exists() -> dict:
    return {"pass": MANIFEST_PATH.exists(), "path": str(MANIFEST_PATH)}


def check_commits(manifest: dict) -> dict:
    zmk_head = git_head(ZMK_DIR)
    coach_head = git_head(COACH_DIR)
    ok = (zmk_head == manifest["commits"]["zmk"]) and (coach_head == manifest["commits"]["coach"])
    return {
        "pass": ok,
        "zmk_expected": manifest["commits"]["zmk"], "zmk_actual": zmk_head,
        "coach_expected": manifest["commits"]["coach"], "coach_actual": coach_head,
    }


def check_csv_hashes(manifest: dict) -> dict:
    zmk_csv = ZMK_DIR / "layout/keybindings_explained.csv"
    coach_csv = COACH_DIR / "data/keybindings_explained.csv"
    if not (zmk_csv.exists() and coach_csv.exists()):
        return {"pass": False, "detail": "one or both CSV copies missing"}
    zmk_hash = sha256_of(zmk_csv)
    coach_hash = sha256_of(coach_csv)
    expected = manifest["csv_sha256"]
    return {
        "pass": zmk_hash == coach_hash == expected,
        "zmk": zmk_hash, "coach": coach_hash, "manifest": expected,
    }


def check_csv_shape() -> dict:
    csv_path = ZMK_DIR / "layout/keybindings_explained.csv"
    if not csv_path.exists():
        return {"pass": False, "detail": f"missing {csv_path}"}
    import csv as csvmod
    layer_counts = Counter()
    behavior_counts = Counter()
    with open(csv_path, newline="", encoding="utf-8") as f:
        for row in csvmod.DictReader(f):
            layer_counts[row["layer"]] += 1
            behavior_counts[row["behavior"]] += 1
    total_keys = sum(layer_counts.values())
    uniform = total_keys == EXPECTED_KEYS and set(layer_counts.values()) == {EXPECTED_PER_LAYER}
    missing_required = [
        prefix for prefix in REQUIRED_BEHAVIOR_PREFIXES
        if not any(b.startswith(prefix) for b in behavior_counts)
    ]
    return {
        "pass": uniform and not missing_required,
        "total_keys": total_keys, "expected_keys": EXPECTED_KEYS,
        "layers_uniform": uniform, "missing_required_behaviors": missing_required,
    }


def check_apply_verify_layout_matches_csv() -> dict:
    """Confirm apply_every_key.js's embedded window.CHARYBDIS_FINAL_LAYOUT
    binding count matches the CSV row count - the same source-of-truth
    extraction promote.py's propagate() already performs."""
    apply_js = ZMK_DIR / "scripts/zmk-studio/apply_every_key.js"
    csv_path = ZMK_DIR / "layout/keybindings_explained.csv"
    if not (apply_js.exists() and csv_path.exists()):
        return {"pass": False, "detail": "apply_every_key.js or CSV missing"}
    text = apply_js.read_text(encoding="utf-8")
    start = text.find("window.CHARYBDIS_FINAL_LAYOUT = ")
    if start == -1:
        return {"pass": False, "detail": "window.CHARYBDIS_FINAL_LAYOUT not found in apply_every_key.js"}
    start += len("window.CHARYBDIS_FINAL_LAYOUT = ")
    end = text.find("\nwindow.CHARYBDIS_MODE = ", start)
    try:
        layout = json.loads(text[start:end].rstrip().rstrip(";"))
    except json.JSONDecodeError as exc:
        return {"pass": False, "detail": f"could not parse embedded layout JSON: {exc}"}
    with open(csv_path, newline="", encoding="utf-8") as f:
        import csv as csvmod
        csv_rows = sum(1 for _ in csvmod.DictReader(f))
    layout_len = len(layout) if isinstance(layout, list) else len(layout.get("keys", layout))
    return {"pass": layout_len == csv_rows, "layout_bindings": layout_len, "csv_rows": csv_rows}


def main() -> int:
    if not MANIFEST_PATH.exists():
        print(json.dumps({"manifest_exists": {"pass": False}, "ALL_RELEASE_CHECKS_PASS": False}, indent=2))
        return 1

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    results = {
        "release": manifest.get("release"),
        "manifest_exists": check_manifest_exists(),
        "commits_match": check_commits(manifest),
        "csv_hashes_match": check_csv_hashes(manifest),
        "csv_shape": check_csv_shape(),
        "apply_verify_layout_matches_csv": check_apply_verify_layout_matches_csv(),
    }
    all_pass = all(r["pass"] for r in results.values() if isinstance(r, dict) and "pass" in r)
    results["ALL_RELEASE_CHECKS_PASS"] = all_pass

    print(json.dumps(results, indent=2))
    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())
