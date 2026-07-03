# Charybdis V2 (Gen 1000, Run bk6ser0gn) - Full Workflow Layer Analysis
> Effort values in this historical report were normalized to the corrected 2026-07-03 per-position effort model. Lower effort means a more valuable/easier key.


**Source:** v2_checkpoint_gen1000.json (timestamp: 2026-06-29T10:08:39Z)
**Generation:** 1000
**Fitness:** effort=50.51, adjacency=-30.73, violations=3.66
**Total score:** N/A

**Important:** The new constraints (hand_bias=2000, arrow_order=200, mouse_layer_access=5000) are NOT wired into the fitness evaluator. The `evaluator.py` does not import `hand_bias` or `arrow_order`. Only the default 9 factors are active. The layout below is from a random-seed evolution with `inject_seed=false`.

## Layer 0

**Shortcuts:** 56 | **Avg effort:** 2.16 | **Hand balance:** 29/27

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (0,0) | 2.75 | left | Esc | Base typing key for the main work layout. |
| (1,0) | 2.00 | left | 1 | Base typing key for the main work layout. |
| (2,0) | 2.00 | left | 2 | Base typing key for the main work layout. |
| (3,0) | 2.00 | left | 3 | Base typing key for the main work layout. |
| (4,0) | 2.00 | left | 4 | Base typing key for the main work layout. |
| (5,0) | 2.75 | left | 5 | Base typing key for the main work layout. |
| (7,0) | 2.75 | right | 6 | Base typing key for the main work layout. |
| (8,0) | 2.00 | right | 7 | Base typing key for the main work layout. |
| (9,0) | 2.00 | right | 8 | Base typing key for the main work layout. |
| (10,0) | 2.00 | right | 9 | Base typing key for the main work layout. |
| (11,0) | 2.00 | right | 0 | Base typing key for the main work layout. |
| (12,0) | 2.75 | right | BkSp | Base typing key for the main work layout. |
| (0,1) | 1.75 | left | Tab | Base typing key for the main work layout. |
| (1,1) | 1.00 | left | Q | Base typing key for the main work layout. |
| (2,1) | 1.00 | left | W | Base typing key for the main work layout. |
| (3,1) | 1.00 | left | E | Base typing key for the main work layout. |
| (4,1) | 1.00 | left | R | Base typing key for the main work layout. |
| (5,1) | 1.75 | left | T | Base typing key for the main work layout. |
| (7,1) | 1.75 | right | Y | Base typing key for the main work layout. |
| (8,1) | 1.00 | right | U | Base typing key for the main work layout. |
| (9,1) | 1.00 | right | I | Base typing key for the main work layout. |
| (10,1) | 1.00 | right | O | Base typing key for the main work layout. |
| (11,1) | 1.00 | right | P | Base typing key for the main work layout. |
| (12,1) | 1.75 | right | å | Norwegian å. Sends the [ scancode (ZMK Studio name 'Left Bra |
| (0,2) | 1.25 | left | Shft | Base typing key for the main work layout. |
| (1,2) | 0.00 | left | A | Base typing key for the main work layout. |
| (2,2) | 0.00 | left | S | Base typing key for the main work layout. |
| (3,2) | 0.00 | left | D | Base typing key for the main work layout. |
| (4,2) | 0.00 | left | F | Base typing key for the main work layout. |
| (5,2) | 1.25 | left | G | Base typing key for the main work layout. |
| (7,2) | 1.25 | right | H | Base typing key for the main work layout. |
| (8,2) | 0.00 | right | J | Base typing key for the main work layout. |
| (9,2) | 0.00 | right | K | Base typing key for the main work layout. |
| (10,2) | 0.00 | right | L | Base typing key for the main work layout. |
| (11,2) | 0.00 | right | ø | Norwegian ø. Keycode is unchanged (SemiColon scancode); Wind |
| (12,2) | 1.25 | right | æ | Norwegian æ. Keycode is unchanged (Apostrophe/Quote scancode |
| (0,3) | 1.75 | left | Ctrl | Base typing key for the main work layout. |
| (1,3) | 1.00 | left | Z | Base typing key for the main work layout. |
| (2,3) | 1.00 | left | X | Base typing key for the main work layout. |
| (3,3) | 1.00 | left | C | Base typing key for the main work layout. |
| (4,3) | 1.00 | left | V | Base typing key for the main work layout. |
| (5,3) | 1.75 | left | B | Base typing key for the main work layout. |
| (7,3) | 1.75 | right | N | Base typing key for the main work layout. |
| (8,3) | 1.00 | right | M | Base typing key for the main work layout. |
| (9,3) | 1.00 | right | , | Base typing key for the main work layout. |
| (10,3) | 1.00 | right | . | CRITICAL v1.9: Period must be on base layer for typing flow. |
| (11,3) | 1.00 | right | / | Base typing key for the main work layout. |
| (12,3) | 1.75 | right | \ | International backslash/pipe (US HID). On Norwegian Windows  |
| (3,4) | 1.00 | left | Nav | Hold Nav for layer 1 navigation/editing. |
| (4,4) | 0.00 | left | ␣ | Thumb/control key for typing, layer access, mouse access, or |
| (5,4) | 1.00 | left | J | Previous tab |
| (7,4) | 1.00 | right | System | Hold System for layer 4 Bluetooth/output/helpers. |
| (8,4) | 0.00 | right | Window | Hold Window for layer 3 window/app/desktop control. |
| (4,5) | 1.00 | left | Shift+Click | Select range |
| (5,5) | 1.50 | left | Ctrl+R | Reply |
| (7,5) | 1.50 | right | Ret | Thumb/control key for typing, layer access, mouse access, or |

## Layer 1

**Shortcuts:** 43 | **Avg effort:** 1.87 | **Hand balance:** 24/19

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (0,0) | 2.75 | left | Page Down | Next slide |
| (2,0) | 2.00 | left | Ctrl+Page Down | Next sheet |
| (3,0) | 2.00 | left | Alt+= | AutoSum |
| (4,0) | 2.00 | left | Ctrl+Shift+1 | Extra large icons |
| (5,0) | 2.75 | left | DownArrow | Down arrow |
| (8,0) | 2.00 | right | Ctrl+P | Print |
| (0,1) | 1.75 | left | Ctrl+Up | Jump to top edge of data |
| (1,1) | 1.00 | left | Alt+Left | Go back |
| (2,1) | 1.00 | left | Ctrl+X | Cut |
| (3,1) | 1.00 | left | Ctrl+Shift+Esc | Task Manager |
| (4,1) | 1.00 | left | Alt+D | Focus address bar (alt) |
| (5,1) | 1.75 | left | Ctrl+K | Insert link |
| (7,1) | 1.75 | right | Shift+Alt+Right | Expand selection |
| (8,1) | 1.00 | right | Ctrl+9 | Last tab |
| (9,1) | 1.00 | right | X | Restore closed tab |
| (10,1) | 1.00 | right | Ctrl+Q | Mark as read |
| (11,1) | 1.00 | right | Shift+Enter | New line in message |
| (0,2) | 1.25 | left | Win+E | File Explorer |
| (1,2) | 0.00 | left | Shift+Alt+Up | Copy line up |
| (2,2) | 0.00 | left | Ctrl+; | Insert current date |
| (3,2) | 0.00 | left | Win+Up | Maximize window |
| (4,2) | 0.00 | left | Win+H | Voice typing |
| (5,2) | 1.25 | left | r | Reload page |
| (7,2) | 1.25 | right | = | Start formula |
| (8,2) | 0.00 | right | Win+3 | Open/switch pinned app 3 |
| (9,2) | 0.00 | right | Alt+Shift+- | Split pane horizontal |
| (10,2) | 0.00 | right | Alt+P | Preview pane |
| (11,2) | 0.00 | right | Ctrl+H | History |
| (12,2) | 1.25 | right | Delete | Delete |
| (2,3) | 1.00 | left | Alt+Shift | Switch keyboard layout (alt) |
| (4,3) | 1.00 | left | F11 | Toggle fullscreen |
| (5,3) | 1.75 | left | Ctrl+Alt+Up | Add cursor above |
| (7,3) | 1.75 | right | C | Control-modified editing shortcut. |
| (8,3) | 1.00 | right | Shift+Space | Scroll up one screen |
| (9,3) | 1.00 | right | gi | Focus first input field |
| (11,3) | 1.00 | right | Ctrl+Shift+S | Attach file |
| (3,4) | 1.00 | left | F7 | Spell check |
| (4,4) | 0.00 | left | Ctrl+A | Select all |
| (7,4) | 1.00 | right | f | Open link in current tab |
| (8,4) | 0.00 | right | Ctrl+T | New tab |
| (4,5) | 1.00 | left | F1 | Help |
| (5,5) | 1.50 | left | Ctrl+Shift+F | Format text |
| (7,5) | 1.50 | right | Alt+Shift+D | Split pane (auto) |

## Layer 2

**Shortcuts:** 46 | **Avg effort:** 1.92 | **Hand balance:** 24/22

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (0,0) | 2.75 | left | Win+Shift+Left | Move to left monitor |
| (1,0) | 2.00 | left | Ctrl+M | Add to favorites |
| (2,0) | 2.00 | left | Win+Shift+Right | Move to right monitor |
| (3,0) | 2.00 | left | Page Up | Previous slide |
| (4,0) | 2.00 | left | Ctrl+D | Bookmark page |
| (5,0) | 2.75 | left | Win+Shift+S | Screenshot (Snip) |
| (8,0) | 2.00 | right | Ctrl+Shift+V | Paste without formatting |
| (10,0) | 2.00 | right | Ctrl+Tab | Next tab |
| (0,1) | 1.75 | left | Win+Left | Snap window left |
| (1,1) | 1.00 | left | Ctrl+/ | Show keyboard shortcuts |
| (2,1) | 1.00 | left | Ctrl+, | Open settings |
| (3,1) | 1.00 | left | Win+Right | Snap window right |
| (4,1) | 1.00 | left | Win+R | Run dialog |
| (5,1) | 1.75 | left | P | Previous slide (in show) |
| (7,1) | 1.75 | right | Alt+Right | Go forward |
| (8,1) | 1.00 | right | Win+V | Clipboard history |
| (9,1) | 1.00 | right | Win+4 | Open/switch pinned app 4 |
| (10,1) | 1.00 | right | N | Find previous match |
| (11,1) | 1.00 | right | Win+Space | Switch input language |
| (12,1) | 1.75 | right | Alt+Up | Move line up |
| (0,2) | 1.25 | left | Ctrl+Home | Go to cell A1 |
| (1,2) | 0.00 | left | Alt+Shift++ | Split pane vertical |
| (2,2) | 0.00 | left | Win+. | Emoji picker |
| (3,2) | 0.00 | left | u | Scroll half page up |
| (4,2) | 0.00 | left | Win+C | Open Copilot |
| (5,2) | 1.25 | left | B | Black screen |
| (7,2) | 1.25 | right | t | Search open tabs |
| (8,2) | 0.00 | right | d | Scroll half page down |
| (9,2) | 0.00 | right | Shift+Tab | Outdent |
| (10,2) | 0.00 | right | Ctrl+Y | Redo |
| (11,2) | 0.00 | right | F5 | Refresh page |
| (12,2) | 1.25 | right | Ctrl+L | Focus address bar |
| (2,3) | 1.00 | left | Ctrl+Shift+> | Increase font size |
| (3,3) | 1.00 | left | MB1 | Left click |
| (4,3) | 1.00 | left | Ctrl+Shift+% | Percent format |
| (5,3) | 1.75 | left | G | Scroll to bottom |
| (7,3) | 1.75 | right | Ctrl+Shift+E | Toggle screen share |
| (8,3) | 1.00 | right | Ctrl+Shift+Right | Select to right edge |
| (10,3) | 1.00 | right | Ctrl+K S | Save all |
| (11,3) | 1.00 | right | Alt+Enter | Properties / metadata card |
| (12,3) | 1.75 | right | Ctrl+Shift+Del | Clear browsing data |
| (3,4) | 1.00 | left | Tab | Indent / accept suggestion |
| (7,4) | 1.00 | right | Win+Down | Minimize / restore |
| (8,4) | 0.00 | right | Win+S | Search |
| (4,5) | 1.00 | left | Ctrl+[ | Evolved (evo_best_gen150): Sends L Ctrl+{. |
| (7,5) | 1.50 | right | Win+Tab | Task View |

## Layer 3

**Shortcuts:** 40 | **Avg effort:** 1.96 | **Hand balance:** 20/20

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (2,0) | 2.00 | left | Shift+Alt+A | Toggle block comment |
| (3,0) | 2.00 | left | MB2 | Right click |
| (4,0) | 2.00 | left | Win+5 | Open/switch pinned app 5 |
| (5,0) | 2.75 | left | Alt+F4 | Close window |
| (7,0) | 2.75 | right | Win+M | Minimize all windows |
| (9,0) | 2.00 | right | x | Close current tab |
| (10,0) | 2.00 | right | Ctrl+- | Zoom out |
| (11,0) | 2.00 | right | Ctrl+B | Bold |
| (0,1) | 1.75 | left | F9 | Toggle breakpoint |
| (1,1) | 1.00 | left | n | Find next match |
| (3,1) | 1.00 | left | UpArrow | Up arrow |
| (4,1) | 1.00 | left | Ctrl+Space | Select entire column |
| (5,1) | 1.75 | left | Ctrl+Shift+C | Inspect element |
| (7,1) | 1.75 | right | o | Open URL/bookmark/history |
| (8,1) | 1.00 | right | Win+I | Settings |
| (10,1) | 1.00 | right | Ctrl+Page Up | Previous sheet |
| (11,1) | 1.00 | right | Alt+Home | Open home page |
| (12,1) | 1.75 | right | Win+; | Emoji picker |
| (0,2) | 1.25 | left | Alt+Shift+Up | Previous unread |
| (2,2) | 0.00 | left | Alt+F12 | Peek definition |
| (3,2) | 0.00 | left | Ctrl+2 | Chat |
| (4,2) | 0.00 | left | Win+D | Show/hide desktop |
| (5,2) | 1.25 | left | LeftArrow | Left arrow |
| (7,2) | 1.25 | right | Alt+Click | Add cursor at position |
| (9,2) | 0.00 | right | Ctrl+Shift+$ | Currency format |
| (10,2) | 0.00 | right | F12 | Open DevTools |
| (11,2) | 0.00 | right | F3 | Find next (alt) |
| (12,2) | 1.25 | right | Ctrl+Shift+N | Incognito/InPrivate window |
| (0,3) | 1.75 | left | Shift+F3 | Find previous |
| (3,3) | 1.00 | left | F4 | Toggle absolute ref ($) |
| (4,3) | 1.00 | left | / | Enter find mode |
| (7,3) | 1.75 | right | F10 | Step over |
| (8,3) | 1.00 | right | Ctrl+Shift+2 | Large icons |
| (9,3) | 1.00 | right | Shift+Delete | Permanent delete |
| (10,3) | 1.00 | right | Ctrl+Shift+P | Toggle chat in meeting |
| (11,3) | 1.00 | right | Shift+Alt+Down | Copy line down |
| (12,3) | 1.75 | right | Ctrl+Shift+U | Mark as unread |
| (3,4) | 1.00 | left | Ctrl+Left | Jump to left edge of data |
| (4,4) | 0.00 | left | Ctrl+C | Copy |
| (4,5) | 1.00 | left | Ctrl+Shift+T | Reopen closed tab |

## Layer 4

**Shortcuts:** 50 | **Avg effort:** 2.02 | **Hand balance:** 27/23

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (0,0) | 2.75 | left | Ctrl+Shift+Enter | Insert line above |
| (1,0) | 2.00 | left | Win+P | Project / display mode |
| (2,0) | 2.00 | left | Ctrl+Z | Undo |
| (3,0) | 2.00 | left | RightArrow | Right arrow |
| (4,0) | 2.00 | left | Win+2 | Open/switch pinned app 2 |
| (7,0) | 2.75 | right | L | Go forward in history |
| (8,0) | 2.00 | right | Ctrl+Shift+Q | New meeting |
| (10,0) | 2.00 | right | MB3 | Middle click |
| (11,0) | 2.00 | right | Ctrl+Shift+G | Find previous |
| (12,0) | 2.75 | right | Ctrl+Shift++ | Insert cells/rows/columns |
| (0,1) | 1.75 | left | Down | Next command |
| (1,1) | 1.00 | left | Ctrl+Shift+O | Toggle camera |
| (2,1) | 1.00 | left | Ctrl+Alt+Down | Add cursor below |
| (3,1) | 1.00 | left | Ctrl+Shift+Left | Select to left edge |
| (4,1) | 1.00 | left | Ctrl++ | Zoom in |
| (5,1) | 1.75 | left | ScrollUp | Scroll up |
| (7,1) | 1.75 | right | Ctrl+Shift+Up | Select to top edge |
| (8,1) | 1.00 | right | Win+Ctrl+Left | Switch desktop left |
| (10,1) | 1.00 | right | Ctrl+Shift+~ | General format |
| (11,1) | 1.00 | right | Ctrl+` | Toggle terminal |
| (12,1) | 1.75 | right | Win+Pause | System info |
| (0,2) | 1.25 | left | Ctrl+Shift+D | Decline call |
| (1,2) | 0.00 | left | Win+N | Notification center |
| (2,2) | 0.00 | left | Ctrl+K Ctrl+W | Close all editors |
| (3,2) | 0.00 | left | Win+B | Focus system tray |
| (4,2) | 0.00 | left | Ctrl+K Ctrl+S | Keyboard shortcuts |
| (5,2) | 1.25 | left | H | Go back in history |
| (8,2) | 0.00 | right | Backspace | Go back / up |
| (9,2) | 0.00 | right | Ctrl+Shift+\ | Jump to matching bracket |
| (10,2) | 0.00 | right | Ctrl+Shift+L | Toggle sidebar |
| (11,2) | 0.00 | right | Ctrl+I | Italic |
| (12,2) | 1.25 | right | Alt+Tab | Switch apps |
| (0,3) | 1.75 | left | Ctrl+Shift+J | Open Console |
| (1,3) | 1.00 | left | Win+K | Connect / Cast |
| (2,3) | 1.00 | left | Ctrl+U | Underline |
| (3,3) | 1.00 | left | MB4 | Back button |
| (4,3) | 1.00 | left | k | Scroll up |
| (5,3) | 1.75 | left | Ctrl+Shift+B | Toggle background blur |
| (7,3) | 1.75 | right | Ctrl+End | Go to last used cell |
| (8,3) | 1.00 | right | Ctrl+S | Save page as |
| (9,3) | 1.00 | right | Ctrl+Shift+Tab | Previous tab |
| (10,3) | 1.00 | right | Ctrl+Shift+End | Select to last used cell |
| (11,3) | 1.00 | right | Ctrl+Shift+R | Start recording |
| (12,3) | 1.75 | right | Ctrl+Shift+H | Hang up / end call |
| (3,4) | 1.00 | left | Ctrl+Shift+X | Expand compose box |
| (4,4) | 0.00 | left | Ctrl+N | New chat |
| (7,4) | 1.00 | right | Alt+Down | Move line down |
| (8,4) | 0.00 | right | Ctrl+Shift+F5 | Restart debugging |
| (4,5) | 1.00 | left | Ctrl+V | Paste |
| (5,5) | 1.50 | left | Win+Home | Minimize all except active |

## Layer 5

**Shortcuts:** 29 | **Avg effort:** 1.67 | **Hand balance:** 19/10

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (2,0) | 2.00 | left | W | White screen |
| (4,0) | 2.00 | left | Alt+Shift+Down | Next unread |
| (7,0) | 2.75 | right | Ctrl+Shift+A | Accept call |
| (8,0) | 2.00 | right | Ctrl+. | Show commands |
| (9,0) | 2.00 | right | Ctrl+Shift+< | Decrease font size |
| (10,0) | 2.00 | right | Win+A | Quick settings / Action center |
| (0,1) | 1.75 | left | Ctrl+Shift+K | Raise/lower hand |
| (1,1) | 1.00 | left | Escape | Close / go back |
| (2,1) | 1.00 | left | Ctrl+4 | Calendar |
| (3,1) | 1.00 | left | Ctrl+Shift+6 | Toggle details pane |
| (4,1) | 1.00 | left | Ctrl+1 | Activity |
| (5,1) | 1.75 | left | Ctrl+Shift+` | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+`. |
| (9,1) | 1.00 | right | Ctrl+W | Evolved (evo_best_gen150): Sends L Ctrl+W. |
| (10,1) | 1.00 | right | f1 | Evolved (evo_best_gen150): Sends F1. |
| (11,1) | 1.00 | right | backslash | Evolved (evo_best_gen150): Sends |. |
| (0,2) | 1.25 | left | Ctrl+N | Evolved (evo_best_gen150): Sends L Ctrl+N. |
| (1,2) | 0.00 | left | Save | v2.2: Code/IDE — Save. |
| (2,2) | 0.00 | left | Ctrl+J | Evolved (evo_best_gen150): Sends L Ctrl+J. |
| (3,2) | 0.00 | left | Sett | v2.2: Code/IDE — Settings. |
| (4,2) | 0.00 | left | DelLn | v2.2: Code/IDE — Delete line. |
| (5,2) | 1.25 | left | Ctrl+Shift+S | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+S. |
| (9,2) | 0.00 | right | Ctrl+L | Evolved (evo_best_gen150): Sends L Ctrl+L. |
| (11,2) | 0.00 | right | coach_travel_toggle | Evolved (evo_best_gen150): coach_travel_toggle |
| (1,3) | 1.00 | left | PstNF | v2.2: Code/IDE — Paste no formatting. |
| (3,3) | 1.00 | left | NTerm | v2.2: Code/IDE — New terminal. |
| (4,3) | 1.00 | left | Ext | v2.2: Code/IDE — Extensions panel. |
| (5,3) | 1.75 | left | f8 | Evolved (evo_best_gen150): Sends F8. |
| (10,3) | 1.00 | right | keypad 3 | Evolved (evo_best_gen150): Sends Keypad 3 and PageDn. |
| (3,4) | 1.00 | left | Base | Exit Code layer to base. |

## Layer 6

**Shortcuts:** 28 | **Avg effort:** 1.36 | **Hand balance:** 15/13

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (3,0) | 2.00 | left | Alt+= | Evolved (evo_best_gen150): Sends L Alt+=. |
| (4,0) | 2.00 | left | Ctrl+Left | Evolved (evo_best_gen150): Sends L Ctrl+LeftArrow. |
| (8,0) | 2.00 | right | Ctrl+Q | Evolved (evo_best_gen150): Sends L Ctrl+Q. |
| (2,1) | 1.00 | left | Ctrl+Space | Evolved (evo_best_gen150): Sends L Ctrl+Space. |
| (3,1) | 1.00 | left | F10 | Evolved (evo_best_gen150): Sends F10. |
| (4,1) | 1.00 | left | Win+Shift+Left | Evolved (evo_best_gen150): Sends L GUI+L Shift+LeftArrow. |
| (5,1) | 1.75 | left | Ctrl+Right | Evolved (evo_best_gen150): Sends L Ctrl+RightArrow. |
| (7,1) | 1.75 | right | Ctrl+Shift+R | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+R. |
| (8,1) | 1.00 | right | Alt+Right | Evolved (evo_best_gen150): Sends L Alt+RightArrow. |
| (9,1) | 1.00 | right | Ctrl+5 | Evolved (evo_best_gen150): Sends L Ctrl+5. |
| (10,1) | 1.00 | right | Ctrl+Shift+Left | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+LeftArrow. |
| (1,2) | 0.00 | left | Ctrl+Shift+Down | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+DownArrow. |
| (2,2) | 0.00 | left | F9 | Evolved (evo_best_gen150): Sends F9. |
| (4,2) | 0.00 | left | Ctrl+3 | Evolved (evo_best_gen150): Sends L Ctrl+3. |
| (5,2) | 1.25 | left | Win+Space | Evolved (evo_best_gen150): Sends L GUI+Space. |
| (8,2) | 0.00 | right | Ctrl+4 | Evolved (evo_best_gen150): Sends L Ctrl+4. |
| (9,2) | 0.00 | right | F5 | Evolved (evo_best_gen150): Sends F5. |
| (10,2) | 0.00 | right | Ctrl+Alt+Down | Evolved (evo_best_gen150): Sends L Ctrl+L Alt+DownArrow. |
| (11,2) | 0.00 | right | Ctrl+Shift+Up | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+UpArrow. |
| (2,3) | 1.00 | left | Ctrl+Shift++ | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+=. |
| (3,3) | 1.00 | left | Shift+F11 | Evolved (evo_best_gen150): Sends L Shift+F11. |
| (4,3) | 1.00 | left | Win+Shift+Right | Evolved (evo_best_gen150): Sends L GUI+L Shift+RightArrow. |
| (5,3) | 1.75 | left | F4 | Evolved (evo_best_gen150): Sends F4. |
| (7,3) | 1.75 | right | Ctrl+Shift+I | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+I. |
| (8,3) | 1.00 | right | Ctrl+Shift+T | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+T. |
| (9,3) | 1.00 | right | Ctrl+6 | Evolved (evo_best_gen150): Sends L Ctrl+6. |
| (10,3) | 1.00 | right | Ctrl+Shift+Right | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+RightArrow. |
| (4,4) | 0.00 | left | Ctrl+0 | Evolved (evo_best_gen150): Sends L Ctrl+0. |

## Layer 8

**Shortcuts:** 24 | **Avg effort:** 1.69 | **Hand balance:** 12/12

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (4,0) | 2.00 | left | escape | Evolved (evo_best_gen150): Sends Escape. |
| (8,0) | 2.00 | right | Shift+Space | Evolved (evo_best_gen150): Sends L Shift+Space. |
| (2,1) | 1.00 | left | F11 | Evolved (evo_best_gen150): Sends F11. |
| (3,1) | 1.00 | left | Ctrl+Shift+S | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+S. |
| (4,1) | 1.00 | left | home | Evolved (evo_best_gen150): Sends Home. |
| (5,1) | 1.75 | left | Win+Ctrl+Right | Evolved (evo_best_gen150): Sends L GUI+L Ctrl+RightArrow. |
| (7,1) | 1.75 | right | Ctrl+Shift+Esc | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+Escape. |
| (8,1) | 1.00 | right | Ctrl+Shift+Z | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+Z. |
| (9,1) | 1.00 | right | Ctrl+- | Evolved (evo_best_gen150): Sends L Ctrl+_. |
| (2,2) | 0.00 | left | Ctrl+Shift+F6 | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+F6. |
| (4,2) | 0.00 | left | left gui | Evolved (evo_best_gen150): Sends LeftGUI. |
| (7,2) | 1.25 | right | Ctrl+Shift+` | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+`. |
| (8,2) | 0.00 | right | Alt+F4 | Evolved (evo_best_gen150): Sends L Alt+F4. |
| (9,2) | 0.00 | right | Alt+Down | Evolved (evo_best_gen150): Sends L Alt+DownArrow. |
| (10,2) | 0.00 | right | Ctrl+. | Evolved (evo_best_gen150): Sends L Ctrl+>. |
| (3,3) | 1.00 | left | Ctrl+Shift+B | Evolved (evo_best_gen150): Sends L Ctrl+L Shift+B. |
| (4,3) | 1.00 | left | tab | Evolved (evo_best_gen150): Sends Tab. |
| (5,3) | 1.75 | left | Win+. | Evolved (evo_best_gen150): Sends L GUI+>. |
| (7,3) | 1.75 | right | Win+; | Evolved (evo_best_gen150): Sends L GUI+:. |
| (8,3) | 1.00 | right | Alt+Up | Evolved (evo_best_gen150): Sends L Alt+UpArrow. |
| (9,3) | 1.00 | right | Ctrl+Home | Evolved (evo_best_gen150): Sends L Ctrl+Home. |
| (7,4) | 1.00 | right | Exit Travel | Right-thumb exit from speed/travel overlay. Must use coach_t |
| (4,5) | 1.00 | left | Delete | Evolved (evo_best_gen150): Sends Delete. |
| (5,5) | 1.50 | left | F10 | Evolved (evo_best_gen150): Sends F10. |

## Layer 9

**Shortcuts:** 26 | **Avg effort:** 1.46 | **Hand balance:** 16/10

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (4,0) | 2.00 | left | yy | Copy current URL |
| (8,0) | 2.00 | right | Ctrl+Up | Evolved (evo_best_gen150): Sends L Ctrl+UpArrow. |
| (0,1) | 1.75 | left | f2 | Evolved (evo_best_gen150): Sends F2. |
| (1,1) | 1.00 | left | WfSt | v2.2: M-Files — Change workflow state. |
| (2,1) | 1.00 | left | Asgn | v2.2: M-Files — Assign to user. |
| (4,1) | 1.00 | left | Fav | v2.2: M-Files — Add to favorites. |
| (5,1) | 1.75 | left | List | v2.2: M-Files — List view. |
| (7,1) | 1.75 | right | Print | v2.2: M-Files — Print. |
| (8,1) | 1.00 | right | Shift+Alt+Down | Evolved (evo_best_gen150): Sends L Shift+L Alt+DownArrow. |
| (0,2) | 1.25 | left | pageup | Evolved (evo_best_gen150): Sends Keypad 9 and PageUp. |
| (1,2) | 0.00 | left | Save | v2.2: M-Files — Save. |
| (2,2) | 0.00 | left | ChkIn | v2.2: M-Files — Check in. |
| (4,2) | 0.00 | left | Win+Tab | Evolved (evo_best_gen150): Sends L GUI+Tab. |
| (5,2) | 1.25 | left | Icon | v2.2: M-Files — Icon view. |
| (8,2) | 0.00 | right | leftshift | Evolved (evo_best_gen150): Sends LeftShift. |
| (10,2) | 0.00 | right | Hist | v2.2: M-Files — Version history. |
| (11,2) | 0.00 | right | Rel | v2.2: M-Files — Add relationship. |
| (12,2) | 1.25 | right | UndCO | v2.2: M-Files — Undo checkout. |
| (1,3) | 1.00 | left | DLoad | v2.2: M-Files — Download copy. |
| (2,3) | 1.00 | left | Open | v2.2: M-Files — Open document. |
| (3,3) | 1.00 | left | CpLnk | v2.2: M-Files — Copy object link. |
| (4,3) | 1.00 | left | Notif | v2.2: M-Files — Send notification. |
| (5,3) | 1.75 | left | Group | v2.2: M-Files — Group by. |
| (7,3) | 1.75 | right | Vault | v2.2: M-Files — Go to vault. |
| (8,3) | 1.00 | right | rightarrow_combo | Evolved (evo_best_gen150): Sends RightArrow. |
| (9,3) | 1.00 | right | Ctrl+Down | Evolved (evo_best_gen150): Sends L Ctrl+DownArrow. |

## Layer 10

**Shortcuts:** 38 | **Avg effort:** 1.91 | **Hand balance:** 21/17

| (x,y) | Effort | Hand | Shortcut | Purpose |
|-------|--------|------|----------|---------|
| (0,0) | 2.75 | left | ShftEnt | Confirm and move up (Shift+Enter). |
| (1,0) | 2.00 | left | SelAll | Select all / current region (Ctrl+A). |
| (2,0) | 2.00 | left | Copy | Copy (Ctrl+C). |
| (3,0) | 2.00 | left | Cut | Cut (Ctrl+X). |
| (4,0) | 2.00 | left | AutoSum | AutoSum (Alt+=). |
| (10,0) | 2.00 | right | Ctrl+Dn | Jump to bottom edge of data region. |
| (12,0) | 2.75 | right | Win+C | Evolved (evo_best_gen150): Sends L GUI+C. |
| (0,1) | 1.75 | left | ShftTab | Move to previous cell (Shift+Tab). |
| (1,1) | 1.00 | left | Sel← | Select to left edge of data. |
| (3,1) | 1.00 | left | Sel↑ | Select to top edge of data. |
| (5,1) | 1.75 | left | InsTime | Insert current time (Ctrl+Shift+;). |
| (8,1) | 1.00 | right | coach_mouse_lock | Evolved (evo_best_gen150): coach_mouse_lock |
| (10,1) | 1.00 | right | SelHome | Select to cell A1 (Ctrl+Shift+Home). |
| (11,1) | 1.00 | right | Win+B | Evolved (evo_best_gen150): Sends L GUI+B. |
| (12,1) | 1.75 | right | coach_game_lock | Evolved (evo_best_gen150): coach_game_lock |
| (0,2) | 1.25 | left | Find | Find (Ctrl+F). |
| (1,2) | 0.00 | left | SelCol | Select entire column (Ctrl+Space). |
| (2,2) | 0.00 | left | F4 $Ref | Toggle absolute reference ($) in formulas. |
| (4,2) | 0.00 | left | SelEnd | Select to last used cell (Ctrl+Shift+End). |
| (7,2) | 1.25 | right | Win+L | Evolved (evo_best_gen150): Sends L GUI+L. |
| (8,2) | 0.00 | right | Paste | Paste (Ctrl+V). |
| (9,2) | 0.00 | right | NextSht | Next sheet tab (Ctrl+Page Down). |
| (10,2) | 0.00 | right | Undo | Undo (Ctrl+Z). |
| (11,2) | 0.00 | right | Win+2 | Evolved (evo_best_gen150): Sends L GUI+2. |
| (12,2) | 1.25 | right | Win+N | Evolved (evo_best_gen150): Sends L GUI+N. |
| (0,3) | 1.75 | left | HideRow | Hide selected rows (Ctrl+9). |
| (1,3) | 1.00 | left | Replace | Find and replace (Ctrl+H). |
| (2,3) | 1.00 | left | Delete | Delete cells/rows/columns (Ctrl+-). |
| (3,3) | 1.00 | left | NumFmt | Number format (Ctrl+Shift+!). |
| (4,3) | 1.00 | left | Ctrl+Alt+Up | Evolved (evo_best_gen150): Sends L Ctrl+L Alt+UpArrow. |
| (5,3) | 1.75 | left | Ctrl+Page Down | Evolved (evo_best_gen150): Sends L Ctrl+PageDown. |
| (8,3) | 1.00 | right | Win+E | Evolved (evo_best_gen150): Sends L GUI+E. |
| (10,3) | 1.00 | right | grave accent_combo | Evolved (evo_best_gen150): Sends `. |
| (11,3) | 1.00 | right | Win+Left | Evolved (evo_best_gen150): Sends L GUI+LeftArrow. |
| (3,4) | 1.00 | left | Base | Exit Excel layer to base. |
| (4,4) | 0.00 | left | f13 | Evolved (evo_best_gen150): Sends F13. |
| (7,4) | 1.00 | right | Win+T | Evolved (evo_best_gen150): Sends L GUI+T. |
| (7,5) | 1.50 | right | Win+Ctrl+D | Evolved (evo_best_gen150): Sends L GUI+L Ctrl+D. |

## Arrow Key Placement Verification

| Key | Layer | (x,y) | Effort | Notes |
|-----|-------|-------|--------|-------|
| LeftArrow | L3 | (5,2) | 1.25 | FOUND OK |
| RightArrow | L4 | (3,0) | 2.00 | FOUND OK |
| UpArrow | L3 | (3,1) | 1.00 | FOUND OK |
| DownArrow | L1 | (5,0) | 2.75 | FOUND OK |

**Grouping:** Arrows split across layers {1, 3, 4} FAIL
**LeftArrow x=5 < RightArrow x=3:** FAIL
**UpArrow between Left/Right:** OK
**DownArrow between Left/Right:** OK

## Mouse Button Placement Verification

| Button | Layer | (x,y) | Hand | Effort | Notes |
|--------|-------|-------|------|--------|-------|
| MB1 | L2 | (3,3) | left | 1.0 | FAIL Left (5x penalty!) |
| MB2 | L3 | (3,0) | left | 3.5 | FAIL Left (5x penalty!) |
| MB3 | L4 | (10,0) | right | 3.5 | OK Right |
| MB4 | L4 | (3,3) | left | 1.0 | FAIL Left (5x penalty!) |
| MB5 | - | - | - | - | NOT FOUND FAIL |

**Right-hand mouse buttons:** 1/5 (20%)
**Missing/left-hand buttons:** 4

## Scroll Key Placement Verification

| Key | Layer | (x,y) | Hand | Effort | Notes |
|-----|-------|-------|------|--------|-------|
| ScrollUp | L4 | (5,1) | left | 3.0 | FAIL |
| ScrollDown | - | - | - | - | NOT FOUND FAIL |

## Synthetic Mouse Layer Analysis

**Core question:** Does the evolved layout support a usable synthetic mouse layer for one-handed right-hand operation?

### 1. Mouse Button Accessibility

- MB1-MB5 present: FAIL (4/5)
- All on right hand: FAIL

### 2. Cursor Navigation (Arrow Keys)

- All arrows on same layer: FAIL
- LeftArrow left of RightArrow: FAIL
- Up/Down between Left/Right: see Arrow section above

### 3. Scroll Access

- ScrollUp/ScrollDown present: FAIL (1/2)

### 4. Overall Mouse Layer Score

- MB1-5 on right hand: FAIL (5x weighted)
- Arrows grouped: FAIL (group_split=200)
- Arrows ordered: FAIL (arrow_order=100)
- Scroll on right: FAIL (preferred_hand=right)
- Consolidated layer: FAIL (workflow_coherence)

**Overall synthetic mouse layer score: 0%**

---

## Code Status Check

The following new constraint files were found but NOT wired into the evaluator:

- `fitness/factors/hand_bias.py` - exists but NOT imported in `evaluator.py`
- `fitness/factors/violation.py` - has `_arrow_order` but NOT called in `evaluator.py`
- No `mouse_layer_access` factor found in codebase

The `evaluator.py` only imports these 9 factors:
```
EffortFactor, AdjacencyFactor, FingerBalanceFactor, SameFingerFactor,
ViolationFactor, WorkflowCoherenceFactor, LearningCurveFactor,
AppCoherenceFactor, TrackballProximityFactor
```

To activate the new constraints, the evaluator must be updated to import and call HandBiasFactor, and the arrow_order must be integrated into the ViolationFactor's compute method or added as a separate factor.

## Recommendations

1. **Wire hand_bias into evaluator.py** - add `from fitness.factors.hand_bias import HandBiasFactor` and include it in `_build_factors()` and `evaluate()`
2. **Wire arrow_order into evaluator.py** - either add it as a separate factor or integrate it into ViolationFactor
3. **Add mouse_layer_access factor** - create a new factor that penalizes mouse buttons being split across layers
4. **Restart with wired constraints** - the current layout is from unconstrained random evolution
