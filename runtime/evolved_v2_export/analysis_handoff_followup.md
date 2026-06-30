# Charybdis V2 Handoff Follow-Up Analysis

**Date:** 2026-06-29  
**Analyst:** Kimi CLI  
**Scope:** Verify the claims in the session handoff and inspect the current local run state.

---

## 1. Local Run Status

- **Latest new-run checkpoint:** `build/v2_checkpoint_gen500.json` — this is the run that was stopped for the refactor.
- **Older-run checkpoints:** `v2_checkpoint_gen{1000,1500,2500,3000}.json` belong to previous runs and should not be treated as successors of gen 500.
- **gen 500 objective:** `[-8.566]` (single-objective mode, surrogate disabled)
- **Best older local objective:** `[-17.342]` at gen 3000
- **Population:** 500
- **Active evolution process:** Not found in process list at check time.
- **Other activity:** A `pip install --force-reinstall torch==2.2.0` was running in the optimizer venv, suggesting the environment is being repaired/reset.

The local repo is well behind the Windows run referenced in the handoff (gen 9000, objective -19.55).

---

## 2. Mouse Button Placement — Local Checkpoints

| Checkpoint | MB1 | MB2 | MB3 | MB4 | MB5 | Right-hand % |
|---|---|---|---|---|---|---|
| **gen 500 (new)** | L1 (7,2) right | L2 (11,2) right | L1 (11,3) right | L1 (11,1) right | **NOT FOUND** | 4/4 found (100%) |
| gen 1000 (old) | L1 (7,2) right | L2 (11,2) right | L1 (11,3) right | L1 (11,1) right | L6 (11,1) right | 5/5 (100%) |
| gen 1500 (old) | L1 (12,3) right | L2 (11,2) right | L2 (12,2) right | L1 (11,1) right | L6 (11,1) right | 5/5 (100%) |
| gen 2500 (old) | L10 (11,2) right | L2 (11,2) right | L2 (12,2) right | L1 (11,1) right | L6 (11,1) right | 5/5 (100%) |
| gen 3000 (old) | L5 (11,1) right | L2 (11,2) right | L2 (12,2) right | L1 (11,1) right | L6 (11,1) right | 5/5 (100%) |

**Finding:** The gen 500 run has only found 4 of 5 mouse buttons (MB5 is missing), but all found buttons are on the right hand. Older runs all reached 5/5 right hand. The right-hand bias for mouse buttons **is** taking effect.

This contradicts the handoff claim that `fitness/factors/hand_bias.py` is unwired and that mouse buttons get no right-hand penalty. The standalone `HandBiasFactor` class is indeed not imported in `fitness/evaluator.py`, but an equivalent `_hand_bias()` method is already called inside `fitness/factors/violation.py` (sub-weight 2000) and is also implemented in `fitness/batch_evaluator.py`. The constraint is active in practice, just not routed through the standalone factor file.

**Recommendation:** If the user wants the standalone `hand_bias.py` to be the single source of truth, a developer should refactor `ViolationFactor` to call it and update `batch_evaluator.py` accordingly. As an analyst, I do not recommend treating unwired `hand_bias.py` as a blocker — the behavior is already present.

---

## 3. Arrow Key Placement — Local Checkpoints

### gen 500 (new/latest run)

| Key | Layer | (x,y) | Hand |
|---|---|---|---|
| LeftArrow | L2 | (7,3) | right |
| UpArrow | L2 | (9,1) | right |
| DownArrow | L2 | (2,2) | left |
| RightArrow | L4 | (0,3) | left |

- **Grouping:** Split across L2 and L4.
- **Order:** LeftArrow x=7 ≥ RightArrow x=0 → **FAIL**; UpArrow x=9 outside [0,7] span → **FAIL**.

### gen 3000 (best older local run)

| Key | Layer | (x,y) | Hand |
|---|---|---|---|
| LeftArrow | L1 | (7,2) | right |
| UpArrow | L4 | (0,2) | left |
| DownArrow | L4 | (5,5) | left |
| RightArrow | L4 | (12,2) | right |

- **Grouping:** Split across L1 and L4.
- **Order:** LeftArrow x=7 < RightArrow x=12 → OK, but UpArrow and DownArrow are outside the [7,12] span → **FAIL**.

### L7 canonical reference
The canonical L7 layer already contains a correct inverted-T arrow cluster:

| Key | L7 Position |
|---|---|
| UpArrow | (10,1) |
| LeftArrow | (9,2) |
| DownArrow | (10,2) |
| RightArrow | (11,2) |

### Actual evolved L7 arrows (present in all checkpoints)
- UpArrow: L7 (2,1) and L7 (10,1)
- LeftArrow: L7 (1,2) and L7 (9,2)
- DownArrow: L7 (2,2) and L7 (10,2)
- RightArrow: L7 (3,2) and L7 (11,2)

So L7 **does** have a usable, correctly ordered arrow cluster. The problem is extra arrow instances on non-L7 layers that break grouping/order constraints.

**Finding:** The arrow order constraint is being evaluated (it produces FAIL scores), but it is not strong enough to force all arrows onto L7. The gen 500 run is even worse than gen 3000 because it has not yet converged.

**Recommendation:**
1. Increase `arrow_scattered` sub-weight to push arrows onto L7 only.
2. Increase `arrow_order` sub-weight so out-of-order arrows are punished more.
3. Investigate whether the pre-seeded scratch genome is pinning arrows to non-L7 positions.

---

## 4. Scroll Key Placement

| Checkpoint | ScrollUp | ScrollDown |
|---|---|---|
| gen 500 (new) | L9 (10,3) right | L3 (5,4) **left** |
| gen 3000 (old) | L4 (11,1) right | L3 (10,2) right |

In the gen 500 run, ScrollDown has landed on the left hand. This is a regression compared to the older gen 3000 run.

---

## 5. Constraint Wiring Verdict

| Constraint | Claim in Handoff | Actual State |
|---|---|---|
| `hand_bias.py` standalone factor | Not wired | True — not imported in `evaluator.py` |
| Mouse right-hand penalty | Not applied | **False** — applied via `ViolationFactor._hand_bias()` and `batch_evaluator.py` |
| `_arrow_order` in `violation.py` | Not wired | **False** — it is called in `ViolationFactor.compute()` and implemented in `batch_evaluator.py` |
| Arrow spatial order | Not enforced | Partially enforced — L7 is correct, but extra arrows on L2/L4 violate it |

**Conclusion:** The critical discovery in the handoff is partially outdated or based on a code read that missed the duplicate implementations inside `ViolationFactor` and `batch_evaluator.py`. The mouse bias is already working. The arrow problem is scattered/out-of-order duplicates, not missing constraints.

---

## 6. Recommendations

1. **Do not restart the run solely to wire `hand_bias.py`.** The desired mouse behavior is already achieved in older runs (5/5 right hand). The gen 500 run has 4/4 found buttons on the right hand and only lacks MB5 because it is early.
2. **Focus arrow tuning on scattered duplicates.** Raise `arrow_scattered` and/or `arrow_order` sub-weights to push arrows onto L7 only.
3. **Fix scroll placement.** ScrollDown landed on the left hand in gen 500. Either increase hand-bias weight for `preferred_hand=either` scroll keys or add a right-hand scroll constraint.
4. **Sync checkpoints.** The best layout per the handoff is gen 9000 on Windows (-19.55). The local new run is only at gen 500 (-8.57). If the Windows run is still active, export its latest checkpoint and copy it here before making further config changes.
5. **If a developer does refactor,** move `_hand_bias` out of `ViolationFactor` into the standalone `HandBiasFactor` and update `batch_evaluator.py` to keep parity. Otherwise the current code is functional.

---

## 7. Files Inspected

- `charybdis-optimizer/charybdis-optimizer-v2/fitness/evaluator.py`
- `charybdis-optimizer/charybdis-optimizer-v2/fitness/factors/hand_bias.py`
- `charybdis-optimizer/charybdis-optimizer-v2/fitness/factors/violation.py`
- `charybdis-optimizer/charybdis-optimizer-v2/fitness/batch_evaluator.py`
- `charybdis-optimizer/build/config_v2.yaml`
- `charybdis-optimizer/build/canonical.json`
- `charybdis-optimizer/build/app_shortcut_scores.json`
- `charybdis-optimizer/build/v2_checkpoint_gen{500,1000,1500,2500,3000}.json`
- `charybdis-optimizer/build/run_logs/v2_wsl.log`
- `charybdis-tools/runtime/evolved_v2_export/workflow_layer_analysis_gen9000_latest.md`
