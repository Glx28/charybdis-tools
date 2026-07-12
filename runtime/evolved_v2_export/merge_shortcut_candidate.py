"""Fold a reviewed shortcut_candidates/<exe>.json draft (written by
shortcut_discovery.py) into coach/data/app_shortcut_reference.json - the live
file the coach inspector reads. Kept as a separate, explicit step from
discovery on purpose: discovery is fully automatic (a script, not a human,
finds the gaps and drafts the data), but a bad shortcut entry silently
poisons the optimizer's fitness scoring once it reaches app_shortcut_scores.json
downstream, so this one step stays a deliberate "yes, merge this" instead of
a second unattended write. See CLAUDE.md's optimizer rule: fix data via
verified sources, never guesses.

Usage:
  merge_shortcut_candidate.py <exe>              # dry run: show what would merge
  merge_shortcut_candidate.py <exe> --apply       # write it into both
                                                   # app_shortcut_reference.json copies
  merge_shortcut_candidate.py --list              # show all candidates and their status
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

TOOLS_DIR = Path(__file__).resolve().parent.parent.parent
CANDIDATES_DIR = Path(__file__).resolve().parent / "shortcut_candidates"
REFERENCE_PATHS = [
    TOOLS_DIR / "coach" / "data" / "app_shortcut_reference.json",
    TOOLS_DIR.parent / "charybdis-coach" / "data" / "app_shortcut_reference.json",
]


def load_candidate(exe_stem: str) -> dict:
    path = CANDIDATES_DIR / f"{exe_stem}.json"
    if not path.exists():
        sys.exit(f"No candidate file at {path}. Run shortcut_discovery.py first.")
    return json.loads(path.read_text(encoding="utf-8"))


def list_candidates() -> None:
    if not CANDIDATES_DIR.exists() or not any(CANDIDATES_DIR.glob("*.json")):
        print("No shortcut candidates found yet.")
        return
    for path in sorted(CANDIDATES_DIR.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        print(f"  {path.stem}: status={data['status']}, "
              f"usage={data.get('usage_count')}x, "
              f"{len(data.get('shortcuts', []))} shortcut(s), "
              f"discovered {data.get('discovered_at')}")


def merge(exe_stem: str, apply: bool) -> None:
    candidate = load_candidate(exe_stem)
    shortcuts = candidate.get("shortcuts", [])
    display_name = candidate["display_name"]
    exe = candidate["app_exe"]

    if not shortcuts:
        print(f"{exe_stem}: no shortcuts in this candidate (status={candidate['status']}) - nothing to merge.")
        return

    print(f"Candidate: {display_name} ({exe}), usage={candidate['usage_count']}x, "
          f"status={candidate['status']}")
    print(f"Sources: {', '.join(candidate.get('sources_tried', [])) or '(none)'}")
    print(f"\n{len(shortcuts)} shortcut(s) to merge into app_shortcut_reference.json[\"{display_name}\"]:")
    for s in shortcuts:
        print(f"  {s['keys']!r}: {s['action']!r}  (from {s.get('extracted_from')}, {s.get('source_url')})")

    if not apply:
        print("\nDry run only. Re-run with --apply once you've eyeballed these for accuracy.")
        return

    for ref_path in REFERENCE_PATHS:
        if not ref_path.exists():
            continue
        data = json.loads(ref_path.read_text(encoding="utf-8"))
        apps = data.setdefault("apps", {})
        entry = apps.setdefault(display_name, {"exeNames": [], "shortcuts": {}})
        if exe not in entry["exeNames"]:
            entry["exeNames"].append(exe)
        for s in shortcuts:
            entry["shortcuts"].setdefault(s["keys"], s["action"])
        ref_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
        print(f"Merged into {ref_path}")

    candidate["status"] = "approved"
    candidate_path = CANDIDATES_DIR / f"{exe_stem}.json"
    candidate_path.write_text(json.dumps(candidate, indent=2) + "\n", encoding="utf-8")
    print(f"Marked {candidate_path} as approved (won't be re-drafted by future discovery runs).")


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    if sys.argv[1] == "--list":
        list_candidates()
        return
    exe_stem = sys.argv[1].lower().replace(".exe", "")
    apply = "--apply" in sys.argv[2:]
    merge(exe_stem, apply)


if __name__ == "__main__":
    main()
