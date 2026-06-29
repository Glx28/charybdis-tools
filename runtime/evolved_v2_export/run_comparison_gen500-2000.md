# Charybdis V2 — Run Comparison: Gen 500 vs Gen 1000 vs Gen 1500 vs Gen 2000

**Run:** `bkl4rsdy2` (new run with Numba cache=False)  
**Checkpoints compared:** gen 500, gen 1000, gen 1500, gen 2000  
**Date:** 2026-06-29 03:50 WEST  

---

## Executive Summary: The Run is Completely Frozen

**Every single checkpoint from gen 500 to gen 2000 contains the IDENTICAL genome.**

| Checkpoint | Generation | Effort | Adjacency | Violations | Hand Bias | Genome Hash |
|------------|-----------|--------|-----------|------------|-----------|-------------|
| v2_checkpoint_gen500.json | 500 | 73.1832 | -32.8814 | 13.3510 | 45.0 | IDENTICAL |
| v2_checkpoint_gen1000.json | 1000 | 73.1832 | -32.8814 | 13.3510 | 45.0 | IDENTICAL |
| v2_checkpoint_gen1500.json | 1500 | 73.1832 | -32.8814 | 13.3510 | 45.0 | IDENTICAL |
| v2_checkpoint_gen2000.json | 2000 | 73.1832 | -32.8814 | 13.3510 | 45.0 | IDENTICAL |

**616/616 positions identical across all checkpoints.** Zero mutations have improved the best individual since at least generation 500.

---

## What This Means

The "new run" `bkl4rsdy2` with `Numba cache=False` is **not a new run at all.** It is the exact same stuck optimization continuing from the same seed genome. The Numba recompilation did not change the evolutionary trajectory because:

1. **The seed genome is injected as individual 0** in every run (line 29 of output: "Seed genome will be injected as initial population individual 0")
2. **The seed genome is the old gen 7500 best** from the previous run, which already had the wrong mouse button and arrow placements
3. **The optimizer cannot escape this local minimum** — even with mutation rate maxed at 0.500 for 2200+ generations

---

## Why the Constraints Are Not Working

The genome being frozen means **none of the new constraints are being optimized** — the layout is stuck at the old pre-constraint state. Here's why:

### Hand Bias (5x penalty for mouse buttons on left hand)

| Factor | Value | Context |
|--------|-------|---------|
| `hand_bias` raw score | 45.0 | Applied to best genome |
| `violations` raw score | 401,296 | Same genome's violation score |
| `hand_bias` weight | 3.0 | In evaluator |
| `violations` weight | 50.0 | In evaluator |
| **Effective hand bias contribution** | 135.0 | 45.0 * 3.0 |
| **Effective violations contribution** | 20,064,818 | 401,296 * 50.0 |
| **Ratio** | 1 : 148,628 | Hand bias is 0.0007% of violations |

**The hand bias penalty is completely invisible to the optimizer.** Moving MB1 from left hand to right hand would change the hand_bias score by ~45 (from 9.0 importance * 5.0 = 45.0 penalty), but the violations score would need to stay the same or improve. Since the violations score is ~400k, any mutation that improves hand_bias but worsens violations by even 0.1% (400 points) would be rejected.

### Arrow Order Constraint (weight=100)

| Constraint | Weight | Effect on frozen genome |
|------------|--------|------------------------|
| `group_split` | 200 | Arrows are split across 3 layers — penalty is already "paid" |
| `arrow_order` | 100 | LeftArrow at x=10, RightArrow at x=3 — reversed order |
| **arrow_order penalty** | ~100 * (10-3+1) * 50 = 20,000 | For LeftArrow > RightArrow |
| **violations total** | 401,296 | Includes this penalty already |

The arrow_order penalty is ~20,000 — but the total violations are 401,296. Again, the optimizer sees a 4% improvement opportunity at the cost of massive effort/adjacency disruption, and it can't find a path.

### The Real Problem: Seed Genome Injection

The root cause is in `run_evolution.py` line 29:

```
Seed genome will be injected as initial population individual 0.
```

This means every restart loads the **same best genome from the previous run** as the starting point. If that genome is a deep local minimum (which it is — 401k violations), the optimizer cannot escape it with incremental mutations. Even 50% mutation rate (0.500) is not enough because:

- Mutating 50% of 616 positions = 308 changes at once
- This destroys the fitness completely (violations skyrocket to millions)
- The surrogate can't model this chaotic landscape
- The exact evaluator rejects all extreme mutations

---

## What Would Actually Fix This

### Option 1: Disable Seed Genome Injection
Modify `run_evolution.py` to NOT inject the old best genome. Start from a fresh random population. The optimizer would then explore the new constraint space freely and might find a better layout that satisfies all constraints.

### Option 2: Dramatically Increase Constraint Weights

| Current Weight | Proposed Weight | Effect |
|----------------|-----------------|--------|
| `hand_bias` 3.0 | 300.0 | Mouse buttons on wrong hand = 15,000 penalty, visible to optimizer |
| `arrow_order` 100 | 10,000 | Arrow reversal = 2,000,000 penalty, stronger than violations |
| `group_split` 200 | 2,000 | Split arrows = 400,000 penalty, forces grouping |

This would make the constraints the PRIMARY optimization target, but risks breaking the whole fitness landscape.

### Option 3: Manual Warm-Start with Constraint-Satisfying Genome
Pre-place all mouse buttons on the right hand, all arrows grouped on one layer with correct order, then run the optimizer to fill in the rest. This gives the optimizer a feasible starting point that already satisfies the hard constraints.

### Option 4: Multi-Stage Optimization
Stage 1: Optimize ONLY mouse button placement + arrow placement (freeze everything else).  
Stage 2: With those fixed, optimize the remaining shortcuts.  

This prevents the optimizer from getting stuck in a global minimum that ignores the constraints.

---

## Conclusion

The new run `bkl4rsdy2` with `Numba cache=False` did **nothing** to fix the underlying problem. The genome is frozen at gen 500 and will remain frozen indefinitely because:

1. The seed genome is a deep local minimum from the old run
2. The new constraints are too weak relative to the violations penalty
3. The mutation rate cannot be high enough to escape without destroying fitness
4. The surrogate has collapsed and cannot guide exploration

**Recommendation:** Stop this run. Choose Option 1 (disable seed injection) or Option 3 (manual warm-start) and restart. The current approach will never produce a layout with right-hand mouse buttons or correctly ordered arrows.

---

## Appendix: Full Layer Data (Same for All Checkpoints)

Since all checkpoints are identical, the layer analysis from `workflow_layer_analysis_gen1000.md` applies verbatim to gen 500, 1500, and 2000. The 0% mouse layer score and reversed arrow placement are unchanged.

**Key stats (all checkpoints identical):**
- Total layers: 10 (excluding L7 game layer)
- Total shortcuts placed: 506
- Hand balance: roughly 50/50 left/right across all layers
- Avg effort per layer: 2.08–2.18

**Critical failures (unchanged):**
- MB1 on left hand at (1,2) effort=0.0 — FAIL
- MB4 missing entirely — FAIL
- LeftArrow at x=10 (right side), RightArrow at x=3 (left side) — FAIL
- Arrows split across 3 layers — FAIL
- ScrollDown on left hand — FAIL

**Synthetic mouse layer score: 0% (all checkpoints)**
