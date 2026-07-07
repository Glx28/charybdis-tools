# Handoff: Charybdis Keyboard Layout Optimization Pipeline

Written 2026-07-06 for a future AI agent (e.g. Kimi) picking up this work cold.
Goal of this doc: let you find/analyze the latest evolved keyboard layout genome
and apply it to the live ZMK Studio config without re-deriving any of the below.

## The system in one paragraph

`charybdis-optimizer-v2` runs a GPU-accelerated genetic algorithm (DEAP-style
custom GA + PyTorch surrogate model) that evolves a 616-position keymap
(56 physical keys x 11 layers) for a Charybdis split keyboard, scoring genomes
against real shortcut-usage data logged from the user's machine. It periodically
writes checkpoint JSON files. A separate exporter turns the best checkpoint's
genome into a ZMK Studio browser-console script, which gets pasted into ZMK
Studio to actually flash the layout onto the keyboard. `promote.py` (in this
directory) automates the entire check -> export -> validate -> propagate ->
commit -> push chain across the three affected repos.

## Repo map (siblings under `/home/nos/charybdis/`)

- `charybdis-optimizer-v2` — the GA/evolution engine. `config_v2.yaml` (fitness
  weights, hard constraints), `run_evolution.py` (entry point), `build/`
  (checkpoints), `build/runs/<run_name>/` (per-run isolated checkpoint dirs).
  Branch: master. Has pre-existing unrelated uncommitted diffs — leave them.
- `charybdis-tools` — **this repo**. Was just consolidated as a monorepo: as of
  commit `66ff9a7` ("Consolidate: merge coach into tools repo"), the former
  `charybdis-coach` repo's files now also live at `charybdis-tools/coach/` in
  addition to the separate `charybdis-coach` repo still existing on disk. Both
  currently get updated in parallel by `promote.py` — check `coach/data/` vs
  `../charybdis-coach/data/` for drift if things look inconsistent. Branch: master.
  This is where `runtime/evolved_v2_export/` (exporter, `promote.py`, all
  `runN_*` export artifacts) lives.
- `charybdis-zmk-config` — ZMK firmware config. **Branch:
  `codex/build-coach-layers-cpi750`** (not main/master — always check
  `git branch --show-current` before assuming). Key paths:
  - `scripts/zmk-studio/apply_every_key.js` — the live "paste this in ZMK
    Studio devtools console" script. Gets overwritten every promotion.
  - `scripts/zmk-studio/verify_every_key.js` — companion verify script, run
    after applying + saving in ZMK Studio to confirm the keyboard matches.
  - `layout/final_user_layout_v2.json` — metadata about the currently-applied
    layout (source run/generation, gap, `verified_in_zmk_studio` flag).
  - `layout/keybindings_explained.csv` — human-readable per-key breakdown.
- `charybdis-coach` — browser-based interactive layout coach app (`app.js`,
  served locally). Reads `data/keybindings_explained.csv` for per-layer
  visualization/labeling. Also mirrored into `charybdis-tools/coach/` now.

## Checkpoint file schema

```json
{
  "generation": 23500,               // raw generation counter when file was written
  "best_generation": 4379,           // generation the ALL-TIME best genome was found at
  "best_source": "global_exact_archive",
  "best_genome": [ ...616 ints... ], // the actual layout, one behavior-index per position
  "best_objectives": [0.063, -54.74, 0.34],  // multi-objective fitness vector
  "best_constraints": [0.0, 0.0, 0.0, 0.0, 0.0]  // hard constraint violations (all-zero = satisfied)
}
```

Important: `generation` (current GA progress) and `best_generation` (when the
best-ever genome was found) diverge constantly — a run can be at gen 57500 while
its best genome hasn't changed since gen 500. **Checkpoints auto-prune to the
last 5 per run directory** — old best-generations can vanish from disk even
though the genome is preserved (identical `best_genome`) in every subsequent
checkpoint that still references that same `best_generation`.

## The gap formula (critical, verified against `optimizer-v2/tools/best.py`)

```
gap = sum(checkpoint["best_objectives"]) + 49.30
```

`49.30` is `GAP_OFFSET` in `promote.py` — an empirical scaling constant matching
`tools/best.py`. **Lower (more negative) gap = better.** Sort ascending, take
`[0]`. If the fitness function or `config_v2.yaml` weights are ever rescaled,
this constant must be re-derived (re-run `tools/best.py` and compare) or all
gap comparisons across old vs. new runs become invalid.

Do NOT compare gaps across runs blindly if you suspect the weights changed —
check `config_v2.yaml`'s `fitness.weights` / `violation_sub_weights` /
`hard_constraints` haven't shifted since the checkpoint was produced.

## `promote.py` — the one tool you need

Location: `charybdis-tools/runtime/evolved_v2_export/promote.py`

```
promote.py --list                          # gap table for all kept checkpoints in optimizer-v2/build/, no export
promote.py                                 # auto-pick best checkpoint in build/, dry run (no files touched)
promote.py --checkpoint PATH               # check one specific checkpoint file, dry run
promote.py --label v20 --apply             # export + propagate into zmk-config/coach (no git)
promote.py --label v20 --apply --commit    # also commit in all 3 repos
promote.py --label v20 --apply --commit --push   # also push
promote.py --mark-verified [--commit] [--push]   # flip verified_in_zmk_studio=true — ONLY after
                                                  # you've genuinely applied+verified in ZMK Studio
```

Caveats baked into the script (don't fight them, they're intentional):
- `--label` is a free-text tag for filenames/commit messages (e.g. `v20`,
  `v22`, matching whatever the active optimizer run calls itself in its log
  filename). Doesn't have to be sequential or globally unique.
- Auto-pick (`find_best_checkpoint()`) only scans
  `OPTIMIZER_DIR/build/*.json` (i.e. `v2_checkpoint_gen*.json` directly in
  `build/`, **not** inside `build/runs/<name>/`). If the active run writes
  into a `build/runs/<timestamp>/` subdirectory (as newer "infinite" runs do),
  you must pass `--checkpoint <full path>` explicitly — auto-pick will not
  find it.
- Refuses to proceed if `genome_len != 616` or prints a loud warning if hard
  constraints (`best_constraints`) aren't all-zero — read that warning, don't
  just override it.
- Commits are scoped to exactly the files touched (never blanket `git add -A`).
- `evolved_v2_export/selected_candidate.json` and `evolved_changes.json` are
  overwritten by every exporter invocation, including exploratory ones from
  other agents/sessions — don't trust their contents as "the current best"
  without cross-checking against the `runN_*` prefix you actually just built.
- Stale unprefixed `evolved_apply.js`/`evolved_verify.js`/etc. files
  (no `runN_` prefix) show up in `git status` periodically from other
  sessions running the exporter with default args — leave them alone, don't
  stage them, they're not part of your promotion.

## How to find "the latest best run" (do this, don't guess)

1. Check for active runs: `pgrep -af run_evolution` — if a PID is returned,
   there's a live GA process. Note its output dir (printed at launch, or in
   `build/runs/<name>/output_dir.txt`).
2. If the run writes into `build/runs/<name>/`, list its checkpoints there
   directly and read the newest one's `best_generation`/`best_objectives` —
   `promote.py --list` won't see it.
3. Compute `gap` yourself with the formula above, or use
   `promote.py --checkpoint <path>` for a dry-run report (syntax-checks +
   prints gap/constraints without touching anything).
4. **Compare against whatever's currently live**, don't just take the newest
   file on disk — a newer/later checkpoint is not necessarily a *better* one.
   Read `charybdis-zmk-config/layout/final_user_layout_v2.json`'s
   `score_summary.gap` for the current baseline before promoting anything.
5. A run can look "active" by PID but have flatlined for tens of thousands of
   generations (`no real improvement for ~N gens` in the log) — that's not a
   bug, just diminishing returns; don't assume the newest checkpoint from a
   long-stagnant run beats an older one from a different run.

## Current state as of 2026-07-06 22:52

- **Live/applied layout**: `run_v20`, source checkpoint gen23500,
  `best_generation=4379`, **gap=-5.068**, all hard constraints satisfied.
  Applied via `promote.py --label v20 --apply --commit --push`. Committed as
  `charybdis-tools` `881e336`, `charybdis-zmk-config` `31b15b2`.
  `verified_in_zmk_studio` is **still false** — nobody has confirmed an actual
  apply+verify pass in ZMK Studio for this genome yet.
- **`build/runs/infinite_20260706_193611/`** (PID 43090, launched 19:36,
  `-g 999999999`): best found once at gen500 (`gap=-5.039`, slightly *worse*
  than the currently-live -5.068) and flatlined every generation since —
  56,500+ stagnant generations by the last checkpoint (gen57500, 22:05).
  **As of this writing the process is no longer running** (`pgrep` finds
  nothing, log stopped updating at 22:33, no error/traceback in the log, no
  `v2_evolution_results.json` written — it died without a clean exit, cause
  unconfirmed: could be a killed shell, WSL hiccup, or manual stop). Nothing
  in this run beats the current default; no promotion needed from it as-is.
- Several dozen other historical run directories exist under `build/runs/`
  (experiments named `v2_test_*`, `smoke_*`, `speed_*`, etc.) — these are
  past one-off experiments, not candidates to promote from unless explicitly
  told to look at one by name.

## ZMK Studio apply/verify mechanics (why this can't be fully scripted)

`apply_every_key.js` / `verify_every_key.js` are meant to be **pasted directly
into the ZMK Studio web app's browser devtools console** — ZMK Studio has no
CLI/API for this. The apply script prompts for confirmation and deliberately
does NOT click Save; the human must click Save in the UI, then paste the
verify script to confirm the keyboard's actual state matches. This is why
`verified_in_zmk_studio` in `final_user_layout_v2.json` must be treated as
untrustworthy until a human explicitly reports back that they did this — never
flip it via `--mark-verified` speculatively or during script testing (this
mistake happened once already this project; it was caught and reverted in
`charybdis-zmk-config` commit `ba89ec7`).

## Known gotchas

- `git push` from this WSL environment prints a harmless-looking but noisy
  line: `/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe
  store: 1: /mnt/c/Program: not found` — this is a broken credential helper
  invocation, NOT a push failure. Check the actual push result line
  (`master -> master` etc.) below it, or `git log --oneline HEAD..origin/...`
  afterward, rather than trusting the stderr noise.
- `charybdis-tools` and `charybdis-coach` remotes can drift out of sync with
  local pushes from concurrent sessions — always `git fetch` + check
  `ahead`/`behind` before pushing if a push gets rejected; merge (not rebase)
  has been conflict-free so far since the two sessions' changes touch disjoint
  paths (export artifacts vs. coach/monorepo restructuring).
- Per `CLAUDE.md` optimizer rules: never freeze/protect layer-key positions in
  the genome, never hand-patch CSV/apply-script output — if something looks
  wrong, fix the fitness function or the exporter, not the generated files.

## Suggested first actions for a fresh agent

1. `pgrep -af run_evolution` — see if anything is currently running.
2. `cd charybdis-tools/runtime/evolved_v2_export && python3 promote.py --list`
   — see the gap table for whatever's in `optimizer-v2/build/` right now.
3. Read `charybdis-zmk-config/layout/final_user_layout_v2.json` for the
   current baseline gap to compare against.
4. If a better checkpoint exists (lower gap, hard constraints satisfied,
   genome_len=616), run
   `promote.py --checkpoint <path> --label <name> --apply --commit --push`.
5. Report the new gap, the apply/verify script paths, and remind the user
   `verified_in_zmk_studio` needs a real ZMK Studio confirmation before
   `--mark-verified` is ever run.
