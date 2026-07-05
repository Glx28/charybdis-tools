# Scroll Layer Architecture Handoff — 2026-07-05

## What was implemented

A dedicated transparent scroll mode layer (L11) was added to the ZMK firmware. Every `@scroll:LX:hold` shortcut on any layer now activates L11 (not layer X), which enables PMW3610 scroll mode without leaving the current layer.

### Before
- `scroll-layers = <6>` — only layer 6 activated scroll mode
- Export mapped `@scroll:LX:hold` → `&mo X`, so only `@scroll:L6:hold` ever worked
- Holding scroll from any other layer switched to L6, losing the current layer's context

### After
- `scroll-layers = <11>` — L11 is the dedicated scroll mode layer
- L11 is all-transparent (56× `&trans`) — current layer bindings stay visible while scrolling
- Export maps ALL `@scroll:LX:hold` → `&mo 11` (coach_l11_hold)
- Holding scroll from layer X: L11 stacks on top of X → scroll active, X bindings still accessible

---

## Files changed

### ZMK firmware (charybdis-zmk-config, branch: codex/build-coach-layers-cpi750)

**`config/boards/shields/charybdis/charybdis_right.overlay`**
```
scroll-layers = <11>;   // was <6>
snipe-layers = <8>;     // unchanged
```

**`config/charybdis.keymap`**
- Added `layer_11` at end of keymap (56× `&trans`)
- This layer exists purely for the PMW3610 scroll-layers property; all keys are transparent

### Export pipeline (charybdis-tools)

**`runtime/evolved_v2_export/export_and_analyze_linux.py`**

Three changes:
1. `COACH_LAYER_ACCESS`: added `("hold", 11): "coach_l11_hold"`
2. `COACH_STUDIO_BEHAVIORS`: added `"coach_l11_hold"` to the list
3. `coach_behavior_for_layer_access()`: scroll mode shortcuts now return `COACH_LAYER_ACCESS.get(("hold", 11))` instead of `("hold", 6)`

---

## What to verify

### 1. Export validation
Run: `python3 runtime/evolved_v2_export/promote.py --apply`

Check the behavior counts in the output. You should see:
- `coach_l11_hold`: N (one per scroll shortcut in the genome, typically 8-10)
- `coach_l6_hold`: 0 or 1 at most (any remaining ones are regular L6 holds, NOT scroll)
- No scroll shortcut should export as `coach_l9_hold`, `coach_l10_hold`, etc.

### 2. Keymap layer count
In `charybdis.keymap`, count the layer definitions: `layer_0` through `layer_11` = 12 layers total.
ZMK requires all layers referenced in key bindings to be defined in the keymap.

### 3. Overlay cross-check
In `charybdis_right.overlay`, confirm:
- `scroll-layers = <11>;` ← must be 11, not 6
- `snipe-layers = <8>;` ← unchanged

### 4. ZMK Studio apply
After flashing the new firmware (built by GitHub Actions from the pushed commit):
1. Open ZMK Studio
2. Run `apply_every_key.js` in the browser console
3. Run `verify_every_key.js` — all keys should verify
4. Test: go to mouse layer (L10), hold the scroll key (right index bottom row), move trackball → should scroll, not cursor-move

### 5. Per-layer scroll test (key behavioral check)
The whole point of L11 is that scroll works from ANY layer. Test:
- On L1: hold scroll key → trackball should scroll
- On L6: hold scroll key → trackball should scroll
- On L10 (mouse layer): hold scroll key → trackball should scroll
- Release scroll key → cursor mode returns, original layer stays active

---

## Optimizer state

The optimizer (charybdis-optimizer-v2) does NOT need changes. The kernel tracks `scroll_right_momentary[layer]` based on which physical layer a scroll shortcut is placed on — this model is correct regardless of which firmware layer actually activates scroll mode. The export is the mapping layer between optimizer model and firmware reality.

Current run state (as of 2026-07-05):
- PID: check with `ps aux | grep run_evolution`
- Log: `/tmp/run_v20.log`
- Best gap: -5.068 at gen 4379 (run currently at gen ~10500, stagnant since gen 4379)
- G=[0,0,0,0,0] — all hard constraints satisfied
- 1 BAD item: Ctrl+S at eff=1.25 (needs eff=0)
- Scroll on L10 (mouse layer): currently at eff=1.00 (was 1.75), optimizer still working to reach eff=0
- Scroll effort coefficient: 15000 (raised this session from 8000)

If the run is stagnant (>5000 gens no improvement): kill, run `tools/best.py`, write warmstart, restart.

---

## Important: no firmware model mismatch

The optimizer generates `@scroll:LX:hold` shortcuts where X ranges across all layer numbers. In firmware, all of these now activate L11 (not layer X). This is NOT a bug — the optimizer's fitness model evaluates scroll PLACEMENT (which physical layer has a scroll key accessible), not which firmware layer activates scroll mode. The export handles the mapping.

Do NOT modify the optimizer kernel or loader to "know about" L11 — that would be leaking firmware details into the optimizer model, which is the wrong abstraction boundary.

---

## Commit reference

`charybdis-zmk-config` commit: `e7f94f4`
Message: "Add L11 transparent scroll mode layer; fix scroll hold for all layers"
Branch: `codex/build-coach-layers-cpi750`
