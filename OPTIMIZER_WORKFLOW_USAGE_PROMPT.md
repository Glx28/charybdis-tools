# Prompt for Optimizer Coder AI

You are working on the Charybdis layout optimizer. The logger in `/home/nos/charybdis/charybdis-tools/ahk/charybdis_helpers.ahk` now emits workflow-oriented telemetry into `/home/nos/charybdis/charybdis-tools/runtime/shortcut_usage.jsonl`.

Goal: duplicates are allowed and often desirable, but they must be justified by real workflow and usage data. Do not treat every duplicate as bad. Penalize unsupported duplicates; reward duplicates when they reduce effort for a high-frequency app workflow, shortcut sequence, or cross-app workflow cluster.

New logger events to consume:

- `shortcut_sequence`
  - Fields: `from`, `to`, `from_app`, `to_app`, `from_layer`, `to_layer`, `gap_ms`, `same_app`, `sequence_id`
  - Meaning: the user used shortcut X then shortcut Y within the short sequence window. This is the clearest signal that X and Y should be close, possibly duplicated on the same workflow layer, even if their semantic categories differ.

- `shortcut_workflow_window`
  - Fields: `keys`, `apps`, `layers`, `chain_len`, `app_count`, `layer_count`, `span_ms`, `reason`
  - Meaning: a rolling 3-5 shortcut chain used within about 15 seconds. Convert repeated windows into `usage_stats.workflows` and/or stronger `usage_stats.chains`.

- `app_transition`
  - Fields: `from_app`, `to_app`, `prev_duration_ms`
  - Meaning: foreground app changed during active work. Frequent short-span transitions should produce app co-use weights.

- `app_workflow_window`
  - Fields: `apps`, `app_count`, `switch_count`, `shortcut_count`, `span_ms`, `reason`
  - Meaning: apps were used together in a rolling two-minute work window. Use this to discover app clusters such as `code.exe + chrome.exe + windowsterminal.exe`.

Implementation request:

1. Update the usage aggregation pipeline, especially `/home/nos/charybdis/charybdis-optimizer/pipeline/aggregate_usage.js` or the v2 equivalent, to parse these new event types.
2. Add output fields to `usage_stats.json`:
   - `shortcut_sequences`: directed pair stats keyed as `A -> B`, with `count`, `avg_gap_ms`, `p50_gap_ms`, `same_app_count`, `cross_app_count`, `apps`, and confidence/recency if practical.
   - `shortcut_workflows`: repeated 3-5 step windows keyed as `A -> B -> C`, with `count`, `avg_span_ms`, `apps`, and `app_count`.
   - `app_sequences`: directed app transition stats keyed as `appA -> appB`, with `count`, `avg_prev_duration_ms`.
   - `app_workflows`: app co-use clusters keyed by sorted app names, with `count`, `switch_count`, `shortcut_count`, `avg_span_ms`.
3. Feed high-confidence shortcut pairs into existing `usage_data.sequences`. Feed repeated 3-5 step chains into `usage_data.chains` and `usage_data.workflows`.
4. Add app-cluster support to scoring:
   - Shortcuts from apps that frequently appear in the same `app_workflows` cluster should receive proximity/co-layer rewards.
   - Example: if VS Code, Browser, and Terminal co-occur frequently, common shortcuts from those apps should be allowed to share a workflow layer or duplicate onto that layer.
5. Adjust duplicate handling:
   - Replace any blanket duplicate penalty with a supported-vs-unsupported model.
   - A duplicate is supported if it appears in a high-frequency app, sequence, chain, workflow, mouse session, or cross-app cluster.
   - Unsupported duplicates should still be penalized, especially if they occupy high-value positions.
   - Supported duplicates should be rewarded when they reduce layer switches or physical travel for a demonstrated workflow.
6. Keep dynamic layer assignment. Do not hardcode `L2 = mouse` or any app-pure layer assumption. Layers may contain mixed shortcuts when usage data shows they are part of the same workflow.

Acceptance checks:

- A frequent sequence like `Ctrl+C -> Alt+Tab -> Ctrl+V` becomes a strong workflow/coherence signal even though the shortcuts are semantically different.
- A frequent app cluster like `code.exe + chrome.exe + windowsterminal.exe` produces proximity rewards across those apps.
- Duplicate `Ctrl+C`/`Ctrl+V` placements are not penalized if they are supported by usage chains, app workflows, or mouse sessions.
- The optimizer report distinguishes unsupported duplicates from workflow-supported duplicates.
