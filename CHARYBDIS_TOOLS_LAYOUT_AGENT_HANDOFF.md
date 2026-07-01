# Charybdis Tools — Layout Conversion & Real-World Analysis Agent

## Your Mission

You are running in the `charybdis-tools` directory. Your job is to:

1. **Find the best evolved layout** from the optimizer (v2 preferred, v1 fallback)
2. **Convert it into a real keyboard layout** — ZMK Studio apply script, verify script, and `keybindings_explained.csv`
3. **Analyze it for REAL HUMAN DAILY WORK** — not abstract fitness metrics, but actual app-by-app, layer-by-layer, shortcut-by-shortcut usability

## ⚠️ CRITICAL USER REQUIREMENT

The user explicitly said they do **NOT** care about abstract optimizer factors like:
- "ctrl factor", "arrow factor", "thumb factor", "structure factor"
- "group split penalty", "cross-layer duplicate score"
- "finger balance metric", "same-finger penalty"

The user **ONLY** cares about:
> **"If the layer they go to has the least amount of effort for their work"**

Your analysis must be grounded in **real apps, real shortcuts, real physical positions, and real effort to reach them**.

## Dynamic Layer Role Rule

Only L0 and L7 have stable semantic roles. L0 is base typing/thumb access. L7 is frozen fallback/game/system-safe space.

Every other layer is dynamically assigned by the optimizer for the current generation. Do not write or assume "L2 is mouse", "L3 is windows", "L4 is system", "L6 is scroll", or "L8 is travel". Behavior names such as `coach_l2_hold` are transport/access beacons only; they do not prove that layer 2 is a mouse layer. Infer layer roles from the current `keybindings_explained.csv`, usage data, mouse/button clusters, app shortcut clusters, and access paths.

---

## Physical Keyboard Reality

- **Split keyboard**: Left hand columns 0–5, Right hand columns 7–12
- **56 positions per layer**, 11 layers total (0–10, L7=Game is frozen)
- **Thumb row**: y=4 (3 keys per side) + y=5 (2 keys per side)
- **L0 (Base)**: Letters, numbers, punctuation. Mostly frozen except ~8 thumb positions
- **L0 thumb positions** (critical — these are the most-pressed keys after letters):
  - (3,4) left inner thumb → usually a layer-access key
  - (4,4) left middle thumb → usually `spacebar` (typing)
  - (5,4) left outer thumb → usually a layer-access key or transparent
  - (4,5) left bottom thumb → usually a layer-access key
  - (7,4) right inner thumb → usually a layer-access key
  - (8,4) right middle thumb → usually a layer-access key
  - (7,5) right bottom thumb → usually `return enter`
- **Layer access mechanics**: Current firmware exposes numbered access beacons. The generated layout decides what each non-L0/non-L7 target layer actually contains.
- **Effort model**: Lower = better. Home row (y=2) = ~1.0, top row (y=0) = ~3.5, thumb (y=4) = ~1.5, thumb bottom (y=5) = ~2.5, outer columns = +2.0 stretch

---

## Data Sources

### READ-ONLY — Do Not Modify These Repos

| File | Purpose | Format |
|------|---------|--------|
| `../charybdis-optimizer/build/v2_evolution_results.json` | v2 evolution results | JSON with `pareto_front`, `best_weighted`, `best_effort`, `best_violations` |
| `../charybdis-optimizer/build/v2_checkpoint_gen*.json` | v2 checkpoints (latest = best) | Same as above |
| `../charybdis-optimizer/build/evolution_scratch_results.json` | v1 fallback results | JSON with `pareto_front`, `best_weighted`, etc. |
| `../charybdis-optimizer/build/canonical.json` | Current physical layout + layer assignments | v1 format: `physical_grid` + `layers` dict |
| `../charybdis-optimizer/build/app_shortcut_scores.json` | Shortcut corpus with importance, frequency, best_match | `apps[].shortcuts[]` with `keys`, `action`, `importance`, `frequency`, `best_match.layer/coord/effort` |
| `../charybdis-optimizer/build/usage_stats.json` | Aggregated AHK usage data | `sequences`, `by_app`, `by_layer_shortcut`, `mouse_sessions`, `layer_transitions`, etc. |
| `../charybdis-tools/runtime/shortcut_usage.jsonl` | RAW AHK usage log | JSON lines: `type: shortcut|mouse|scroll|typing_counter|app_focus|mouse_session` |
| `../charybdis-zmk-config/config/charybdis.json` | ZMK physical layout definition | `layouts.default_transform.layout[]` with `row`, `col`, `x`, `y` |
| `../charybdis-zmk-config/config/charybdis_apps.json` | App definitions | `apps[].id`, `aliases`, `launch`, `window_match.exe/title` |
| `../charybdis-zmk-config/layout/keybindings_explained.csv` | Current human-readable layout | CSV: `layer,layer_role,x,y,visual_label,behavior,parameter,modifiers,purpose,usage_notes` |
| `../charybdis-optimizer/evolve/export_zmk.py` | v1 ZMK export script | Python — reads genome, writes `evolved_apply.js` |
| `../charybdis-optimizer/evolve/generate_verify.py` | v1 verify script | Python — reads `evolved_apply.js`, writes `evolved_verify.js` |
| `../charybdis-optimizer/evolve/representation.py` | v1 genome encoding | `build_position_index`, `build_shortcut_pool`, `decode_genome`, `LAYER_NAMES` |

### WRITE — Your Output Directory

Create and write to: `runtime/evolved_v2_export/`

| File | Purpose |
|------|---------|
| `evolved_apply.js` | ZMK Studio console script to apply the evolved layout |
| `evolved_verify.js` | ZMK Studio console script to verify the applied layout |
| `evolved_changes.json` | Machine-readable list of every changed key |
| `evolved_diff.txt` | Human-readable diff (layer-by-layer) |
| `keybindings_explained.csv` | Updated human-readable layout CSV (~616 rows) |
| `daily_task_analysis.md` | **Your main report** — real-world analysis |
| `selected_candidate.json` | Metadata about which candidate was chosen and why |

---

## Step 1: Find the Best Evolved Layout

### 1.1 Check v2 Results First

```python
import json
from pathlib import Path

build_dir = Path("../charybdis-optimizer/build")

# Try v2 results first
v2_results = None
for candidate in [
    build_dir / "v2_evolution_results.json",
    build_dir / "v2_checkpoint_gen999999.json",
    # Find latest checkpoint
]:
    if candidate.exists():
        v2_results = json.load(open(candidate, encoding='utf-8'))
        print(f"Loaded v2 results from {candidate}")
        break

# If no v2, fall back to v1
if v2_results is None:
    v1_path = build_dir / "evolution_scratch_results.json"
    if v1_path.exists():
        v1_results = json.load(open(v1_path, encoding='utf-8'))
        print(f"Falling back to v1 results from {v1_path}")
```

### 1.2 Select the Best Candidate

Use the **same selection logic** as v1:

```python
candidates = []

if v2_results:
    # v2 format may vary — inspect the structure first
    if 'pareto_front' in v2_results:
        candidates.extend(v2_results['pareto_front'])
    for key in ('best_weighted', 'best_effort', 'best_violations', 'best_adaptive'):
        if key in v2_results and v2_results[key] and v2_results[key].get('genome'):
            candidates.append(v2_results[key])
else:
    # v1 format
    candidates.extend(v1_results.get('pareto_front', []))
    for key in ('best_weighted', 'best_effort', 'best_violations'):
        entry = v1_results.get(key)
        if entry and entry.get('genome'):
            candidates.append(entry)

# Selection rule: feasible first, then lowest effort
feasible = [c for c in candidates if c['fitness']['violations'] < 200]
if feasible:
    best = min(feasible, key=lambda x: x['fitness']['effort'])
    mode = "feasible"
else:
    best = min(candidates, key=lambda x: x['fitness']['violations'])
    mode = "fallback (lowest violations)"

print(f"Selected: {mode} | effort={best['fitness']['effort']:.0f} viol={best['fitness']['violations']:.0f}")
```

**Save `selected_candidate.json`** with:
- `mode`: "feasible" or "fallback"
- `source`: which key in the results file (e.g., "best_weighted")
- `fitness`: the fitness dict
- `change_count`: number of changes from canonical
- `genome_summary`: first 20 gene values (for debugging)

### 1.3 If v2 Genome Format is Different

The v2 optimizer may use a different genome encoding than v1. Inspect it:
- v1: `genome` is a list of integers, length = number of mutable positions, values = shortcut IDs
- v2: May be a numpy array, may include -1 for transparent, may have different indexing

If the format differs, you must write a **converter** that maps the v2 genome to v1's position index and shortcut IDs, or write a **new exporter** that understands v2's format directly.

**Rule**: If in doubt, write a small Python script that loads the genome alongside `canonical.json` and `app_shortcut_scores.json`, and manually maps genes to `(layer, x, y)` positions and `shortcut keys`.

---

## Step 2: Convert to ZMK Format

### 2.1 Option A — Reuse v1 Export Scripts (Preferred if Genome is Compatible)

If the v2 genome is identical in format to v1:

```bash
cd ../charybdis-optimizer/evolve
python export_zmk.py ../build
python generate_verify.py ../build
```

Then copy the results:
```bash
cp ../charybdis-optimizer/build/evolved_apply.js ../charybdis-tools/runtime/evolved_v2_export/
cp ../charybdis-optimizer/build/evolved_verify.js ../charybdis-tools/runtime/evolved_v2_export/
```

### 2.2 Option B — Build Your Own Exporter (If v2 Format Differs)

Write a Python script at `runtime/evolved_v2_export/export_v2_to_zmk.py` that:

1. **Load `canonical.json`** to get the physical grid and current layer assignments
2. **Load the best genome** from v2 results
3. **Load `app_shortcut_scores.json`** to get shortcut metadata (keys, action, modifiers)
4. **Build `evolved_changes.json`** — array of objects:
   ```json
   {
     "layer": 1,
     "x": 8,
     "y": 2,
     "behavior": "Key Press",
     "parameter": "Keyboard C",
     "modifiers": ["L Ctrl"],
     "label": "ctrl+c",
     "rationale": "Clipboard: Ctrl+C on L1 right index home row",
     "optimizer_changed": true,
     "apply_batch": true
   }
   ```
5. **Generate `evolved_apply.js`** — ZMK Studio console script
   - Must set `window.CHARYBDIS_VERSION = "evolved-v2"`
   - Must set `window.CHARYBDIS_FINAL_LAYOUT` as array of all keys
   - Must use `clickKeyButton(layer, x, y)` to navigate
   - Must use `selectBehavior("Key Press")` then `typeParameter("Keyboard ...")` then `addModifier("L Ctrl")` for each key
   - Must store errors in `window._CHARYBDIS_APPLY_ERRORS = []`
   - Must batch: apply 50 keys, pause, then click "Save" if available
6. **Generate `evolved_verify.js`** — reads back every key and compares to expected
   - Must define `EXPECTED_CSV` as a multiline string with CSV content
   - Must iterate every layer, every key, read `getKeyBinding(layer, x, y)`, compare to expected
   - Must report pass/fail per key and overall percentage
7. **Generate `evolved_diff.txt`** — human-readable text diff
   - Group by layer
   - For each changed key: `(x,y) -> behavior parameter [label]`
   - Highlight what changed from canonical

### 2.3 ZMK Parameter Mapping Reference

Use the same mapping as v1 `export_zmk.py`:

```python
MOD_MAP = {
    "Ctrl": "L Ctrl", "Shift": "L Shift", "Alt": "L Alt", "Win": "L GUI"
}

KEY_TO_ZMK_PARAM = {
    # Letters
    "A": "Keyboard A", "B": "Keyboard B", ... "Z": "Keyboard Z",
    # Digits
    "0": "Keyboard 0 and Right Bracket", "1": "Keyboard 1 and Bang",
    "2": "Keyboard 2 and At", "3": "Keyboard 3 and Hash",
    "4": "Keyboard 4 and Dollar", "5": "Keyboard 5 and Percent",
    "6": "Keyboard 6 and Caret", "7": "Keyboard 7 and Ampersand",
    "8": "Keyboard 8 and Star", "9": "Keyboard 9 and Left Bracket",
    # F-keys
    "F1": "Keyboard F1", ... "F24": "Keyboard F24",
    # Special
    "Enter": "Keyboard Return Enter", "Return": "Keyboard Return Enter",
    "Tab": "Keyboard Tab", "Escape": "Keyboard Escape", "Esc": "Keyboard Escape",
    "Space": "Keyboard Spacebar", "Spacebar": "Keyboard Spacebar",
    "Delete": "Keyboard Delete", "Backspace": "Keyboard Delete",
    "Left": "Keyboard LeftArrow", "Right": "Keyboard RightArrow",
    "Up": "Keyboard UpArrow", "Down": "Keyboard DownArrow",
    "LeftArrow": "Keyboard LeftArrow", "RightArrow": "Keyboard RightArrow",
    "UpArrow": "Keyboard UpArrow", "DownArrow": "Keyboard DownArrow",
    "Home": "Keyboard Home", "End": "Keyboard End",
    "PageUp": "Keyboard PageUp", "PageDown": "Keyboard PageDown",
    "Insert": "Keyboard Insert",
    "PrintScreen": "Keyboard PrintScreen and SysReq",
    "LeftShift": "Keyboard LeftShift", "RightShift": "Keyboard RightShift",
    "LeftControl": "Keyboard LeftControl", "RightControl": "Keyboard RightControl",
    "LeftAlt": "Keyboard LeftAlt", "RightAlt": "Keyboard RightAlt",
    "LeftGUI": "Keyboard Left GUI",
    # Symbols
    "!": "Keyboard 1 and Bang", "@": "Keyboard 2 and At", "#": "Keyboard 3 and Hash",
    "$": "Keyboard 4 and Dollar", "%": "Keyboard 5 and Percent",
    "^": "Keyboard 6 and Caret", "&": "Keyboard 7 and Ampersand",
    "*": "Keyboard 8 and Star", "(": "Keyboard 9 and Left Bracket",
    ")": "Keyboard 0 and Right Bracket", "-": "Keyboard Dash and Underscore",
    "_": "Keyboard Dash and Underscore", "=": "Keyboard Equals and Plus",
    "+": "Keyboard Equals and Plus", "[": "Keyboard Left Brace",
    "{": "Keyboard Left Brace", "]": "Keyboard Right Brace",
    "}": "Keyboard Right Brace", "\\": "Keyboard Backslash and Pipe",
    "|": "Keyboard Backslash and Pipe", ";": "Keyboard SemiColon and Colon",
    ":": "Keyboard SemiColon and Colon", "'": "Keyboard Left Apos and Double",
    '"': "Keyboard Left Apos and Double", ",": "Keyboard Comma and LessThan",
    "<": "Keyboard Comma and LessThan", ".": "Keyboard Period and GreaterThan",
    ">": "Keyboard Period and GreaterThan", "/": "Keyboard ForwardSlash and QuestionMark",
    "?": "Keyboard ForwardSlash and QuestionMark",
    "`": "Keyboard Grave Accent and Tilde", "~": "Keyboard Grave Accent and Tilde",
}
```

### 2.4 Generate `keybindings_explained.csv`

The CSV has exactly these columns:
```
"layer","layer_role","x","y","visual_label","behavior","parameter","modifiers","purpose","usage_notes"
```

Rules:
- ~616 rows (56 positions × 11 layers)
- `layer` = 0–10 (skip 7 = Game)
- `layer_role` = human description inferred from the current generated layout:
  - L0: "Base typing and thumb access"
  - L7: "Frozen fallback/game/system-safe layer"
  - L1–L6/L8–L10: inferred from current app clusters, shortcut clusters, mouse actions, and access path usage
- `visual_label` = short lowercase name (e.g., "ctrl+c", "mb1", "spacebar", "coach_l1")
- `behavior` = "Key Press", "Transparent", "Momentary Layer", "Toggle Layer", "Mod Tap", etc.
- `parameter` = ZMK parameter name (e.g., "Keyboard C", "Spacebar")
- `modifiers` = "" or "L Ctrl" or "L Ctrl+L Shift" etc.
- `purpose` = what the key does (e.g., "Copy to clipboard")
- `usage_notes` = which app uses it, estimated frequency

**Important**: If you do not know the exact `layer_role` for a layer, infer it from the shortcuts on that layer. A layer with mostly Ctrl+C/V/X/Z is "Clipboard". A layer with MB1/MB2/MB3 is "Mouse". A layer with app-specific shortcuts is "App shortcuts".

---

## Step 3: Real-World Daily Task Analysis

This is **the most important part**. Write everything to `daily_task_analysis.md`.

### 3.1 Per-App Layer Profiles

For each app in `charybdis_apps.json` (Edge, M-Files, VS Code, Teams, Outlook, Excel, Terminal, Explorer, Proton Pass):

1. Extract all shortcuts from `app_shortcut_scores.json`
2. For each shortcut, find its position in the evolved layout:
   - Which layer?
   - Which (x, y)?
   - Which hand and finger?
   - What is the effort score?
3. Calculate **Weighted Average Effort per App**:
   ```
   weighted_effort = sum(effort_i * importance_i * freq_weight_i) / sum(importance_i * freq_weight_i)
   ```
   - Lower = better
   - `freq_weight`: 10=constant, 7=high, 4=medium, 2=low, 1=rare
4. List the **top 5 easiest** and **top 5 hardest** shortcuts per app
5. Flag any shortcut with effort > 5.0 on a high-frequency action

**App priority order** (based on typical user workday):
1. Browser (Edge) — most used
2. VS Code — development work
3. Teams — communication
4. Excel — data work
5. Outlook — email
6. M-Files — document management
7. Terminal — shell commands
8. Explorer — file management
9. Proton Pass — password manager

### 3.2 Layer Effort Scorecards

For each layer (0–10, excluding 7):

| Metric | How to Calculate |
|--------|-----------------|
| Avg Effort | Mean effort of all non-transparent keys |
| Median Effort | Median effort |
| Worst Effort | Highest effort key |
| Shortcut Count | Number of non-transparent keys |
| App Count | Number of unique apps served |
| Hand Balance | % left vs right hand keys |
| Thumb Reliance | Number of keys requiring thumb hold + key press |

**Quality Rating**:
- EXCELLENT: avg < 2.5
- GOOD: 2.5–3.5
- FAIR: 3.5–4.5
- POOR: > 4.5

### 3.3 Base Layer (L0) Thumb Analysis

The L0 thumbs are the interface to the entire keyboard. Analyze them deeply:

**Physical thumb positions**:
| Position | Typical Role | Key Question |
|----------|-------------|--------------|
| (3,4) left inner | layer access or generated binding | Is the target layer useful enough for this prime thumb position? |
| (4,4) left middle | spacebar | Correct for typing — yes, but verify |
| (5,4) left outer | layer access or transparent | Is the target layer useful enough for this reach? |
| (4,5) left bottom | layer access | Is this comfortable for the target layer's expected hold/toggle use? |
| (7,4) right inner | layer access | Are the target layer's actions worth this prime right-thumb position? |
| (8,4) right middle | layer access | Are the target layer's actions worth this right-thumb position? |
| (7,5) right bottom | return enter | Is this easy for right thumb? |

**Analysis to perform**:
1. From `usage_stats.json`, which layer is accessed most frequently?
2. Does the most-accessed layer get the EASIEST thumb hold?
3. Are there any thumb positions that are transparent (wasted)?
4. If a thumb hold is on y=5 (bottom), is it comfortable for repeated use?
5. Compare to `shortcut_usage.jsonl`: count how many times each layer is accessed

### 3.4 Mouse + Keyboard Combo Analysis

The AHK logger tracks `mouse_context` — shortcuts pressed within ~1 second of a mouse click. These are critical because the user is already using their right hand for the trackball.

From `shortcut_usage.jsonl`:
```bash
grep '"mouse_context"' runtime/shortcut_usage.jsonl | head -50
```

For each mouse-context shortcut:
1. Which layer is it on?
2. What is its effort?
3. Is it on the **left hand**? (Ideal: mouse on right, shortcut on left)
4. Is it on the **same hand** as the mouse? (Bad — hand conflict)
5. Is it on L0 (no layer switch needed)? (Best)
6. Is it on L1/L2 (one thumb hold)? (Good)
7. Is it on L5+ (toggle, requires switching back)? (Bad)

**Calculate mouse combo score**:
```
mouse_score = sum( (left_hand_bonus ? 0.5 : 0) + (no_layer_switch ? 0.5 : 0) + (effort < 2.0 ? 0.5 : 0) ) / count
```

### 3.5 Daily Workflow Simulations

Simulate realistic workflows. A typical day involves these sequences:

#### Workflow A: Browser Session (15 min)
```
Ctrl+T (new tab) → type URL → Enter → Ctrl+F (find) → type query → Esc → Ctrl+Tab (next tab) → Ctrl+W (close) → Ctrl+Shift+T (reopen)
```
- Map each shortcut to layer, position, effort
- Count layer switches
- Calculate total effort
- Identify friction points

#### Workflow B: Teams Call (10 min)
```
Ctrl+Shift+M (mute) → Ctrl+Shift+E (camera) → Ctrl+Shift+O (share) → Ctrl+2 (chat) → Ctrl+E (search)
```
- Teams shortcuts often use Ctrl+Shift — are they on an easy layer?

#### Workflow C: Coding Session (30 min)
```
Ctrl+S (save) → Ctrl+Shift+P (command palette) → Ctrl+P (quick open) → Ctrl+` (terminal) → Ctrl+Shift+F (search) → F5 (debug) → Ctrl+Shift+K (delete line)
```
- VS Code has MANY shortcuts — are they clustered on the same layer?

#### Workflow D: Excel Data Entry (20 min)
```
Ctrl+S → Ctrl+Z → Ctrl+Y → Ctrl+C → Ctrl+V → Ctrl+Shift+L (filter) → F2 (edit cell) → Ctrl+Home → Ctrl+End → Arrow keys → Enter → Tab
```
- Arrow keys and Enter are used heavily — are they on the base layer or a navigation layer?

#### Workflow E: Email (Outlook) (10 min)
```
Ctrl+N (new mail) → type → Ctrl+Enter (send) → Ctrl+1 (mail view) → Ctrl+2 (calendar) → Ctrl+3 (contacts)
```

#### Workflow F: Mouse + Keyboard Combo (5 min)
```
MB1 click → Ctrl+V (paste into field) → MB1 click → Ctrl+C (copy value) → Scroll down → MB1 click → Ctrl+Shift+V (paste special)
```

For each workflow:
1. **Shortcut mapping table**: shortcut → layer → (x,y) → effort → hand
2. **Layer switch count**: how many times must the user switch layers?
3. **Total effort**: sum of all key efforts + layer switch penalties (0.5 per switch)
4. **Friction points**: shortcuts with effort > 4.0 or requiring same hand as previous key
5. **Suggestions**: "Ctrl+Shift+M should be on L3 instead of L5 because..."

### 3.6 Learning Curve Assessment

Compare the evolved layout to the current layout (`canonical.json`):

1. **L0 change percentage**: How many L0 keys changed? (Should be < 15% — thumbs only)
2. **Non-L0 change percentage**: How many keys on L1–L6, L8–L10 changed?
3. **Layer migration**: Which shortcuts moved to a different layer?
4. **Position migration**: Which shortcuts stayed on the same layer but moved position?
5. **Relearning cost matrix**:
   | Change Type | Cost |
   |-------------|------|
   | Same layer, adjacent position (|dx|+|dy| ≤ 2) | LOW (1–2 days) |
   | Same layer, different position | MEDIUM (3–5 days) |
   | Different layer, same hand | HIGH (1–2 weeks) |
   | Different layer, different hand | VERY HIGH (2–4 weeks) |
   | Removed (was on old layout, now transparent) | HIGH (muscle memory loss) |

6. **Total estimated learning time**: Sum of all relearning costs, capped at 30 days

### 3.7 Trackball Proximity

13 shortcuts are related to trackball/scroll/click:
- MB1, MB2, MB3, MB4, MB5
- Scroll up, scroll down
- Cursor left, right, up, down
- Click, double-click

Check:
- Do mouse buttons and scroll-mode access form a coherent dynamic cluster or access path?
- Are they reachable while holding the trackball?
- Is there a "scroll cluster" (scroll up/down adjacent) on the left hand?
- Is the detected mouse/action cluster accessible via a comfortable hold, toggle, or lock path?

### 3.8 Norwegian Character Accessibility

The user is Norwegian. Check the layout for:
- `æ`, `ø`, `å` — are they on a dedicated layer?
- If on L0: are they accessible via Compose or AltGr?
- If on a separate layer: which layer and how easy is it to reach?
- Are Norwegian characters in the `keybindings_explained.csv`?

If not present, note this as a gap and suggest adding them to L5 or L6.

### 3.9 Cross-Layer Consistency & Duplicate Detection

Check if the same shortcut appears on multiple layers:
- **Intentional duplicates**: Ctrl+C on L1 (clipboard) AND L0 (thumb) for convenience → OK
- **Wasteful duplicates**: Ctrl+C on L1, L3, and L5 with no purpose → BAD (wastes positions)
- **Missing critical shortcuts**: Ctrl+S only on L9 (hard to reach) → BAD

For each duplicate, judge whether it is beneficial or wasteful.

### 3.10 App Affinity & Transition Cost

Build an **App Affinity Matrix**:
- Rows = apps, Columns = apps
- Value = number of shared shortcuts on the same layer
- High values = apps work well together (no layer switching)
- Low values = apps require layer switching

Calculate **Transition Cost** for common app switches:
| From → To | Shared Layer? | Cost |
|-----------|---------------|------|
| Browser → VS Code | If both use L3 | LOW |
| Teams → Outlook | If both use L4 | LOW |
| Excel → Browser | If different layers | HIGH |

### 3.11 Real Usage Data Validation

Compare the evolved layout to the **actual usage log** (`shortcut_usage.jsonl`):

1. **Top 20 most-used shortcuts** from the log — are they all mapped?
2. **Top 20 most-used shortcuts** — are they on easy layers (L0, L1, L2, L3)?
3. **Shortcuts that appear in the log but are NOT in `app_shortcut_scores.json`** — are they lost?
4. **Layer transition patterns** from the log — does the evolved layout reduce transitions?
5. **Mouse session shortcuts** — are the shortcuts that follow mouse clicks well-placed?

If there are shortcuts in the log that are NOT in the optimizer corpus, flag them: "The user frequently presses Win+Shift+S but this is not in the shortcut corpus — add it!"

---

## Step 4: Write the Report

The report MUST be saved as `runtime/evolved_v2_export/daily_task_analysis.md`.

### Required Sections

```markdown
# Charybdis V2 Layout — Daily Task Analysis

## 1. Executive Summary
- Which candidate was selected (feasible/fallback, source)
- Fitness: effort, adjacency, violations
- Estimated learning time: X days
- Overall verdict: [EXCELLENT / GOOD / FAIR / NEEDS WORK]
- Top 3 strengths
- Top 3 concerns

## 2. App Profiles
### 2.1 Browser (Edge)
[Table of all shortcuts with layer, position, effort, hand]
Weighted average effort: X

### 2.2 VS Code
...

### 2.3 Teams
...

[Continue for all 9 apps]

## 3. Layer Scorecards
| Layer | Role | Avg Effort | Shortcut Count | Apps | Quality | Hand Balance |
...

## 4. L0 Thumb Analysis
[Which thumb does what, which is most comfortable, any wasted positions]

## 5. Mouse + Keyboard Combo Analysis
[Mouse-context shortcuts, hand conflict analysis, mouse combo score]

## 6. Workflow Simulations
### 6.1 Browser Session
[Step-by-step with effort, layer switches, total cost]

### 6.2 Teams Call
...

### 6.3 Coding Session
...

### 6.4 Excel Data Entry
...

### 6.5 Email
...

### 6.6 Mouse + Keyboard Combo
...

## 7. Learning Curve
[% changed, relearning cost matrix, estimated days to proficiency]

## 8. Trackball Proximity
[Where are MB1–5, scroll, cursor keys?]

## 9. Norwegian Character Accessibility
[æ, ø, å — where are they?]

## 10. Cross-Layer Consistency & Duplicates
[Which shortcuts are duplicated? Are they beneficial?]

## 11. App Affinity & Transition Cost
[App affinity matrix, common transition costs]

## 12. Real Usage Validation
[Top 20 logged shortcuts vs evolved layout]

## 13. Recommendations
1. [Specific, actionable, e.g., "Move Ctrl+Shift+M from L5 to L3 because Teams mute is used 20x/day"]
2. [Specific, actionable]
3. [Specific, actionable]
...
```

### Writing Style

- **DO**: Use plain language. "Ctrl+V is on L1 at (8,2) — your right index finger home row. Very easy."
- **DO**: Compare to the current layout. "This moved from L3 (7,4) to L1 (8,2) — much better."
- **DO**: Quantify everything. "Effort reduced from 4.5 to 1.5."
- **DO**: Use tables for any data with 3+ rows.
- **DO NOT**: Use optimizer jargon. No "group_split penalty", "cross-layer duplicate factor", "finger balance objective."
- **DO NOT**: Say "the fitness function optimized this." Say "this is easy to reach because..."
- **DO NOT**: Give vague recommendations. "Improve the layout" is bad. "Move Ctrl+Z from (5,5) to (3,2) because..." is good.

---

## Step 5: Validation & Checklist

Before declaring success, verify:

### Export Artifacts
- [ ] `evolved_apply.js` exists and is >10KB
- [ ] `evolved_verify.js` exists and is >10KB
- [ ] `evolved_changes.json` exists and has entries for all changed keys
- [ ] `evolved_diff.txt` exists and is human-readable
- [ ] `keybindings_explained.csv` exists and has ~616 rows with correct 10-column header
- [ ] `selected_candidate.json` exists with selection metadata

### Analysis Report
- [ ] `daily_task_analysis.md` exists and has all 13 sections
- [ ] All 9 apps from `charybdis_apps.json` have profiles
- [ ] Layer scorecards cover all 11 layers (0–10, excluding 7)
- [ ] L0 thumb analysis is present and specific to physical positions
- [ ] Mouse+keyboard combo analysis references actual `mouse_context` data from the log
- [ ] At least 6 workflow simulations are present with step-by-step effort calculations
- [ ] Learning curve is quantified (% changed, relearning cost, estimated days)
- [ ] Trackball proximity is analyzed (MB1–5, scroll, cursor)
- [ ] Norwegian characters are checked
- [ ] Real usage validation compares top 20 logged shortcuts to the evolved layout
- [ ] Recommendations are specific, actionable, and justified with data

### Sanity Checks
- [ ] L0 letter positions (QWERTY) are unchanged — they should be frozen
- [ ] L0 number positions (1–0) are unchanged
- [ ] `spacebar` is at (4,4) on L0
- [ ] `return enter` is at (7,5) on L0
- [ ] `coach_l1_hold` through `coach_l4_hold` are on L0 thumb positions
- [ ] No layer has effort > 5.0 for critical shortcuts
- [ ] The most-used app (Browser) has the lowest weighted effort

---

## If V2 Results Are Missing or Incomplete

The v2 optimizer may not have finished yet. Here's how to handle it:

1. **Check for checkpoints**: Look for `v2_checkpoint_gen*.json` in `../charybdis-optimizer/build/`
2. **If the v2 run is active**: Note the current generation in the report. Generate everything you can from the latest checkpoint. The analysis will improve as the run continues.
3. **If v2 has no data at all**: Use v1 `evolution_scratch_results.json` as fallback. Label the report clearly: "Analysis based on v1 Run 7 (v2 still in progress)."
4. **You can still generate the framework**: Even if no evolved layout exists yet, you can write the analysis scripts and populate them when data arrives.

---

## What NOT to Do

1. **Do NOT modify `../charybdis-optimizer/`** — read-only
2. **Do NOT modify `../charybdis-zmk-config/` or `../charybdis-coach/` unless applying** — if you write to these repos, do it as a final step after user approval
3. **Do NOT stop any active evolution run** — check if `run_evolution.py` is running before doing heavy CPU work
4. **Do NOT use abstract fitness jargon** — the user will reject it
5. **Do NOT make up data** — if you don't have usage stats for an app, say "No usage data available; analysis based on importance scores only"
6. **Do NOT skip the real-world analysis** — the ZMK scripts are necessary but the analysis is the VALUE
7. **Do NOT recommend changes to frozen L0 positions** — letters and numbers are fixed

---

## Summary

Your deliverables are:
1. **ZMK apply/verify scripts** — so the user can apply the evolved layout to their real keyboard
2. **Updated keybindings_explained.csv** — so the user knows what every key does
3. **Daily task analysis report** — so the user understands if the layout is actually good for their work

The user is a real human with a real job. They use Edge, Teams, VS Code, Excel, Outlook, and M-Files all day. They have a trackball. They speak Norwegian. They want to know: **"If I go to this layer, will my work be easy?"**

Answer that question. Everything else is secondary.
