"""Merge a discovered-shortcuts export into the canonical shortcut corpus.

Usage:
    python python/merge_shortcut_export.py runtime/discovered_shortcuts.json

This updates the per-app source files in
../charybdis-optimizer-v2/data/shortcuts_source/ and regenerates the optimizer
and coach output JSONs.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# Import the shared corpus module from the optimizer repo.
_CORPUS_DIR = Path(__file__).parent.parent.parent / "charybdis-optimizer-v2" / "tools"
sys.path.insert(0, str(_CORPUS_DIR))

from shortcut_corpus import (  # noqa: E402
    DEFAULT_SOURCES_DIR,
    Shortcut,
    generate_coach_json,
    generate_optimizer_json,
    load_all_apps,
    save_app,
    slugify,
)


def normalize_keys(keys: str) -> str:
    """Normalize a key combo for deduplication."""
    parts = [p.strip() for p in keys.split("+")]
    # Sort modifiers, keep base key last.
    modifiers = {"ctrl", "alt", "shift", "win", "command", "cmd", "meta"}
    mods = [p for p in parts if p.lower() in modifiers]
    base = [p for p in parts if p.lower() not in modifiers]
    return "+".join(mods + base).lower()


def merge_app(app, discovered_shortcuts: list[dict]) -> bool:
    """Merge discovered shortcuts into an app. Returns True if changed."""
    existing = {normalize_keys(sc.keys) for sc in app.shortcuts}
    changed = False
    for raw in discovered_shortcuts:
        keys = raw.get("keys", "").strip()
        if not keys:
            continue
        norm = normalize_keys(keys)
        if norm in existing:
            continue
        # Skip bare single letters / typing keys.
        if re.fullmatch(r"[a-zA-Z0-9]", keys):
            continue
        app.shortcuts.append(
            Shortcut(
                keys=keys,
                action=raw.get("action", ""),
                category=raw.get("category", "general"),
                frequency=raw.get("frequency", "medium"),
                importance=float(raw.get("importance", 5.0)),
                preferred_hand=raw.get("preferred_hand", "either"),
            )
        )
        existing.add(norm)
        changed = True
    return changed


def main() -> None:
    parser = argparse.ArgumentParser(description="Merge discovered shortcuts into corpus.")
    parser.add_argument("export", type=Path, help="Path to discovered_shortcuts.json")
    parser.add_argument(
        "--sources",
        type=Path,
        default=DEFAULT_SOURCES_DIR,
        help="Canonical source directory.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would change without writing files.",
    )
    args = parser.parse_args()

    with open(args.export, "r", encoding="utf-8") as f:
        export = json.load(f)

    apps = {a.id: a for a in load_all_apps(args.sources)}
    changes: list[tuple[str, int]] = []

    for app_data in export.get("discoveredApps", []):
        app_id = slugify(app_data.get("id", app_data.get("name", "")))
        app_name = app_data.get("name", "")
        shortcuts = app_data.get("shortcuts", [])

        app = apps.get(app_id)
        if not app:
            # Try to match by name slug.
            name_id = slugify(app_name)
            app = apps.get(name_id)
        if not app:
            # Create a new app entry.
            app = __import__("shortcut_corpus").App(
                id=app_id,
                name=app_name,
                exe_names=app_data.get("exeNames", []),
                expected_count=len(shortcuts),
                shortcuts=[],
            )
            apps[app_id] = app

        before = len(app.shortcuts)
        if merge_app(app, shortcuts):
            changes.append((app.name, len(app.shortcuts) - before))

    if not changes:
        print("No new shortcuts to merge.")
        return

    print(f"Would merge new shortcuts into {len(changes)} apps:")
    for name, count in changes:
        print(f"  {name}: +{count}")

    if args.dry_run:
        return

    for app in apps.values():
        save_app(app, args.sources)

    # Regenerate outputs.
    app_list = sorted(apps.values(), key=lambda a: a.id)
    opt_data = generate_optimizer_json(app_list)
    opt_data["timestamp"] = export.get("generatedAt", "")
    coach_data = generate_coach_json(app_list)

    opt_path = args.sources.parent / "app_shortcut_scores.json"
    coach_path = (
        args.sources.parent.parent.parent
        / "charybdis-coach"
        / "data"
        / "app_shortcut_reference.json"
    )

    with open(opt_path, "w", encoding="utf-8") as f:
        json.dump(opt_data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    with open(coach_path, "w", encoding="utf-8") as f:
        json.dump(coach_data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"Regenerated {opt_path}")
    print(f"Regenerated {coach_path}")


if __name__ == "__main__":
    main()
