[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [int]$Port = 0,
    [switch]$NoBrowser,
    [switch]$Restart
)

$command = if ($Restart) { "restart" } else { "start" }
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = $PSScriptRoot }
$launcher = Join-Path $RepoRoot "charybdis.ps1"
$arguments = @($command, "-RepoRoot", $RepoRoot)
if ($Port -gt 0) { $arguments += @("-Port", "$Port") }
if ($NoBrowser) { $arguments += "-NoBrowser" }
& $launcher @arguments
