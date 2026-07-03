"""Dynamic workflow layer analysis for evolved Charybdis layout.

Treats every layer as a workflow cluster evolved from real usage data.
No predetermined roles. Layers are what the optimizer made them.
"""
import json
import sys
import os
from pathlib import Path
from collections import Counter, defaultdict
from datetime import datetime

sys.path.insert(0, "C:/Users/nos/charybdis-optimizer/charybdis-optimizer-v2")
sys.path.insert(0, "C:/Users/nos/charybdis-optimizer/evolve")

from core.loader import build_layout, load_canonical, load_shortcuts
from representation import split_shortcut_keys

BUILD_DIR = Path("C:/Users/nos/charybdis-optimizer/build")
OUT_DIR = Path("C:/Users/nos/charybdis-tools/runtime/evolved_v2_export")
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------------
layout = build_layout(str(BUILD_DIR))
shortcuts = layout.shortcuts
positions = layout.positions

with open(BUILD_DIR / "canonical.json", encoding='utf-8') as f:
    canonical = json.load(f)

with open(BUILD_DIR / "app_shortcut_scores.json", encoding='utf-8') as f:
    app_scores = json.load(f)

with open(BUILD_DIR / "usage_stats.json", encoding='utf-8') as f:
    usage_stats = json.load(f)

# Load latest checkpoint
import glob
checkpoints = sorted(BUILD_DIR.glob("v2_checkpoint_gen*.json"), key=lambda p: int(p.stem.split('gen')[1]))
latest_cp = checkpoints[-1]
with open(latest_cp, encoding='utf-8') as f:
    cp = json.load(f)

genome = cp['best_exact']['genome']

# ---------------------------------------------------------------------------
# Build evolved binding per position
# ---------------------------------------------------------------------------

def effort_from_xy(x, y):
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

# Build canonical lookup
can_bindings = {}
for layer_id, layer_data in canonical['layers'].items():
    if not layer_id or not layer_id.strip():
        continue
    for coord, binding in layer_data.get('keys', {}).items():
        can_bindings[(int(layer_id), coord)] = binding

# Critical L0 positions that must stay canonical
CRITICAL_L0 = {(3, 4), (4, 4), (7, 4), (8, 4), (7, 5)}

# Build evolved layout
layer_bindings = defaultdict(list)  # layer -> list of binding dicts

for i, pos in enumerate(positions):
    coord = f"{int(pos.x)}:{int(pos.y)}"
    key = (pos.layer, coord)
    can_binding = can_bindings.get(key, {})
    
    is_critical = (pos.layer == 0 and (int(pos.x), int(pos.y)) in CRITICAL_L0)
    
    if is_critical or pos.is_frozen:
        # Use canonical
        label = can_binding.get('label', '') if can_binding else 'transparent'
        behavior = can_binding.get('behavior', 'Transparent') if can_binding else 'Transparent'
        parameter = can_binding.get('parameter', '') if can_binding else ''
        modifiers = can_binding.get('modifiers', []) if can_binding else []
        purpose = can_binding.get('purpose', '') if can_binding else ''
        usage = can_binding.get('usage_notes', '') if can_binding else ''
    else:
        sid = genome[i]
        if sid >= 0 and sid < len(shortcuts):
            sc = shortcuts[sid]
            mods, base = split_shortcut_keys(sc.keys)
            label = sc.keys
            behavior = "Key Press"
            parameter = base
            modifiers = mods
            purpose = sc.action or ''
            usage = f"App: {sc.app}, importance={sc.importance}"
        else:
            # transparent / canonical fallback
            if can_binding:
                label = can_binding.get('label', 'transparent')
                behavior = can_binding.get('behavior', 'Transparent')
                parameter = can_binding.get('parameter', '')
                modifiers = can_binding.get('modifiers', [])
                purpose = can_binding.get('purpose', '')
                usage = can_binding.get('usage_notes', '')
            else:
                label = 'transparent'
                behavior = 'Transparent'
                parameter = ''
                modifiers = []
                purpose = ''
                usage = ''
    
    if label.lower() == 'transparent' or behavior.lower() == 'transparent':
        continue
    
    binding = {
        'layer': pos.layer,
        'x': int(pos.x),
        'y': int(pos.y),
        'coord': coord,
        'hand': pos.hand,
        'effort': effort_from_xy(int(pos.x), int(pos.y)),
        'label': label,
        'behavior': behavior,
        'parameter': parameter,
        'modifiers': modifiers,
        'purpose': purpose,
        'usage': usage,
    }
    layer_bindings[pos.layer].append(binding)

# ---------------------------------------------------------------------------
# Load usage data for workflow analysis
# ---------------------------------------------------------------------------

# Sequences from usage_stats
sequences = usage_stats.get('sequences', {})
# chains from usage_stats
chains = usage_stats.get('chains', {})
# by_app
by_app = usage_stats.get('by_app', {})
# by_layer_shortcut
by_layer_shortcut = usage_stats.get('by_layer_shortcut', {})

# Build a shortcut->layer lookup from evolved layout
shortcut_layer_map = {}
for layer, bindings in layer_bindings.items():
    for b in bindings:
        label = b['label'].lower()
        shortcut_layer_map[label] = layer

# ---------------------------------------------------------------------------
# Infer layer workflow from co-occurrence in usage data
# ---------------------------------------------------------------------------

def infer_layer_workflows(layer_num, bindings):
    """Given a layer's bindings, infer what workflows it serves by cross-referencing usage data."""
    labels = {b['label'].lower() for b in bindings}
    
    # Find sequences/chains where at least 2 shortcuts on this layer appear together
    workflow_matches = []
    
    # Check sequences (2-step)
    for seq_key, count in sequences.items():
        if isinstance(count, dict):
            count = count.get('count', 0)
        parts = seq_key.split(" -> ")
        if len(parts) != 2:
            continue
        a, b = parts[0].lower(), parts[1].lower()
        if a in labels and b in labels:
            workflow_matches.append((a, b, count, 'sequence'))
    
    # Check chains (3+ step)
    for chain_key, count in chains.items():
        if isinstance(count, dict):
            count = count.get('count', 0)
        parts = [p.lower() for p in chain_key.split(" -> ")]
        layer_parts = [p for p in parts if p in labels]
        if len(layer_parts) >= 2:
            workflow_matches.append((layer_parts[0], layer_parts[-1], count, 'chain'))
    
    # Also check app affinity: which apps have the most shortcuts on this layer?
    app_counts = Counter()
    for b in bindings:
        # Extract app from usage notes or purpose
        usage = b.get('usage', '')
        if 'App:' in usage:
            app = usage.split('App:')[1].split(',')[0].strip()
            app_counts[app] += 1
    
    return workflow_matches, app_counts

# ---------------------------------------------------------------------------
# Analyze each layer
# ---------------------------------------------------------------------------

report = []
def w(text=""):
    report.append(text)

w("# Charybdis V2 — Dynamic Workflow Layer Analysis")
w()
w(f"**Source:** {latest_cp.name} (generation {cp.get('generation')})")
w(f"**Fitness:** effort={cp['best_exact']['effort']:.2f}, adjacency={cp['best_exact']['adjacency']:.2f}, violations={cp['best_exact']['violations']:.2f}")
w(f"**Generated:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M')} UTC")
w()
w("**Core premise:** Every layer is a dynamically evolved workflow cluster. No predetermined roles. L2 is not 'mouse', L1 is not 'clipboard'. The optimizer placed shortcuts based on real usage data, frequency, and co-occurrence patterns.")
w()
w("---")
w()

# Total shortcuts per layer
for layer in sorted(layer_bindings.keys()):
    if layer == 7:
        continue
    bindings = layer_bindings[layer]
    n = len(bindings)
    avg_eff = sum(b['effort'] for b in bindings) / n if n else 0
    left_count = sum(1 for b in bindings if b['hand'] == 'left')
    right_count = n - left_count
    
    workflow_matches, app_counts = infer_layer_workflows(layer, bindings)
    
    w(f"## Layer {layer}")
    w()
    w(f"**Shortcuts:** {n} | **Avg effort:** {avg_eff:.2f} | **Hand balance:** {left_count}/{right_count}")
    w()
    
    # Show all shortcuts on this layer
    w("| (x,y) | Effort | Hand | Shortcut | Purpose |")
    w("|-------|--------|------|----------|---------|")
    for b in sorted(bindings, key=lambda x: (x['y'], x['x'])):
        mods = '+'.join(b['modifiers']) if b['modifiers'] else ''
        shortcut = f"{mods}+{b['label']}" if mods else b['label']
        w(f"| ({b['x']},{b['y']}) | {b['effort']:.1f} | {b['hand']} | {shortcut} | {b['purpose'][:40]} |")
    w()
    
    # Workflow analysis
    if workflow_matches:
        w("**Workflow co-occurrence (from usage log):**")
        # Sum counts by type
        seq_total = sum(c for _, _, c, t in workflow_matches if t == 'sequence')
        chain_total = sum(c for _, _, c, t in workflow_matches if t == 'chain')
        w(f"- Sequence pairs on this layer: {seq_total} events")
        w(f"- Chain pairs on this layer: {chain_total} events")
        
        # Top co-occurring pairs
        top_pairs = sorted(workflow_matches, key=lambda x: -x[2])[:5]
        w("- Top co-occurring pairs:")
        for a, b, count, t in top_pairs:
            w(f"  - {a} → {b} ({count} times, {t})")
        w()
    else:
        w("**No workflow co-occurrence data found for this layer.**")
        w()
    
    # App affinity
    if app_counts:
        w("**App representation on this layer:**")
        for app, count in app_counts.most_common(5):
            w(f"- {app}: {count} shortcuts")
        w()
    
    # Identify the dominant workflow pattern
    if app_counts:
        dominant_app = app_counts.most_common(1)[0][0]
    else:
        dominant_app = "mixed"
    
    # Describe the layer based on its actual content
    categories = Counter()
    for b in bindings:
        purpose = b.get('purpose', '').lower()
        if any(w in purpose for w in ['copy', 'paste', 'cut', 'undo', 'redo', 'delete']):
            categories['editing'] += 1
        if any(w in purpose for w in ['tab', 'window', 'close', 'switch', 'next', 'prev']):
            categories['window/tab'] += 1
        if any(w in purpose for w in ['scroll', 'mouse', 'click', 'mb', 'cursor', 'pointer']):
            categories['mouse/trackball'] += 1
        if any(w in purpose for w in ['search', 'find', 'goto', 'jump', 'navigate']):
            categories['navigation'] += 1
        if any(w in purpose for w in ['bluetooth', 'output', 'system', 'settings', 'profile']):
            categories['system'] += 1
        if any(w in purpose for w in ['call', 'mute', 'camera', 'share', 'chat', 'teams']):
            categories['communication'] += 1
        if any(w in b['label'].lower() for w in ['ctrl+', 'shift+', 'alt+', 'win+']):
            categories['modifier shortcuts'] += 1
    
    if categories:
        w("**Observed shortcut categories:**")
        for cat, count in categories.most_common():
            w(f"- {cat}: {count}")
        w()
    
    # Access method
    if layer == 0:
        w("**Access:** Always active (base layer)")
    elif layer in (1, 2, 3, 4):
        # Thumb access
        thumb_pos = {
            1: "(3,4) left inner thumb",
            2: "(4,5) left bottom thumb",
            3: "(8,4) right middle thumb",
            4: "(7,4) right inner thumb",
        }
        w(f"**Access:** Hold {thumb_pos.get(layer, 'thumb')} — momentary")
    else:
        w(f"**Access:** Toggled or locked (no thumb hold)")
    w()
    w("---")
    w()

# ---------------------------------------------------------------------------
# Cross-layer workflow transitions
# ---------------------------------------------------------------------------

w("## Cross-Layer Workflow Transitions")
w()
w("For each sequence in the usage log, check if the two shortcuts ended up on the same layer or different layers. Same layer = good (no thumb switch). Different layers = friction.")
w()

total_pairs = 0
same_layer = 0
different_layer = 0

for seq_key, count in sequences.items():
    if isinstance(count, dict):
        count = count.get('count', 0)
    parts = seq_key.split(" -> ")
    if len(parts) != 2:
        continue
    a, b = parts[0].lower(), parts[1].lower()
    layer_a = shortcut_layer_map.get(a)
    layer_b = shortcut_layer_map.get(b)
    if layer_a is None or layer_b is None:
        continue
    total_pairs += count
    if layer_a == layer_b:
        same_layer += count
    else:
        different_layer += count

if total_pairs > 0:
    w(f"**Total sequence pairs in log:** {total_pairs}")
    w(f"**Same layer:** {same_layer} ({same_layer/total_pairs*100:.1f}%)")
    w(f"**Different layer (requires thumb switch):** {different_layer} ({different_layer/total_pairs*100:.1f}%)")
    w()
    
    # Most painful transitions (different layer, high count)
    painful = []
    for seq_key, count in sequences.items():
        if isinstance(count, dict):
            count = count.get('count', 0)
        parts = seq_key.split(" -> ")
        if len(parts) != 2:
            continue
        a, b = parts[0].lower(), parts[1].lower()
        layer_a = shortcut_layer_map.get(a)
        layer_b = shortcut_layer_map.get(b)
        if layer_a is not None and layer_b is not None and layer_a != layer_b:
            painful.append((a, b, layer_a, layer_b, count))
    
    painful.sort(key=lambda x: -x[4])
    w("**Most frequent cross-layer transitions (friction):**")
    for a, b, la, lb, count in painful[:15]:
        w(f"- {a} (L{la}) → {b} (L{lb}): {count} times")
    w()
    
    # Best same-layer clusters
    good = []
    for seq_key, count in sequences.items():
        if isinstance(count, dict):
            count = count.get('count', 0)
        parts = seq_key.split(" -> ")
        if len(parts) != 2:
            continue
        a, b = parts[0].lower(), parts[1].lower()
        layer_a = shortcut_layer_map.get(a)
        layer_b = shortcut_layer_map.get(b)
        if layer_a is not None and layer_b is not None and layer_a == layer_b:
            good.append((a, b, layer_a, count))
    
    good.sort(key=lambda x: -x[3])
    w("**Best same-layer pairs (no thumb switch needed):**")
    for a, b, layer, count in good[:15]:
        w(f"- {a} → {b} on L{layer}: {count} times")
    w()

# ---------------------------------------------------------------------------
# L0 Thumb Analysis (Dynamic)
# ---------------------------------------------------------------------------

w("## L0 Thumb Analysis — Dynamic Workflow Access Points")
w()
w("The thumb positions on L0 are the gateway to all workflow layers. Their roles are evolved, not fixed. Here is what the optimizer assigned:")
w()
w("| Position | Physical | Access | Evolved Assignment | Effort | Notes |")
w("|----------|----------|--------|-------------------|--------|-------|")

thumb_bindings = {b['coord']: b for b in layer_bindings[0]}

thumb_positions = [
    ('3:4', 'left inner', 'momentary L1'),
    ('4:4', 'left middle', 'spacebar (typing)'),
    ('5:4', 'left outer', 'momentary L2'),
    ('4:5', 'left bottom', 'momentary L2'),
    ('7:4', 'right inner', 'momentary L3'),
    ('8:4', 'right middle', 'momentary L4'),
    ('7:5', 'right bottom', 'return enter'),
]

for coord, physical, access in thumb_positions:
    b = thumb_bindings.get(coord)
    if b:
        label = b['label']
        effort = b['effort']
        notes = b.get('purpose', '')[:30]
    else:
        label = 'transparent'
        effort = '-'
        notes = ''
    w(f"| {coord} | {physical} | {access} | {label} | {effort} | {notes} |")

w()

# Thumb -> layer mapping and what each layer contains
for layer in (1, 2, 3, 4):
    bindings = layer_bindings[layer]
    if not bindings:
        continue
    labels = [b['label'] for b in bindings]
    w(f"**Layer {layer}** (accessed via L0 thumb) contains: {', '.join(labels[:10])}{'...' if len(labels) > 10 else ''}")
w()

# ---------------------------------------------------------------------------
# Mouse + Keyboard Combo Analysis
# ---------------------------------------------------------------------------

w("## Mouse + Keyboard Combo Analysis")
w()

# Parse usage log for mouse_context shortcuts
usage_log_path = Path("C:/Users/nos/charybdis-tools/runtime/shortcut_usage.jsonl")
mouse_context_events = []
if usage_log_path.exists():
    with open(usage_log_path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
            except:
                continue
            if event.get('type') == 'shortcut' and event.get('mouse_context'):
                mouse_context_events.append(event)

if mouse_context_events:
    w(f"**Mouse-context shortcuts found:** {len(mouse_context_events)} events")
    w()
    w("| Shortcut | App | Evolved Layer | (x,y) | Hand | Effort | Notes |")
    w("|----------|-----|---------------|-------|------|--------|-------|")
    for event in mouse_context_events[:20]:
        keys = event.get('keys', '').lower()
        layer = shortcut_layer_map.get(keys, '?')
        # Find position
        b = None
        for binding in layer_bindings.get(layer, []):
            if binding['label'].lower() == keys:
                b = binding
                break
        if b:
            w(f"| {keys} | {event.get('app','')} | {layer} | ({b['x']},{b['y']}) | {b['hand']} | {b['effort']:.1f} | |")
        else:
            w(f"| {keys} | {event.get('app','')} | {layer} | ? | ? | ? | NOT MAPPED |")
    w()
    
    # Score: left hand + low effort = ideal for mouse combos
    left_hand_combos = sum(1 for e in mouse_context_events 
                           for b in layer_bindings.get(shortcut_layer_map.get(e.get('keys','').lower(), -1), [])
                           if b['label'].lower() == e.get('keys','').lower() and b['hand'] == 'left')
    total_mapped = sum(1 for e in mouse_context_events 
                       if shortcut_layer_map.get(e.get('keys','').lower()) is not None)
    if total_mapped > 0:
        w(f"**Left-hand mouse-context shortcuts:** {left_hand_combos}/{total_mapped} ({left_hand_combos/total_mapped*100:.0f}%)")
        w("(Higher is better — right hand on trackball, left hand on shortcuts)")
        w()
else:
    w("No mouse-context shortcut data found in usage log.")
    w()

# ---------------------------------------------------------------------------
# Recommendations
# ---------------------------------------------------------------------------

w("## Recommendations")
w()
w("1. **Check L0 thumbs:** Each thumb should access a layer that makes sense for your most common workflows. If you spend 80% of time in browser + VS Code, the most-used workflow should be on the easiest thumb hold (typically left inner thumb or right inner thumb).")
w()
w("2. **Look for workflow clusters:** If two shortcuts appear together in your usage log 50+ times, they should be on the same layer. The cross-layer transition section above shows where they got split — those are friction points.")
w()
w("3. **Mouse-context shortcuts:** Any shortcut you press within 1 second of a mouse click should ideally be on the left hand (trackball is right hand). Check the combo analysis above.")
w()
w("4. **High-effort outliers:** Any shortcut on effort > 4.0 that you use 10+ times per day should be moved to a lower-effort position. The optimizer may have placed it high because it ran out of good positions — check if other layers have room.")
w()
w("5. **Empty layers:** If a layer has < 10 shortcuts, it's underutilized. The optimizer may have consolidated workflows onto fewer layers. Verify that the remaining layers are actually comfortable to reach.")
w()

# ---------------------------------------------------------------------------
# Save report
# ---------------------------------------------------------------------------
with open(OUT_DIR / "workflow_layer_analysis.md", "w", encoding='utf-8') as f:
    f.write("\n".join(report))

print(f"Saved workflow_layer_analysis.md ({len(report)} lines)")

def main(ctx):
    return {"status": "done", "path": str(OUT_DIR / "workflow_layer_analysis.md")}
