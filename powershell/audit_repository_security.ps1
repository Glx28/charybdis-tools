<#
.SYNOPSIS
    Privacy and secret-safety checks for files tracked by Git.

.DESCRIPTION
    Reports file paths and rule names only; matching values are never printed.
    Use -History to additionally run Gitleaks over reachable Git history when
    Gitleaks is installed.
#>
[CmdletBinding()]
param([switch]$History)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Invoke-GitLines {
    param([string[]]$Arguments)
    $output = & git -C $repoRoot @Arguments 2>$null
    if ($LASTEXITCODE -notin @(0, 1)) { throw "git failed while running repository audit" }
    @($output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

$tracked = @(Invoke-GitLines @("ls-files"))
$failures = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[object]

$privateRuntimePatterns = @(
    '^runtime/.*shortcut_usage.*\.jsonl$',
    '^runtime/.*charybdis_events.*\.jsonl$',
    '^runtime/charybdis_state\.json$',
    '^runtime/logs/',
    '^runtime/.*(?:probe|audit).*\.json$'
)
foreach ($file in $tracked) {
    if ($privateRuntimePatterns | Where-Object { $file -match $_ }) {
        $failures.Add([pscustomobject]@{ Rule = "tracked-private-runtime"; Path = $file })
    }
    if ($file -match '(?i)(^|/)(?:\.env(?:\..+)?|\.npmrc|\.pypirc|\.netrc|credentials\.json|secrets?\.json|id_rsa|id_ed25519|[^/]+\.(?:pem|key|pfx|p12|jks|keystore|kdbx))$') {
        $failures.Add([pscustomobject]@{ Rule = "tracked-secret-file"; Path = $file })
    }
}

$secretRules = [ordered]@{
    "private-key" = '-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'
    "aws-access-key" = 'AKIA[0-9A-Z]{16}'
    "github-token" = 'gh[pousr]_[A-Za-z0-9_]{20,}'
    "slack-token" = 'xox[baprs]-[A-Za-z0-9-]{10,}'
    "google-api-key" = 'AIza[0-9A-Za-z_-]{35}'
}
foreach ($entry in $secretRules.GetEnumerator()) {
    $matches = @(Invoke-GitLines @("grep", "-Il", "-E", "-e", $entry.Value, "--"))
    foreach ($file in $matches) { $failures.Add([pscustomobject]@{ Rule = $entry.Key; Path = $file }) }
}

$absolutePathRules = @(
    @{ Name = "windows-user-path"; Pattern = 'C:\\Users\\[^\\/[:space:]]+' },
    @{ Name = "linux-home-path"; Pattern = '/home/[^/[:space:]]+' }
)
foreach ($rule in $absolutePathRules) {
    $matches = @(Invoke-GitLines @("grep", "-Il", "-E", "-e", $rule.Pattern, "--"))
    foreach ($file in $matches) { $warnings.Add([pscustomobject]@{ Rule = $rule.Name; Path = $file }) }
}

Write-Host "Security audit: $($tracked.Count) tracked files" -ForegroundColor Cyan
if ($warnings.Count) {
    Write-Host "Warnings (review portability/privacy):" -ForegroundColor Yellow
    $warnings | Sort-Object Rule, Path -Unique | Group-Object Rule |
        Select-Object Count, Name | Format-Table -AutoSize
    Write-Host "Use git grep for a listed rule's pattern when reviewing individual paths." -ForegroundColor DarkGray
}
if ($failures.Count) {
    Write-Host "Failures:" -ForegroundColor Red
    $failures | Sort-Object Rule, Path -Unique | Format-Table -AutoSize
}

if ($History) {
    $gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue
    if ($gitleaks) {
        $report = Join-Path $repoRoot "runtime\gitleaks-history.json"
        & $gitleaks.Source git --redact --report-format json --report-path $report --exit-code 0 $repoRoot
        $items = if (Test-Path -LiteralPath $report) { @(Get-Content -Raw $report | ConvertFrom-Json) } else { @() }
        Write-Host "Gitleaks historical candidates: $($items.Count) (manual validation required)" -ForegroundColor Cyan
        $items | Group-Object RuleID | Select-Object Count, Name | Format-Table -AutoSize
    } else {
        Write-Warning "Gitleaks is not installed; skipped historical scan."
    }
}

if ($failures.Count) { exit 1 }
Write-Host "No prohibited tracked runtime data or high-confidence secrets found." -ForegroundColor Green
