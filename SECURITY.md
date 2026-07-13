# Security Policy

## Supported Version

Only the latest commit on the repository's default branch is supported.

## Reporting

Do not open a public issue containing credentials, private telemetry, or
exploit details. Contact the repository owner privately through GitHub first.
Revoke or rotate any exposed credential immediately; repository cleanup is not
a substitute for rotation.

## Local Security Model

- The coach HTTP server must bind only to loopback, validate the `Host` header,
  disable directory listings, and serve only allowlisted coach/state paths.
- Runtime telemetry and state are private local data and must not be committed.
- Launcher updates use fast-forward-only Git pulls and refuse dirty tracked
  trees unless the user explicitly opts into the current tree.
- PID records are identity-checked before a process tree is stopped.
- Runtime Python dependencies are version-pinned and audited in CI.

Run local checks with:

```powershell
.\powershell\audit_repository_security.ps1
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
.\.venv\Scripts\python.exe -m pip_audit -r requirements-runtime.txt
```
