# START - Trackball Benchmark V2

## What You Do

### Step 1: Run Benchmark Script (~75 min)

```powershell
cd C:\Users\sondr\splitted_zmk_keyboard\runtime\trackball_benchmarks
.\run_benchmark.ps1 -ProfileName "P0-current-3mon"
```

### Step 2: Follow Script Instructions

The script will guide you through 5 tests:

1. **R1 - TestUFO** (5 min) - 3 runs, paste 3 Hz numbers
2. **A1 - Aim Trainer** (10 min) - 3 runs, paste 3 ms numbers
3. **A2 - MouseAccuracy** (15 min) - 5 runs, paste score/targets/misclicks for each
4. **P1 - Precision Movement** (15 min) - 5 runs, paste precision%/jitter/points for each
5. **P2 - XbitLabs** (30 min) - 4 modes × 3 runs, paste accuracy%/deviation/failures for each

Script shows:
- Link for each test
- What settings to use
- What to record
- Clear prompts for results

### Step 3: Get Results File

Results saved to:
```
results\P0-current-3mon_YYYYMMDD_HHMMSS\benchmark_results.txt
```

### Step 4: Paste File to AI

Copy the entire benchmark_results.txt file and paste it here.

AI will:
1. Analyze all metrics
2. Identify problems (overshoot, jitter, control issues)
3. Suggest specific firmware changes (CPI, scaler, etc.)
4. Give you exact config changes to test

### Step 5: Test Next Profile

After firmware change:
```powershell
.\run_benchmark.ps1 -ProfileName "P1-CPI400"
```

Paste results to AI.

AI will:
1. Compare P1 vs P0
2. Show improvements/regressions
3. Decide: KEEP / ITERATE / PIVOT
4. Suggest P2 if needed

---

## Test Suite Overview

| Test | Weight | What It Measures | Runs | Time |
|------|--------|------------------|------|------|
| R1 TestUFO | 10% | Wireless/polling stability | 3 | 5 min |
| A1 Aim Trainer | 15% | Target acquisition speed | 3 | 10 min |
| **A2 MouseAccuracy** | **30%** | **Tiny-target precision** | 5 | 15 min |
| P1 Precision Movement | 25% | Straight-line path quality | 5 | 15 min |
| P2 XbitLabs | 20% | Curves/shapes/steady-hand | 12 | 30 min |
| **TOTAL** | **100%** | | | **~75 min** |

---

## Why This Suite

**Your problem:** "Overshooting, hard to be accurate, unable to make clean paths"

**Tests that matter most:**
- **A2 (30%)** - Directly tests overshoot on tiny targets
- **P1 (25%)** - Tests straight-line jitter and control
- **P2 (20%)** - Tests curved paths and steady hand

**A1 (15%)** - Makes sure setup doesn't become too slow
**R1 (10%)** - Makes sure wireless/polling is stable

---

## What AI Will Do

1. **Parse your results** (handles user error in formatting)
2. **Calculate medians** for all tests
3. **Identify root cause:**
   - High A2 misclicks + low score = CPI too high
   - High P1 jitter = sensor/scaling issues
   - Good P1 but bad P2 = scaling wrong for curves
4. **Suggest firmware change:**
   - CPI adjustment (600 → 400 or 800)
   - XY scaler adjustment (2:1 → 1.5:1 or 1:1)
   - Polling mode change (if R1 shows issues)
5. **Give exact config** for you to change
6. **After P1 test:** Compare and recommend next step

---

## Current Config

```
CPI: 200 (hardware minimum)
Speed Mode CPI (Layer 8): 1000
XY Scaler: 2:1
Polling: 125_SW
Connection: Wireless
```

---

## Run It Now

```powershell
cd C:\Users\sondr\splitted_zmk_keyboard\runtime\trackball_benchmarks

# Open browser tests for reference
start .\tools\browser_tests_V2.html

# Run benchmark
.\run_benchmark.ps1 -ProfileName "P0-current-3mon"
```

**Then paste benchmark_results.txt here for AI analysis.**
