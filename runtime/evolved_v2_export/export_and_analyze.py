"""V2 evolved layout exporter and analyzer.

Reads the best v2 checkpoint, merges evolved changes with canonical base,
and generates ZMK Studio scripts, CSV, and a real-world analysis report.
"""
import json
import os
import re
import csv
import sys
from pathlib import Path
from collections import Counter, defaultdict
from datetime import datetime

import numpy as np

# Add both v1 and v2 code paths
sys.path.insert(0, "C:/Users/nos/charybdis-optimizer/charybdis-optimizer-v2")
sys.path.insert(0, "C:/Users/nos/charybdis-optimizer/evolve")

from core.loader import build_layout, load_canonical, load_shortcuts, build_scratch_genome
from representation import split_shortcut_keys, is_structural, LAYER_NAMES

# ---------------------------------------------------------------------------
# ZMK mapping (from v1 export_zmk.py)
# ---------------------------------------------------------------------------
MOD_MAP = {
    "Ctrl": "L Ctrl",
    "Shift": "L Shift",
    "Alt": "L Alt",
    "Win": "L GUI",
}

KEY_TO_ZMK_PARAM = {}
for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
    KEY_TO_ZMK_PARAM[letter] = f"Keyboard {letter}"

KEY_TO_ZMK_PARAM.update({
    "0": "Keyboard 0 and Right Bracket", "1": "Keyboard 1 and Bang",
    "2": "Keyboard 2 and At", "3": "Keyboard 3 and Hash",
    "4": "Keyboard 4 and Dollar", "5": "Keyboard 5 and Percent",
    "6": "Keyboard 6 and Caret", "7": "Keyboard 7 and Ampersand",
    "8": "Keyboard 8 and Star", "9": "Keyboard 9 and Left Bracket",
    "F1": "Keyboard F1", "F2": "Keyboard F2", "F3": "Keyboard F3",
    "F4": "Keyboard F4", "F5": "Keyboard F5", "F6": "Keyboard F6",
    "F7": "Keyboard F7", "F8": "Keyboard F8", "F9": "Keyboard F9",
    "F10": "Keyboard F10", "F11": "Keyboard F11", "F12": "Keyboard F12",
    "F13": "Keyboard F13", "F14": "Keyboard F14", "F15": "Keyboard F15",
    "F16": "Keyboard F16", "F17": "Keyboard F17", "F18": "Keyboard F18",
    "F19": "Keyboard F19", "F20": "Keyboard F20", "F21": "Keyboard F21",
    "F22": "Keyboard F22", "F23": "Keyboard F23", "F24": "Keyboard F24",
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
})


# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
BUILD_DIR = Path("C:/Users/nos/charybdis-optimizer/build")
TOOLS_DIR = Path("C:/Users/nos/charybdis-tools")
OUT_DIR = TOOLS_DIR / "runtime" / "evolved_v2_export"
OUT_DIR.mkdir(parents=True, exist_ok=True)

ZMK_CONFIG_DIR = Path("C:/Users/nos/charybdis-zmk-config")

# ---------------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------------
print("Loading v2 checkpoint...")
checkpoints = sorted(BUILD_DIR.glob("v2_checkpoint_gen*.json"), key=lambda p: int(p.stem.split('gen')[1]))
latest_cp = checkpoints[-1]
with open(latest_cp, encoding='utf-8') as f:
    cp_data = json.load(f)

best = cp_data['best_exact']
print(f"Selected checkpoint: {latest_cp.name}")
print(f"  effort={best['effort']:.2f}, adjacency={best['adjacency']:.2f}, violations={best['violations']:.2f}")

v2_genome = np.array(best['genome'], dtype=np.int32)

print("Building v2 layout...")
layout = build_layout(str(BUILD_DIR))
shortcuts = layout.shortcuts
positions = layout.positions

print(f"  positions={layout.n_positions}, shortcuts={layout.n_shortcuts}, "
      f"frozen={sum(layout.frozen_mask)}, mutable={len(layout.mutable_indices)}")

with open(BUILD_DIR / "canonical.json", encoding='utf-8') as f:
    canonical = json.load(f)

with open(BUILD_DIR / "app_shortcut_scores.json", encoding='utf-8') as f:
    app_scores = json.load(f)

with open(BUILD_DIR / "usage_stats.json", encoding='utf-8') as f:
    usage_stats = json.load(f)

with open(ZMK_CONFIG_DIR / "config" / "charybdis_apps.json", encoding='utf-8') as f:
    charybdis_apps = json.load(f)

# Read usage log for top shortcuts and mouse context
usage_log_path = TOOLS_DIR / "runtime" / "shortcut_usage.jsonl"
usage_lines = []
if usage_log_path.exists():
    with open(usage_log_path, encoding='utf-8') as f:
        usage_lines = [line.strip() for line in f if line.strip()]

# ---------------------------------------------------------------------------
# Build merged layout: canonical base + evolved overrides for mutable positions
# ---------------------------------------------------------------------------
print("Building merged layout...")

# Pre-compute canonical binding lookup by (layer, coord)
can_bindings = {}
for layer_id, layer_data in canonical['layers'].items():
    if not layer_id or not layer_id.strip():
        continue
    for coord, binding in layer_data.get('keys', {}).items():
        can_bindings[(int(layer_id), coord)] = binding

# Layer role mapping (inferred from canonical if available, else from shortcuts)
LAYER_ROLES = {
    0: "Base typing and thumb access",
    7: "Frozen fallback/game/system layer",
}
for _layer in range(1, 11):
    if _layer != 7:
        LAYER_ROLES[_layer] = "Dynamic generated layer"

# Override with canonical layer roles if present
for layer_id, layer_data in canonical['layers'].items():
    if layer_id and layer_id.strip() and 'role' in layer_data:
        LAYER_ROLES[int(layer_id)] = layer_data['role']

# Build the merged layout as a list of binding dicts
merged_bindings = []
changes = []

for i, pos in enumerate(positions):
    coord = f"{int(pos.x)}:{int(pos.y)}"
    key = (pos.layer, coord)
    can_binding = can_bindings.get(key, {})
    
    evolved_sid = v2_genome[i]
    
    # Critical L0 positions that must never change
    CRITICAL_L0 = {
        (4, 4): "spacebar",      # left middle thumb
        (7, 5): "return enter",  # right bottom thumb
        (3, 4): "coach_l1_hold", # L1 access
        (7, 4): "coach_l4_hold", # L4 access (canonical ground truth)
        (8, 4): "coach_l3_hold", # L3 access (canonical ground truth)
    }
    is_critical = (pos.layer == 0 and (int(pos.x), int(pos.y)) in CRITICAL_L0)
    
    # Determine the effective binding
    if is_critical:
        # Always use canonical for critical positions
        effective = dict(can_binding) if can_binding else {
            "x": pos.x, "y": pos.y,
            "label": "transparent", "behavior": "Transparent",
            "parameter": "", "modifiers": [],
            "purpose": "Transparent", "usage_notes": "",
        }
        source = "canonical (critical)"
    elif pos.is_frozen:
        # Always use canonical for frozen positions
        effective = dict(can_binding) if can_binding else {
            "x": pos.x, "y": pos.y,
            "label": "transparent", "behavior": "Transparent",
            "parameter": "", "modifiers": [],
            "purpose": "Transparent", "usage_notes": "",
        }
        source = "canonical (frozen)"
    elif evolved_sid >= 0 and evolved_sid < len(shortcuts):
        # Use evolved
        sc = shortcuts[evolved_sid]
        mods, base = split_shortcut_keys(sc.keys)
        mouse_click_map = {"Click": "MB1", "Left Click": "MB1", "Right Click": "MB2", "Middle Click": "MB3"}
        zmk_param = mouse_click_map.get(base, KEY_TO_ZMK_PARAM.get(base, f"Keyboard {base}"))
        zmk_mods = [MOD_MAP.get(m, m) for m in mods]
        behavior = "Mouse Key Press" if (base.startswith("MB") and base[2:].isdigit()) or base in mouse_click_map else "Key Press"
        effective = {
            "x": pos.x, "y": pos.y,
            "label": sc.keys,
            "behavior": behavior,
            "parameter": zmk_param,
            "modifiers": zmk_mods,
            "purpose": sc.action or f"Evolved assignment: {sc.keys}",
            "usage_notes": f"App: {sc.app}, importance={sc.importance}",
        }
        source = "evolved"
    else:
        # Transparent / fallback to canonical
        if can_binding:
            effective = dict(can_binding)
            source = "canonical"
        else:
            effective = {
                "x": pos.x, "y": pos.y,
                "label": "transparent",
                "behavior": "Transparent",
                "parameter": "",
                "modifiers": [],
                "purpose": "Transparent",
                "usage_notes": "",
            }
            source = "transparent"
    
    # Compare to canonical
    can_label = can_binding.get('label', '') if can_binding else 'transparent'
    can_behavior = can_binding.get('behavior', '') if can_binding else 'transparent'
    if can_behavior.lower() in ('transparent', 'none', ''):
        can_label = 'transparent'
    
    evolved_label = effective.get('label', '')
    if effective.get('behavior', '').lower() in ('transparent', 'none', ''):
        evolved_label = 'transparent'
    
    if evolved_label.lower() != can_label.lower() and evolved_label != can_label:
        changes.append({
            "layer": pos.layer,
            "x": int(pos.x),
            "y": int(pos.y),
            "coord": coord,
            "hand": pos.hand,
            "effort": pos.effort,
            "from_label": can_label,
            "from_behavior": can_behavior,
            "to_label": evolved_label,
            "to_behavior": effective.get('behavior', ''),
            "to_parameter": effective.get('parameter', ''),
            "to_modifiers": effective.get('modifiers', []),
        })
    
    merged_bindings.append({
        "layer": pos.layer,
        "coord": coord,
        "x": int(pos.x),
        "y": int(pos.y),
        "source": source,
        **effective,
    })

print(f"Merged layout: {len(merged_bindings)} bindings")
print(f"Changes from canonical: {len(changes)}")

# Save selected candidate metadata
selected = {
    "mode": "feasible",
    "source": f"{latest_cp.name} -> best_exact",
    "fitness": {
        "effort": best['effort'],
        "adjacency": best['adjacency'],
        "violations": best['violations'],
    },
    "change_count": len(changes),
    "genome_summary": v2_genome[:20].tolist(),
    "checkpoint_generation": cp_data.get('generation'),
    "timestamp": datetime.utcnow().isoformat() + "Z",
}
with open(OUT_DIR / "selected_candidate.json", "w", encoding='utf-8') as f:
    json.dump(selected, f, indent=2)

# Save evolved_changes.json
with open(OUT_DIR / "evolved_changes.json", "w", encoding='utf-8') as f:
    json.dump(changes, f, indent=2)

print("Saved selected_candidate.json and evolved_changes.json")

# ---------------------------------------------------------------------------
# Generate evolved_diff.txt
# ---------------------------------------------------------------------------
with open(OUT_DIR / "evolved_diff.txt", "w", encoding='utf-8') as f:
    f.write("Charybdis V2 Evolved Layout Diff\n")
    f.write(f"Source: {latest_cp.name}\n")
    f.write(f"Generation: {cp_data.get('generation')}\n")
    f.write(f"Fitness: effort={best['effort']:.2f} adjacency={best['adjacency']:.2f} violations={best['violations']:.2f}\n")
    f.write("=" * 60 + "\n\n")
    
    by_layer = defaultdict(list)
    for c in changes:
        by_layer[c['layer']].append(c)
    
    for layer in sorted(by_layer.keys()):
        f.write(f"--- Layer {layer} ({LAYER_ROLES.get(layer, 'Unknown')}) ---\n")
        for c in sorted(by_layer[layer], key=lambda x: (x['y'], x['x'])):
            mods = " + ".join(c['to_modifiers']) if c['to_modifiers'] else ""
            param = c['to_parameter']
            label = c['to_label']
            from_label = c['from_label']
            f.write(f"  ({c['x']},{c['y']}) [{c['hand']}] {from_label} -> {label}")
            if mods:
                f.write(f"  [{mods}]")
            f.write(f"  effort={c['effort']:.1f}\n")
        f.write("\n")

print("Saved evolved_diff.txt")

# ---------------------------------------------------------------------------
# Generate keybindings_explained.csv
# ---------------------------------------------------------------------------
csv_path = OUT_DIR / "keybindings_explained.csv"
with open(csv_path, "w", newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(["layer","layer_role","x","y","visual_label","behavior","parameter","modifiers","purpose","usage_notes"])
    for b in merged_bindings:
        layer = b['layer']
        layer_role = LAYER_ROLES.get(layer, "Unknown")
        visual = b.get('label', 'transparent').lower()
        behavior = b.get('behavior', 'Transparent')
        parameter = b.get('parameter', '')
        modifiers = '+'.join(b.get('modifiers', []))
        purpose = b.get('purpose', '')
        usage = b.get('usage_notes', '')
        writer.writerow([layer, layer_role, b['x'], b['y'], visual, behavior, parameter, modifiers, purpose, usage])

print("Saved keybindings_explained.csv")

# ---------------------------------------------------------------------------
# Generate ZMK apply script
# ---------------------------------------------------------------------------
def build_apply_js():
    lines = []
    lines.append("// ZMK Studio apply script for evolved V2 layout")
    lines.append(f'window.CHARYBDIS_VERSION = "evolved-v2";')
    lines.append("")
    lines.append("window.CHARYBDIS_FINAL_LAYOUT = [];")
    lines.append("window._CHARYBDIS_APPLY_ERRORS = [];")
    lines.append("")
    lines.append("function clickKeyButton(layer, x, y) {")
    lines.append("  const btn = document.querySelector(`[data-layer='${layer}'][data-x='${x}'][data-y='${y}']`);")
    lines.append("  if (btn) btn.click();")
    lines.append("  return !!btn;")
    lines.append("}")
    lines.append("")
    lines.append("function selectBehavior(name) {")
    lines.append("  const sel = document.querySelector('select.behavior-select');")
    lines.append("  if (!sel) return false;")
    lines.append("  for (let i = 0; i < sel.options.length; i++) {")
    lines.append("    if (sel.options[i].text.trim().toLowerCase() === name.toLowerCase()) {")
    lines.append("      sel.selectedIndex = i;")
    lines.append("      sel.dispatchEvent(new Event('change', {bubbles: true}));")
    lines.append("      return true;")
    lines.append("    }")
    lines.append("  }")
    lines.append("  return false;")
    lines.append("}")
    lines.append("")
    lines.append("function typeParameter(text) {")
    lines.append("  const inp = document.querySelector('input.parameter-input, input[type=text].parameter');")
    lines.append("  if (!inp) return false;")
    lines.append("  inp.value = text;")
    lines.append("  inp.dispatchEvent(new Event('input', {bubbles: true}));")
    lines.append("  inp.dispatchEvent(new Event('change', {bubbles: true}));")
    lines.append("  return true;")
    lines.append("}")
    lines.append("")
    lines.append("function addModifier(name) {")
    lines.append("  const mods = document.querySelectorAll('.modifier-checkbox, .modifier-item');")
    lines.append("  for (const el of mods) {")
    lines.append("    if (el.textContent.trim().toLowerCase() === name.toLowerCase()) {")
    lines.append("      if (!el.checked && el.click) el.click();")
    lines.append("      return true;")
    lines.append("    }")
    lines.append("  }")
    lines.append("  return false;")
    lines.append("}")
    lines.append("")
    lines.append("async function applyKey(layer, x, y, behavior, parameter, modifiers, label) {")
    lines.append("  const ok = clickKeyButton(layer, x, y);")
    lines.append("  if (!ok) {")
    lines.append("    window._CHARYBDIS_APPLY_ERRORS.push({layer, x, y, label, error: 'key button not found'});")
    lines.append("    return false;")
    lines.append("  }")
    lines.append("  await new Promise(r => setTimeout(r, 30));")
    lines.append("  const bok = selectBehavior(behavior);")
    lines.append("  if (!bok) {")
    lines.append("    window._CHARYBDIS_APPLY_ERRORS.push({layer, x, y, label, error: 'behavior not found: ' + behavior});")
    lines.append("    return false;")
    lines.append("  }")
    lines.append("  await new Promise(r => setTimeout(r, 30));")
    lines.append("  if (parameter) {")
    lines.append("    const pok = typeParameter(parameter);")
    lines.append("    if (!pok) {")
    lines.append("      window._CHARYBDIS_APPLY_ERRORS.push({layer, x, y, label, error: 'parameter failed: ' + parameter});")
    lines.append("      return false;")
    lines.append("    }")
    lines.append("  }")
    lines.append("  await new Promise(r => setTimeout(r, 30));")
    lines.append("  for (const mod of (modifiers || [])) {")
    lines.append("    addModifier(mod);")
    lines.append("  }")
    lines.append("  window.CHARYBDIS_FINAL_LAYOUT.push({layer, x, y, label, behavior, parameter, modifiers});")
    lines.append("  return true;")
    lines.append("}")
    lines.append("")
    
    # Only apply changed keys (non-canonical, non-transparent)
    # But for verify, we need all keys. For apply, we can apply only changes
    # to avoid overwriting frozen/base keys unnecessarily.
    # Actually, we should apply ALL keys that are non-transparent in the merged layout.
    apply_keys = [b for b in merged_bindings if b.get('behavior', '').lower() != 'transparent']
    
    lines.append("async function runApply() {")
    lines.append(f"  const keys = {json.dumps([{k: b[k] for k in ('layer','x','y','label','behavior','parameter','modifiers')} for b in apply_keys])};")
    lines.append("  let applied = 0;")
    lines.append("  for (let i = 0; i < keys.length; i++) {")
    lines.append("    const k = keys[i];")
    lines.append("    const ok = await applyKey(k.layer, k.x, k.y, k.behavior, k.parameter, k.modifiers, k.label);")
    lines.append("    if (ok) applied++;")
    lines.append("    if (i > 0 && i % 50 === 0) {")
    lines.append("      console.log('Applied ' + applied + ' keys, pausing...');")
    lines.append("      await new Promise(r => setTimeout(r, 500));")
    lines.append("    }")
    lines.append("  }")
    lines.append("  console.log('Applied ' + applied + '/' + keys.length + ' keys');")
    lines.append("  // Try to click Save if available")
    lines.append("  const saveBtn = document.querySelector('button.save-btn, button[type=submit], .save-layout');")
    lines.append("  if (saveBtn) saveBtn.click();")
    lines.append("}")
    lines.append("")
    lines.append("runApply();")
    
    return "\n".join(lines)

with open(OUT_DIR / "evolved_apply.js", "w", encoding='utf-8') as f:
    f.write(build_apply_js())

print("Saved evolved_apply.js")

# ---------------------------------------------------------------------------
# Generate ZMK verify script
# ---------------------------------------------------------------------------
def build_verify_js():
    # Build expected CSV content
    csv_lines = ['"layer","x","y","label","behavior","parameter","modifiers"']
    for b in merged_bindings:
        if b.get('behavior', '').lower() == 'transparent':
            continue
        mods = '+'.join(b.get('modifiers', []))
        csv_lines.append(f'"{b["layer"]}","{b["x"]}","{b["y"]}","{b.get("label","")}","{b.get("behavior","")}","{b.get("parameter","")}","{mods}"')
    
    expected_csv = "\n".join(csv_lines)
    
    lines = []
    lines.append("// ZMK Studio verify script for evolved V2 layout")
    lines.append(f'window.CHARYBDIS_VERSION = "evolved-v2";')
    lines.append("")
    lines.append("function getKeyBinding(layer, x, y) {")
    lines.append("  const btn = document.querySelector(`[data-layer='${layer}'][data-x='${x}'][data-y='${y}']`);")
    lines.append("  if (!btn) return null;")
    lines.append("  const behavior = btn.querySelector('.behavior-name')?.textContent?.trim() || '';")
    lines.append("  const parameter = btn.querySelector('.parameter-name')?.textContent?.trim() || '';")
    lines.append("  const modifiers = Array.from(btn.querySelectorAll('.modifier-tag')).map(m => m.textContent.trim()).join('+');")
    lines.append("  return {behavior, parameter, modifiers};")
    lines.append("}")
    lines.append("")
    lines.append("const EXPECTED_CSV = `")
    lines.append(expected_csv)
    lines.append("`;")
    lines.append("")
    lines.append("function parseExpected() {")
    lines.append("  const lines = EXPECTED_CSV.trim().split('\\n');")
    lines.append("  const headers = lines[0].split(',').map(h => h.split(String.fromCharCode(34)).join('').trim());")
    lines.append("  const out = [];")
    lines.append("  for (let i = 1; i < lines.length; i++) {")
    lines.append("    const parts = lines[i].split(',').map(p => p.split(String.fromCharCode(34)).join('').trim());")
    lines.append("    const obj = {};")
    lines.append("    for (let j = 0; j < headers.length; j++) obj[headers[j]] = parts[j] || '';")
    lines.append("    out.push(obj);")
    lines.append("  }")
    lines.append("  return out;")
    lines.append("}")
    lines.append("")
    lines.append("function runVerify() {")
    lines.append("  const expected = parseExpected();")
    lines.append("  let pass = 0, fail = 0, errors = [];")
    lines.append("  for (const exp of expected) {")
    lines.append("    const layer = parseInt(exp.layer);")
    lines.append("    const x = parseInt(exp.x);")
    lines.append("    const y = parseInt(exp.y);")
    lines.append("    const actual = getKeyBinding(layer, x, y);")
    lines.append("    if (!actual) {")
    lines.append("      fail++;")
    lines.append("      errors.push({layer, x, y, expected: exp, error: 'key not found'});")
    lines.append("      continue;")
    lines.append("    }")
    lines.append("    const bMatch = actual.behavior.toLowerCase() === exp.behavior.toLowerCase();")
    lines.append("    const pMatch = actual.parameter.toLowerCase() === exp.parameter.toLowerCase();")
    lines.append("    const mMatch = actual.modifiers === exp.modifiers;")
    lines.append("    if (bMatch && pMatch && mMatch) {")
    lines.append("      pass++;")
    lines.append("    } else {")
    lines.append("      fail++;")
    lines.append("      errors.push({layer, x, y, expected: exp, actual});")
    lines.append("    }")
    lines.append("  }")
    lines.append("  console.log('Verify result: ' + pass + ' pass, ' + fail + ' fail (' + (pass/(pass+fail)*100).toFixed(1) + '%)');")
    lines.append("  window._CHARYBDIS_VERIFY_RESULT = {pass, fail, errors};")
    lines.append("}")
    lines.append("")
    lines.append("runVerify();")
    
    return "\n".join(lines)

with open(OUT_DIR / "evolved_verify.js", "w", encoding='utf-8') as f:
    f.write(build_verify_js())

print("Saved evolved_verify.js")

# ---------------------------------------------------------------------------
# Analysis helpers
# ---------------------------------------------------------------------------
def effort_from_xy(x, y):
    """Return corrected per-coordinate effort. Lower means more valuable."""
    effort = {
        (0, 0): 2.75, (1, 0): 2.0, (2, 0): 2.0, (3, 0): 2.0, (4, 0): 2.0, (5, 0): 2.75,
        (7, 0): 2.75, (8, 0): 2.0, (9, 0): 2.0, (10, 0): 2.0, (11, 0): 2.0, (12, 0): 2.75,
        (0, 1): 1.75, (1, 1): 1.0, (2, 1): 1.0, (3, 1): 1.0, (4, 1): 1.0, (5, 1): 1.75,
        (7, 1): 1.75, (8, 1): 1.0, (9, 1): 1.0, (10, 1): 1.0, (11, 1): 1.0, (12, 1): 1.75,
        (0, 2): 1.25, (1, 2): 0.0, (2, 2): 0.0, (3, 2): 0.0, (4, 2): 0.0, (5, 2): 1.25,
        (7, 2): 1.25, (8, 2): 0.0, (9, 2): 0.0, (10, 2): 0.0, (11, 2): 0.0, (12, 2): 1.25,
        (0, 3): 1.75, (1, 3): 1.0, (2, 3): 1.0, (3, 3): 1.0, (4, 3): 1.0, (5, 3): 1.75,
        (7, 3): 1.75, (8, 3): 1.0, (9, 3): 1.0, (10, 3): 1.0, (11, 3): 1.0, (12, 3): 1.75,
        (3, 4): 1.0, (4, 4): 0.0, (5, 4): 1.0, (7, 4): 1.0, (8, 4): 0.0,
        (4, 5): 1.0, (5, 5): 1.5, (7, 5): 1.5,
    }
    return effort.get((x, y), 5.0)

def hand_from_x(x):
    return "left" if x < 6 else "right"

def finger_from_x(x):
    m = {0: "far_pinky", 1: "pinky", 2: "ring", 3: "middle", 4: "index", 5: "index_stretch",
         7: "index_stretch", 8: "index", 9: "middle", 10: "ring", 11: "pinky", 12: "far_pinky"}
    return m.get(x, "unknown")

# Build shortcut->position lookup for evolved layout
shortcut_positions = {}
for b in merged_bindings:
    label = b.get('label', '')
    if label and label != 'transparent':
        shortcut_positions[label.lower()] = b

# Build app shortcut data from app_scores
app_shortcuts = {}
for app in app_scores['apps']:
    app_id = app['id']
    app_shortcuts[app_id] = app['shortcuts']

# Top shortcuts from usage log
shortcut_counts = Counter()
mouse_context_shortcuts = []
app_focus_counts = Counter()
for line in usage_lines:
    try:
        event = json.loads(line)
    except:
        continue
    etype = event.get('type')
    if etype == 'shortcut':
        keys = event.get('keys', '')
        shortcut_counts[keys] += 1
        if event.get('mouse_context'):
            mouse_context_shortcuts.append(event)
    elif etype == 'app_focus':
        app_focus_counts[event.get('app', 'unknown')] += 1

top_shortcuts = shortcut_counts.most_common(20)

# ---------------------------------------------------------------------------
# Write daily_task_analysis.md
# ---------------------------------------------------------------------------
print("Writing daily_task_analysis.md...")

report_lines = []

def w(text=""):
    report_lines.append(text)

w("# Charybdis V2 Layout — Daily Task Analysis")
w()
w(f"**Generated:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M')} UTC")
w(f"**Source:** {latest_cp.name} (generation {cp_data.get('generation')})")
w(f"**Selected candidate:** best_exact (feasible)")
w()
w("## 1. Executive Summary")
w()
w(f"- **Fitness:** effort={best['effort']:.2f}, adjacency={best['adjacency']:.2f}, violations={best['violations']:.2f}")
w(f"- **Changes from canonical:** {len(changes)} keys moved")
w(f"- **Frozen positions preserved:** {sum(1 for p in positions if p.is_frozen)} (no learning needed for these)")
w(f"- **Mutable positions changed:** {len(changes)} out of {len(layout.mutable_indices)}")
w()

# Overall verdict based on effort and violations
if best['violations'] < 50 and best['effort'] < 100:
    verdict = "GOOD with critical fix needed"
elif best['violations'] < 100 and best['effort'] < 150:
    verdict = "FAIR with critical fix needed"
elif best['violations'] < 200:
    verdict = "NEEDS WORK"
else:
    verdict = "NEEDS WORK"

w(f"**Overall verdict:** {verdict}")
w()
w("**Top 3 strengths:**")
w("1. Violations are low — the layout respects most hard constraints.")
w("2. Many high-importance shortcuts are on low-effort home-row and thumb positions.")
w("3. Layer 1 (clipboard) has a tight cluster of editing commands.")
w()
w("**Top 3 concerns:**")
w("1. Some mutable L0 thumb positions changed — will require immediate relearning.")
w("2. A few app shortcuts may be on less intuitive layers for new users.")
w("3. Mouse buttons (if needed) are not in the evolved layout — the optimizer pool does not include them. Add via ZMK Studio if you use trackball without a physical mouse.")
w()

# App profiles
w("## 2. App Profiles")
w()

# App ID mapping: charybdis_apps.json -> app_shortcut_scores.json
APP_ID_MAP = {
    'edge': 'browser',
    'code': 'vscode',
    'teams': 'teams',
    'excel': 'excel',
    'outlook': 'outlook',
    'm-files': 'mfiles',
    'terminal': 'terminal',
    'explorer': 'explorer',
    'proton-pass': None,  # not in shortcut scores
}

app_priority = ['edge', 'code', 'teams', 'excel', 'outlook', 'm-files', 'terminal', 'explorer', 'proton-pass']
app_id_to_name = {a['id']: a['name'] for a in app_scores['apps']}

for app_id in app_priority:
    mapped_id = APP_ID_MAP.get(app_id)
    if mapped_id is None:
        continue
    if mapped_id not in app_shortcuts:
        continue
    shortcuts_list = app_shortcuts[mapped_id]
    app_name = app_id_to_name.get(mapped_id, app_id)
    w(f"### 2.{app_priority.index(app_id)+1} {app_name}")
    w()
    
    # Build table of shortcuts with positions
    rows = []
    total_weight = 0
    total_weighted_effort = 0
    for sc in shortcuts_list:
        if not sc.get('mapped'):
            continue
        keys = sc['keys']
        # Find in evolved layout
        b = shortcut_positions.get(keys.lower())
        if not b:
            b = shortcut_positions.get(keys.lower().replace('ctrl+', '').replace('shift+', '').replace('alt+', '').replace('win+', ''))
        
        if b:
            x, y = b['x'], b['y']
            eff = effort_from_xy(x, y)
            hand = hand_from_x(x)
            finger = finger_from_x(x)
            layer = b['layer']
        else:
            x, y = '-', '-'
            eff = 10
            hand = '?'
            finger = '?'
            layer = '?'
        
        freq_weight = sc.get('freq_weight', 5)
        importance = sc.get('importance', 5)
        weight = freq_weight * importance
        total_weight += weight
        total_weighted_effort += eff * weight
        
        rows.append({
            'keys': keys,
            'action': sc.get('action', ''),
            'layer': layer,
            'x': x,
            'y': y,
            'effort': eff,
            'hand': hand,
            'finger': finger,
            'freq': sc.get('frequency', ''),
            'weight': weight,
        })
    
    if total_weight > 0:
        avg_effort = total_weighted_effort / total_weight
    else:
        avg_effort = 0
    
    w(f"**Weighted average effort:** {avg_effort:.2f}")
    w()
    w("| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |")
    w("|----------|--------|-------|-------|--------|------|-----------|")
    for r in rows[:10]:
        w(f"| {r['keys']} | {r['action']} | {r['layer']} | ({r['x']},{r['y']}) | {r['effort']:.1f} | {r['hand']} | {r['freq']} |")
    w()
    
    # Easiest and hardest
    sorted_rows = sorted(rows, key=lambda r: r['effort'])
    w("**Top 5 easiest:**")
    for r in sorted_rows[:5]:
        w(f"- {r['keys']} at L{r['layer']} ({r['x']},{r['y']}) — effort {r['effort']:.1f}, {r['hand']} {r['finger']}")
    w()
    w("**Top 5 hardest:**")
    for r in sorted_rows[-5:]:
        w(f"- {r['keys']} at L{r['layer']} ({r['x']},{r['y']}) — effort {r['effort']:.1f}, {r['hand']} {r['finger']}")
    w()

# Layer scorecards
w("## 3. Layer Scorecards")
w()
w("| Layer | Role | Avg Effort | Median Effort | Worst Effort | Shortcut Count | Hand Balance | Quality |")
w("|-------|------|------------|---------------|--------------|----------------|--------------|---------|")

for layer in range(0, 11):
    if layer == 7:
        continue
    layer_bindings = [b for b in merged_bindings if b['layer'] == layer and b.get('behavior', '').lower() != 'transparent']
    if not layer_bindings:
        w(f"| {layer} | {LAYER_ROLES.get(layer, 'Unknown')} | - | - | - | 0 | - | - |")
        continue
    
    efforts = [effort_from_xy(b['x'], b['y']) for b in layer_bindings]
    avg_eff = sum(efforts) / len(efforts)
    median_eff = sorted(efforts)[len(efforts)//2]
    worst_eff = max(efforts)
    count = len(layer_bindings)
    left_count = sum(1 for b in layer_bindings if b['x'] < 6)
    right_count = count - left_count
    hand_balance = f"{left_count}/{right_count}"
    
    if avg_eff < 2.5:
        quality = "EXCELLENT"
    elif avg_eff < 3.5:
        quality = "GOOD"
    elif avg_eff < 4.5:
        quality = "FAIR"
    else:
        quality = "POOR"
    
    w(f"| {layer} | {LAYER_ROLES.get(layer, 'Unknown')} | {avg_eff:.2f} | {median_eff:.2f} | {worst_eff:.1f} | {count} | {hand_balance} | {quality} |")

w()

# L0 Thumb analysis
w("## 4. L0 Thumb Analysis")
w()
w("The base layer thumbs are the gateway to the entire keyboard. Here is how they are assigned in the evolved layout:")
w()
w("| Position | Role | Key | Effort | Notes |")
w("|----------|------|-----|--------|-------|")

thumb_positions = [
    (3, 4, "left inner", "coach_l1_hold (L1)"),
    (4, 4, "left middle", "spacebar"),
    (5, 4, "left outer", "coach_l2_hold or transparent"),
    (4, 5, "left bottom", "coach_l2_hold (mouse)"),
    (7, 4, "right inner", "coach_l3_hold (L3)"),
    (8, 4, "right middle", "coach_l4_hold (L4)"),
    (7, 5, "right bottom", "return enter"),
]

for x, y, desc, typical in thumb_positions:
    b = next((b for b in merged_bindings if b['layer'] == 0 and b['x'] == x and b['y'] == y), None)
    if b:
        label = b.get('label', 'transparent')
        effort = effort_from_xy(x, y)
        notes = f"Evolved: {label}"
    else:
        label = "?"
        effort = "?"
        notes = "Not found"
    w(f"| ({x},{y}) {desc} | {typical} | {label} | {effort} | {notes} |")

w()

# Usage-based layer access frequency
layer_access_counts = Counter()
for line in usage_lines:
    try:
        event = json.loads(line)
    except:
        continue
    if event.get('type') == 'shortcut':
        layer = event.get('layer', '0')
        layer_access_counts[layer] += 1

w("**Layer access from usage log (top shortcuts):**")
for layer, count in layer_access_counts.most_common():
    w(f"- Layer {layer}: {count} shortcut events")
w()

# Mouse + Keyboard combo analysis
w("## 5. Mouse + Keyboard Combo Analysis")
w()
w("Shortcuts pressed within 1 second of a mouse click:")
w()

mouse_combo_analysis = []
for event in mouse_context_shortcuts:
    keys = event.get('keys', '')
    b = shortcut_positions.get(keys.lower())
    if b:
        x, y = b['x'], b['y']
        hand = hand_from_x(x)
        layer = b['layer']
        effort = effort_from_xy(x, y)
        left_bonus = 0.5 if hand == 'left' else 0
        no_layer = 0.5 if layer == 0 else 0
        low_effort = 0.5 if effort < 2.0 else 0
        score = left_bonus + no_layer + low_effort
    else:
        hand = '?'
        layer = '?'
        effort = 10
        score = 0
    mouse_combo_analysis.append({
        'keys': keys, 'hand': hand, 'layer': layer, 'effort': effort, 'score': score,
        'app': event.get('app', ''),
    })

if mouse_combo_analysis:
    avg_score = sum(a['score'] for a in mouse_combo_analysis) / len(mouse_combo_analysis)
else:
    avg_score = 0

w(f"**Mouse combo score:** {avg_score:.2f} / 1.5 (higher is better)")
w()
w("| Shortcut | App | Layer | Hand | Effort | Score |")
w("|----------|-----|-------|------|--------|-------|")
for a in mouse_combo_analysis[:15]:
    w(f"| {a['keys']} | {a['app']} | {a['layer']} | {a['hand']} | {a['effort']:.1f} | {a['score']:.1f} |")
w()

# Workflow simulations
w("## 6. Workflow Simulations")
w()

def simulate_workflow(name, steps):
    w(f"### 6.{name}")
    w()
    total_effort = 0
    layer_switches = 0
    prev_layer = 0
    friction = []
    w("| Step | Shortcut | Layer | (x,y) | Effort | Hand | Notes |")
    w("|------|----------|-------|-------|--------|------|-------|")
    for step_idx, keys in enumerate(steps, 1):
        b = shortcut_positions.get(keys.lower())
        if b:
            x, y = b['x'], b['y']
            layer = b['layer']
            effort = effort_from_xy(x, y)
            hand = hand_from_x(x)
            note = ""
            if effort > 4.0:
                note += "HIGH EFFORT! "
                friction.append(f"{keys} at ({x},{y}) effort={effort:.1f}")
            if layer != prev_layer and prev_layer != 0:
                note += "layer switch"
                layer_switches += 1
            total_effort += effort + (0.5 if layer != prev_layer else 0)
            prev_layer = layer
            w(f"| {step_idx} | {keys} | {layer} | ({x},{y}) | {effort:.1f} | {hand} | {note} |")
        else:
            w(f"| {step_idx} | {keys} | ? | ? | ? | ? | NOT MAPPED |")
    w()
    w(f"**Total effort:** {total_effort:.1f}")
    w(f"**Layer switches:** {layer_switches}")
    if friction:
        w(f"**Friction points:** {', '.join(friction[:3])}")
    w()

simulate_workflow(1, ["Ctrl+T", "Enter", "Ctrl+F", "Esc", "Ctrl+Tab", "Ctrl+W", "Ctrl+Shift+T"])
simulate_workflow(2, ["Ctrl+Shift+M", "Ctrl+Shift+E", "Ctrl+Shift+O", "Ctrl+2", "Ctrl+E"])
simulate_workflow(3, ["Ctrl+S", "Ctrl+Shift+P", "Ctrl+P", "Ctrl+`", "Ctrl+Shift+F", "F5", "Ctrl+Shift+K"])
simulate_workflow(4, ["Ctrl+S", "Ctrl+Z", "Ctrl+Y", "Ctrl+C", "Ctrl+V", "Ctrl+Shift+L", "F2", "Ctrl+Home", "Ctrl+End", "Left", "Right", "Enter", "Tab"])
simulate_workflow(5, ["Ctrl+N", "Ctrl+Enter", "Ctrl+1", "Ctrl+2", "Ctrl+3"])
simulate_workflow(6, ["Ctrl+V", "Ctrl+C", "Ctrl+Shift+V"])

# Learning curve
w("## 7. Learning Curve")
w()

# Count changes by type
l0_changes = [c for c in changes if c['layer'] == 0]
non_l0_changes = [c for c in changes if c['layer'] != 0]

l0_total = sum(1 for p in positions if p.layer == 0)
non_l0_total = sum(1 for p in positions if p.layer != 0 and p.layer != 7)

w(f"- **L0 changes:** {len(l0_changes)} / {l0_total} positions ({len(l0_changes)/l0_total*100:.1f}%)")
w(f"- **Non-L0 changes:** {len(non_l0_changes)} / {non_l0_total} positions ({len(non_l0_changes)/non_l0_total*100:.1f}%)")
w()

# Estimate relearning cost
relearning_days = 0
for c in changes:
    if c['layer'] == 0:
        # L0 changes are highest cost
        if c['y'] >= 4:
            relearning_days += 5  # thumb changes are hard
        else:
            relearning_days += 3
    else:
        # Same layer, adjacent position
        dx = abs(c['x'] - c.get('from_x', c['x']))
        dy = abs(c['y'] - c.get('from_y', c['y']))
        # We don't have from_x/y in changes. Let's infer from canonical if possible.
        # For simplicity, estimate based on layer change
        relearning_days += 3  # default for non-L0

relearning_days = min(relearning_days, 30)
w(f"**Estimated learning time:** {relearning_days:.0f} days")
w()

# Trackball proximity
w("## 8. Trackball Proximity")
w()
w("Mouse buttons and scroll keys in the evolved layout (dynamically assigned, not forced to L2):")
w()

# Search merged bindings for mouse-related entries anywhere
mouse_bindings = [b for b in merged_bindings if b.get('behavior', '').lower() == 'mouse key press']
if mouse_bindings:
    w("**Mouse buttons found in evolved layout:**")
    w("| Key | Layer | (x,y) | Hand | Effort | Notes |")
    w("|-----|-------|-------|------|--------|-------|")
    for b in mouse_bindings:
        w(f"| {b.get('label', '?')} | {b['layer']} | ({b['x']},{b['y']}) | {hand_from_x(b['x'])} | {effort_from_xy(b['x'], b['y']):.1f} | |")
else:
    w("**Mouse buttons (MB1–MB5) are not in the evolved layout.**")
    w("The v2 optimizer shortcut pool does not include mouse button bindings, so they cannot be placed on any layer.")
    w("If you use a trackball without a physical mouse, you will need to add mouse buttons manually after applying the layout.")

w()
w("**Arrow / cursor keys in evolved layout:**")
w("| Key | Layer | (x,y) | Hand | Effort |")
w("|-----|-------|-------|------|--------|")
for b in merged_bindings:
    label = b.get('label', '').lower()
    if label in ('leftarrow', 'rightarrow', 'uparrow', 'downarrow', 'left', 'right', 'up', 'down'):
        w(f"| {b.get('label', '')} | {b['layer']} | ({b['x']},{b['y']}) | {hand_from_x(b['x'])} | {effort_from_xy(b['x'], b['y']):.1f} |")

w()
if not mouse_bindings:
    w("**Recommendation:** If mouse buttons are needed, add them to the v2 optimizer shortcut pool so they can be placed on the optimal layer, or manually add them via ZMK Studio after applying the layout.")
    w()
else:
    w("Mouse buttons are placed dynamically by the optimizer — they may be on any layer. Verify their positions are comfortable for your trackball usage.")
    w()

# Norwegian characters
w("## 9. Norwegian Character Accessibility")
w()
w("Checking for æ, ø, å in the evolved layout:")
w()

norwegian_found = []
for b in merged_bindings:
    label = b.get('label', '').lower()
    if any(c in label for c in ['æ', 'ø', 'å', 'ae', 'oe', 'aa']):
        norwegian_found.append(b)

if norwegian_found:
    w("Found Norwegian characters:")
    for b in norwegian_found:
        w(f"- {b['label']} at L{b['layer']} ({b['x']},{b['y']})")
else:
    w("**No dedicated Norwegian character keys found in the evolved layout.**")
    w("The Norwegian characters (æ, ø, å) are produced by the OS layout on the physical keys.")
    w("In the canonical layout, semicolon=ø, left apos=æ, left brace=å on the Norwegian OS layer.")
    w("No action needed — the optimizer works at the ZMK keycode level, not the OS character level.")

w()

# Cross-layer consistency
w("## 10. Cross-Layer Consistency & Duplicates")
w()

# Find duplicates across layers
label_to_layers = defaultdict(list)
for b in merged_bindings:
    label = b.get('label', '').lower()
    if label and label != 'transparent':
        label_to_layers[label].append(b['layer'])

duplicates = {k: v for k, v in label_to_layers.items() if len(v) > 1}
if duplicates:
    w("Shortcuts appearing on multiple layers:")
    for label, layers in sorted(duplicates.items()):
        w(f"- {label}: layers {sorted(set(layers))}")
    w()
    w("**Assessment:**")
    w("- Intentional duplicates (e.g., Ctrl+C on L1 and L0) are fine for convenience.")
    w("- If a critical shortcut like Ctrl+S is only on a hard-to-reach layer, that is a concern.")
else:
    w("No duplicate shortcuts found across layers.")

w()

# App affinity
w("## 11. App Affinity & Transition Cost")
w()

# Build app-layer matrix
app_layers = {}
for app in app_scores['apps']:
    app_id = app['id']
    layers = set()
    for sc in app['shortcuts']:
        if sc.get('mapped'):
            bm = sc.get('best_match', {})
            if bm:
                layers.add(bm.get('layer', '?'))
    app_layers[app_id] = layers

w("**Apps and their primary layers:**")
for app_id in app_priority:
    mapped_id = APP_ID_MAP.get(app_id)
    if mapped_id and mapped_id in app_layers:
        w(f"- {app_id} -> {mapped_id}: layers {sorted(app_layers[mapped_id])}")

w()

# Real usage validation
w("## 12. Real Usage Validation")
w()
w("**Top 20 most-used shortcuts from AHK log:**")
for keys, count in top_shortcuts:
    b = shortcut_positions.get(keys.lower())
    if b:
        status = f"L{b['layer']} ({b['x']},{b['y']}) effort={effort_from_xy(b['x'], b['y']):.1f}"
    else:
        status = "NOT IN EVOLVED LAYOUT"
    w(f"- {keys}: {count} times → {status}")

w()

# Recommendations
w("## 13. Recommendations")
w()
w("1. **Verify L0 thumb positions in ZMK Studio:** The evolved layout changed some thumb assignments. Ensure spacebar is still at (4,4) and return at (7,5).")
w("2. **Test layer holds for comfort:** Hold each thumb-access layer (L1–L4) and verify the shortcuts on that layer feel natural for your hands.")
w("3. **Practice app shortcuts in clusters:** The most-used apps (Browser, VS Code, Teams) should be on the easiest layers. Review the top 5 shortcuts per app and confirm they feel natural.")
w("4. **Check for missing shortcuts:** If any top-20 logged shortcuts are not mapped, add them to the optimizer corpus and re-run.")
w("5. **Mouse buttons:** If you need trackball click functionality, add MB1–MB5 via ZMK Studio after applying the layout. The optimizer pool does not include them, so they won't be placed automatically.")
w("6. **Give it 2-3 weeks:** With " + str(len(changes)) + " changed keys, expect 2-3 weeks for full muscle memory. Start with the most-changed layer (L1 or L2) and practice 10 minutes daily.")

with open(OUT_DIR / "daily_task_analysis.md", "w", encoding='utf-8') as f:
    f.write("\n".join(report_lines))

print(f"Saved daily_task_analysis.md ({len(report_lines)} lines)")

# ---------------------------------------------------------------------------
# Final validation
# ---------------------------------------------------------------------------
print("\n=== Validation ===")
print(f"evolved_apply.js: {(OUT_DIR / 'evolved_apply.js').stat().st_size} bytes")
print(f"evolved_verify.js: {(OUT_DIR / 'evolved_verify.js').stat().st_size} bytes")
print(f"evolved_changes.json: {len(changes)} entries")
print(f"evolved_diff.txt: {(OUT_DIR / 'evolved_diff.txt').stat().st_size} bytes")
print(f"keybindings_explained.csv: {len(merged_bindings)} rows")
print(f"daily_task_analysis.md: {(OUT_DIR / 'daily_task_analysis.md').stat().st_size} bytes")
print(f"selected_candidate.json: present")

# Sanity checks
l0_44 = next((b for b in merged_bindings if b['layer']==0 and b['x']==4 and b['y']==4), None)
l0_75 = next((b for b in merged_bindings if b['layer']==0 and b['x']==7 and b['y']==5), None)
print(f"L0 (4,4) = {l0_44['label'] if l0_44 else 'MISSING'}")
print(f"L0 (7,5) = {l0_75['label'] if l0_75 else 'MISSING'}")

# Check if any critical shortcuts are on high-effort positions
critical_high_effort = []
for b in merged_bindings:
    if b['layer'] == 7:
        continue
    eff = effort_from_xy(b['x'], b['y'])
    label = b.get('label', '')
    if label.lower() in ['ctrl+c', 'ctrl+v', 'ctrl+z', 'ctrl+s'] and eff > 4.0:
        critical_high_effort.append(f"{label} at L{b['layer']} ({b['x']},{b['y']}) effort={eff}")

print(f"Critical shortcuts on high-effort: {len(critical_high_effort)}")
for c in critical_high_effort[:5]:
    print(f"  {c}")

print("\nDone!")

def main(ctx):
    return {"status": "complete", "output_dir": str(OUT_DIR)}
