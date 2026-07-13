# Claude Current Handoff — Charybdis Tools

Date: 2026-07-09
Repo root: `/home/nos/charybdis/charybdis-tools`

> **2026-07-13 update:** the launcher was overhauled since this was written.
> `charybdis-tools/coach/` (the "coach monorepo copy... kept in sync with
> tools/coach" described below) was deleted — `charybdis-coach` is now the
> sole coach source, and `powershell/update_and_start_charybdis.ps1` /
> `bootstrap.ps1` / `Start-Charybdis.ps1` were replaced by `charybdis.ps1`.
> See `CLAUDE.md`'s "Launcher" and "Coach source" sections for the current
> state; treat the rest of this file as a historical snapshot, not current
> architecture.

This file is the current tactical handoff for continuing the recent Codex work.
It does not replace the durable repo rules in `AGENTS.md`, `CLAUDE.md`, or
`runtime/evolved_v2_export/HANDOFF_LAYOUT_OPTIMIZATION.md`; read those first.

## Current Repo Map

Sibling repos live under `/home/nos/charybdis/`:

- `charybdis-tools` — host helpers, coach monorepo copy, promotion tools.
- `charybdis-zmk-config` — ZMK Studio apply/verify scripts and layout metadata.
- `charybdis-coach` — standalone coach app copy, kept in sync with `tools/coach`.
- `charybdis-optimizer-v2` — current GPU/evolution optimizer and checkpoints.

## Non-Negotiable Working Rules

- Use existing layout tools first. Do not reverse-engineer checkpoint schemas or
  hand-write apply scripts.
- Do not hardcode `L2 = mouse`. The optimizer dynamically assigns layers.
- L7 is intentionally frozen. Do not report frozen L7 as an optimizer error.
- Toggle access may be on the same layer it toggles to. Momentary access has
  restrictions; toggle does not.
- Do not hand-edit generated CSV/apply/verify artifacts. Fix exporter,
  acceptance checker, or optimizer scoring instead.
- For default layout promotion, use `promote.py --default-only`; the user does
  not want archive JS clutter.
- Preserve unrelated untracked files. The worktree has old generated artifacts
  and runtime logs that should not be staged.

## Current Default Layout

Current default layout metadata in:

`/home/nos/charybdis/charybdis-zmk-config/layout/final_user_layout_v2.json`

Reports:

- name: `scroll_home_priority gen15000 (best gen 15000)`
- source_run: `run_scroll_home_priority`
- source_generation: `15000`
- best_generation: `15000`
- gap: `-312.663`
- source apply script:
  `/home/nos/charybdis/charybdis-zmk-config/scripts/zmk-studio/apply_every_key.js`
- `verified_in_zmk_studio`: `false`

Promoted checkpoint:

`/home/nos/charybdis/charybdis-optimizer-v2/build/runs/v2_scroll_home_priority_run_20260708_231923/v2_checkpoint_gen15000.json`

Standard tool results at promotion time:

- constraints all zero
- genome length `616`
- acceptance passed
- mouse layer dynamically detected as `L6`
- MB1-MB5 all on right side of mouse layer
- arrows form a valid L1 cluster
- mutable L0 contained only layer/scroll access:
  - pos 48 x3,y4 left effort 1.00 `@access:L3:toggle`
  - pos 50 x5,y4 left effort 1.00 `@access:L6:hold`
  - pos 51 x7,y4 right effort 1.00 `@scroll:L2:hold`
  - pos 52 x8,y4 right effort 0.00 `@access:L1:hold`
  - pos 53 x4,y5 left effort 1.00 `@access:L4:hold`
  - pos 54 x5,y5 left effort 1.50 `@access:L8:hold`

## Recent Commits

`charybdis-tools`:

- `78206d5 Preserve foreground app in Python state writers`
- `208b764 Add coach icon rendering fallback`
- `e6bd6d1 Remove emoji labels from coach HTML`
- `7b8317f Set gen15000 default layout data (scroll_home_priority, gap=-312.663)`
- `baaa184 Support layout.json in checkpoint acceptance check`

`charybdis-zmk-config`:

- `a28cbc3 Set gen15000 as default ZMK Studio layout (scroll_home_priority, gap=-312.663)`

`charybdis-coach`:

- `335f728 Add coach icon rendering fallback`
- `41d48fa Remove emoji labels from coach HTML`
- `d724589 Update keybindings CSV for gen15000 checkpoint layout (scroll_home_priority run, gap=-312.663)`

## Fixed Issues

### Python Beacon Active-App Race

Observed bug: `runtime/charybdis_state.json` sometimes showed
`activeApp: "Charybdis beacon listener"` while idle, even when the real
foreground app was Codex.

Root cause: both AHK and Python wrote the whole state file. AHK wrote real
foreground app labels; Python overwrote them with a hardcoded fake app.

Fix committed in `78206d5`:

- `python/coach_beacon_listener.py`
  - now reads the current state file and preserves `activeApp` and
    `launcherVisible`
  - no longer writes `"Charybdis beacon listener"` as `activeApp`
- `python/usb_state_monitor.py`
  - no longer defaults `activeApp` to `"USB Monitor"`
  - uses `"Unknown"` only when no prior state exists

Validation used:

```bash
python3 -m py_compile python/coach_beacon_listener.py python/usb_state_monitor.py
rg -n '"activeApp"\s*:\s*"(Charybdis beacon listener|USB Monitor)"' python
```

Also ran a focused temp-state test that preserved `Codex.exe - Codex` while
updating `beaconSource=python`.

### Coach Emoji/Mojibake Fallback

Observed bug: after Windows 25H2 reset language/locale settings, emoji labels
could render as mojibake such as `ÃƒÂ¢Ã…Â¡Ã‚Â¡ Last`.

Fixes:

- `e6bd6d1` removed fragile static emoji labels from `coach/index.html`.
- `208b764` added runtime icon fallback:
  - HTML keeps plain text as the source of truth.
  - `data-icon` markers are ASCII-only.
  - `coach/app.js` uses a canvas-based icon rendering check.
  - if icon rendering works, it prepends icons at runtime.
  - if icon rendering fails, it leaves normal text.
  - dynamic layer/app glyphs also fall back to text labels.

Same changes were mirrored to standalone `../charybdis-coach` in commits
`41d48fa` and `335f728`.

Validation used:

```bash
node --check coach/app.js
node --check /home/nos/charybdis/charybdis-coach/app.js
rg -n 'Ã|Â|â' coach/index.html coach/app.js /home/nos/charybdis/charybdis-coach/index.html /home/nos/charybdis/charybdis-coach/app.js
```

## Layout Promotion Workflow

Always use this standard workflow:

```bash
sed -n '1,240p' runtime/evolved_v2_export/HANDOFF_LAYOUT_OPTIMIZATION.md
pgrep -af run_evolution
cat /home/nos/charybdis/charybdis-optimizer-v2/build/latest_run_dir
ls -lt /home/nos/charybdis/charybdis-optimizer-v2/build/runs
```

If a user names a run directory, use that run directory as source of truth.
Otherwise prefer the active `pgrep -af run_evolution` output directory over
stale `latest_run_dir`.

For a specific checkpoint:

```bash
python3 runtime/evolved_v2_export/promote.py --checkpoint <checkpoint.json>
python3 runtime/evolved_v2_export/analyze_checkpoint_standalone.py <checkpoint.json>
NUMBA_DISABLE_JIT=1 /home/nos/charybdis/charybdis-optimizer-v2/.venv/bin/python runtime/evolved_v2_export/acceptance_check.py <checkpoint.json>
```

To promote as the default layout and push:

```bash
python3 runtime/evolved_v2_export/promote.py \
  --checkpoint <checkpoint.json> \
  --label <run_label> \
  --default-only \
  --commit \
  --push
```

Then verify:

```bash
node --check /home/nos/charybdis/charybdis-zmk-config/scripts/zmk-studio/apply_every_key.js
node --check /home/nos/charybdis/charybdis-zmk-config/scripts/zmk-studio/verify_every_key.js
python3 -c "import json; from pathlib import Path; d=json.loads(Path('/home/nos/charybdis/charybdis-zmk-config/layout/final_user_layout_v2.json').read_text()); print(d.get('name')); print(d.get('source_generation'), d.get('best_generation'), d.get('score_summary')); print(d.get('source_apply_script')); print(d.get('verified_in_zmk_studio'))"
```

Do not run `promote.py --mark-verified` unless the user actually applied and
verified the layout in ZMK Studio.

## Acceptance Checker Note

`runtime/evolved_v2_export/acceptance_check.py` was updated in `baaa184` because
optimizer-v2 now uses `data/layout.json` instead of the old `data/canonical.json`.
It supports both schemas. If acceptance fails because of file shape drift, fix
the checker/tool, not the generated output.

## Active Optimizer State

At the time this handoff was written:

```bash
pgrep -af run_evolution
```

returned no active optimizer process.

If the user says “latest run,” check again; do not trust this snapshot.

## Current Known Worktree Noise

These untracked files/directories have existed as local/runtime noise and should
not be staged unless explicitly requested:

- `charybdis_events.jsonl`
- `shortcut_usage.jsonl`
- `powershell/pull_and_apply_layout.ps1`
- `runtime/evolved_v2_export/__pycache__/`
- older `runtime/evolved_v2_export/run17_*`, `run18_*`, `run20_*`, `test_*`
  artifacts
- old ZMK archive apply/verify scripts in
  `/home/nos/charybdis/charybdis-zmk-config/scripts/zmk-studio/`

## Useful One-Command Runtime Refresh

On Windows, after pulling, the intended one-command refresh is:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\nos\charybdis-tools\powershell\update_and_start_charybdis.ps1
```

It pulls sibling repos, updates cache-busters, validates JS/AHK, restarts helper,
beacon, and coach, then prints PIDs and the coach URL.

## What To Watch Next

- If active app display still flickers, inspect actual writer timestamps in
  `runtime/charybdis_state.json` and `runtime/charybdis_events.jsonl`; do not
  assume AHK foreground detection is broken before checking Python state writes.
- If emoji/mojibake persists, inspect served HTML/JS bytes and cache-busting;
  the current source should safely fall back to plain text.
- If a new optimizer run is requested, wait for retained checkpoints, then use
  the standard tools above.
- The current default layout is useful but not ZMK-Studio-verified yet.

