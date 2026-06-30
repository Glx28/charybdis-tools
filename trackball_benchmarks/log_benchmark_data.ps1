# Structured Benchmark Data Logger - NEW SUITE
# R1, A1, A2, P1 only

param(
    [Parameter(Mandatory=$true)]
    [string]$Profile,

    [Parameter(Mandatory=$true)]
    [ValidateSet("R1", "A1", "A2", "P1")]
    [string]$Test,

    # R1 - TestUFO
    [int]$R1_Run1_Hz,
    [int]$R1_Run2_Hz,
    [int]$R1_Run3_Hz,

    # A1 - Aim Trainer
    [int]$A1_Run1_ms,
    [int]$A1_Run2_ms,
    [int]$A1_Run3_ms,

    # A2 - MouseAccuracy Classic (5 runs)
    [int]$A2_Run1_Score,
    [int]$A2_Run1_Targets,
    [int]$A2_Run1_Misclicks,
    [int]$A2_Run2_Score,
    [int]$A2_Run2_Targets,
    [int]$A2_Run2_Misclicks,
    [int]$A2_Run3_Score,
    [int]$A2_Run3_Targets,
    [int]$A2_Run3_Misclicks,
    [int]$A2_Run4_Score,
    [int]$A2_Run4_Targets,
    [int]$A2_Run4_Misclicks,
    [int]$A2_Run5_Score,
    [int]$A2_Run5_Targets,
    [int]$A2_Run5_Misclicks,

    # P1 - Precision Movement (5 runs)
    [double]$P1_Run1_Precision,
    [double]$P1_Run1_AvgJitter,
    [double]$P1_Run1_MaxJitter,
    [int]$P1_Run1_Points,
    [double]$P1_Run2_Precision,
    [double]$P1_Run2_AvgJitter,
    [double]$P1_Run2_MaxJitter,
    [int]$P1_Run2_Points,
    [double]$P1_Run3_Precision,
    [double]$P1_Run3_AvgJitter,
    [double]$P1_Run3_MaxJitter,
    [int]$P1_Run3_Points,
    [double]$P1_Run4_Precision,
    [double]$P1_Run4_AvgJitter,
    [double]$P1_Run4_MaxJitter,
    [int]$P1_Run4_Points,
    [double]$P1_Run5_Precision,
    [double]$P1_Run5_AvgJitter,
    [double]$P1_Run5_MaxJitter,
    [int]$P1_Run5_Points
)

# Find session folder
$sessionPattern = "results\${Profile}_*"
$sessionFolder = Get-ChildItem -Path $sessionPattern -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $sessionFolder) {
    Write-Host "ERROR: Session folder not found for profile '$Profile'" -ForegroundColor Red
    exit 1
}

$dataFile = Join-Path $sessionFolder.FullName "benchmark_data.json"

# Load or create
if (Test-Path $dataFile) {
    $data = Get-Content $dataFile -Raw | ConvertFrom-Json -AsHashtable
} else {
    $data = @{
        profile = $Profile
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        tests = @{}
    }
}

# Build test entry
$testEntry = @{ timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") }

switch ($Test) {
    "R1" {
        if ($R1_Run1_Hz) { $testEntry.run1_hz = $R1_Run1_Hz }
        if ($R1_Run2_Hz) { $testEntry.run2_hz = $R1_Run2_Hz }
        if ($R1_Run3_Hz) { $testEntry.run3_hz = $R1_Run3_Hz }
        if ($R1_Run1_Hz -and $R1_Run2_Hz -and $R1_Run3_Hz) {
            $sorted = @($R1_Run1_Hz, $R1_Run2_Hz, $R1_Run3_Hz) | Sort-Object
            $testEntry.median_hz = $sorted[1]
        }
    }
    "A1" {
        if ($A1_Run1_ms) { $testEntry.run1_ms = $A1_Run1_ms }
        if ($A1_Run2_ms) { $testEntry.run2_ms = $A1_Run2_ms }
        if ($A1_Run3_ms) { $testEntry.run3_ms = $A1_Run3_ms }
        if ($A1_Run1_ms -and $A1_Run2_ms -and $A1_Run3_ms) {
            $sorted = @($A1_Run1_ms, $A1_Run2_ms, $A1_Run3_ms) | Sort-Object
            $testEntry.median_ms = $sorted[1]
        }
    }
    "A2" {
        $testEntry.runs = @()
        for ($i = 1; $i -le 5; $i++) {
            $score = Get-Variable -Name "A2_Run${i}_Score" -ValueOnly -ErrorAction SilentlyContinue
            $targets = Get-Variable -Name "A2_Run${i}_Targets" -ValueOnly -ErrorAction SilentlyContinue
            $misclicks = Get-Variable -Name "A2_Run${i}_Misclicks" -ValueOnly -ErrorAction SilentlyContinue
            if ($score) {
                $testEntry.runs += @{
                    run = $i
                    score = $score
                    targets = $targets
                    misclicks = $misclicks
                }
            }
        }
        if ($testEntry.runs.Count -eq 5) {
            $scores = $testEntry.runs | ForEach-Object { $_.score } | Sort-Object
            $misclicks = $testEntry.runs | ForEach-Object { $_.misclicks } | Sort-Object
            $testEntry.median_score = $scores[2]
            $testEntry.median_misclicks = $misclicks[2]
        }
    }
    "P1" {
        $testEntry.runs = @()
        for ($i = 1; $i -le 5; $i++) {
            $prec = Get-Variable -Name "P1_Run${i}_Precision" -ValueOnly -ErrorAction SilentlyContinue
            $avg = Get-Variable -Name "P1_Run${i}_AvgJitter" -ValueOnly -ErrorAction SilentlyContinue
            $max = Get-Variable -Name "P1_Run${i}_MaxJitter" -ValueOnly -ErrorAction SilentlyContinue
            $pts = Get-Variable -Name "P1_Run${i}_Points" -ValueOnly -ErrorAction SilentlyContinue
            if ($prec) {
                $testEntry.runs += @{
                    run = $i
                    precision = $prec
                    avg_jitter = $avg
                    max_jitter = $max
                    points = $pts
                }
            }
        }
        if ($testEntry.runs.Count -eq 5) {
            $prec = $testEntry.runs | ForEach-Object { $_.precision } | Sort-Object
            $avg = $testEntry.runs | ForEach-Object { $_.avg_jitter } | Sort-Object
            $max = $testEntry.runs | ForEach-Object { $_.max_jitter } | Sort-Object
            $testEntry.median_precision = $prec[2]
            $testEntry.median_avg_jitter = $avg[2]
            $testEntry.median_max_jitter = $max[2]
        }
    }
}

# Update data
if (-not $data.tests) { $data.tests = @{} }
$data.tests[$Test] = $testEntry

# Save
$data | ConvertTo-Json -Depth 10 | Set-Content $dataFile

Write-Host "✅ Logged: $Test" -ForegroundColor Green
Write-Host "   Profile: $Profile" -ForegroundColor Cyan
Write-Host "   Data: $dataFile" -ForegroundColor Gray
