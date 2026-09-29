[CmdletBinding()]
param(
    [int]$Port = 0,
    [switch]$NoBrowser,
    [switch]$ForceRestart
)

# Compatibility for the previous three-repository launcher path.
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$launcher = Join-Path $repoRoot "start_charybdis.ps1"
$arguments = @("-RepoRoot", $repoRoot)
if ($Port -gt 0) { $arguments += @("-Port", "$Port") }
if ($NoBrowser) { $arguments += "-NoBrowser" }
if ($ForceRestart) { $arguments += "-Restart" }
& $launcher @arguments
