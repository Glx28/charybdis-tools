# Charybdis V2 Layout â€” Daily Task Analysis

**Generated:** 2026-06-28 23:22 UTC
**Source:** v2_checkpoint_gen7500.json (generation 7500)
**Selected candidate:** best_exact (feasible)

## 1. Executive Summary

- **Fitness:** effort=71.35, adjacency=-29.65, violations=14.56
- **Changes from canonical:** 235 keys moved
- **Frozen positions preserved:** 104 (no learning needed for these)
- **Mutable positions changed:** 235 out of 512

**Overall verdict:** GOOD with critical fix needed

**Top 3 strengths:**
1. Violations are low â€” the layout respects most hard constraints.
2. Many high-importance shortcuts are on low-effort home-row and thumb positions.
3. Layer 1 (clipboard) has a tight cluster of editing commands.

**Top 3 concerns:**
1. Some mutable L0 thumb positions changed â€” will require immediate relearning.
2. A few app shortcuts may be on less intuitive layers for new users.
3. Mouse buttons (if needed) are not in the evolved layout â€” the optimizer pool does not include them. Add via ZMK Studio if you use trackball without a physical mouse.

## 2. App Profiles

### 2.1 Browser (Chrome/Edge)

**Weighted average effort:** 2.55

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Ctrl+T | New tab | 2 | (5.0,5.0) | 4.5 | left | constant |
| Ctrl+W | Close tab | 5 | (9,1) | 1.0 | right | constant |
| Ctrl+Tab | Next tab | 3 | (0.0,2.0) | 2.0 | left | constant |
| Alt+Left | Back | 5 | (2.0,0.0) | 3.5 | left | constant |
| Ctrl+L | Focus address bar | 5 | (9,2) | 0.0 | right | constant |
| Ctrl+C | Copy | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| j | Scroll down | 4 | (5.0,3.0) | 3.0 | left | constant |
| k | Scroll up | 10 | (1.0,0.0) | 3.5 | left | constant |
| f | Open link in current tab | 5 | (0.0,0.0) | 5.5 | left | constant |

**Top 5 easiest:**
- Ctrl+L at L5 (9,2) â€” effort 0.0, right middle
- F5 at L6 (9,2) â€” effort 0.0, right middle
- F12 at L4 (3.0,2.0) â€” effort 0.0, left middle
- u at L3 (8.0,2.0) â€” effort 0.0, right index
- Ctrl+D at L1 (1.0,2.0) â€” effort 0.0, left pinky

**Top 5 hardest:**
- f at L5 (0.0,0.0) â€” effort 5.5, left far_pinky
- Escape at L10 (12.0,0.0) â€” effort 5.5, right far_pinky
- Ctrl+Z at L1 (7.0,0.0) â€” effort 5.5, right index_stretch
- F at L5 (0.0,0.0) â€” effort 5.5, left far_pinky
- Ctrl+Shift+G at L2 (12.0,0.0) â€” effort 5.5, right far_pinky

### 2.2 Visual Studio Code

**Weighted average effort:** 1.89

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Ctrl+Shift+P | Command palette | 3 | (11.0,3.0) | 1.0 | right | constant |
| Ctrl+P | Quick open file | 5 | (3.0,0.0) | 3.5 | left | constant |
| Ctrl+S | Save | 1 | (7.0,4.0) | 3.5 | right | constant |
| Ctrl+W | Close editor | 5 | (9,1) | 1.0 | right | constant |
| Ctrl+C | Copy (line if no selection) | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| Ctrl+Z | Undo | 1 | (7.0,0.0) | 5.5 | right | constant |
| Ctrl+D | Select next occurrence | 1 | (1.0,2.0) | 0.0 | left | constant |
| Ctrl+/ | Toggle line comment | 2 | (3.0,3.0) | 1.0 | left | constant |
| Tab | Indent / accept suggestion | 8 | (4,3) | 1.0 | left | constant |

**Top 5 easiest:**
- Ctrl+D at L1 (1.0,2.0) â€” effort 0.0, left pinky
- F12 at L4 (3.0,2.0) â€” effort 0.0, left middle
- Ctrl+J at L5 (2,2) â€” effort 0.0, left ring
- Alt+Down at L8 (9,2) â€” effort 0.0, right middle
- Ctrl+Shift+E at L4 (11.0,2.0) â€” effort 0.0, right pinky

**Top 5 hardest:**
- F10 at L8 (5,5) â€” effort 4.5, left index_stretch
- Ctrl+T at L2 (5.0,5.0) â€” effort 4.5, left index_stretch
- Ctrl+Z at L1 (7.0,0.0) â€” effort 5.5, right index_stretch
- Ctrl+Shift+G at L2 (12.0,0.0) â€” effort 5.5, right far_pinky
- Ctrl+Shift+H at L5 (7,0) â€” effort 5.5, right index_stretch

### 2.3 Microsoft Teams

**Weighted average effort:** 2.20

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Ctrl+2 | Chat | 4 | (11.0,0.0) | 3.5 | right | constant |
| Ctrl+E | Search / command bar | 4 | (0.0,1.0) | 3.0 | left | constant |
| Ctrl+Enter | Send (expanded mode) | 3 | (3.0,4.0) | 1.5 | left | constant |
| Enter | Send message | 1 | (4.0,1.0) | 1.0 | left | constant |
| Ctrl+C | Copy | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| Ctrl+Shift+M | Toggle mute | 1 | (8.0,4.0) | 1.5 | right | constant |
| Ctrl+1 | Activity | 9 | (5.0,1.0) | 3.0 | left | high |
| Ctrl+3 | Teams/channels | 6 | (4,2) | 0.0 | left | high |
| Ctrl+4 | Calendar | 6 | (8,2) | 0.0 | right | high |

**Top 5 easiest:**
- Ctrl+3 at L6 (4,2) â€” effort 0.0, left index
- Ctrl+4 at L6 (8,2) â€” effort 0.0, right index
- Up at L3 (2.0,2.0) â€” effort 0.0, left ring
- Ctrl+Shift+E at L4 (11.0,2.0) â€” effort 0.0, right pinky
- Ctrl+. at L8 (10,2) â€” effort 0.0, right ring

**Top 5 hardest:**
- Ctrl+G at L5 (8,0) â€” effort 3.5, right index
- Ctrl+V at L4 (7.0,5.0) â€” effort 4.5, right index_stretch
- Ctrl+Z at L1 (7.0,0.0) â€” effort 5.5, right index_stretch
- Ctrl+Shift+H at L5 (7,0) â€” effort 5.5, right index_stretch
- Escape at L10 (12.0,0.0) â€” effort 5.5, right far_pinky

### 2.4 Microsoft Excel

**Weighted average effort:** 2.52

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Ctrl+Left | Jump to left edge of data | 6 | (4,0) | 3.5 | left | constant |
| Ctrl+Right | Jump to right edge of data | 6 | (5,1) | 3.0 | left | constant |
| Tab | Move to next cell | 8 | (4,3) | 1.0 | left | constant |
| Enter | Confirm and move down | 1 | (4.0,1.0) | 1.0 | left | constant |
| F2 | Edit cell | 9 | (0,1) | 3.0 | left | constant |
| Escape | Cancel edit | 10 | (12.0,0.0) | 5.5 | right | constant |
| Ctrl+C | Copy | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| Ctrl+Z | Undo | 1 | (7.0,0.0) | 5.5 | right | constant |
| Ctrl+S | Save | 1 | (7.0,4.0) | 3.5 | right | constant |

**Top 5 easiest:**
- Ctrl+Shift+Up at L6 (11,2) â€” effort 0.0, right pinky
- Ctrl+Shift+Down at L6 (1,2) â€” effort 0.0, left pinky
- Ctrl+D at L1 (1.0,2.0) â€” effort 0.0, left pinky
- Ctrl+I at L2 (3.0,2.0) â€” effort 0.0, left middle
- F9 at L6 (2,2) â€” effort 0.0, left ring

**Top 5 hardest:**
- Ctrl+Shift+End at L4 (10.0,0.0) â€” effort 3.5, right ring
- Ctrl+9 at L3 (10.0,0.0) â€” effort 3.5, right ring
- Ctrl+V at L4 (7.0,5.0) â€” effort 4.5, right index_stretch
- Escape at L10 (12.0,0.0) â€” effort 5.5, right far_pinky
- Ctrl+Z at L1 (7.0,0.0) â€” effort 5.5, right index_stretch

### 2.5 Microsoft Outlook

**Weighted average effort:** 2.46

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Ctrl+E | Search | 4 | (0.0,1.0) | 3.0 | left | constant |
| Ctrl+N | New mail | 5 | (0,2) | 2.0 | left | constant |
| Ctrl+R | Reply | 4 | (0.0,3.0) | 3.0 | left | constant |
| Ctrl+Enter | Send message | 3 | (3.0,4.0) | 1.5 | left | constant |
| Ctrl+C | Copy | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| Ctrl+1 | Switch to Mail | 9 | (5.0,1.0) | 3.0 | left | high |
| Ctrl+2 | Switch to Calendar | 4 | (11.0,0.0) | 3.5 | right | high |
| Ctrl+Shift+I | Go to Inbox | 6 | (7,3) | 3.0 | right | high |
| Ctrl+Shift+R | Reply all | 6 | (7,1) | 3.0 | right | high |

**Top 5 easiest:**
- Ctrl+3 at L6 (4,2) â€” effort 0.0, left index
- F9 at L6 (2,2) â€” effort 0.0, left ring
- Ctrl+D at L1 (1.0,2.0) â€” effort 0.0, left pinky
- Ctrl+I at L2 (3.0,2.0) â€” effort 0.0, left middle
- Alt+Down at L8 (9,2) â€” effort 0.0, right middle

**Top 5 hardest:**
- Ctrl+K at L1 (5.0,4.0) â€” effort 3.5, left index_stretch
- Ctrl+V at L4 (7.0,5.0) â€” effort 4.5, right index_stretch
- Ctrl+Z at L1 (7.0,0.0) â€” effort 5.5, right index_stretch
- Ctrl+Shift+G at L2 (12.0,0.0) â€” effort 5.5, right far_pinky
- Ctrl+Shift+Q at L2 (0.0,0.0) â€” effort 5.5, left far_pinky

### 2.6 M-Files Desktop Client

**Weighted average effort:** 2.34

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Ctrl+F | Quick search | 3 | (2.0,1.0) | 1.0 | left | constant |
| Enter | Open / expand selected | 1 | (4.0,1.0) | 1.0 | left | constant |
| Ctrl+E | Check out document | 4 | (0.0,1.0) | 3.0 | left | constant |
| Ctrl+Shift+E | Check in document | 4 | (11.0,2.0) | 0.0 | right | constant |
| Ctrl+S | Save / check in | 1 | (7.0,4.0) | 3.5 | right | constant |
| Ctrl+C | Copy | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| Backspace | Go back / up | 2 | (4.0,5.0) | 2.5 | left | high |
| Alt+Left | Navigate back | 5 | (2.0,0.0) | 3.5 | left | high |
| F5 | Refresh view | 6 | (9,2) | 0.0 | right | high |

**Top 5 easiest:**
- Ctrl+Shift+E at L4 (11.0,2.0) â€” effort 0.0, right pinky
- F5 at L6 (9,2) â€” effort 0.0, right middle
- Ctrl+I at L2 (3.0,2.0) â€” effort 0.0, left middle
- Ctrl+F at L3 (2.0,1.0) â€” effort 1.0, left ring
- Enter at L1 (4.0,1.0) â€” effort 1.0, left index

**Top 5 hardest:**
- Ctrl+2 at L4 (11.0,0.0) â€” effort 3.5, right pinky
- Ctrl+V at L4 (7.0,5.0) â€” effort 4.5, right index_stretch
- Ctrl+Shift+H at L5 (7,0) â€” effort 5.5, right index_stretch
- Ctrl+Z at L1 (7.0,0.0) â€” effort 5.5, right index_stretch
- Ctrl+Shift+G at L2 (12.0,0.0) â€” effort 5.5, right far_pinky

### 2.7 Windows Terminal / PowerShell

**Weighted average effort:** 1.82

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Ctrl+C | Copy / Cancel | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| Tab | Autocomplete | 8 | (4,3) | 1.0 | left | constant |
| Up | Previous command | 3 | (2.0,2.0) | 0.0 | left | constant |
| Ctrl+Shift+T | New tab | 6 | (8,3) | 1.0 | right | high |
| Ctrl+Shift+W | Close tab/pane | 1 | (3.0,4.0) | 1.5 | left | high |
| Ctrl+Tab | Next tab | 3 | (0.0,2.0) | 2.0 | left | high |
| Alt+Shift+D | Split pane (auto) | 1 | (12.0,0.0) | 5.5 | right | high |
| Ctrl+Shift+C | Copy (explicit) | 0 | (5.0,4.0) | 3.5 | left | high |
| Ctrl+Shift+V | Paste (explicit) | 1 | (1.0,3.0) | 1.0 | left | high |

**Top 5 easiest:**
- Up at L3 (2.0,2.0) â€” effort 0.0, left ring
- Ctrl+L at L5 (9,2) â€” effort 0.0, right middle
- Alt+Down at L8 (9,2) â€” effort 0.0, right middle
- Ctrl+C at L4 (2.0,1.0) â€” effort 1.0, left ring
- Tab at L8 (4,3) â€” effort 1.0, left index

**Top 5 hardest:**
- Alt+Right at L10 (5.0,3.0) â€” effort 3.0, left index_stretch
- Ctrl+Shift+C at L0 (5.0,4.0) â€” effort 3.5, left index_stretch
- Alt+Left at L5 (2.0,0.0) â€” effort 3.5, left ring
- Ctrl+V at L4 (7.0,5.0) â€” effort 4.5, right index_stretch
- Alt+Shift+D at L1 (12.0,0.0) â€” effort 5.5, right far_pinky

### 2.8 File Explorer

**Weighted average effort:** 2.57

| Shortcut | Action | Layer | (x,y) | Effort | Hand | Frequency |
|----------|--------|-------|-------|--------|------|-----------|
| Alt+Left | Back | 5 | (2.0,0.0) | 3.5 | left | constant |
| Enter | Open selected item | 1 | (4.0,1.0) | 1.0 | left | constant |
| F2 | Rename | 9 | (0,1) | 3.0 | left | constant |
| Ctrl+C | Copy | 4 | (2.0,1.0) | 1.0 | left | constant |
| Ctrl+V | Paste | 4 | (7.0,5.0) | 4.5 | right | constant |
| Alt+Up | Parent folder | 8 | (8,3) | 1.0 | right | high |
| Alt+Right | Forward | 10 | (5.0,3.0) | 3.0 | left | high |
| Alt+D | Focus address bar | 4 | (1.0,0.0) | 3.5 | left | high |
| Backspace | Go up one level | 2 | (4.0,5.0) | 2.5 | left | high |
| Ctrl+Shift+N | New folder | 3 | (12.0,3.0) | 3.0 | right | high |

**Top 5 easiest:**
- Ctrl+L at L5 (9,2) â€” effort 0.0, right middle
- Enter at L1 (4.0,1.0) â€” effort 1.0, left index
- Ctrl+C at L4 (2.0,1.0) â€” effort 1.0, left ring
- Alt+Up at L8 (8,3) â€” effort 1.0, right index
- Delete at L10 (2,3) â€” effort 1.0, left ring

**Top 5 hardest:**
- Ctrl+Y at L5 (4.0,0.0) â€” effort 3.5, left index
- Ctrl+Shift+1 at L4 (8.0,0.0) â€” effort 3.5, right index
- Ctrl+V at L4 (7.0,5.0) â€” effort 4.5, right index_stretch
- Alt+P at L3 (5.0,5.0) â€” effort 4.5, left index_stretch
- Ctrl+Z at L1 (7.0,0.0) â€” effort 5.5, right index_stretch

## 3. Layer Scorecards

| Layer | Role | Avg Effort | Median Effort | Worst Effort | Shortcut Count | Hand Balance | Quality |
|-------|------|------------|---------------|--------------|----------------|--------------|---------|
| 0 | Base typing and thumb access | 2.16 | 2.00 | 5.5 | 56 | 29/27 | EXCELLENT |
| 1 | Navigation, function keys, programming/editing helpers | 2.16 | 2.00 | 5.5 | 56 | 29/27 | EXCELLENT |
| 2 | Mouse lock and button layer | 2.16 | 2.00 | 5.5 | 56 | 29/27 | EXCELLENT |
| 3 | Window, app, language, mouse/game/travel control | 2.10 | 2.00 | 5.5 | 55 | 29/26 | EXCELLENT |
| 4 | Bluetooth, output, Studio/system, F13-F24 macro layer | 2.18 | 2.00 | 5.5 | 55 | 29/26 | EXCELLENT |
| 5 | Code/IDE layer (VS Code shortcuts) | 2.02 | 1.00 | 5.5 | 33 | 23/10 | EXCELLENT |
| 6 | Reserved transparent layer | 1.36 | 1.00 | 3.5 | 28 | 15/13 | EXCELLENT |
| 8 | Pointer travel overlay | 1.69 | 1.00 | 4.5 | 24 | 12/12 | EXCELLENT |
| 9 | M-Files/DMS document management | 1.46 | 1.00 | 3.5 | 26 | 16/10 | EXCELLENT |
| 10 | Excel spreadsheet layer | 1.91 | 1.50 | 5.5 | 38 | 21/17 | EXCELLENT |

## 4. L0 Thumb Analysis

The base layer thumbs are the gateway to the entire keyboard. Here is how they are assigned in the evolved layout:

| Position | Role | Key | Effort | Notes |
|----------|------|-----|--------|-------|
| (3,4) left inner | coach_l1_hold (L1) | Nav | 1.5 | Evolved: Nav |
| (4,4) left middle | spacebar | ␣ | 1.5 | Evolved: ␣ |
| (5,4) left outer | coach_l2_hold or transparent | Ctrl+Shift+C | 3.5 | Evolved: Ctrl+Shift+C |
| (4,5) left bottom | coach_l2_hold (mouse) | Page Down | 2.5 | Evolved: Page Down |
| (7,4) right inner | coach_l3_hold (L3) | System | 3.5 | Evolved: System |
| (8,4) right middle | coach_l4_hold (L4) | Window | 1.5 | Evolved: Window |
| (7,5) right bottom | return enter | Ret | 4.5 | Evolved: Ret |

**Layer access from usage log (top shortcuts):**
- Layer 0: 138 shortcut events

## 5. Mouse + Keyboard Combo Analysis

Shortcuts pressed within 1 second of a mouse click:

**Mouse combo score:** 0.44 / 1.5 (higher is better)

| Shortcut | App | Layer | Hand | Effort | Score |
|----------|-----|-------|------|--------|-------|
| Ctrl+V | Kimi.exe | 4 | right | 4.5 | 0.0 |
| Ctrl+C | Kimi.exe | 4 | left | 1.0 | 1.0 |
| Ctrl+V | claude.exe | 4 | right | 4.5 | 0.0 |
| Ctrl+Backspace | Kimi.exe | ? | ? | 10.0 | 0.0 |
| Ctrl+V | claude.exe | 4 | right | 4.5 | 0.0 |
| Ctrl+C | claude.exe | 4 | left | 1.0 | 1.0 |
| Shift+Tab | Codex.exe | 1 | right | 1.0 | 0.5 |
| Ctrl+A | Code.exe | 3 | left | 3.0 | 0.5 |
| Ctrl+C | Code.exe | 4 | left | 1.0 | 1.0 |
| Ctrl+V | Codex.exe | 4 | right | 4.5 | 0.0 |
| Ctrl+C | claude.exe | 4 | left | 1.0 | 1.0 |
| Ctrl+V | Kimi.exe | 4 | right | 4.5 | 0.0 |
| Ctrl+V | WindowsTerminal.exe | 4 | right | 4.5 | 0.0 |
| Ctrl+C | Kimi.exe | 4 | left | 1.0 | 1.0 |
| Ctrl+V | claude.exe | 4 | right | 4.5 | 0.0 |

## 6. Workflow Simulations

### 6.1

| Step | Shortcut | Layer | (x,y) | Effort | Hand | Notes |
|------|----------|-------|-------|--------|------|-------|
| 1 | Ctrl+T | 2 | (5.0,5.0) | 4.5 | left | HIGH EFFORT!  |
| 2 | Enter | 1 | (4.0,1.0) | 1.0 | left | layer switch |
| 3 | Ctrl+F | 3 | (2.0,1.0) | 1.0 | left | layer switch |
| 4 | Esc | 7 | (8,3) | 1.0 | right | layer switch |
| 5 | Ctrl+Tab | 3 | (0.0,2.0) | 2.0 | left | layer switch |
| 6 | Ctrl+W | 5 | (9,1) | 1.0 | right | layer switch |
| 7 | Ctrl+Shift+T | 6 | (8,3) | 1.0 | right | layer switch |

**Total effort:** 15.0
**Layer switches:** 6
**Friction points:** Ctrl+T at (5.0,5.0) effort=4.5

### 6.2

| Step | Shortcut | Layer | (x,y) | Effort | Hand | Notes |
|------|----------|-------|-------|--------|------|-------|
| 1 | Ctrl+Shift+M | 1 | (8.0,4.0) | 1.5 | right |  |
| 2 | Ctrl+Shift+E | 4 | (11.0,2.0) | 0.0 | right | layer switch |
| 3 | Ctrl+Shift+O | 4 | (3.0,4.0) | 1.5 | left |  |
| 4 | Ctrl+2 | 4 | (11.0,0.0) | 3.5 | right |  |
| 5 | Ctrl+E | 4 | (0.0,1.0) | 3.0 | left |  |

**Total effort:** 10.5
**Layer switches:** 1

### 6.3

| Step | Shortcut | Layer | (x,y) | Effort | Hand | Notes |
|------|----------|-------|-------|--------|------|-------|
| 1 | Ctrl+S | 1 | (7.0,4.0) | 3.5 | right |  |
| 2 | Ctrl+Shift+P | 3 | (11.0,3.0) | 1.0 | right | layer switch |
| 3 | Ctrl+P | 5 | (3.0,0.0) | 3.5 | left | layer switch |
| 4 | Ctrl+` | 4 | (4.0,4.0) | 1.5 | left | layer switch |
| 5 | Ctrl+Shift+F | 5 | (1,1) | 1.0 | left | layer switch |
| 6 | F5 | 6 | (9,2) | 0.0 | right | layer switch |
| 7 | Ctrl+Shift+K | 3 | (7.0,4.0) | 3.5 | right | layer switch |

**Total effort:** 17.5
**Layer switches:** 6

### 6.4

| Step | Shortcut | Layer | (x,y) | Effort | Hand | Notes |
|------|----------|-------|-------|--------|------|-------|
| 1 | Ctrl+S | 1 | (7.0,4.0) | 3.5 | right |  |
| 2 | Ctrl+Z | 1 | (7.0,0.0) | 5.5 | right | HIGH EFFORT!  |
| 3 | Ctrl+Y | 5 | (4.0,0.0) | 3.5 | left | layer switch |
| 4 | Ctrl+C | 4 | (2.0,1.0) | 1.0 | left | layer switch |
| 5 | Ctrl+V | 4 | (7.0,5.0) | 4.5 | right | HIGH EFFORT!  |
| 6 | Ctrl+Shift+L | 1 | (9.0,3.0) | 1.0 | right | layer switch |
| 7 | F2 | 9 | (0,1) | 3.0 | left | layer switch |
| 8 | Ctrl+Home | 8 | (9,3) | 1.0 | right | layer switch |
| 9 | Ctrl+End | 9 | (4,0) | 3.5 | left | layer switch |
| 10 | Left | ? | ? | ? | ? | NOT MAPPED |
| 11 | Right | ? | ? | ? | ? | NOT MAPPED |
| 12 | Enter | 1 | (4.0,1.0) | 1.0 | left | layer switch |
| 13 | Tab | 8 | (4,3) | 1.0 | left | layer switch |

**Total effort:** 33.0
**Layer switches:** 8
**Friction points:** Ctrl+Z at (7.0,0.0) effort=5.5, Ctrl+V at (7.0,5.0) effort=4.5

### 6.5

| Step | Shortcut | Layer | (x,y) | Effort | Hand | Notes |
|------|----------|-------|-------|--------|------|-------|
| 1 | Ctrl+N | 5 | (0,2) | 2.0 | left |  |
| 2 | Ctrl+Enter | 3 | (3.0,4.0) | 1.5 | left | layer switch |
| 3 | Ctrl+1 | 9 | (5.0,1.0) | 3.0 | left | layer switch |
| 4 | Ctrl+2 | 4 | (11.0,0.0) | 3.5 | right | layer switch |
| 5 | Ctrl+3 | 6 | (4,2) | 0.0 | left | layer switch |

**Total effort:** 12.5
**Layer switches:** 4

### 6.6

| Step | Shortcut | Layer | (x,y) | Effort | Hand | Notes |
|------|----------|-------|-------|--------|------|-------|
| 1 | Ctrl+V | 4 | (7.0,5.0) | 4.5 | right | HIGH EFFORT!  |
| 2 | Ctrl+C | 4 | (2.0,1.0) | 1.0 | left |  |
| 3 | Ctrl+Shift+V | 1 | (1.0,3.0) | 1.0 | left | layer switch |

**Total effort:** 7.5
**Layer switches:** 1
**Friction points:** Ctrl+V at (7.0,5.0) effort=4.5

## 7. Learning Curve

- **L0 changes:** 3 / 56 positions (5.4%)
- **Non-L0 changes:** 232 / 504 positions (46.0%)

**Estimated learning time:** 30 days

## 8. Trackball Proximity

Mouse buttons and scroll keys in the evolved layout (dynamically assigned, not forced to L2):

**Mouse buttons found in evolved layout:**
| Key | Layer | (x,y) | Hand | Effort | Notes |
|-----|-------|-------|------|--------|-------|
| Click | 7 | (4,5) | left | 2.5 | |
| Right Click | 7 | (5,5) | left | 4.5 | |

**Arrow / cursor keys in evolved layout:**
| Key | Layer | (x,y) | Hand | Effort |
|-----|-------|-------|------|--------|
| Down | 2 | (3.0,4.0) | left | 1.5 |
| Up | 3 | (2.0,2.0) | left | 0.0 |

Mouse buttons are placed dynamically by the optimizer â€” they may be on any layer. Verify their positions are comfortable for your trackball usage.

## 9. Norwegian Character Accessibility

Checking for Ã¦, Ã¸, Ã¥ in the evolved layout:

**No dedicated Norwegian character keys found in the evolved layout.**
The Norwegian characters (Ã¦, Ã¸, Ã¥) are produced by the OS layout on the physical keys.
In the canonical layout, semicolon=Ã¸, left apos=Ã¦, left brace=Ã¥ on the Norwegian OS layer.
No action needed â€” the optimizer works at the ZMK keycode level, not the OS character level.

## 10. Cross-Layer Consistency & Duplicates

Shortcuts appearing on multiple layers:
- /: layers [0, 2]
- 3 pd: layers [7]
- 9 pu: layers [7]
- alt+=: layers [2, 6]
- alt+down: layers [1, 8]
- alt+f4: layers [2, 8]
- alt+right: layers [6, 10]
- alt+up: layers [2, 8]
- b: layers [0, 2]
- base: layers [5, 10]
- c: layers [0, 7]
- ctrl+-: layers [1, 3, 8]
- ctrl+.: layers [3, 8]
- ctrl+3: layers [2, 6]
- ctrl+4: layers [3, 6]
- ctrl+5: layers [1, 6]
- ctrl+6: layers [3, 6]
- ctrl+alt+down: layers [3, 6]
- ctrl+alt+up: layers [2, 10]
- ctrl+down: layers [2, 9]
- ctrl+end: layers [2, 9]
- ctrl+g: layers [3, 5]
- ctrl+home: layers [1, 8]
- ctrl+j: layers [1, 5]
- ctrl+l: layers [1, 5]
- ctrl+left: layers [1, 6]
- ctrl+n: layers [2, 5]
- ctrl+q: layers [3, 6]
- ctrl+right: layers [4, 6]
- ctrl+shift++: layers [3, 6]
- ctrl+shift+`: layers [3, 5, 8]
- ctrl+shift+down: layers [3, 6]
- ctrl+shift+esc: layers [3, 8]
- ctrl+shift+f: layers [1, 5]
- ctrl+shift+f6: layers [2, 8]
- ctrl+shift+h: layers [4, 5]
- ctrl+shift+i: layers [3, 6]
- ctrl+shift+left: layers [1, 6]
- ctrl+shift+r: layers [4, 6]
- ctrl+shift+right: layers [1, 6]
- ctrl+shift+s: layers [2, 5, 8]
- ctrl+shift+t: layers [2, 6]
- ctrl+shift+up: layers [4, 6]
- ctrl+shift+z: layers [2, 8]
- ctrl+space: layers [3, 6]
- ctrl+up: layers [1, 9]
- ctrl+w: layers [3, 5]
- d: layers [0, 4]
- delete: layers [4, 8, 10]
- esc: layers [0, 7]
- escape: layers [3, 8, 10]
- exit base: layers [7]
- f: layers [0, 3, 5]
- f1: layers [4, 5]
- f10: layers [3, 6, 8]
- f11: layers [1, 8]
- f2: layers [5, 9]
- f4: layers [1, 6]
- f5: layers [3, 6]
- f8: layers [1, 5]
- f9: layers [1, 6]
- g: layers [0, 3]
- h: layers [0, 1]
- j: layers [0, 4]
- k: layers [0, 10]
- l: layers [0, 4]
- n: layers [0, 3]
- o: layers [0, 2]
- p: layers [0, 4]
- r: layers [0]
- ret: layers [0, 7]
- save: layers [5, 9]
- shft: layers [0, 7]
- shift+alt+down: layers [2, 9]
- shift+f11: layers [3, 6]
- shift+space: layers [4, 8]
- t: layers [0, 2]
- tab: layers [0, 1, 8]
- transparen: layers [3, 4, 5, 8, 9, 10]
- u: layers [0, 3]
- w: layers [0, 2]
- win+.: layers [3, 8]
- win+2: layers [3, 10]
- win+;: layers [2, 8]
- win+b: layers [2, 10]
- win+ctrl+d: layers [2, 10]
- win+ctrl+right: layers [4, 5, 8]
- win+e: layers [2, 10]
- win+l: layers [4, 10]
- win+left: layers [1, 10]
- win+n: layers [4, 10]
- win+shift+left: layers [1, 6]
- win+shift+right: layers [1, 6]
- win+space: layers [4, 6]
- win+t: layers [3, 10]
- win+tab: layers [5, 9]
- x: layers [0, 1, 2, 3, 7]
- z: layers [0, 7]
- ←: layers [7]
- ↑: layers [7]
- →: layers [7]
- ↓: layers [1, 7]
- ␣: layers [0, 7]

**Assessment:**
- Intentional duplicates (e.g., Ctrl+C on L1 and L0) are fine for convenience.
- If a critical shortcut like Ctrl+S is only on a hard-to-reach layer, that is a concern.

## 11. App Affinity & Transition Cost

**Apps and their primary layers:**
- edge -> browser: layers [0, 2, 3, 4, 5, 6, 7, 8, 9, 10]
- code -> vscode: layers [0, 1, 2, 3, 4, 5, 6, 8, 9, 10]
- teams -> teams: layers [0, 1, 2, 3, 4, 5, 6, 8, 9, 10]
- excel -> excel: layers [0, 1, 2, 3, 4, 5, 6, 8, 9, 10]
- outlook -> outlook: layers [2, 3, 4, 5, 6, 8, 9, 10]
- m-files -> mfiles: layers [0, 2, 3, 4, 5, 6, 8, 9, 10]
- terminal -> terminal: layers [0, 1, 2, 4, 5, 6, 7, 8, 10]
- explorer -> explorer: layers [0, 2, 3, 4, 5, 6, 8, 10]

## 12. Real Usage Validation

**Top 20 most-used shortcuts from AHK log:**
- Ctrl+V: 37 times â†’ L4 (7.0,5.0) effort=4.5
- Ctrl+Backspace: 36 times â†’ NOT IN EVOLVED LAYOUT
- Ctrl+C: 33 times â†’ L4 (2.0,1.0) effort=1.0
- Shift+Enter: 22 times â†’ L4 (10.0,3.0) effort=1.0
- Ctrl+A: 5 times â†’ L3 (5.0,1.0) effort=3.0
- Ctrl+S: 2 times â†’ L1 (7.0,4.0) effort=3.5
- Ctrl+Enter: 2 times â†’ L3 (3.0,4.0) effort=1.5
- Shift+Tab: 1 times â†’ L1 (8.0,3.0) effort=1.0

## 13. Recommendations

1. **Verify L0 thumb positions in ZMK Studio:** The evolved layout changed some thumb assignments. Ensure spacebar is still at (4,4) and return at (7,5).
2. **Test layer holds for comfort:** Hold each thumb-access layer (L1â€“L4) and verify the shortcuts on that layer feel natural for your hands.
3. **Practice app shortcuts in clusters:** The most-used apps (Browser, VS Code, Teams) should be on the easiest layers. Review the top 5 shortcuts per app and confirm they feel natural.
4. **Check for missing shortcuts:** If any top-20 logged shortcuts are not mapped, add them to the optimizer corpus and re-run.
5. **Mouse buttons:** If you need trackball click functionality, add MB1â€“MB5 via ZMK Studio after applying the layout. The optimizer pool does not include them, so they won't be placed automatically.
6. **Give it 2-3 weeks:** With 235 changed keys, expect 2-3 weeks for full muscle memory. Start with the most-changed layer (L1 or L2) and practice 10 minutes daily.