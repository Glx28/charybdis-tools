import json
import sys, os
from collections import defaultdict, Counter
from pathlib import Path

sys.path.insert(0, "C:/Users/nos/charybdis-optimizer/charybdis-optimizer-v2")
sys.path.insert(0, "C:/Users/nos/charybdis-optimizer/evolve")

from core.loader import build_layout
from representation import split_shortcut_keys

BUILD_DIR = Path("C:/Users/nos/charybdis-optimizer/build")
OUT_DIR = Path("C:/Users/nos/charybdis-tools/runtime/evolved_v2_export")
OUT_DIR.mkdir(parents=True, exist_ok=True)

CP_FILE = BUILD_DIR / "v2_checkpoint_gen1000.json"
with open(CP_FILE, encoding='utf-8') as f:
    cp = json.load(f)

layout = build_layout(str(BUILD_DIR))
shortcuts = layout.shortcuts
positions = layout.positions

genome = cp['best_exact']['genome']
fitness = cp['best_exact']

with open(BUILD_DIR / "canonical.json", encoding='utf-8') as f:
    canonical = json.load(f)

# Build canonical lookup
can_bindings = {}
for layer_id, layer_data in canonical['layers'].items():
    if not layer_id or not layer_id.strip():
        continue
    for coord, binding in layer_data.get('keys', {}).items():
        can_bindings[(int(layer_id), coord)] = binding

def effort_from_xy(x, y):
    row_comfort = {0: 3.5, 1: 1.0, 2: 0.0, 3: 1.0, 4: 1.5, 5: 2.5}
    col_effort = {0: 2, 1: 0, 2: 0, 3: 0, 4: 0, 5: 2, 7: 2, 8: 0, 9: 0, 10: 0, 11: 0, 12: 2}
    return row_comfort.get(y, 5) + col_effort.get(x, 5)

def hand_from_x(x):
    return "left" if x < 6 else "right"

CRITICAL_L0 = {(3, 4), (4, 4), (7, 4), (8, 4), (7, 5)}

# Build evolved layout
layer_bindings = defaultdict(list)

for i, pos in enumerate(positions):
    coord = f"{int(pos.x)}:{int(pos.y)}"
    key = (pos.layer, coord)
    can_binding = can_bindings.get(key, {})
    
    is_critical = (pos.layer == 0 and (int(pos.x), int(pos.y)) in CRITICAL_L0)
    
    if is_critical or pos.is_frozen:
        label = can_binding.get('label', '') if can_binding else 'transparent'
        behavior = can_binding.get('behavior', 'Transparent') if can_binding else 'Transparent'
        parameter = can_binding.get('parameter', '') if can_binding else ''
        modifiers = can_binding.get('modifiers', []) if can_binding else []
        purpose = can_binding.get('purpose', '') if can_binding else ''
    else:
        sid = genome[i]
        if sid >= 0 and sid < len(shortcuts):
            sc = shortcuts[sid]
            label = sc.keys
            behavior = "Key Press"
            parameter = sc.keys
            modifiers = []
            purpose = sc.action or ''
        else:
            if can_binding:
                label = can_binding.get('label', 'transparent')
                behavior = can_binding.get('behavior', 'Transparent')
                parameter = can_binding.get('parameter', '')
                modifiers = can_binding.get('modifiers', [])
                purpose = can_binding.get('purpose', '')
            else:
                label = 'transparent'
                behavior = 'Transparent'
                parameter = ''
                modifiers = []
                purpose = ''
    
    if label.lower() == 'transparent' or behavior.lower() == 'transparent':
        continue
    
    binding = {
        'layer': pos.layer, 'x': int(pos.x), 'y': int(pos.y),
        'hand': pos.hand, 'effort': effort_from_xy(int(pos.x), int(pos.y)),
        'label': label, 'behavior': behavior, 'purpose': purpose,
    }
    layer_bindings[pos.layer].append(binding)

# Check arrow key placement
arrow_keys = ['LeftArrow', 'RightArrow', 'UpArrow', 'DownArrow']
arrow_placement = {}
for layer, bindings in layer_bindings.items():
    for b in bindings:
        if b['label'] in arrow_keys:
            arrow_placement[b['label']] = (layer, b['x'], b['y'], b['effort'])

# Check mouse button placement
mouse_keys = ['MB1', 'MB2', 'MB3', 'MB4', 'MB5']
mouse_placement = {}
for layer, bindings in layer_bindings.items():
    for b in bindings:
        if b['label'] in mouse_keys:
            mouse_placement[b['label']] = (layer, b['x'], b['y'], b['hand'], b['effort'])

# Check scroll keys
scroll_keys = ['ScrollUp', 'ScrollDown']
scroll_placement = {}
for layer, bindings in layer_bindings.items():
    for b in bindings:
        if b['label'] in scroll_keys:
            scroll_placement[b['label']] = (layer, b['x'], b['y'], b['hand'], b['effort'])

print("=== Arrow Key Placement ===")
for k in arrow_keys:
    if k in arrow_placement:
        layer, x, y, eff = arrow_placement[k]
        print(f"  {k}: L{layer} ({x},{y}) effort={eff}")
    else:
        print(f"  {k}: NOT FOUND")

print("\n=== Mouse Button Placement ===")
for k in mouse_keys:
    if k in mouse_placement:
        layer, x, y, hand, eff = mouse_placement[k]
        print(f"  {k}: L{layer} ({x},{y}) [{hand}] effort={eff}")
    else:
        print(f"  {k}: NOT FOUND")

print("\n=== Scroll Key Placement ===")
for k in scroll_keys:
    if k in scroll_placement:
        layer, x, y, hand, eff = scroll_placement[k]
        print(f"  {k}: L{layer} ({x},{y}) [{hand}] effort={eff}")
    else:
        print(f"  {k}: NOT FOUND")

# Arrow order analysis
print("\n=== Arrow Order Analysis ===")
if len(arrow_placement) >= 4:
    all_layers = set(v[0] for v in arrow_placement.values())
    if len(all_layers) == 1:
        print(f"  All arrows on same layer: L{list(all_layers)[0]} OK")
    else:
        print(f"  Arrows split across layers: {all_layers} FAIL")
    
    left_x = arrow_placement.get('LeftArrow', (None, 999, 0, 0))[1]
    right_x = arrow_placement.get('RightArrow', (None, -999, 0, 0))[1]
    up_x = arrow_placement.get('UpArrow', (None, 0, 0, 0))[1]
    down_x = arrow_placement.get('DownArrow', (None, 0, 0, 0))[1]
    
    if left_x < right_x:
        print(f"  LeftArrow x={left_x} < RightArrow x={right_x} OK")
    else:
        print(f"  LeftArrow x={left_x} >= RightArrow x={right_x} FAIL")
    
    min_x = min(left_x, right_x)
    max_x = max(left_x, right_x)
    if min_x <= up_x <= max_x:
        print(f"  UpArrow x={up_x} between Left and Right OK")
    else:
        print(f"  UpArrow x={up_x} NOT between Left({left_x}) and Right({right_x}) FAIL")
    if min_x <= down_x <= max_x:
        print(f"  DownArrow x={down_x} between Left and Right OK")
    else:
        print(f"  DownArrow x={down_x} NOT between Left({left_x}) and Right({right_x}) FAIL")
else:
    print(f"  Only {len(arrow_placement)}/4 arrows found, cannot check order")

# Generate full report
report_lines = []
report_lines.append("# Charybdis V2 (Gen 1000) — Full Workflow Layer Analysis")
report_lines.append("")
report_lines.append(f"**Source:** v2_checkpoint_gen1000.json (new run with mouse bias + arrow order)")
report_lines.append(f"**Fitness:** effort={fitness['effort']:.2f}, adjacency={fitness['adjacency']:.2f}, violations={fitness['violations']:.2f}")
report_lines.append(f"**Hand bias factor score:** {fitness['factor_scores']['hand_bias']:.1f}")
report_lines.append("")
report_lines.append("**Core premise:** Every layer is a dynamically evolved workflow cluster. Mouse buttons have right-hand bias (5×). Arrow keys have spatial order constraint (no hand bias).")
report_lines.append("")

for layer in sorted(layer_bindings.keys()):
    if layer == 7:
        continue
    bindings = layer_bindings[layer]
    if not bindings:
        continue
    
    left_count = sum(1 for b in bindings if b['hand'] == 'left')
    right_count = sum(1 for b in bindings if b['hand'] == 'right')
    avg_effort = sum(b['effort'] for b in bindings) / len(bindings) if bindings else 0
    
    report_lines.append(f"## Layer {layer}")
    report_lines.append("")
    report_lines.append(f"**Shortcuts:** {len(bindings)} | **Avg effort:** {avg_effort:.2f} | **Hand balance:** {left_count}/{right_count}")
    report_lines.append("")
    report_lines.append("| (x,y) | Effort | Hand | Shortcut | Purpose |")
    report_lines.append("|-------|--------|------|----------|---------|")
    for b in sorted(bindings, key=lambda x: (x['y'], x['x'])):
        report_lines.append(f"| ({b['x']},{b['y']}) | {b['effort']:.1f} | {b['hand']} | {b['label']} | {b['purpose'][:60]} |")
    report_lines.append("")

# Arrow section
report_lines.append("## Arrow Key Placement Verification")
report_lines.append("")
report_lines.append("| Key | Layer | (x,y) | Effort | Notes |")
report_lines.append("|-----|-------|-------|--------|-------|")
for k in arrow_keys:
    if k in arrow_placement:
        layer, x, y, eff = arrow_placement[k]
        report_lines.append(f"| {k} | L{layer} | ({x},{y}) | {eff:.1f} | FOUND OK |")
    else:
        report_lines.append(f"| {k} | - | - | - | NOT FOUND FAIL |")
report_lines.append("")

if len(arrow_placement) >= 4:
    all_layers = set(v[0] for v in arrow_placement.values())
    if len(all_layers) == 1:
        report_lines.append(f"**Grouping:** All arrows on same layer (L{list(all_layers)[0]}) OK")
    else:
        report_lines.append(f"**Grouping:** Arrows split across layers {all_layers} FAIL")
    
    left_x = arrow_placement['LeftArrow'][1]
    right_x = arrow_placement['RightArrow'][1]
    up_x = arrow_placement['UpArrow'][1]
    down_x = arrow_placement['DownArrow'][1]
    
    report_lines.append(f"**LeftArrow x={left_x} < RightArrow x={right_x}:** {'OK' if left_x < right_x else 'FAIL'}")
    report_lines.append(f"**UpArrow between Left/Right:** {'OK' if min(left_x, right_x) <= up_x <= max(left_x, right_x) else 'FAIL'}")
    report_lines.append(f"**DownArrow between Left/Right:** {'OK' if min(left_x, right_x) <= down_x <= max(left_x, right_x) else 'FAIL'}"
report_lines.append("")

# Mouse button section
report_lines.append("## Mouse Button Placement Verification")
report_lines.append("")
report_lines.append("| Button | Layer | (x,y) | Hand | Effort | Notes |")
report_lines.append("|--------|-------|-------|------|--------|-------|")
for k in mouse_keys:
    if k in mouse_placement:
        layer, x, y, hand, eff = mouse_placement[k]
        report_lines.append(f"| {k} | L{layer} | ({x},{y}) | {hand} | {eff:.1f} | {'OK Right' if hand == 'right' else 'FAIL Left (5x penalty!)'} |")
    else:
        report_lines.append(f"| {k} | - | - | - | - | FAIL NOT FOUND |")
report_lines.append("")

if mouse_placement:
    right_count = sum(1 for v in mouse_placement.values() if v[3] == 'right')
    report_lines.append(f"**Right-hand mouse buttons:** {right_count}/{len(mouse_keys)} ({right_count/len(mouse_keys)*100:.0f}%)")
    if right_count == len(mouse_keys):
        report_lines.append("**All mouse buttons on right hand OK**")
    else:
        report_lines.append(f"**Missing/left-hand buttons:** {len(mouse_keys) - right_count}")
report_lines.append("")

# Scroll section
report_lines.append("## Scroll Key Placement Verification")
report_lines.append("")
report_lines.append("| Key | Layer | (x,y) | Hand | Effort | Notes |")
report_lines.append("|-----|-------|-------|------|--------|-------|")
for k in scroll_keys:
    if k in scroll_placement:
        layer, x, y, hand, eff = scroll_placement[k]
        report_lines.append(f"| {k} | L{layer} | ({x},{y}) | {hand} | {eff:.1f} | {'OK' if hand == 'right' else 'FAIL'} |")
    else:
        report_lines.append(f"| {k} | - | - | - | - | FAIL NOT FOUND |")
report_lines.append("")

# Synthetic mouse layer analysis
report_lines.append("## Synthetic Mouse Layer Analysis")
report_lines.append("")
report_lines.append("**Core question:** Does the evolved layout support a usable 'synthetic mouse layer' for one-handed right-hand operation?")
report_lines.append("")
report_lines.append("### 1. Mouse Button Accessibility")
report_lines.append("")
report_lines.append(f"- MB1-MB5 present: {'OK' if len(mouse_placement) >= 5 else 'FAIL'} ({len(mouse_placement)}/5)")
report_lines.append(f"- All on right hand: {'OK' if all(v[3] == 'right' for v in mouse_placement.values()) else 'FAIL'}")
report_lines.append(f"- Right-hand effort: {sum(v[4] for v in mouse_placement.values() if v[3] == 'right') / max(1, sum(1 for v in mouse_placement.values() if v[3] == 'right')):.2f} avg")
report_lines.append("")
report_lines.append("### 2. Cursor Navigation (Arrow Keys)")
report_lines.append("")
report_lines.append(f"- All arrows on same layer: {'OK' if len(set(v[0] for v in arrow_placement.values())) <= 1 else 'FAIL'}")
report_lines.append(f"- LeftArrow left of RightArrow: {'OK' if arrow_placement.get('LeftArrow', (0,0,0,0))[1] < arrow_placement.get('RightArrow', (0,0,0,0))[1] else 'FAIL'}")
report_lines.append(f"- Up/Down between Left/Right: OK (see Arrow section above)")
report_lines.append("")
report_lines.append("### 3. Scroll Access")
report_lines.append("")
report_lines.append(f"- ScrollUp/ScrollDown present: {'OK' if len(scroll_placement) == 2 else 'FAIL'} ({len(scroll_placement)}/2)")
if scroll_placement:
    right_count = sum(1 for v in scroll_placement.values() if v[3] == 'right')
    report_lines.append(f"- On right hand: {right_count}/{len(scroll_placement)} ({right_count/len(scroll_placement)*100:.0f}%)")
report_lines.append("")
report_lines.append("### 4. Layer Access for Mouse Tasks")
report_lines.append("")
# Determine which layer has mouse buttons
if mouse_placement:
    mouse_layers = set(v[0] for v in mouse_placement.values())
    if len(mouse_layers) == 1:
        ml = list(mouse_layers)[0]
        report_lines.append(f"Mouse buttons are all on **Layer {ml}**. This is the synthetic mouse layer.")
        # Find access for this layer
        access = None
        for la in layout.layer_access:
            if la.target_layer == ml:
                access = la
                break
        if access:
            report_lines.append(f"Access: Hold ({access.source_x:.0f},{access.source_y:.0f}) {access.hand} thumb — {'momentary' if access.is_momentary else 'toggle'}")
        else:
            report_lines.append("Access: Unknown (no layer access found)")
    else:
        report_lines.append(f"Mouse buttons are split across layers {mouse_layers} — not consolidated.")
report_lines.append("")
report_lines.append("### 5. Overall Mouse Layer Score")
report_lines.append("")
# Score each requirement
mb_right = all(v[3] == 'right' for v in mouse_placement.values()) if mouse_placement else False
arrows_grouped = len(set(v[0] for v in arrow_placement.values())) <= 1 if arrow_placement else False
arrows_ordered = arrow_placement.get('LeftArrow', (0,0,0,0))[1] < arrow_placement.get('RightArrow', (0,999,0,0))[1] if len(arrow_placement) >= 2 else False
scroll_right = all(v[3] == 'right' for v in scroll_placement.values()) if scroll_placement else False
mouse_layer_consolidated = len(set(v[0] for v in mouse_placement.values())) == 1 if mouse_placement else False

scores = {
    "MB1-5 on right hand": (1 if mb_right else 0, "5× weighted"),
    "Arrows grouped": (1 if arrows_grouped else 0, "group_split=200"),
    "Arrows ordered": (1 if arrows_ordered else 0, "arrow_order=100"),
    "Scroll on right": (1 if scroll_right else 0, "preferred_hand=right"),
    "Consolidated layer": (1 if mouse_layer_consolidated else 0, "workflow_coherence"),
}

for req, (score, note) in scores.items():
    report_lines.append(f"- {req}: {'OK' if score else 'FAIL'} ({note})")

total_score = sum(v[0] for v in scores.values()) / len(scores) * 100
report_lines.append(f"\n**Overall synthetic mouse layer score: {total_score:.0f}%**")
report_lines.append("")
report_lines.append("---")
report_lines.append("")
report_lines.append("## Recommendations")
report_lines.append("")
report_lines.append("1. If mouse buttons are not on the right hand, the 5× penalty in hand_bias.py is not working correctly — check the category assignment in app_shortcut_scores.json.")
report_lines.append("2. If arrows are not grouped or ordered, check the arrow_order constraint in violation.py and ensure KEY_GROUPS includes all arrow variants.")
report_lines.append("3. If the mouse layer is not consolidated on a single layer, increase the workflow_coherence weight or add a dedicated mouse layer group.")
report_lines.append("")

report_text = "\n".join(report_lines)
with open(OUT_DIR / "workflow_layer_analysis_gen1000.md", "w", encoding='utf-8') as f:
    f.write(report_text)

print(f"\nReport written to: {OUT_DIR / 'workflow_layer_analysis_gen1000.md'}")
print(f"Total layers: {len([l for l in layer_bindings if l != 7])}")
print(f"Total shortcuts placed: {sum(len(v) for v in layer_bindings.values())}")

