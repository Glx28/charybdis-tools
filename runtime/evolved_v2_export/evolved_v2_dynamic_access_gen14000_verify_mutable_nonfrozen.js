/*
Mutable/non-frozen verifier for evolved-v2.
Generated from:
  /home/nos/charybdis/charybdis-tools/runtime/evolved_v2_export/evolved_v2_dynamic_access_gen14000_apply.js

Paste this whole file into the ZMK Studio browser console after connecting the keyboard.
It verifies optimizer-changed keys only, skipping layer 7 and frozen/canonical keys.
It does not modify anything. Mismatches are collected and printed at the end.
*/

window.CHARYBDIS_VERIFY_MUTABLE_EXPECTED = [
  {
    "layer": 0,
    "x": 5,
    "y": 4,
    "behavior": "coach_l3_hold",
    "parameter": "",
    "modifiers": [],
    "label": "Window",
    "rationale": "evolved: Dynamic layer access: @access:L0->L3:hold:Window",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 4,
    "y": 5,
    "behavior": "Toggle Layer",
    "parameter": "Layer::6",
    "modifiers": [],
    "label": "Scroll",
    "rationale": "evolved: Dynamic layer access: @access:L2->L6:toggle:Scroll",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 5,
    "y": 5,
    "behavior": "coach_l2_hold",
    "parameter": "",
    "modifiers": [],
    "label": "Mouse",
    "rationale": "evolved: Dynamic layer access: @access:L0->L2:hold:Mouse",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 4 and Dollar",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+$",
    "rationale": "evolved: Currency format",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+G",
    "rationale": "evolved: Go to...",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+N",
    "rationale": "evolved: Notification center",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Down",
    "rationale": "evolved: Jump to bottom edge of data",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard F2",
    "modifiers": [],
    "label": "F2",
    "rationale": "evolved: Rename",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 12,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+P",
    "rationale": "evolved: Print",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 0,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [],
    "label": "F5",
    "rationale": "evolved: Refresh page",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+N",
    "rationale": "evolved: Notification center",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Up",
    "rationale": "evolved: Move line up",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Space",
    "rationale": "evolved: Select entire column",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+E",
    "rationale": "evolved: Search / command bar",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Grave Accent and Tilde",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+~",
    "rationale": "evolved: General format",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard U",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+U",
    "rationale": "evolved: Underline",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+A",
    "rationale": "evolved: Accept call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Down",
    "rationale": "evolved: Jump to bottom edge of data",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+V",
    "rationale": "evolved: Paste without formatting",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+V",
    "rationale": "evolved: Clipboard history",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+A",
    "rationale": "evolved: Accept call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+L",
    "rationale": "evolved: Focus address bar",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F5",
    "rationale": "evolved: Hard refresh (bypass cache)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl++",
    "rationale": "evolved: Zoom in",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard U",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+U",
    "rationale": "evolved: Underline",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 12,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+D",
    "rationale": "evolved: Show/hide desktop",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 0,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+<",
    "rationale": "evolved: Decrease font size",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Left",
    "rationale": "evolved: Jump to left edge of data",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+T",
    "rationale": "evolved: Cycle taskbar apps",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Z",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Z",
    "rationale": "evolved: Undo",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Z",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Z",
    "rationale": "evolved: Redo",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+N",
    "rationale": "evolved: New chat",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+D",
    "rationale": "evolved: Decline call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 5 and Percent",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+5",
    "rationale": "evolved: Calls",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 0 and Right Bracket",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+0",
    "rationale": "evolved: Reset zoom",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 12,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Right Brace",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+]",
    "rationale": "evolved: Indent line",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F4",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+F4",
    "rationale": "evolved: Close window",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Backslash and Pipe",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+\\",
    "rationale": "evolved: Split editor",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+X",
    "rationale": "evolved: Power User menu",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 4,
    "behavior": "coach_travel_toggle",
    "parameter": "",
    "modifiers": [],
    "label": "coach_travel_toggle",
    "rationale": "evolved: Dynamic layer access: @access:L5->L8:toggle:coach_travel_toggle",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+A",
    "rationale": "evolved: Accept call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 5,
    "behavior": "coach_travel_toggle",
    "parameter": "",
    "modifiers": [],
    "label": "coach_travel_toggle",
    "rationale": "evolved: Dynamic layer access: @access:L2->L8:toggle:coach_travel_toggle",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+P",
    "rationale": "evolved: Toggle chat in meeting",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard End",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+End",
    "rationale": "evolved: Select to last used cell",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+;",
    "rationale": "evolved: Insert current time",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F",
    "rationale": "evolved: Find in conversation",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard U",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+U",
    "rationale": "evolved: Mark as unread",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 12,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+E",
    "rationale": "evolved: Toggle screen share",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 0,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+E",
    "rationale": "evolved: File Explorer",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+Left",
    "rationale": "evolved: Shrink selection",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Tab",
    "rationale": "evolved: Outdent",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F8",
    "modifiers": [],
    "label": "F8",
    "rationale": "evolved: Go to next problem",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L GUI",
      "L Shift"
    ],
    "label": "Win+Shift+Right",
    "rationale": "evolved: Move to right monitor",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Left",
    "rationale": "evolved: Select to left edge",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F11",
    "modifiers": [],
    "label": "F11",
    "rationale": "evolved: Toggle fullscreen",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+!",
    "rationale": "evolved: Number format",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 1,
    "behavior": "Mouse Key Press",
    "parameter": "MB2",
    "modifiers": [],
    "label": "MB2",
    "rationale": "evolved: Right click",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 1,
    "behavior": "Mouse Key Press",
    "parameter": "MB1",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Click",
    "rationale": "evolved: Select non-adjacent cells",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 0,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+V",
    "rationale": "evolved: Paste without formatting",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F11",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F11",
    "rationale": "evolved: Step out",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F9",
    "modifiers": [],
    "label": "F9",
    "rationale": "evolved: Toggle breakpoint",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+I",
    "rationale": "evolved: Settings",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift++",
    "rationale": "evolved: Insert cells/rows/columns",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard M",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+M",
    "rationale": "evolved: Minimize all windows",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 3 and Hash",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+3",
    "rationale": "evolved: Teams/channels",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+2",
    "rationale": "evolved: Chat",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F",
    "rationale": "evolved: Find in conversation",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+2",
    "rationale": "evolved: Chat",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+Up",
    "rationale": "evolved: Copy line up",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F2",
    "modifiers": [],
    "label": "F2",
    "rationale": "evolved: Rename",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Space",
    "rationale": "evolved: Switch input language",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Tab",
    "rationale": "evolved: Switch apps",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F6",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F6",
    "rationale": "evolved: Previous section",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard PageDown",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Page Down",
    "rationale": "evolved: Next sheet",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+V",
    "rationale": "evolved: Paste",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 12,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+N",
    "rationale": "evolved: Incognito/InPrivate window",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+S",
    "rationale": "evolved: Attach file",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Left",
    "rationale": "evolved: Snap window left",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 4,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "coach_base",
    "rationale": "evolved: Dynamic layer access: @access:L2->L0:toggle:coach_base",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+S",
    "rationale": "evolved: Attach file",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+C",
    "rationale": "evolved: Copy",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 5,
    "behavior": "coach_game_lock",
    "parameter": "",
    "modifiers": [],
    "label": "coach_game_lock",
    "rationale": "evolved: Dynamic layer access: @access:L1->L7:toggle:coach_game_lock",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [],
    "label": "F5",
    "rationale": "evolved: Refresh page",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 2,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+1",
    "rationale": "evolved: Extra large icons",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+,",
    "rationale": "evolved: Open settings",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+A",
    "rationale": "evolved: Quick settings / Action center",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+P",
    "rationale": "evolved: Print",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard PageUp",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Page Up",
    "rationale": "evolved: Previous sheet",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+H",
    "rationale": "evolved: Hang up / end call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 9,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 9 and Left Bracket",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+9",
    "rationale": "evolved: Last tab",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 10,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+E",
    "rationale": "evolved: Toggle screen share",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 11,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Q",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Q",
    "rationale": "evolved: New meeting",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 0,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Q",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Q",
    "rationale": "evolved: Mark as read",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+C",
    "rationale": "evolved: Inspect element",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard W",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+W",
    "rationale": "evolved: Close tab",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F11",
    "modifiers": [],
    "label": "F11",
    "rationale": "evolved: Toggle fullscreen",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Alt",
      "L Shift"
    ],
    "label": "Alt+Shift+Down",
    "rationale": "evolved: Next unread",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F7",
    "modifiers": [],
    "label": "F7",
    "rationale": "evolved: Spell check",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+I",
    "rationale": "evolved: Open DevTools (alt)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+C",
    "rationale": "evolved: Inspect element",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+;",
    "rationale": "evolved: Insert current date",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 0,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+D",
    "rationale": "evolved: New virtual desktop",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+I",
    "rationale": "evolved: Italic",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard O",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+O",
    "rationale": "evolved: Open file",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [],
    "label": "F5",
    "rationale": "evolved: Refresh page",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 4 and Dollar",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+4",
    "rationale": "evolved: Open/switch pinned app 4",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+2",
    "rationale": "evolved: Open/switch pinned app 2",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+.",
    "rationale": "evolved: Show commands",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+V",
    "rationale": "evolved: Paste without formatting",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Backslash and Pipe",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+\\",
    "rationale": "evolved: Split editor",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+Down",
    "rationale": "evolved: Copy line down",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F8",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F8",
    "rationale": "evolved: Go to previous problem",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+D",
    "rationale": "evolved: New virtual desktop",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L GUI",
      "L Shift"
    ],
    "label": "Win+Shift+S",
    "rationale": "evolved: Screenshot (Snip)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard O",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+O",
    "rationale": "evolved: Toggle camera",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard M",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+M",
    "rationale": "evolved: Toggle mute",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F6",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+F6",
    "rationale": "evolved: Next section",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [],
    "label": "UpArrow",
    "rationale": "evolved: Up arrow",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 12,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard J",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+J",
    "rationale": "evolved: Downloads",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+F5",
    "rationale": "evolved: Restart debugging",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+H",
    "rationale": "evolved: History",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 4,
    "behavior": "Toggle Layer",
    "parameter": "Layer::5",
    "modifiers": [],
    "label": "Code",
    "rationale": "evolved: Dynamic layer access: @access:L1->L5:toggle:Code",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+F",
    "rationale": "evolved: Format text",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 4,
    "behavior": "Toggle Layer",
    "parameter": "Layer::9",
    "modifiers": [],
    "label": "DMS",
    "rationale": "evolved: Dynamic layer access: @access:L4->L9:toggle:DMS",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard 5 and Percent",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+%",
    "rationale": "evolved: Percent format",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 0,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+B",
    "rationale": "evolved: Focus system tray",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 1,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Down",
    "rationale": "evolved: Jump to bottom edge of data",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+H",
    "rationale": "evolved: Hang up / end call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F5",
    "rationale": "evolved: Stop debugging",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Left Brace",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+[",
    "rationale": "evolved: Outdent line",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 9,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [],
    "label": "LeftArrow",
    "rationale": "evolved: Left arrow",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 10,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [],
    "label": "DownArrow",
    "rationale": "evolved: Down arrow",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 11,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+H",
    "rationale": "evolved: Hang up / end call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 12,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Tab",
    "rationale": "evolved: Previous tab",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 0,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+1",
    "rationale": "evolved: Activity",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 1,
    "y": 1,
    "behavior": "Mouse Key Press",
    "parameter": "MB1",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Click",
    "rationale": "evolved: Add cursor at position",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+G",
    "rationale": "evolved: Go to...",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "Page"
    ],
    "label": "Page Down",
    "rationale": "evolved: Next slide",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+1",
    "rationale": "evolved: Activity",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Up",
    "rationale": "evolved: Select to top edge",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+=",
    "rationale": "evolved: AutoSum",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 12,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+H",
    "rationale": "evolved: Hang up / end call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 0,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Q",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Q",
    "rationale": "evolved: New meeting",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+B",
    "rationale": "evolved: Focus system tray",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 5 and Percent",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+5",
    "rationale": "evolved: Open/switch pinned app 5",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+.",
    "rationale": "evolved: Emoji picker",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+E",
    "rationale": "evolved: Toggle screen share",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Escape",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Esc",
    "rationale": "evolved: Task Manager",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+G",
    "rationale": "evolved: Go to...",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Home",
    "rationale": "evolved: Go to cell A1",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F3",
    "modifiers": [],
    "label": "F3",
    "rationale": "evolved: Find next (alt)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F12",
    "modifiers": [],
    "label": "F12",
    "rationale": "evolved: Open DevTools",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Home",
    "rationale": "evolved: Open home page",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 12,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+E",
    "rationale": "evolved: Toggle screen share",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+>",
    "rationale": "evolved: Increase font size",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+Right",
    "rationale": "evolved: Switch desktop right",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Down",
    "rationale": "evolved: Minimize / restore",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F10",
    "modifiers": [],
    "label": "F10",
    "rationale": "evolved: Step over",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 3,
    "behavior": "coach_travel_toggle",
    "parameter": "",
    "modifiers": [],
    "label": "Speed",
    "rationale": "evolved: Dynamic layer access: @access:L1->L8:toggle:Speed",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+B",
    "rationale": "evolved: Bold",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+G",
    "rationale": "evolved: Find previous",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+E",
    "rationale": "evolved: Toggle screen share",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard 6 and Caret",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+6",
    "rationale": "evolved: Files",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftShift",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Shift",
    "rationale": "evolved: Switch keyboard layout (alt)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 4,
    "behavior": "coach_mouse_lock",
    "parameter": "",
    "modifiers": [],
    "label": "coach_mouse_lock",
    "rationale": "evolved: Dynamic layer access: @access:L10->L2:toggle:coach_mouse_lock",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Enter",
    "rationale": "evolved: Send (expanded mode)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 5,
    "behavior": "Momentary Layer",
    "parameter": "Layer::8",
    "modifiers": [],
    "label": "Speed",
    "rationale": "evolved: Dynamic layer access: @access:L2->L8:hold:Speed",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 1,
    "y": 0,
    "behavior": "Mouse Key Press",
    "parameter": "MB1",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Click",
    "rationale": "evolved: Select range",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Right Brace",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+]",
    "rationale": "evolved: Indent line",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 12,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+G",
    "rationale": "evolved: Go to...",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Enter",
    "rationale": "evolved: Insert line above",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Right",
    "rationale": "evolved: Select to right edge",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard W",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+W",
    "rationale": "evolved: Close tab",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard ForwardSlash and QuestionMark",
    "modifiers": [],
    "label": "?",
    "rationale": "evolved: Show Vimium help",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard W",
    "modifiers": [
      "L Ctrl",
      "K Ctrl"
    ],
    "label": "Ctrl+K Ctrl+W",
    "rationale": "evolved: Close all editors",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 9 and Left Bracket",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+9",
    "rationale": "evolved: Unhide rows",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+L",
    "rationale": "evolved: Focus address bar",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+P",
    "rationale": "evolved: Print",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+B",
    "rationale": "evolved: Focus system tray",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+H",
    "rationale": "evolved: Voice typing",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Left",
    "rationale": "evolved: Go back",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+A",
    "rationale": "evolved: Toggle block comment",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+C",
    "rationale": "evolved: Open Copilot",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 4,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "Base",
    "rationale": "evolved: Dynamic layer access: @access:L5->L0:toggle:Base",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+E",
    "rationale": "evolved: Toggle screen share",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 5,
    "behavior": "Momentary Layer",
    "parameter": "Layer::6",
    "modifiers": [],
    "label": "Scroll",
    "rationale": "evolved: Dynamic layer access: @access:L2->L6:hold:Scroll",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 0,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Ctrl",
      "L Alt"
    ],
    "label": "Ctrl+Alt+Up",
    "rationale": "evolved: Add cursor above",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 2,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard ForwardSlash and QuestionMark",
    "modifiers": [],
    "label": "?",
    "rationale": "evolved: Show Vimium help",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard F4",
    "modifiers": [],
    "label": "F4",
    "rationale": "evolved: Toggle absolute ref ($)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 9,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+G",
    "rationale": "evolved: Go to...",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 11,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+X",
    "rationale": "evolved: Expand compose box",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Home",
    "rationale": "evolved: Select to cell A1",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+C",
    "rationale": "evolved: Copy",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Backslash and Pipe",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+\\",
    "rationale": "evolved: Split editor",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [],
    "label": "F5",
    "rationale": "evolved: Refresh page",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard R",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+R",
    "rationale": "evolved: Start recording",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard PageUp",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Page Up",
    "rationale": "evolved: Previous sheet",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 12,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Right Brace",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+]",
    "rationale": "evolved: Indent line",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Enter",
    "rationale": "evolved: Properties / metadata card",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Tab",
    "rationale": "evolved: Task View",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Up",
    "rationale": "evolved: Maximize window",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+X",
    "rationale": "evolved: Expand compose box",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 4 and Dollar",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+4",
    "rationale": "evolved: Calendar",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Space",
    "rationale": "evolved: Scroll up one screen",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F3",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F3",
    "rationale": "evolved: Find previous",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Backslash and Pipe",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+\\",
    "rationale": "evolved: Jump to matching bracket",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Right",
    "rationale": "evolved: Snap window right",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+Left",
    "rationale": "evolved: Switch desktop left",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Right",
    "rationale": "evolved: Go forward",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+T",
    "rationale": "evolved: Reopen closed tab",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Dash and Underscore",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+-",
    "rationale": "evolved: Zoom out",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+T",
    "rationale": "evolved: New tab",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+S",
    "rationale": "evolved: Search",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Y",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Y",
    "rationale": "evolved: Redo",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard 7 and Ampersand",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+7",
    "rationale": "evolved: Switch to tab 7",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F",
    "rationale": "evolved: Find in conversation",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [],
    "label": "=",
    "rationale": "evolved: Start formula",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 5,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "Base",
    "rationale": "evolved: Dynamic layer access: @access:L10->L0:toggle:Base",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+V",
    "rationale": "evolved: Paste",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 1,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+N",
    "rationale": "evolved: Notification center",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 9,
    "y": 0,
    "behavior": "Mouse Key Press",
    "parameter": "MB1",
    "modifiers": [],
    "label": "MB1",
    "rationale": "evolved: Left click",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+P",
    "rationale": "evolved: Project / display mode",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+T",
    "rationale": "evolved: Cycle taskbar apps",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+1",
    "rationale": "evolved: Open/switch pinned app 1",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Up",
    "rationale": "evolved: Jump to top edge of data",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+2",
    "rationale": "evolved: Chat",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+K",
    "rationale": "evolved: Raise/lower hand",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Ctrl",
      "K Ctrl"
    ],
    "label": "Ctrl+K Ctrl+F",
    "rationale": "evolved: Format selection",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+L",
    "rationale": "evolved: Lock PC",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+G",
    "rationale": "evolved: Go to...",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+H",
    "rationale": "evolved: Hang up / end call",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+D",
    "rationale": "evolved: Focus address bar (alt)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 7 and Ampersand",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+7",
    "rationale": "evolved: Switch to tab 7",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 7,
    "y": 4,
    "behavior": "coach_travel_off",
    "parameter": "",
    "modifiers": [],
    "label": "Exit Travel",
    "rationale": "evolved: Dynamic layer access: @access:L8->L0:toggle:Exit_Travel",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 4,
    "behavior": "Momentary Layer",
    "parameter": "Layer::6",
    "modifiers": [],
    "label": "Scroll",
    "rationale": "evolved: Dynamic layer access: @access:L1->L6:hold:Scroll",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+K",
    "rationale": "evolved: Raise/lower hand",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+D",
    "rationale": "evolved: Bookmark page",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Dash and Underscore",
    "modifiers": [
      "L Alt",
      "L Shift"
    ],
    "label": "Alt+Shift+-",
    "rationale": "evolved: Split pane horizontal",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+E",
    "rationale": "evolved: File Explorer",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Right Brace",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+]",
    "rationale": "evolved: Indent line",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 6 and Caret",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+6",
    "rationale": "evolved: Files",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+K",
    "rationale": "evolved: Raise/lower hand",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+K",
    "rationale": "evolved: Insert link",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard ForwardSlash and QuestionMark",
    "modifiers": [],
    "label": "?",
    "rationale": "evolved: Show Vimium help",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+F",
    "rationale": "evolved: Settings menu",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+D",
    "rationale": "evolved: New virtual desktop",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+K",
    "rationale": "evolved: Insert link",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard J",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+J",
    "rationale": "evolved: Open Console",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard R",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+R",
    "rationale": "evolved: Run dialog",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L GUI",
      "L Shift"
    ],
    "label": "Win+Shift+Left",
    "rationale": "evolved: Move to left monitor",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [],
    "label": "Up",
    "rationale": "evolved: Edit last sent message",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard U",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+U",
    "rationale": "evolved: Mark as unread",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 0,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L Ctrl",
      "K Ctrl"
    ],
    "label": "Ctrl+K Ctrl+S",
    "rationale": "evolved: Keyboard shortcuts",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 1,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+A",
    "rationale": "evolved: Select all",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 2,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard ForwardSlash and QuestionMark",
    "modifiers": [],
    "label": "?",
    "rationale": "evolved: Show Vimium help",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+L",
    "rationale": "evolved: Toggle sidebar",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl",
      "L Alt"
    ],
    "label": "Ctrl+Alt+Down",
    "rationale": "evolved: Add cursor below",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Tab",
    "rationale": "evolved: Next tab",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F11",
    "modifiers": [],
    "label": "F11",
    "rationale": "evolved: Toggle fullscreen",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+Right",
    "rationale": "evolved: Expand selection",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Right",
    "rationale": "evolved: Jump to right edge of data",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+X",
    "rationale": "evolved: Cut",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+B",
    "rationale": "evolved: Toggle background blur",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard End",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+End",
    "rationale": "evolved: Go to last used cell",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+,",
    "rationale": "evolved: Open settings",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Down",
    "rationale": "evolved: Move line down",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+;",
    "rationale": "evolved: Emoji picker",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+X",
    "rationale": "evolved: Cut",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Z",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Z",
    "rationale": "evolved: Undo",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Enter",
    "rationale": "evolved: New line in message",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+I",
    "rationale": "evolved: Italic",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+H",
    "rationale": "evolved: History",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [],
    "label": "RightArrow",
    "rationale": "evolved: Right arrow",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 0,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Down",
    "rationale": "evolved: Select to bottom edge",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F12",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+F12",
    "rationale": "evolved: Peek definition",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+,",
    "rationale": "evolved: Open settings",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+S",
    "rationale": "evolved: Search",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+V",
    "rationale": "evolved: Paste",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 3,
    "behavior": "Mouse Key Press",
    "parameter": "MB5",
    "modifiers": [],
    "label": "MB5",
    "rationale": "evolved: Forward button",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [],
    "label": "F5",
    "rationale": "evolved: Refresh page",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard M",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+M",
    "rationale": "evolved: Add to favorites",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Delete",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Del",
    "rationale": "evolved: Clear browsing data",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard 3 and Hash",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+3",
    "rationale": "evolved: Open/switch pinned app 3",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F4",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+F4",
    "rationale": "evolved: Close current desktop",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+C",
    "rationale": "evolved: Copy",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 5,
    "behavior": "coach_game_lock",
    "parameter": "",
    "modifiers": [],
    "label": "coach_game_lock",
    "rationale": "evolved: Dynamic layer access: @access:L10->L7:toggle:coach_game_lock",
    "optimizer_changed": true,
    "apply_batch": true
  }
];

(function () {
  const EXPECTED = window.CHARYBDIS_VERIFY_MUTABLE_EXPECTED;

  function clean(value) {
    return String(value ?? '').replace(/\s+/g, ' ').trim();
  }

  function normBehavior(value) {
    const v = clean(value).toLowerCase();
    if (v === 'none') return 'none';
    if (v === 'transparent') return 'transparent';
    return v;
  }

  function stripKeyboardPrefix(value) {
    return clean(value).replace(/^Keyboard\s+/i, '');
  }

  function normParam(value, behavior) {
    let v = stripKeyboardPrefix(value);
    const b = normBehavior(behavior);
    if (!v) return '';
    if (/layer/i.test(b)) {
      const m = v.match(/(?:Layer::)?(\d+)/i);
      return m ? m[1] : v.toLowerCase();
    }
    v = v
      .replace(/^Keyboard\s+/i, '')
      .replace(/^Select:\s*/i, '')
      .replace(/^default_transform$/i, '')
      .replace(/^Return Enter$/i, 'Enter')
      .replace(/^Delete Forward$/i, 'Delete')
      .replace(/^Left GUI$/i, 'LeftGUI')
      .replace(/^Left Control$/i, 'LeftControl')
      .replace(/^Left Shift$/i, 'LeftShift')
      .replace(/^Left Alt$/i, 'LeftAlt');
    return clean(v).toLowerCase();
  }

  function normMods(value) {
    const text = Array.isArray(value) ? value.join('+') : clean(value);
    if (!text) return '';
    return text
      .split('+')
      .map(clean)
      .filter(Boolean)
      .map(m => m
        .replace(/^LeftControl$/i, 'L Ctrl')
        .replace(/^LeftCtrl$/i, 'L Ctrl')
        .replace(/^LCtrl$/i, 'L Ctrl')
        .replace(/^LeftShift$/i, 'L Shift')
        .replace(/^LShift$/i, 'L Shift')
        .replace(/^LeftAlt$/i, 'L Alt')
        .replace(/^LAlt$/i, 'L Alt')
        .replace(/^LeftGUI$/i, 'L GUI')
        .replace(/^LGUI$/i, 'L GUI')
      )
      .sort((a, b) => a.localeCompare(b))
      .join('+')
      .toLowerCase();
  }

  function keySelector(layer, x, y) {
    return [
      "[data-layer='" + layer + "'][data-x='" + x + "'][data-y='" + y + "']",
      '[data-layer="' + layer + '"][data-x="' + x + '"][data-y="' + y + '"]',
      "[data-layer='" + layer + "'][data-col='" + x + "'][data-row='" + y + "']",
      '[data-layer="' + layer + '"][data-col="' + x + '"][data-row="' + y + '"]'
    ].join(',');
  }

  function textFrom(el, selectors) {
    for (const selector of selectors) {
      const hit = el.querySelector(selector);
      const text = clean(hit?.textContent || hit?.value || hit?.getAttribute?.('value'));
      if (text) return text;
    }
    return '';
  }

  function getKeyBinding(layer, x, y) {
    const btn = document.querySelector(keySelector(layer, x, y));
    if (!btn) return null;
    const behavior = textFrom(btn, [
      '.behavior-name',
      '[data-testid="behavior-name"]',
      '[class*="behavior"]',
      'select option:checked'
    ]);
    const parameter = textFrom(btn, [
      '.parameter-name',
      '[data-testid="parameter-name"]',
      '[class*="parameter"]',
      '[class*="param"]',
      'input',
      'select:nth-of-type(2) option:checked'
    ]);
    const modifierTags = Array.from(btn.querySelectorAll('.modifier-tag, [class*="modifier"]'))
      .map(m => clean(m.textContent))
      .filter(Boolean);
    const allText = clean(btn.textContent);
    return { behavior, parameter, modifiers: modifierTags.join('+'), allText };
  }

  function expectedSummary(k) {
    return ((k.behavior || '') + ' ' + (k.parameter || '') + ' ' + (Array.isArray(k.modifiers) ? k.modifiers.join('+') : (k.modifiers || ''))).trim();
  }

  function actualSummary(a) {
    if (!a) return 'KEY NOT FOUND';
    return ((a.behavior || '') + ' ' + (a.parameter || '') + ' ' + (a.modifiers || '')).trim() || a.allText || 'EMPTY';
  }

  async function runVerify() {
    const mismatches = [];
    const missing = [];
    let pass = 0;
    let checked = 0;

    for (const exp of EXPECTED) {
      checked++;
      const actual = getKeyBinding(exp.layer, exp.x, exp.y);
      if (!actual) {
        missing.push({ exp, reason: 'key tile not found' });
        continue;
      }

      const expectedBehavior = normBehavior(exp.behavior);
      const actualBehavior = normBehavior(actual.behavior);
      const expectedParam = normParam(exp.parameter, exp.behavior);
      const actualParam = normParam(actual.parameter, actual.behavior || exp.behavior);
      const expectedMods = normMods(exp.modifiers || []);
      const actualMods = normMods(actual.modifiers || '');

      const behaviorOk = actualBehavior === expectedBehavior;
      const paramOk = actualParam === expectedParam;
      const modsOk = actualMods === expectedMods || !expectedMods;

      if (behaviorOk && paramOk && modsOk) {
        pass++;
      } else {
        mismatches.push({
          layer: exp.layer,
          x: exp.x,
          y: exp.y,
          label: exp.label,
          expected: expectedSummary(exp),
          actual: actualSummary(actual),
          expectedNormalized: { behavior: expectedBehavior, parameter: expectedParam, modifiers: expectedMods },
          actualNormalized: { behavior: actualBehavior, parameter: actualParam, modifiers: actualMods },
          rationale: exp.rationale || ''
        });
      }
    }

    const fail = mismatches.length + missing.length;
    console.log('Charybdis mutable verify: ' + pass + '/' + checked + ' passed, ' + fail + ' failed. Skipped layer 7 and frozen/canonical keys.');

    if (missing.length) {
      console.group('Missing key tiles (' + missing.length + ')');
      for (const item of missing) {
        console.log('L' + item.exp.layer + ' x' + item.exp.x + ',y' + item.exp.y + ' ' + item.exp.label + ': ' + item.reason);
      }
      console.groupEnd();
    }

    if (mismatches.length) {
      console.group('MISMATCHES AT END (' + mismatches.length + ')');
      for (const m of mismatches) {
        console.log(
          'L' + m.layer + ' x' + m.x + ',y' + m.y + ' ' + m.label + '\n' +
          '  expected: ' + m.expected + '\n' +
          '  actual:   ' + m.actual + '\n' +
          '  normalized expected: ' + JSON.stringify(m.expectedNormalized) + '\n' +
          '  normalized actual:   ' + JSON.stringify(m.actualNormalized) + '\n' +
          '  ' + m.rationale
        );
      }
      console.groupEnd();
      console.table(mismatches.map(m => ({
        layer: m.layer,
        x: m.x,
        y: m.y,
        label: m.label,
        expected: m.expected,
        actual: m.actual
      })));
    } else {
      console.log('No mismatches found in mutable/non-frozen keys outside layer 7.');
    }

    window.CHARYBDIS_MUTABLE_VERIFY_RESULT = { checked, pass, fail, mismatches, missing };
    return window.CHARYBDIS_MUTABLE_VERIFY_RESULT;
  }

  runVerify();
})();
