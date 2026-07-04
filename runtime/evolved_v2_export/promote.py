#!/usr/bin/env python3
"""Check and/or promote an optimizer-v2 checkpoint to the live default layout.

Automates the repeated manual workflow of: pick a checkpoint -> export via
export_and_analyze_linux.py -> validate (syntax, key count, layer balance,
behavior sanity) -> copy into charybdis-zmk-config / charybdis-coach ->
update final_user_layout_v2.json -> optionally git commit/push across all
three repos.

Usage:
  promote.py --list                          # gap table for all kept checkpoints, no export
  promote.py                                 # auto-pick best checkpoint, check only (dry run)
  promote.py --checkpoint PATH               # check a specific checkpoint, dry run
  promote.py --apply                         # check + export + propagate files (no git)
  promote.py --apply --commit                # also git commit in all 3 repos
  promote.py --apply --commit --push         # also git push
  promote.py --mark-verified                 # flip verified_in_zmk_studio on the currently
                                              # applied layout after you've confirmed it in
                                              # ZMK Studio (add --commit/--push to persist)

The "gap" is computed the same way as optimizer-v2/tools/best.py:
sum(best_objectives) + 49.30. That constant is this project's fitness
scaling offset; if the fitness function is ever rescaled, update GAP_OFFSET
here to match tools/best.py.
"""
import argparse
import csv as csvmod
import json
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

OPTIMIZER_DIR = Path("/home/nos/charybdis/charybdis-optimizer-v2")
BUILD_DIR = OPTIMIZER_DIR / "build"
TOOLS_DIR = Path("/home/nos/charybdis/charybdis-tools")
EXPORT_DIR = TOOLS_DIR / "runtime/evolved_v2_export"
ZMK_DIR = Path("/home/nos/charybdis/charybdis-zmk-config")
COACH_DIR = Path("/home/nos/charybdis/charybdis-coach")
EXPORTER = EXPORT_DIR / "export_and_analyze_linux.py"
GAP_OFFSET = 49.30
EXPECTED_KEYS = 616
EXPECTED_PER_LAYER = 56


def gap_of(checkpoint_json):
    return sum(checkpoint_json.get("best_objectives", [])) + GAP_OFFSET


def _gen_number(path):
    m = re.search(r"gen(\d+)", path.name)
    if not m:
        sys.exit(f"Checkpoint filename doesn't match v2_checkpoint_gen<N>.json: {path.name}")
    return int(m.group(1))


def all_checkpoints():
    files = sorted(BUILD_DIR.glob("v2_checkpoint_gen*.json"), key=_gen_number)
    if not files:
        sys.exit(f"No checkpoints found in {BUILD_DIR}")
    return files


def checkpoint_stats(path):
    d = json.loads(path.read_text())
    return {
        "path": path,
        "generation": d.get("generation"),
        "best_generation": d.get("best_generation"),
        "best_source": d.get("best_source"),
        "gap": gap_of(d),
        "constraints": d.get("best_constraints", []),
        "genome_len": len(d.get("best_genome", [])),
    }


def find_best_checkpoint():
    stats = [checkpoint_stats(f) for f in all_checkpoints()]
    stats.sort(key=lambda s: s["gap"])
    return stats[0]


def list_checkpoints():
    stats = [checkpoint_stats(f) for f in all_checkpoints()]
    for s in stats:
        print(f"  gen{s['generation']:>6} (best_gen={s['best_generation']:>6}): "
              f"gap={s['gap']:+.3f}  G={s['constraints']}  source={s['best_source']}")
    best = min(stats, key=lambda s: s["gap"])
    print(f"\nBEST: {best['path'].name}  gap={best['gap']:+.3f}")
    return best


def next_run_number():
    nums = []
    for f in EXPORT_DIR.glob("run*_*_apply.js"):
        m = re.match(r"run(\d+)_", f.name)
        if m:
            nums.append(int(m.group(1)))
    return max(nums, default=0) + 1


def run_export(checkpoint_path, prefix):
    result = subprocess.run(
        [sys.executable, str(EXPORTER), "--checkpoint", str(checkpoint_path), "--prefix", prefix],
        cwd=EXPORT_DIR, capture_output=True, text=True,
    )
    print(result.stdout.strip())
    if result.returncode != 0:
        print(result.stderr)
        sys.exit("Export failed")


def node_check(path):
    r = subprocess.run(["node", "--check", str(path)], capture_output=True, text=True)
    return r.returncode == 0, r.stderr


def validate_export(prefix):
    apply_js = EXPORT_DIR / f"{prefix}_apply.js"
    verify_js = EXPORT_DIR / f"{prefix}_verify.js"
    csv_path = EXPORT_DIR / f"{prefix}_keybindings_explained.csv"

    ok, err = node_check(apply_js)
    if not ok:
        sys.exit(f"apply.js syntax error:\n{err}")
    ok, err = node_check(verify_js)
    if not ok:
        sys.exit(f"verify.js syntax error:\n{err}")

    layer_counts = Counter()
    behavior_counts = Counter()
    with open(csv_path) as f:
        for row in csvmod.DictReader(f):
            layer_counts[row["layer"]] += 1
            behavior_counts[row["behavior"]] += 1

    total_keys = sum(layer_counts.values())
    layers_uniform = total_keys == EXPECTED_KEYS and set(layer_counts.values()) == {EXPECTED_PER_LAYER}
    transparent = behavior_counts.get("Transparent", 0)
    mouse = behavior_counts.get("Mouse Key Press", 0)

    print(f"  Syntax: OK  |  Keys: {total_keys}/{EXPECTED_KEYS}  |  layers uniform: {layers_uniform}")
    print(f"  Transparent: {transparent}  |  Mouse Key Press: {mouse}")
    print(f"  Behaviors: {dict(behavior_counts)}")
    if not layers_uniform:
        print("  WARNING: layer distribution not uniform 56/layer - inspect before applying")

    return {
        "apply_js": apply_js, "verify_js": verify_js, "csv_path": csv_path,
        "total_keys": total_keys, "layers_uniform": layers_uniform,
        "transparent": transparent, "mouse": mouse,
    }


def propagate(validated, run_label, generation, best_generation, gap):
    apply_js, verify_js, csv_path = validated["apply_js"], validated["verify_js"], validated["csv_path"]

    (ZMK_DIR / "layout/keybindings_explained.csv").write_bytes(csv_path.read_bytes())
    (ZMK_DIR / "scripts/zmk-studio/apply_every_key.js").write_bytes(apply_js.read_bytes())
    (ZMK_DIR / "scripts/zmk-studio/verify_every_key.js").write_bytes(verify_js.read_bytes())
    archive_apply = ZMK_DIR / f"scripts/zmk-studio/apply_v2_current_best_gen{generation}_{run_label}.js"
    archive_verify = ZMK_DIR / f"scripts/zmk-studio/verify_v2_current_best_gen{generation}_{run_label}.js"
    archive_apply.write_bytes(apply_js.read_bytes())
    archive_verify.write_bytes(verify_js.read_bytes())

    (COACH_DIR / "data/keybindings_explained.csv").write_bytes(csv_path.read_bytes())

    text = apply_js.read_text()
    start = text.find("window.CHARYBDIS_FINAL_LAYOUT = ") + len("window.CHARYBDIS_FINAL_LAYOUT = ")
    end = text.find("\nwindow.CHARYBDIS_MODE = ", start)
    layout = json.loads(text[start:end].rstrip().rstrip(";"))
    layout["name"] = f"{run_label} gen{generation} (best gen {best_generation})"
    layout["source_run"] = f"run_{run_label}"
    layout["source_generation"] = generation
    layout["best_generation"] = best_generation
    layout["source_apply_script"] = str(apply_js)
    layout["source_verify_script"] = str(verify_js)
    layout["source_csv"] = str(csv_path)
    layout["verified_in_zmk_studio"] = False
    layout["verify_result"] = {
        "pass": None, "fail": None, "percent": None,
        "note": f"Run verify_every_key.js in ZMK Studio after applying {run_label} gen{generation}.",
    }
    layout["score_summary"] = {"run": run_label, "best_generation": best_generation, "gap": round(gap, 3)}
    (ZMK_DIR / "layout/final_user_layout_v2.json").write_text(json.dumps(layout, indent=2))

    print(f"\nPropagated to zmk-config + coach (gap={gap:+.3f}).")
    print(f"  Apply:  {ZMK_DIR / 'scripts/zmk-studio/apply_every_key.js'}")
    print(f"  Verify: {ZMK_DIR / 'scripts/zmk-studio/verify_every_key.js'}")
    return archive_apply, archive_verify


def git_run(cmd, cwd):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if r.stdout.strip():
        print(f"  [{cwd.name}] {r.stdout.strip()}")
    if r.returncode != 0 and r.stderr.strip():
        print(f"  [{cwd.name}] {r.stderr.strip()}")
    return r.returncode == 0


def commit_and_push(export_prefix, archive_apply, archive_verify, run_label, generation, gap, push):
    coauthor = "Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>"

    tools_files = [
        f"runtime/evolved_v2_export/{export_prefix}_apply.js",
        f"runtime/evolved_v2_export/{export_prefix}_verify.js",
        f"runtime/evolved_v2_export/{export_prefix}_keybindings_explained.csv",
        f"runtime/evolved_v2_export/{export_prefix}_diff.txt",
        "runtime/evolved_v2_export/selected_candidate.json",
        "runtime/evolved_v2_export/evolved_changes.json",
    ]
    git_run(["git", "add", *tools_files], cwd=TOOLS_DIR)
    git_run(["git", "commit", "-m",
             f"Export gen{generation} checkpoint layout ({run_label} run, gap={gap:+.3f})\n\n{coauthor}"],
            cwd=TOOLS_DIR)

    zmk_files = [
        "layout/final_user_layout_v2.json",
        "layout/keybindings_explained.csv",
        "scripts/zmk-studio/apply_every_key.js",
        "scripts/zmk-studio/verify_every_key.js",
        str(archive_apply.relative_to(ZMK_DIR)),
        str(archive_verify.relative_to(ZMK_DIR)),
    ]
    git_run(["git", "add", *zmk_files], cwd=ZMK_DIR)
    git_run(["git", "commit", "-m",
             f"Apply gen{generation} checkpoint layout ({run_label} run, gap={gap:+.3f})\n\n{coauthor}"],
            cwd=ZMK_DIR)

    git_run(["git", "add", "data/keybindings_explained.csv"], cwd=COACH_DIR)
    git_run(["git", "commit", "-m",
             f"Update keybindings CSV for gen{generation} checkpoint layout ({run_label} run, gap={gap:+.3f})\n\n{coauthor}"],
            cwd=COACH_DIR)

    if push:
        for repo in (TOOLS_DIR, ZMK_DIR, COACH_DIR):
            git_run(["git", "push"], cwd=repo)


def mark_verified(commit, push):
    meta_path = ZMK_DIR / "layout/final_user_layout_v2.json"
    layout = json.loads(meta_path.read_text())
    layout["verified_in_zmk_studio"] = True
    layout["verify_result"] = {"pass": True, "fail": None, "percent": 100, "note": "Confirmed applied in ZMK Studio."}
    meta_path.write_text(json.dumps(layout, indent=2))
    print(f"Marked verified_in_zmk_studio=true in {meta_path}")
    if commit:
        coauthor = "Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>"
        git_run(["git", "add", "layout/final_user_layout_v2.json"], cwd=ZMK_DIR)
        git_run(["git", "commit", "-m", f"Mark layout as verified in ZMK Studio\n\n{coauthor}"], cwd=ZMK_DIR)
        if push:
            git_run(["git", "push"], cwd=ZMK_DIR)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--checkpoint", type=Path, help="Specific checkpoint path; default = best by gap in build/")
    ap.add_argument("--label", default="auto", help="Run label used in filenames/commit messages (e.g. v19)")
    ap.add_argument("--apply", action="store_true", help="Export and propagate files into zmk-config/coach")
    ap.add_argument("--commit", action="store_true", help="Also git commit in all 3 repos (implies --apply)")
    ap.add_argument("--push", action="store_true", help="Also git push (implies --commit)")
    ap.add_argument("--list", action="store_true", help="Print gap table for all kept checkpoints and exit")
    ap.add_argument("--mark-verified", action="store_true",
                    help="Flip verified_in_zmk_studio on the currently applied layout and exit")
    args = ap.parse_args()

    if args.push:
        args.commit = True
    if args.commit:
        args.apply = True

    if args.list:
        list_checkpoints()
        return

    if args.mark_verified:
        mark_verified(commit=args.commit, push=args.push)
        return

    if args.checkpoint:
        stats = checkpoint_stats(args.checkpoint)
    else:
        stats = find_best_checkpoint()
        print(f"Auto-picked best checkpoint by gap: {stats['path'].name}")

    print(f"Checkpoint: {stats['path']}")
    print(f"  generation={stats['generation']}  best_generation={stats['best_generation']}  "
          f"source={stats['best_source']}")
    print(f"  gap={stats['gap']:+.3f}  constraints={stats['constraints']}  genome_len={stats['genome_len']}")

    if stats["genome_len"] != EXPECTED_KEYS:
        sys.exit(f"genome length {stats['genome_len']} != expected {EXPECTED_KEYS}, refusing to proceed")
    if any(c != 0 for c in stats["constraints"]):
        print("WARNING: hard constraints not all satisfied (G != all-zero) - review before applying")

    if not args.apply:
        print("\nDry run only (no --apply). Re-run with --apply to export and propagate.")
        return

    run_number = next_run_number()
    prefix = f"run{run_number}_{args.label}_gen{stats['generation']}_bestgen{stats['best_generation']}"
    print(f"\nExporting as prefix: {prefix}")
    run_export(stats["path"], prefix)

    print("\nValidating export:")
    validated = validate_export(prefix)

    archive_apply, archive_verify = propagate(
        validated, args.label, stats["generation"], stats["best_generation"], stats["gap"]
    )

    if args.commit:
        print("\nCommitting:")
        commit_and_push(prefix, archive_apply, archive_verify, args.label,
                         stats["generation"], stats["gap"], push=args.push)

    print("\nDone. verified_in_zmk_studio=false — run apply -> verify in ZMK Studio, "
          "then `promote.py --mark-verified --commit --push`.")


if __name__ == "__main__":
    main()
