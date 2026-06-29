# Push charybdis-optimizer-v2 to GitHub — one giant PowerShell command
# Save this file as `push_v2.ps1` and run it in an elevated PowerShell window:
#   powershell -ExecutionPolicy Bypass -File C:\Users\nos\charybdis-tools\push_v2.ps1

$ErrorActionPreference = "Stop"
$repoPath = "C:\Users\nos\charybdis-optimizer-v2"
$repoName = "charybdis-optimizer-v2"

Write-Host "=== Charybdis Optimizer V2 GitHub Push ===" -ForegroundColor Cyan

# 1. Install GitHub CLI via winget if missing
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
    Write-Host "GitHub CLI not found. Installing via winget..." -ForegroundColor Yellow
    winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $gh) { Write-Error "Failed to install GitHub CLI. Install manually from https://cli.github.com/"; exit 1 }
    Write-Host "GitHub CLI installed." -ForegroundColor Green
} else {
    Write-Host "GitHub CLI found: $($gh.Source)" -ForegroundColor Green
}

# 2. Authenticate (interactive if needed)
gh auth status *>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not authenticated. Running 'gh auth login'..." -ForegroundColor Yellow
    gh auth login
}

# 3. Create remote repo if it doesn't exist
try { gh repo view "Glx28/$repoName" *>$null; $exists = $true } catch { $exists = $false }
if (-not $exists) {
    Write-Host "Creating GitHub repo Glx28/$repoName ..." -ForegroundColor Cyan
    gh repo create "$repoName" --public --confirm
} else {
    Write-Host "Repo already exists." -ForegroundColor Green
}

# 4. Push
Set-Location $repoPath
Write-Host "Pushing from $repoPath ..." -ForegroundColor Cyan
git push -u origin master
Write-Host "DONE: charybdis-optimizer-v2 pushed to GitHub!" -ForegroundColor Green
Read-Host "Press Enter to exit"
