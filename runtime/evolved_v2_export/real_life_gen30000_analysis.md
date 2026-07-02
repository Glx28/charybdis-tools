# Real-Life Review: V2 Gen 30000 Layout

Source checkpoint: `/home/nos/charybdis/charybdis-optimizer/build/v2_checkpoint_gen30000.json`

Generated artifacts:

- Apply script: `runtime/evolved_v2_export/v2_full_nor5key_gen30000_apply.js`
- Verify script: `runtime/evolved_v2_export/v2_full_nor5key_gen30000_verify.js`
- Human-readable CSV: `runtime/evolved_v2_export/v2_full_nor5key_gen30000_keybindings_explained.csv`
- Diff: `runtime/evolved_v2_export/v2_full_nor5key_gen30000_diff.txt`

## Run Result

- Generation: 30000
- Objective: `-19.5721492767334`
- Population size: 500
- Stagnation count at checkpoint: 0

This is stronger than the newly finished `-19.051` run, but weaker than the previously reported `-21.33` best run.

## Layout Shape

- Total positions: 616
- Non-transparent bindings: 387
- Layer 0 remains fully populated with canonical typing keys plus 6 evolved thumb/access changes.
- Layer 7 remains canonical/frozen for navigation and recovery.
- All 11 layers are represented: L0 through L10.

Layer non-transparent counts:

- L0: 56
- L1: 30
- L2: 33
- L3: 41
- L4: 37
- L5: 34
- L6: 32
- L7: 30
- L8: 29
- L9: 35
- L10: 30

## Base Layer Changes

The optimizer changed only thumb/access-oriented L0 positions:

- L0 `(3,4)` -> `L4` toggle
- L0 `(5,4)` -> `L8` toggle
- L0 `(7,4)` -> `Ctrl+X`
- L0 `(8,4)` -> `L9` hold
- L0 `(4,5)` -> `L3` toggle
- L0 `(5,5)` -> `L4` hold

Main typing rows are not displaced.

## Mouse / Trackball

The layout has a good right-hand mouse cluster on L4:

- MB1: L4 `(7,1)`
- MB2: L4 `(12,1)`
- MB3: L4 `(7,2)`
- MB4: L4 `(8,2)`
- MB5: L4 `(9,2)`

There is also an extra MB4 on L3 `(10,2)`, which is acceptable as a workflow duplicate.

This satisfies the dynamic-layer rule: mouse is not hardcoded to L2. The mouse cluster naturally lands on L4.

## Navigation / Recovery

L7 keeps the canonical arrow clusters and exit-to-base keys:

- Left/Down/Right cluster at L7 `(1,2)`, `(2,2)`, `(3,2)`
- Up at L7 `(2,1)`
- Mirrored right-hand cluster at L7 `(9,2)`, `(10,2)`, `(11,2)` with Up at `(10,1)`
- Exit Base keys remain on L7 `(3,4)`, `(5,4)`, `(7,4)`, `(8,4)`

Layer access is present across the generated CSV, including access to L7 from L6 and L9. L1 also has a direct `coach_base` return.

## Real-Life Risk Notes

The layout is technically plausible for daily use, but it is not a low-risk final layout.

Known sharp keys:

- `Win+L` appears on L2 `(2,1)` and L9 `(8,4)`.
- `Win+Ctrl+F4` appears on L2 `(0,3)`, L8 `(2,0)`, and L9 `(12,3)`.
- `Alt+F4` appears on L6 `(7,2)`.
- `Ctrl+W` appears on L3 `(7,5)` and L4 `(8,1)`.

These are valid shortcuts, but they can lock the PC, close a virtual desktop, close a window, or close a tab. Treat the first application as a supervised trial, not a blind permanent save.

The apply script has built-in confirmation and does not click Save. It also skips Layer 7 during apply. The generated script currently contains repeated summary blocks at the tail; this is sloppy but not a semantic blocker.

## Verdict

Usable for a real-life trial: yes.

Recommended as the permanent layout without manual ZMK Studio verification: no.

Apply flow:

1. Export or otherwise preserve the current ZMK Studio layout first.
2. Paste `v2_full_nor5key_gen30000_apply.js` into the ZMK Studio console.
3. Let it apply, then check `window._CHARYBDIS_APPLY_ERRORS`.
4. Paste `v2_full_nor5key_gen30000_verify.js`.
5. Only save if verify reports zero failures and the dangerous shortcuts above are acceptable.
