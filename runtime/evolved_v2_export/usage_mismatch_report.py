"""Real-usage-vs-CSV-importance mismatch report.

Compares real logged shortcut usage (shortcut_usage.jsonl) against the
static importance values baked into a freshly-exported layout CSV, and
prints any meaningful divergence. Read-only, advisory only - never blocks
or fails promotion; this is visibility, not a gate. See CLAUDE.md's
"Shortcut Usage Tracker" section for the root-vs-runtime/ path-drift
context this resolver works around.

Called from promote.py's main() right after validate_export() succeeds.
Can also be run standalone: usage_mismatch_report.py <exported_csv_path>
"""
from __future__ import annotations

import csv as csv_module
import json
import re
import sys
from collections import Counter
from pathlib import Path

TOOLS_DIR = Path(__file__).resolve().parent.parent.parent
APP_REFERENCE_PATH = TOOLS_DIR / "coach" / "data" / "app_shortcut_reference.json"
WORKFLOWS_DIR = TOOLS_DIR / "coach" / "workflows"
APPS_JSON_PATH = TOOLS_DIR / "coach" / "data" / "charybdis_apps.json"

TOP_N = 10
MISMATCH_MIN_COUNT = 10  # ignore noise below this many real occurrences
LOW_IMPORTANCE_THRESHOLD = 2.0
HIGH_IMPORTANCE_THRESHOLD = 8.0

USAGE_NOTE_RE = re.compile(r"App:\s*([^,]+?)\s*,\s*importance=([\d.]+)")


def resolve_usage_log_path() -> Path:
    """Repo root first, then runtime/ - same order as
    ../charybdis-optimizer-v2/pipeline/aggregate_usage.js's USAGE_CANDIDATES."""
    root = TOOLS_DIR / "shortcut_usage.jsonl"
    if root.exists():
        return root
    return TOOLS_DIR / "runtime" / "shortcut_usage.jsonl"


def load_exe_to_app_map() -> dict[str, str]:
    if not APP_REFERENCE_PATH.exists():
        return {}
    data = json.loads(APP_REFERENCE_PATH.read_text(encoding="utf-8"))
    exe_to_app: dict[str, str] = {}
    for app_name, app_data in data.get("apps", {}).items():
        for exe in app_data.get("exeNames", []):
            exe_to_app[exe.lower()] = app_name
    return exe_to_app


def load_real_usage_counts(usage_log_path: Path) -> Counter:
    """Counter keyed by (exe_lower, keys) -> count, from real 'shortcut' events."""
    counts: Counter = Counter()
    if not usage_log_path.exists():
        return counts
    with open(usage_log_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if event.get("type") != "shortcut":
                continue
            exe = str(event.get("app", "")).strip().lower()
            keys = str(event.get("keys", "")).strip()
            if not exe or not keys:
                continue
            counts[(exe, keys)] += 1
    return counts


def load_csv_importance(csv_path: Path) -> dict[str, tuple[str, float]]:
    """keys (visual_label) -> (app_name, importance), from an exported CSV."""
    result: dict[str, tuple[str, float]] = {}
    if not csv_path.exists():
        return result
    with open(csv_path, newline="", encoding="utf-8") as f:
        for row in csv_module.DictReader(f):
            label = row.get("visual_label", "").strip()
            notes = row.get("usage_notes", "")
            match = USAGE_NOTE_RE.search(notes)
            if not label or not match:
                continue
            app_name = match.group(1).strip()
            importance = float(match.group(2))
            existing = result.get(label)
            if existing is None or importance > existing[1]:
                result[label] = (app_name, importance)
    return result


def load_known_app_ids() -> set[str]:
    known: set[str] = set()
    if APPS_JSON_PATH.exists():
        apps_data = json.loads(APPS_JSON_PATH.read_text(encoding="utf-8"))
        for app in apps_data.get("apps", []):
            known.add(str(app.get("id", "")).lower())
            for alias in app.get("aliases", []):
                known.add(str(alias).lower())
    if WORKFLOWS_DIR.exists():
        for wf in WORKFLOWS_DIR.glob("*.json"):
            known.add(wf.stem.lower())
    return known


def report(csv_path: Path) -> None:
    print("\n=== Real-usage-vs-CSV-importance mismatch report (advisory only) ===")

    usage_log_path = resolve_usage_log_path()
    if not usage_log_path.exists():
        print("  Usage log unavailable (checked repo root and runtime/) - skipping.")
        return

    real_counts = load_real_usage_counts(usage_log_path)
    if not real_counts:
        print(f"  Usage log at {usage_log_path} has no parseable 'shortcut' events - skipping.")
        return

    exe_to_app = load_exe_to_app_map()
    csv_importance = load_csv_importance(csv_path)
    if not csv_importance:
        print(f"  Could not parse importance data from {csv_path} - skipping.")
        return

    # Aggregate real counts by (display_app, keys), summed across exe aliases
    # (e.g. chrome.exe + msedge.exe both roll up to "Browser (Chrome/Edge)").
    by_app_keys: Counter = Counter()
    for (exe, keys), count in real_counts.items():
        app_name = exe_to_app.get(exe, exe)
        by_app_keys[(app_name, keys)] += count

    # 1. Top real-usage shortcuts with no/low/mis-attributed CSV importance.
    under_scored = []
    for (app_name, keys), count in by_app_keys.items():
        if count < MISMATCH_MIN_COUNT:
            continue
        entry = csv_importance.get(keys)
        if entry is None:
            under_scored.append((count, keys, app_name, None, None))
        else:
            csv_app, importance = entry
            if importance < LOW_IMPORTANCE_THRESHOLD or csv_app != app_name:
                under_scored.append((count, keys, app_name, csv_app, importance))
    under_scored.sort(key=lambda row: -row[0])

    print(f"\n  Real shortcuts your CSV under-values or mis-attributes (top {TOP_N}):")
    if not under_scored:
        print("    None found.")
    for count, keys, real_app, csv_app, importance in under_scored[:TOP_N]:
        if csv_app is None:
            print(f"    {keys!r} used {count}x in {real_app} - no CSV entry for this app at all")
        elif csv_app != real_app:
            print(f"    {keys!r} used {count}x in {real_app} - CSV attributes it to {csv_app!r} instead (importance={importance})")
        else:
            print(f"    {keys!r} used {count}x in {real_app} - CSV importance is only {importance}")

    # 2. High-importance CSV rows with zero observed real usage.
    real_by_keys: Counter = Counter()
    for (_app_name, keys), count in by_app_keys.items():
        real_by_keys[keys] += count

    over_scored = [
        (importance, keys, app_name)
        for keys, (app_name, importance) in csv_importance.items()
        if importance >= HIGH_IMPORTANCE_THRESHOLD and real_by_keys.get(keys, 0) == 0
    ]
    over_scored.sort(key=lambda row: -row[0])

    print(f"\n  High-importance CSV shortcuts with zero observed real usage (top {TOP_N}):")
    if not over_scored:
        print("    None found.")
    for importance, keys, app_name in over_scored[:TOP_N]:
        print(f"    {keys!r} ({app_name}) - importance={importance}, never observed in the usage log")

    # 3. Apps with real usage but no launcher/workflow/reference representation.
    known_app_ids = load_known_app_ids()
    exe_totals: Counter = Counter()
    for (exe, _keys), count in real_counts.items():
        exe_totals[exe] += count

    unrepresented = []
    for exe, count in exe_totals.items():
        if count < MISMATCH_MIN_COUNT or exe in exe_to_app:
            continue
        exe_stem = exe.replace(".exe", "")
        if exe_stem in known_app_ids or exe in known_app_ids:
            continue
        unrepresented.append((count, exe))
    unrepresented.sort(key=lambda row: -row[0])

    print(f"\n  Apps with real usage but no launcher/workflow/shortcut-reference entry anywhere (top {TOP_N}):")
    if not unrepresented:
        print("    None found.")
    for count, exe in unrepresented[:TOP_N]:
        print(f"    {exe} - {count} real shortcut events, no representation in charybdis_apps.json, coach/workflows/, or app_shortcut_reference.json")

    print()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: usage_mismatch_report.py <exported_keybindings_csv_path>")
        sys.exit(1)
    report(Path(sys.argv[1]))
