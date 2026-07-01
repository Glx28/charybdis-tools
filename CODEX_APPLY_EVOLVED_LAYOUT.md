# Codex Task: Apply Evolved Layout from Optimizer Run 7

## Objective

Extract the best layout from the optimizer's latest 1000-generation evolution run and apply it across all sibling repos. This is a READ from the optimizer repo, WRITE to the other repos. **Do NOT modify any files in `../charybdis-optimizer/` — treat it as read-only.**

## Repos (all in same parent directory)

| Repo | Path | Role in this task |
|------|------|-------------------|
| `charybdis-optimizer` | `../charybdis-optimizer` | **READ ONLY** — source of evolved layout |
| `charybdis-zmk-config` | `../charybdis-zmk-config` | Update layout CSV, apply script, verify script |
| `charybdis-coach` | `../charybdis-coach` | Copy updated layout data files |
| `charybdis-tools` | `.` (this repo) | Archive old usage data, update AHK if needed |

---

## Step 1: Generate the Apply/Verify Scripts

The optimizer has tools to export the best evolved genome to ZMK Studio scripts. Run these from the optimizer repo (read-only — they only write to `build/`):

```powershell
cd C:\Users\nos\charybdis-optimizer\evolve

# Generate apply script (reads evolution_scratch_results.json, writes evolved_apply.js)
python export_zmk.py ../build --scratch

# Generate verify script (reads evolved_apply.js, writes evolved_verify.js)  
python generate_verify.py ../build
```

**IMPORTANT:** The export script (`export_zmk.py`) currently reads `evolution_results.json` (non-scratch). It needs the `--scratch` flag or you need to check if it supports scratch results. If it doesn't:

```python
# Fallback: manually load the best genome and export
cd C:\Users\nos\charybdis-optimizer\evolve
python -c "
import json, sys
sys.path.insert(0, '.')
from representation import build_position_index, build_shortcut_pool
from export_zmk import export_genome_to_zmk, generate_apply_script
from layer_access import LayerAccessAnalyzer

canonical = json.load(open('../build/canonical.json', encoding='utf-8'))
scores = json.load(open('../build/app_shortcut_scores.json', encoding='utf-8'))
results = json.load(open('../build/evolution_scratch_results.json', encoding='utf-8'))

positions = build_position_index(canonical, {7})
pool = build_shortcut_pool(scores, canonical)

# Use the smart selection: feasible (viol<200), lowest effort
candidates = list(results.get('pareto_front', []))
for key in ('best_weighted', 'best_effort', 'best_violations'):
    entry = results.get(key)
    if entry and entry.get('genome'):
        candidates.append(entry)

feasible = [c for c in candidates if c['fitness']['violations'] < 200]
if feasible:
    best = min(feasible, key=lambda x: x['fitness']['effort'])
    print(f'Selected feasible: eff={best[\"fitness\"][\"effort\"]:.0f} viol={best[\"fitness\"][\"violations\"]:.0f}')
else:
    best = min(candidates, key=lambda x: x['fitness']['violations'])
    print(f'Selected fallback: eff={best[\"fitness\"][\"effort\"]:.0f} viol={best[\"fitness\"][\"violations\"]:.0f}')

genome = best['genome']

# Validate layer access
analyzer = LayerAccessAnalyzer(canonical, positions, pool)
validation = analyzer.validate(genome)
if not validation.valid:
    print('WARNING: Selected genome has layer access errors:')
    for err in validation.errors:
        print(f'  - {err}')
    print('Aborting — do NOT apply an invalid layout')
    sys.exit(1)
print('Layer access: VALID')

# Export
changes = export_genome_to_zmk(genome, positions, pool, canonical, 'run7-best')
print(f'ZMK changes: {len(changes)} keys')

script = generate_apply_script(changes, version='evolved-run7-best')
with open('../build/evolved_apply.js', 'w', encoding='utf-8') as f:
    f.write(script)
print('Written: ../build/evolved_apply.js')
"

# Then generate verify script
python generate_verify.py ../build
```

### Verify the export succeeded:
- `../charybdis-optimizer/build/evolved_apply.js` should exist and be >10KB
- `../charybdis-optimizer/build/evolved_diff.txt` should exist — read it to understand what changed
- No "bad parameter" warnings in the export output (if there are, fix the KEY_TO_ZMK_PARAM mapping in export_zmk.py before proceeding)

---

## Step 2: Analyze the Diff

Before applying anything, read and understand the changes:

```powershell
cat C:\Users\nos\charybdis-optimizer\build\evolved_diff.txt
```

Check for sanity:
- [ ] Are the number of changes reasonable? (expect 100-300 key changes across layers)
- [ ] Do dynamic layer assignments make sense? Infer each non-L0/non-L7 layer role from the generated CSV; do not assume L2 is mouse or that any other layer number has a fixed role.
- [ ] Are frozen L0 keys unchanged? (letters, numbers on main grid should not change)
- [ ] Are structural keys present? (coach_base on exit-required layers, coach holds on L0 thumbs)

---

## Step 3: Apply to ZMK Studio (User Manual Step)

**This step requires the user to manually paste scripts in ZMK Studio.** Generate clear instructions:

1. Connect the Charybdis keyboard via USB
2. Open ZMK Studio in the browser
3. Open browser DevTools console (F12 → Console)
4. Paste the contents of `C:\Users\nos\charybdis-optimizer\build\evolved_apply.js`
5. Wait for it to complete — it will click through every key on every layer
6. Check the console output for errors (stored in `window._CHARYBDIS_APPLY_ERRORS`)
7. If errors: read the candidate suggestions in the error output, fix, re-apply
8. Paste `C:\Users\nos\charybdis-optimizer\build\evolved_verify.js` to verify
9. **Save** in ZMK Studio (Ctrl+S or the Save button)

---

## Step 4: Export Updated Layout from ZMK Studio

After applying and saving, the user needs to export the new canonical state. Instructions for the user:

1. In ZMK Studio DevTools console, paste `C:\Users\nos\charybdis-zmk-config\scripts\zmk-studio\export_current_layout_console.js`
2. This outputs a JSON blob — save it to `C:\Users\nos\charybdis-zmk-config\config\charybdis.json`
3. Copy it also to `C:\Users\nos\charybdis-optimizer\build\canonical.json` (the optimizer's input)

---

## Step 5: Update keybindings_explained.csv

The CSV in `charybdis-zmk-config/layout/keybindings_explained.csv` is the human-readable layout spec. It needs to be regenerated from the verify output or directly from the new canonical.json.

**Option A — From ZMK Studio verify JSON:**
After running the verify script in Step 3, it outputs verified key data. Use `rebuild_csv_from_verify.js`:
```powershell
cd C:\Users\nos\charybdis-zmk-config\scripts\zmk-studio
node rebuild_csv_from_verify.js
```

**Option B — From the evolved_apply.js data:**
Parse the `window.CHARYBDIS_FINAL_LAYOUT` from the apply script and merge changes into the existing CSV.

The CSV format is:
```
"layer","layer_role","x","y","visual_label","behavior","parameter","modifiers","purpose","usage_notes"
```

Each row is one key position. There are ~616 rows (56 positions × 11 layers).

---

## Step 6: Update Coach Data

The coach app (`charybdis-coach`) reads layout data from its `data/` directory. These are copies from `charybdis-zmk-config`:

```powershell
# Copy updated layout files to coach
Copy-Item "C:\Users\nos\charybdis-zmk-config\layout\keybindings_explained.csv" "C:\Users\nos\charybdis-coach\data\keybindings_explained.csv" -Force
Copy-Item "C:\Users\nos\charybdis-zmk-config\layout\layout_spec.json" "C:\Users\nos\charybdis-coach\data\layout_spec.json" -Force
```

After copying, verify the coach still loads correctly:
```powershell
cd C:\Users\nos\charybdis-coach
python -m http.server 8765
# Open http://127.0.0.1:8765/ and check layers display correctly
```

---

## Step 7: Update ZMK Config Baseline Scripts

Update the baseline apply/verify scripts in `charybdis-zmk-config` so they reflect the new layout:

```powershell
# Update the baseline apply script with new layout data
Copy-Item "C:\Users\nos\charybdis-optimizer\build\evolved_apply.js" "C:\Users\nos\charybdis-zmk-config\scripts\zmk-studio\apply_every_key.js" -Force

# Update the baseline verify script
Copy-Item "C:\Users\nos\charybdis-optimizer\build\evolved_verify.js" "C:\Users\nos\charybdis-zmk-config\scripts\zmk-studio\verify_every_key.js" -Force
```

---

## Step 8: Archive Old Usage Data (charybdis-tools)

The shortcut usage log was collected under the OLD layout. It shouldn't contaminate the new layout's usage baseline.

```powershell
$ts = Get-Date -Format "yyyyMMdd"
$runtime = "C:\Users\nos\charybdis-tools\runtime"

# Archive old usage data
if (Test-Path "$runtime\shortcut_usage.jsonl") {
    Copy-Item "$runtime\shortcut_usage.jsonl" "$runtime\shortcut_usage_pre_run7_$ts.jsonl"
    # Clear the current log to start fresh
    Set-Content "$runtime\shortcut_usage.jsonl" ""
}

# Archive old events
if (Test-Path "$runtime\charybdis_events.jsonl") {
    Copy-Item "$runtime\charybdis_events.jsonl" "$runtime\charybdis_events_pre_run7_$ts.jsonl"
    Set-Content "$runtime\charybdis_events.jsonl" ""
}
```

---

## Step 9: Check AHK Helper Compatibility

The AHK helper (`ahk/charybdis_helpers.ahk`) has hardcoded layer-related hotkeys (F13-F24 for beacon detection, layer state tracking). If the evolved layout changed which F-keys trigger layer switches, the AHK script may need updating.

Check:
1. Read `evolved_diff.txt` for any F13-F24 position changes
2. If F-key layer triggers moved, update the corresponding hotkey definitions in `charybdis_helpers.ahk`
3. If coach_hold keys moved to different physical positions, the beacon detection may need updating

If no F-key or layer-trigger changes: no AHK changes needed.

---

## Step 10: Validation Checklist

Before committing changes across repos, verify:

- [ ] `evolved_apply.js` has 0 "bad parameter" warnings
- [ ] `evolved_verify.js` shows 100% pass rate after applying
- [ ] `keybindings_explained.csv` has ~616 rows, correct headers
- [ ] Coach app loads and shows all 11 layers correctly
- [ ] Frozen L0 keys (letters, numbers, spacebar at (4,4), return enter at (7,5)) are unchanged
- [ ] Mouse buttons form a usable cluster on the layer or layers chosen by the generated layout
- [ ] Clipboard/editing shortcuts are reachable through the access path chosen by the generated layout
- [ ] Coach holds (coach_l1_hold through coach_l4_hold) are on L0 thumb positions
- [ ] Usage log is archived and fresh log file exists

---

## What NOT to Do

1. **Do NOT modify any files in `../charybdis-optimizer/`** — the optimizer repo is read-only for this task
2. **Do NOT manually edit the apply script** — if there are parameter errors, fix them in `export_zmk.py` (which is in the optimizer repo, so flag them for the user instead)
3. **Do NOT apply a layout that failed layer access validation** — if the validator says invalid, stop and report
4. **Do NOT delete the old `keybindings_explained.csv`** — rename it to `keybindings_explained_pre_run7.csv` as backup
5. **Do NOT modify shortcut importance scores or optimizer config** — this task is about applying, not optimizing

---

## Expected Outcome

After this task:
- ZMK keyboard has the evolved layout applied via ZMK Studio
- `charybdis-zmk-config` has updated CSV, apply script, verify script
- `charybdis-coach` has updated data files and displays the new layout
- `charybdis-tools` has archived old usage data and fresh logs
- `charybdis-optimizer/build/canonical.json` has the new baseline (for next evolution run)
- All changes committed to respective repos with descriptive messages

## Key Layout Summary (what the evolved layout should have)

From Run 7 (1000 gen) best_weighted selection. Treat this as a historical snapshot, not a role template:
- **L0 thumbs:** spacebar (4,4), return enter (7,5), layer-access behaviors, MB2 at one thumb
- **Mouse actions:** MB1/MB2/MB3/MB4/MB5 landed on the generated layout's chosen access paths; future runs may place them on different non-L0/non-L7 layers
- **Clipboard/editing actions:** Ctrl+C, Ctrl+V, Ctrl+Z, Ctrl+X landed on the generated layout's chosen access path; future runs may move them when usage data changes
- **All groups 100%:** arrows, clipboard, f_keys
- **Violations:** 49 (acceptable)
- **Effort:** -2,785 (negative = rewards exceed penalties)
