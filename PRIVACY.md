# Privacy

Charybdis Tools runs locally, but it observes keyboard-layer activity and the
foreground application to power the coach and optimizer.

## Data Collected

- `runtime/shortcut_usage.jsonl`: shortcut names, app process names, layers,
  timing, mouse actions, and workflow sequences. Bare letter typing is not
  logged.
- `runtime/charybdis_events.jsonl`: beacon, layer, and state events.
- `runtime/charybdis_state.json`: current layer, recent action, transport,
  beacon health, and foreground app/window label.
- `runtime/logs/`: launcher and component diagnostics.

These files can reveal work patterns, application usage, document or browser
tab titles, and timestamps. Treat the whole `runtime/` directory as private.

## Storage And Network Boundaries

Runtime data stays on the Windows machine unless the user deliberately shares
or uploads it. The coach server binds to loopback and exposes only the coach
static files plus `runtime/charybdis_state.json`; it must never use the user
profile or repository parent as a document root.

Runtime telemetry, logs, state snapshots, audit reports, and common credential
file types are ignored by Git. Run the repository audit before publishing:

```powershell
.\powershell\audit_repository_security.ps1
```

Use `-History` with Gitleaks installed to inspect reachable Git history. The
audit prints paths and rule names, never matched secret values.

## Deletion

Stop the stack before deleting live data:

```powershell
.\charybdis.ps1 stop
Remove-Item .\runtime\shortcut_usage*.jsonl, .\runtime\charybdis_events*.jsonl -Force
Remove-Item .\runtime\charybdis_state.json, .\runtime\logs -Recurse -Force
```

Deleting a tracked file in a new commit does not remove it from older Git
history. Historical removal requires a coordinated history rewrite and all
clones must be replaced afterward.
