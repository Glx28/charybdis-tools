/*
Charybdis optimizer layout VERIFY — evolved-run7-best
Verifies 559 evolved changes across layers [0, 1, 2, 3, 4, 5, 6, 8, 9, 10].
Paste in ZMK Studio console AFTER applying. Does not edit or save.
*/

window.CHARYBDIS_LAYER_ACCESS_REPORT = {
  "valid": true,
  "reachable_layers": [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10
  ],
  "required_layers": [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10
  ],
  "access_costs": {
    "0": 0.0,
    "1": 1.5,
    "2": 2.5,
    "3": 3.5,
    "4": 1.5,
    "5": 3.5,
    "6": 1.5,
    "7": 3.5,
    "10": 5.5,
    "9": 3.5,
    "8": 3.5
  }
};


(async function VerifyEvolvedLayout() {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));
  const clean = (s) => String(s || "").trim();
  const qa = (sel, root) => [...(root || document).querySelectorAll(sel)];

  const expected = [
  {
    "layer": 0,
    "x": 0,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Escape",
    "modifiers": [],
    "label": "escape",
    "rationale": "Optimizer (run7-best): _base_escape (Base key: Escape)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 0,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [],
    "label": "tab",
    "rationale": "Optimizer (run7-best): _base_tab (Base key: Tab)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 0,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftShift",
    "modifiers": [],
    "label": "leftshift",
    "rationale": "Optimizer (run7-best): _base_leftshift (Base key: LeftShift)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 0,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftControl",
    "modifiers": [],
    "label": "leftcontrol",
    "rationale": "Optimizer (run7-best): _base_leftcontrol (Base key: LeftControl)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 10,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 9 and Left Bracket",
    "modifiers": [],
    "label": "9",
    "rationale": "Optimizer (run7-best): _base_9 (Base key: 9 and Left Bracket)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard O",
    "modifiers": [],
    "label": "o",
    "rationale": "Optimizer (run7-best): _base_o (Base key: O)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [],
    "label": "l",
    "rationale": "Optimizer (run7-best): _base_l (Base key: L)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [],
    "label": "period",
    "rationale": "Optimizer (run7-best): _base_period (Base key: Period and GreaterThan)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 11,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 0 and Right Bracket",
    "modifiers": [],
    "label": "0",
    "rationale": "Optimizer (run7-best): _base_0 (Base key: 0 and Right Bracket)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [],
    "label": "p",
    "rationale": "Optimizer (run7-best): _base_p (Base key: P)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [],
    "label": "semicolon",
    "rationale": "Optimizer (run7-best): _base_semicolon (Base key: SemiColon and Colon)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard ForwardSlash and QuestionMark",
    "modifiers": [],
    "label": "forwardslash",
    "rationale": "Optimizer (run7-best): _base_forwardslash (Base key: ForwardSlash and QuestionMark)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 12,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Delete",
    "modifiers": [],
    "label": "delete",
    "rationale": "Optimizer (run7-best): _base_delete (Base key: Delete)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 12,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Left Brace",
    "modifiers": [],
    "label": "left brace",
    "rationale": "Optimizer (run7-best): _base_left brace (Base key: Left Brace)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 12,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Left Apos and Double",
    "modifiers": [],
    "label": "left apos",
    "rationale": "Optimizer (run7-best): _base_left apos (Base key: Left Apos and Double)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 12,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Backslash and Pipe",
    "modifiers": [],
    "label": "backslash",
    "rationale": "Optimizer (run7-best): _base_backslash (Base key: Backslash and Pipe)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 1,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [],
    "label": "1",
    "rationale": "Optimizer (run7-best): _base_1 (Base key: 1 and Bang)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Q",
    "modifiers": [],
    "label": "q",
    "rationale": "Optimizer (run7-best): _base_q (Base key: Q)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [],
    "label": "a",
    "rationale": "Optimizer (run7-best): _base_a (Base key: A)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Z",
    "modifiers": [],
    "label": "z",
    "rationale": "Optimizer (run7-best): _base_z (Base key: Z)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 2,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [],
    "label": "2",
    "rationale": "Optimizer (run7-best): _base_2 (Base key: 2 and At)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard W",
    "modifiers": [],
    "label": "w",
    "rationale": "Optimizer (run7-best): _base_w (Base key: W)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [],
    "label": "s",
    "rationale": "Optimizer (run7-best): _base_s (Base key: S)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [],
    "label": "x",
    "rationale": "Optimizer (run7-best): _base_x (Base key: X)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 3,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 3 and Hash",
    "modifiers": [],
    "label": "3",
    "rationale": "Optimizer (run7-best): _base_3 (Base key: 3 and Hash)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [],
    "label": "e",
    "rationale": "Optimizer (run7-best): _base_e (Base key: E)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [],
    "label": "d",
    "rationale": "Optimizer (run7-best): _base_d (Base key: D)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [],
    "label": "c",
    "rationale": "Optimizer (run7-best): _base_c (Base key: C)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 3,
    "y": 4,
    "behavior": "coach_l1_hold",
    "parameter": "",
    "modifiers": [],
    "label": "coach_l1_hold",
    "rationale": "Optimizer (run7-best): _base_coach_l1_hold (Base key: coach_l1_hold)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 4,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 4 and Dollar",
    "modifiers": [],
    "label": "4",
    "rationale": "Optimizer (run7-best): _base_4 (Base key: 4 and Dollar)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard R",
    "modifiers": [],
    "label": "r",
    "rationale": "Optimizer (run7-best): _base_r (Base key: R)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [],
    "label": "f",
    "rationale": "Optimizer (run7-best): _base_f (Base key: F)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [],
    "label": "v",
    "rationale": "Optimizer (run7-best): _base_v (Base key: V)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [],
    "label": "spacebar",
    "rationale": "Optimizer (run7-best): _base_spacebar (Base key: Spacebar)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 4,
    "y": 5,
    "behavior": "coach_l2_hold",
    "parameter": "",
    "modifiers": [],
    "label": "coach_l2_hold",
    "rationale": "Optimizer (run7-best): _base_coach_l2_hold (Base key: coach_l2_hold)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 5,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 5 and Percent",
    "modifiers": [],
    "label": "5",
    "rationale": "Optimizer (run7-best): _base_5 (Base key: 5 and Percent)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 5,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [],
    "label": "t",
    "rationale": "Optimizer (run7-best): _base_t (Base key: T)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [],
    "label": "g",
    "rationale": "Optimizer (run7-best): _base_g (Base key: G)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [],
    "label": "b",
    "rationale": "Optimizer (run7-best): _base_b (Base key: B)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 5,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [],
    "label": "downarrow_combo",
    "rationale": "Optimizer (run7-best): _base_downarrow_combo (Base key: DownArrow)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 7,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 6 and Caret",
    "modifiers": [],
    "label": "6",
    "rationale": "Optimizer (run7-best): _base_6 (Base key: 6 and Caret)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Y",
    "modifiers": [],
    "label": "y",
    "rationale": "Optimizer (run7-best): _base_y (Base key: Y)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [],
    "label": "h",
    "rationale": "Optimizer (run7-best): _base_h (Base key: H)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [],
    "label": "n",
    "rationale": "Optimizer (run7-best): _base_n (Base key: N)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 7,
    "y": 4,
    "behavior": "coach_l3_hold",
    "parameter": "",
    "modifiers": [],
    "label": "coach_l3_hold",
    "rationale": "Optimizer (run7-best): _base_coach_l3_hold (Base key: coach_l3_hold)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 7,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [],
    "label": "return enter",
    "rationale": "Optimizer (run7-best): _base_return enter (Base key: Return Enter)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 8,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 7 and Ampersand",
    "modifiers": [],
    "label": "7",
    "rationale": "Optimizer (run7-best): _base_7 (Base key: 7 and Ampersand)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard U",
    "modifiers": [],
    "label": "u",
    "rationale": "Optimizer (run7-best): _base_u (Base key: U)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard J",
    "modifiers": [],
    "label": "j",
    "rationale": "Optimizer (run7-best): _base_j (Base key: J)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard M",
    "modifiers": [],
    "label": "m",
    "rationale": "Optimizer (run7-best): _base_m (Base key: M)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 8,
    "y": 4,
    "behavior": "coach_l4_hold",
    "parameter": "",
    "modifiers": [],
    "label": "coach_l4_hold",
    "rationale": "Optimizer (run7-best): _base_coach_l4_hold (Base key: coach_l4_hold)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 9,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard 8 and Star",
    "modifiers": [],
    "label": "8",
    "rationale": "Optimizer (run7-best): _base_8 (Base key: 8 and Star)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [],
    "label": "i",
    "rationale": "Optimizer (run7-best): _base_i (Base key: I)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [],
    "label": "k",
    "rationale": "Optimizer (run7-best): _base_k (Base key: K)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 0,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [],
    "label": "comma",
    "rationale": "Optimizer (run7-best): _base_comma (Base key: Comma and LessThan)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 0,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+1",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+1 (Extra large icons)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 0,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F4",
    "modifiers": [],
    "label": "f4",
    "rationale": "Optimizer (run7-best): _base_f4 (Base key: F4)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 0,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 0 and Right Bracket",
    "modifiers": [],
    "label": "right bracket_combo",
    "rationale": "Optimizer (run7-best): _base_right bracket_combo (Base key: 0 and Right Bracket)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 10,
    "y": 0,
    "behavior": "Bluetooth",
    "parameter": "BT_SEL 1",
    "modifiers": [],
    "label": "Bluetooth",
    "rationale": "Optimizer (run7-best): _base_bt_sel 1 (Base key: BT_SEL 1)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+V",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+V (Paste without formatting)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Enter",
    "rationale": "Optimizer (run7-best): Ctrl+Enter (Send (expanded mode))",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+E",
    "rationale": "Optimizer (run7-best): Ctrl+E (Search / command bar)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 11,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Alt",
      "L Shift"
    ],
    "label": "Alt+Shift+Down",
    "rationale": "Optimizer (run7-best): Alt+Shift+Down (Next unread)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+<",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+< (Decrease font size)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+F",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+F (Format document)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Left Brace",
    "modifiers": [],
    "label": "left brace_combo",
    "rationale": "Optimizer (run7-best): _base_left brace_combo (Base key: Left Brace)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 12,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Grave Accent and Tilde",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+`",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+` (New terminal)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 12,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard End",
    "modifiers": [],
    "label": "end_combo",
    "rationale": "Optimizer (run7-best): _base_end_combo (Base key: End)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 12,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F18",
    "modifiers": [],
    "label": "f18",
    "rationale": "Optimizer (run7-best): _base_f18 (Base key: F18)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 12,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F14",
    "modifiers": [],
    "label": "f14",
    "rationale": "Optimizer (run7-best): _base_f14 (Base key: F14)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 1,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 1,
    "y": 1,
    "behavior": "Toggle Layer",
    "parameter": "Layer::5",
    "modifiers": [],
    "label": "Toggle Layer",
    "rationale": "Optimizer (run7-best): _base_toggle_layer_layer::5 (Base key: Layer::5)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+2",
    "rationale": "Optimizer (run7-best): Ctrl+2 (Chat)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F3",
    "modifiers": [],
    "label": "F3",
    "rationale": "Optimizer (run7-best): F3 (Find next)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+H",
    "rationale": "Optimizer (run7-best): Ctrl+H (Find and replace)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [],
    "label": "Enter",
    "rationale": "Optimizer (run7-best): Enter (Send message)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+G",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+G (Source control panel)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard J",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+J",
    "rationale": "Optimizer (run7-best): Ctrl+J (Toggle bottom panel)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 2,
    "behavior": "Momentary Layer",
    "parameter": "Layer::6",
    "modifiers": [],
    "label": "Momentary Layer",
    "rationale": "Optimizer (run7-best): _base_momentary_layer_layer::6 (Base key: Layer::6)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F11",
    "modifiers": [],
    "label": "F11",
    "rationale": "Optimizer (run7-best): F11 (Step into)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F1",
    "modifiers": [],
    "label": "F1",
    "rationale": "Optimizer (run7-best): F1 (Help)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard PrintScreen and SysReq",
    "modifiers": [],
    "label": "printscreen_combo",
    "rationale": "Optimizer (run7-best): _base_printscreen_combo (Base key: PrintScreen)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F1",
    "modifiers": [],
    "label": "f1",
    "rationale": "Optimizer (run7-best): _base_f1 (Base key: F1)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F6",
    "modifiers": [],
    "label": "f6",
    "rationale": "Optimizer (run7-best): _base_f6 (Base key: F6)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F3",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F3",
    "rationale": "Optimizer (run7-best): Shift+F3 (Find previous)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F7",
    "modifiers": [],
    "label": "F7",
    "rationale": "Optimizer (run7-best): F7 (Spell check)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 4,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F10",
    "modifiers": [],
    "label": "f10",
    "rationale": "Optimizer (run7-best): _base_f10 (Base key: F10)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [],
    "label": "f5",
    "rationale": "Optimizer (run7-best): _base_f5 (Base key: F5)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+>",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+> (Increase font size)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 5,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard F8",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F8",
    "rationale": "Optimizer (run7-best): Shift+F8 (Go to previous problem)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard Z",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Z",
    "rationale": "Optimizer (run7-best): Ctrl+Z (Undo)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Z",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Z",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Z (Redo)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Y",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Y",
    "rationale": "Optimizer (run7-best): Ctrl+Y (Redo (alt))",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+X",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+X (Expand compose box)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+X",
    "rationale": "Optimizer (run7-best): Ctrl+X (Cut)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 7,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard 9 and Left Bracket",
    "modifiers": [],
    "label": "left bracket_combo",
    "rationale": "Optimizer (run7-best): _base_left bracket_combo (Base key: 9 and Left Bracket)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 8,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+C",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+C (Inspect element)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Up",
    "rationale": "Optimizer (run7-best): Alt+Up (Move line up)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+C",
    "rationale": "Optimizer (run7-best): Ctrl+C (Copy)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Down",
    "rationale": "Optimizer (run7-best): Alt+Down (Move line down)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+K",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+K (Delete line)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+Down",
    "rationale": "Optimizer (run7-best): Shift+Alt+Down (Copy line down)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+V",
    "rationale": "Optimizer (run7-best): Ctrl+V (Paste)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 1,
    "x": 9,
    "y": 3,
    "behavior": "coach_game_lock",
    "parameter": "",
    "modifiers": [],
    "label": "coach_game_lock",
    "rationale": "Optimizer (run7-best): _base_coach_game_lock (Base key: coach_game_lock)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 0,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Dash and Underscore",
    "modifiers": [],
    "label": "dash_combo",
    "rationale": "Optimizer (run7-best): _base_dash_combo (Base key: Dash and Underscore)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 0,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [],
    "label": "leftarrow",
    "rationale": "Optimizer (run7-best): _base_leftarrow (Base key: LeftArrow)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 0,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [],
    "label": "rightarrow",
    "rationale": "Optimizer (run7-best): _base_rightarrow (Base key: RightArrow)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [],
    "label": "semicolon_combo",
    "rationale": "Optimizer (run7-best): _base_semicolon_combo (Base key: SemiColon and Colon)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Tab",
    "rationale": "Optimizer (run7-best): Shift+Tab (Outdent)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 2,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "coach_base",
    "rationale": "Optimizer (run7-best): _base_coach_base (Base key: coach_base)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F12",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+F12",
    "rationale": "Optimizer (run7-best): Alt+F12 (Peek definition)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard W",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+W",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+W (Change workflow state)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Dash and Underscore",
    "modifiers": [],
    "label": "dash",
    "rationale": "Optimizer (run7-best): _base_dash (Base key: Dash and Underscore)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard M",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+M",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+M (Toggle mute)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 11,
    "y": 3,
    "behavior": "Momentary Layer",
    "parameter": "Layer::8",
    "modifiers": [],
    "label": "Momentary Layer",
    "rationale": "Optimizer (run7-best): _base_momentary_layer_layer::8 (Base key: Layer::8)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 12,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F17",
    "modifiers": [],
    "label": "f17",
    "rationale": "Optimizer (run7-best): _base_f17 (Base key: F17)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 12,
    "y": 2,
    "behavior": "Toggle Layer",
    "parameter": "Layer::6",
    "modifiers": [],
    "label": "Toggle Layer",
    "rationale": "Optimizer (run7-best): _base_toggle_layer_layer::6 (Base key: Layer::6)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 12,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+1",
    "rationale": "Optimizer (run7-best): Win+1 (Open/switch pinned app 1)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard F12",
    "modifiers": [],
    "label": "f12",
    "rationale": "Optimizer (run7-best): _base_f12 (Base key: F12)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl",
      "L Alt"
    ],
    "label": "Ctrl+Alt+Down",
    "rationale": "Optimizer (run7-best): Ctrl+Alt+Down (Add cursor below)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Tab",
    "rationale": "Optimizer (run7-best): Alt+Tab (Switch apps)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 1,
    "y": 3,
    "behavior": "Mouse Key Press",
    "parameter": "MB3",
    "modifiers": [],
    "label": "MB3",
    "rationale": "Optimizer (run7-best): _base_select:mb3 (Base key: default_transform)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 2,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Ctrl",
      "L Alt"
    ],
    "label": "Ctrl+Alt+Up",
    "rationale": "Optimizer (run7-best): Ctrl+Alt+Up (Add cursor above)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+S",
    "rationale": "Optimizer (run7-best): Win+S (Search)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Left",
    "rationale": "Optimizer (run7-best): Win+Left (Snap window left)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F11",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F11",
    "rationale": "Optimizer (run7-best): Shift+F11 (Step out)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Right Brace",
    "modifiers": [],
    "label": "right brace",
    "rationale": "Optimizer (run7-best): _base_right brace (Base key: Right Brace)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Right",
    "rationale": "Optimizer (run7-best): Win+Right (Snap window right)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 3,
    "behavior": "Mouse Key Press",
    "parameter": "MB1",
    "modifiers": [],
    "label": "MB1",
    "rationale": "Optimizer (run7-best): _base_select:mb1 (Base key: MB1)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard O",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+O",
    "rationale": "Optimizer (run7-best): Ctrl+O (Open document)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [],
    "label": "leftarrow_combo",
    "rationale": "Optimizer (run7-best): _base_leftarrow_combo (Base key: LeftArrow)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Delete",
    "modifiers": [],
    "label": "Backspace",
    "rationale": "Optimizer (run7-best): Backspace (Go back / up)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 3,
    "behavior": "Mouse Key Press",
    "parameter": "MB5",
    "modifiers": [],
    "label": "MB5",
    "rationale": "Optimizer (run7-best): _base_select:mb5 (Base key: MB5)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 4,
    "behavior": "Mouse Key Press",
    "parameter": "MB2",
    "modifiers": [],
    "label": "MB2",
    "rationale": "Optimizer (run7-best): _base_select:mb2 (Base key: default_transform)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 4,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [],
    "label": "downarrow",
    "rationale": "Optimizer (run7-best): _base_downarrow (Base key: DownArrow)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 0,
    "behavior": "Bluetooth",
    "parameter": "BT_SEL 2",
    "modifiers": [],
    "label": "Bluetooth",
    "rationale": "Optimizer (run7-best): _base_bt_sel 2 (Base key: BT_SEL 2)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F10",
    "modifiers": [],
    "label": "F10",
    "rationale": "Optimizer (run7-best): F10 (Step over)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [],
    "label": "uparrow",
    "rationale": "Optimizer (run7-best): _base_uparrow (Base key: UpArrow)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard End",
    "modifiers": [],
    "label": "end",
    "rationale": "Optimizer (run7-best): _base_end (Base key: End)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 4,
    "behavior": "Bootloader",
    "parameter": "",
    "modifiers": [],
    "label": "Bootloader",
    "rationale": "Optimizer (run7-best): _base_bootloader (Base key: Bootloader)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F9",
    "modifiers": [],
    "label": "F9",
    "rationale": "Optimizer (run7-best): F9 (Toggle breakpoint)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F9",
    "modifiers": [],
    "label": "f9",
    "rationale": "Optimizer (run7-best): _base_f9 (Base key: F9)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard ForwardSlash and QuestionMark",
    "modifiers": [],
    "label": "forwardslash_combo",
    "rationale": "Optimizer (run7-best): _base_forwardslash_combo (Base key: ForwardSlash and QuestionMark)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Left",
    "rationale": "Optimizer (run7-best): Ctrl+Left (Jump to left edge of data)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Right",
    "rationale": "Optimizer (run7-best): Ctrl+Right (Jump to right edge of data)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 2,
    "behavior": "Mouse Key Press",
    "parameter": "MB4",
    "modifiers": [],
    "label": "MB4",
    "rationale": "Optimizer (run7-best): _base_select:mb4 (Base key: default_transform)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F4",
    "modifiers": [],
    "label": "F4",
    "rationale": "Optimizer (run7-best): F4 (Toggle absolute ref ($))",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [],
    "label": "uparrow_combo",
    "rationale": "Optimizer (run7-best): _base_uparrow_combo (Base key: UpArrow)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 9,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard F15",
    "modifiers": [],
    "label": "f15",
    "rationale": "Optimizer (run7-best): _base_f15 (Base key: F15)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard U",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+U",
    "rationale": "Optimizer (run7-best): Ctrl+U (Mark as unread)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 9,
    "y": 2,
    "behavior": "coach_travel_toggle",
    "parameter": "",
    "modifiers": [],
    "label": "coach_travel_toggle",
    "rationale": "Optimizer (run7-best): _base_coach_travel_toggle (Base key: coach_travel_toggle)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 2,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard R",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+R",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+R (Reply all)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 0,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 0,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 0,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 10,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F22",
    "modifiers": [],
    "label": "f22",
    "rationale": "Optimizer (run7-best): _base_f22 (Base key: F22)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard PageDown",
    "modifiers": [],
    "label": "pagedown_combo",
    "rationale": "Optimizer (run7-best): _base_pagedown_combo (Base key: PageDown)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F13",
    "modifiers": [],
    "label": "f13",
    "rationale": "Optimizer (run7-best): _base_f13 (Base key: F13)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 11,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F11",
    "modifiers": [],
    "label": "f11",
    "rationale": "Optimizer (run7-best): _base_f11 (Base key: F11)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [],
    "label": "comma_combo",
    "rationale": "Optimizer (run7-best): _base_comma_combo (Base key: Comma and LessThan)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Right",
    "rationale": "Optimizer (run7-best): Alt+Right (Forward)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 12,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 12,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 12,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 1,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Tab",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Tab (Previous tab)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard PageUp",
    "modifiers": [],
    "label": "pageup_combo",
    "rationale": "Optimizer (run7-best): _base_pageup_combo (Base key: PageUp)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F7",
    "modifiers": [],
    "label": "f7",
    "rationale": "Optimizer (run7-best): _base_f7 (Base key: F7)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [],
    "label": "equals_combo",
    "rationale": "Optimizer (run7-best): _base_equals_combo (Base key: Equals and Plus)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Delete",
    "modifiers": [],
    "label": "Delete",
    "rationale": "Optimizer (run7-best): Delete (Delete)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+T",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+T (Reopen closed tab)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F8",
    "modifiers": [],
    "label": "f8",
    "rationale": "Optimizer (run7-best): _base_f8 (Base key: F8)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 2,
    "behavior": "Bluetooth",
    "parameter": "BT_SEL 4",
    "modifiers": [],
    "label": "Bluetooth",
    "rationale": "Optimizer (run7-best): _base_bt_sel 4 (Base key: BT_SEL 4)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F2",
    "modifiers": [],
    "label": "f2",
    "rationale": "Optimizer (run7-best): _base_f2 (Base key: F2)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Grave Accent and Tilde",
    "modifiers": [],
    "label": "grave accent",
    "rationale": "Optimizer (run7-best): _base_grave accent (Base key: Grave Accent and Tilde)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [],
    "label": "F5",
    "rationale": "Optimizer (run7-best): F5 (Refresh page)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F2",
    "modifiers": [],
    "label": "F2",
    "rationale": "Optimizer (run7-best): F2 (Rename)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 3,
    "behavior": "Bluetooth",
    "parameter": "BT_SEL 3",
    "modifiers": [],
    "label": "Bluetooth",
    "rationale": "Optimizer (run7-best): _base_bt_sel 3 (Base key: BT_SEL 3)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 4,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [],
    "label": "period_combo",
    "rationale": "Optimizer (run7-best): _base_period_combo (Base key: Period and GreaterThan)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F19",
    "modifiers": [],
    "label": "f19",
    "rationale": "Optimizer (run7-best): _base_f19 (Base key: F19)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 3,
    "behavior": "coach_mouse_lock",
    "parameter": "",
    "modifiers": [],
    "label": "coach_mouse_lock",
    "rationale": "Optimizer (run7-best): _base_coach_mouse_lock (Base key: coach_mouse_lock)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 8,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F20",
    "modifiers": [],
    "label": "f20",
    "rationale": "Optimizer (run7-best): _base_f20 (Base key: F20)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 9,
    "y": 2,
    "behavior": "coach_game_lock",
    "parameter": "",
    "modifiers": [],
    "label": "coach_game_lock",
    "rationale": "Optimizer (run7-best): _base_coach_game_lock (Base key: coach_game_lock)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 3,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftAlt",
    "modifiers": [],
    "label": "leftalt",
    "rationale": "Optimizer (run7-best): _base_leftalt (Base key: LeftAlt)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 0,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 0,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 0,
    "y": 3,
    "behavior": "Toggle Layer",
    "parameter": "Layer::10",
    "modifiers": [],
    "label": "Toggle Layer",
    "rationale": "Optimizer (run7-best): _base_toggle_layer_layer::10 (Base key: Layer::10)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+I",
    "rationale": "Optimizer (run7-best): Win+I (Settings)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+P",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+P (Command palette)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+L",
    "rationale": "Optimizer (run7-best): Win+L (Lock PC)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 11,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Grave Accent and Tilde",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+`",
    "rationale": "Optimizer (run7-best): Ctrl+` (Toggle terminal)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard ForwardSlash and QuestionMark",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+/",
    "rationale": "Optimizer (run7-best): Ctrl+/ (Toggle line comment)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard X",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+X",
    "rationale": "Optimizer (run7-best): Win+X (Power User menu)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 12,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 12,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 12,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 1,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+.",
    "rationale": "Optimizer (run7-best): Win+. (Emoji picker)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F12",
    "modifiers": [],
    "label": "F12",
    "rationale": "Optimizer (run7-best): F12 (Go to definition)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Escape",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Esc",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Esc (Task Manager)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 4 and Dollar",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+4",
    "rationale": "Optimizer (run7-best): Win+4 (Open/switch pinned app 4)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+D",
    "rationale": "Optimizer (run7-best): Ctrl+D (Select next occurrence)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 2,
    "y": 3,
    "behavior": "Toggle Layer",
    "parameter": "Layer::9",
    "modifiers": [],
    "label": "Toggle Layer",
    "rationale": "Optimizer (run7-best): _base_toggle_layer_layer::9 (Base key: Layer::9)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 5 and Percent",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+5",
    "rationale": "Optimizer (run7-best): Win+5 (Open/switch pinned app 5)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+P",
    "rationale": "Optimizer (run7-best): Ctrl+P (Quick open file)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+;",
    "rationale": "Optimizer (run7-best): Win+; (Emoji picker)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 3,
    "y": 4,
    "behavior": "Bluetooth",
    "parameter": "BT_SEL 0",
    "modifiers": [],
    "label": "Bluetooth",
    "rationale": "Optimizer (run7-best): _base_bt_sel 0 (Base key: BT_SEL 0)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Space",
    "rationale": "Optimizer (run7-best): Shift+Space (Select entire row)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+S",
    "rationale": "Optimizer (run7-best): Ctrl+S (Save)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Dash and Underscore",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+-",
    "rationale": "Optimizer (run7-best): Ctrl+- (Delete cells/rows/columns)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [],
    "label": "equals",
    "rationale": "Optimizer (run7-best): _base_equals (Base key: Equals and Plus)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 4,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Home",
    "rationale": "Optimizer (run7-best): Ctrl+Home (Go to cell A1)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard R",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+R",
    "rationale": "Optimizer (run7-best): Win+R (Run dialog)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard End",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+End",
    "rationale": "Optimizer (run7-best): Ctrl+End (Go to last used cell)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 8,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Up",
    "rationale": "Optimizer (run7-best): Ctrl+Up (Jump to top edge of data)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [],
    "label": "Tab",
    "rationale": "Optimizer (run7-best): Tab (Indent / accept suggestion)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 4,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Down",
    "rationale": "Optimizer (run7-best): Ctrl+Down (Jump to bottom edge of data)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 0,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 0,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 0,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+2",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+2 (Large icons)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 10,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard PageDown",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Page Down",
    "rationale": "Optimizer (run7-best): Ctrl+Page Down (Next sheet)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+E",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+E (Check in document)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard PageUp",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Page Up",
    "rationale": "Optimizer (run7-best): Ctrl+Page Up (Previous sheet)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 11,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Left",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Left (Select to left edge)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 11,
    "y": 2,
    "behavior": "coach_travel_toggle",
    "parameter": "",
    "modifiers": [],
    "label": "coach_travel_toggle",
    "rationale": "Optimizer (run7-best): _base_coach_travel_toggle (Base key: coach_travel_toggle)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Right",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Right (Select to right edge)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 12,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 12,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Grave Accent and Tilde",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+~",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+~ (General format)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 12,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 1,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Space",
    "rationale": "Optimizer (run7-best): Ctrl+Space (Select entire column)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Enter",
    "rationale": "Optimizer (run7-best): Alt+Enter (Properties / metadata card)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Down",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Down (Select to bottom edge)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Up",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Up (Select to top edge)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+N",
    "rationale": "Optimizer (run7-best): Ctrl+N (New mail)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift++",
    "rationale": "Optimizer (run7-best): Ctrl+Shift++ (Insert cells/rows/columns)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+=",
    "rationale": "Optimizer (run7-best): Alt+= (AutoSum)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard R",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+R",
    "rationale": "Optimizer (run7-best): Ctrl+R (Reply)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F5",
    "rationale": "Optimizer (run7-best): Ctrl+F5 (Hard refresh (bypass cache))",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 3,
    "y": 4,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "coach_base",
    "rationale": "Optimizer (run7-best): _base_coach_base (Base key: coach_base)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+D",
    "rationale": "Optimizer (run7-best): Alt+D (Focus address bar (alt))",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+1",
    "rationale": "Optimizer (run7-best): Ctrl+1 (Activity)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl++",
    "rationale": "Optimizer (run7-best): Ctrl++ (Zoom in)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Home",
    "rationale": "Optimizer (run7-best): Alt+Home (Open home page)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 4,
    "y": 5,
    "behavior": "Key Press",
    "parameter": "Keyboard Delete",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Delete",
    "rationale": "Optimizer (run7-best): Shift+Delete (Permanent delete)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 9 and Left Bracket",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+9",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+9 (Unhide rows)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+;",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+; (Insert current time)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 6 and Caret",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+6",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+6 (Toggle details pane)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 8,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 0 and Right Bracket",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+0",
    "rationale": "Optimizer (run7-best): Ctrl+0 (Reset zoom)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 3 and Hash",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+3",
    "rationale": "Optimizer (run7-best): Ctrl+3 (Teams/channels)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard J",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+J",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+J (Open Console)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+P",
    "rationale": "Optimizer (run7-best): Alt+P (Preview pane)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+F",
    "rationale": "Optimizer (run7-best): Alt+F (Settings menu)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 4 and Dollar",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+4",
    "rationale": "Optimizer (run7-best): Ctrl+4 (Calendar)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 5,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+N",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+N (New folder)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 0,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 0,
    "y": 2,
    "behavior": "Bluetooth",
    "parameter": "BT_SEL ?",
    "modifiers": [],
    "label": "Bluetooth",
    "rationale": "Optimizer (run7-best): _base_bt_sel ? (Base key: BT_SEL ?)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 0,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 10,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F6",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+F6",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+F6 (Next section)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+I",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+I (Go to Inbox)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Tab",
    "rationale": "Optimizer (run7-best): Ctrl+Tab (Next tab)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 11,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard W",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+W",
    "rationale": "Optimizer (run7-best): Ctrl+W (Close tab)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+Left",
    "rationale": "Optimizer (run7-best): Alt+Left (Back)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard I",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+I",
    "rationale": "Optimizer (run7-best): Ctrl+I (Italic)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 12,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 12,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Delete Forward",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Del",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Del (Clear browsing data)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 12,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 1,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+L",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+L (Autofill login)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Q",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+Q",
    "rationale": "Optimizer (run7-best): Ctrl+Q (Mark as read)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 8 and Star",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+8",
    "rationale": "Optimizer (run7-best): Ctrl+8 (Switch to tab 8)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+S",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+S (Attach file)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F",
    "rationale": "Optimizer (run7-best): Ctrl+F (Find)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Alt",
      "L Shift"
    ],
    "label": "Alt+Shift+Up",
    "rationale": "Optimizer (run7-best): Alt+Shift+Up (Previous unread)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+K",
    "rationale": "Optimizer (run7-best): Ctrl+K (Insert link)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard U",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+U",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+U (Mark as unread)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard L",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+L",
    "rationale": "Optimizer (run7-best): Ctrl+L (Focus address bar)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 3,
    "y": 4,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "coach_base",
    "rationale": "Optimizer (run7-best): _base_coach_base (Base key: coach_base)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+B",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+B (Toggle background blur)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+Left",
    "rationale": "Optimizer (run7-best): Win+Ctrl+Left (Switch desktop left)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+D",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+D (Decline call)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+Right",
    "rationale": "Optimizer (run7-best): Win+Ctrl+Right (Switch desktop right)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 4,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+D",
    "rationale": "Optimizer (run7-best): Win+Ctrl+D (New virtual desktop)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [],
    "label": "home",
    "rationale": "Optimizer (run7-best): _base_home (Base key: Home)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [],
    "label": "rightarrow_combo",
    "rationale": "Optimizer (run7-best): _base_rightarrow_combo (Base key: RightArrow)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Period and GreaterThan",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+.",
    "rationale": "Optimizer (run7-best): Ctrl+. (Show commands)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard K",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+K",
    "rationale": "Optimizer (run7-best): Win+K (Connect / Cast)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard 7 and Ampersand",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+7",
    "rationale": "Optimizer (run7-best): Ctrl+7 (Switch to tab 7)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 6 and Caret",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+6",
    "rationale": "Optimizer (run7-best): Ctrl+6 (Files)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+T",
    "rationale": "Optimizer (run7-best): Ctrl+T (New tab)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 6,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 5 and Percent",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+5",
    "rationale": "Optimizer (run7-best): Ctrl+5 (Calls)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 0,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 0,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Home",
    "rationale": "Optimizer (run7-best): Win+Home (Minimize all except active)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 0,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 10,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [],
    "label": "Down",
    "rationale": "Optimizer (run7-best): Down (Next command)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F4",
    "modifiers": [
      "L Alt"
    ],
    "label": "Alt+F4",
    "rationale": "Optimizer (run7-best): Alt+F4 (Close window)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Q",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Q",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Q (New meeting)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 11,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 9 and Left Bracket",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+9",
    "rationale": "Optimizer (run7-best): Ctrl+9 (Hide selected rows)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+D",
    "rationale": "Optimizer (run7-best): Win+D (Show/hide desktop)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard End",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+End",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+End (Select to last used cell)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 12,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 12,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 12,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 1,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Home",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Home (Select to cell A1)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Tab",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Tab",
    "rationale": "Optimizer (run7-best): Win+Tab (Task View)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 1,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard SemiColon and Colon",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+;",
    "rationale": "Optimizer (run7-best): Ctrl+; (Insert current date)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 1 and Bang",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+!",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+! (Number format)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Up",
    "rationale": "Optimizer (run7-best): Win+Up (Maximize window)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard 4 and Dollar",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+$",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+$ (Currency format)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 3,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard 5 and Percent",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+%",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+% (Percent format)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard DownArrow",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Down",
    "rationale": "Optimizer (run7-best): Win+Down (Minimize / restore)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard Dash and Underscore",
    "modifiers": [
      "L Alt",
      "L Shift"
    ],
    "label": "Alt+Shift+-",
    "rationale": "Optimizer (run7-best): Alt+Shift+- (Split pane horizontal)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 3,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard F16",
    "modifiers": [],
    "label": "f16",
    "rationale": "Optimizer (run7-best): _base_f16 (Base key: F16)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Equals and Plus",
    "modifiers": [
      "L Alt",
      "L Shift"
    ],
    "label": "Alt+Shift++",
    "rationale": "Optimizer (run7-best): Alt+Shift++ (Split pane vertical)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L GUI",
      "L Shift"
    ],
    "label": "Win+Shift+Left",
    "rationale": "Optimizer (run7-best): Win+Shift+Left (Move to left monitor)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard PageDown",
    "modifiers": [],
    "label": "Page Down",
    "rationale": "Optimizer (run7-best): Page Down (Next slide)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Left GUI",
    "modifiers": [],
    "label": "left gui",
    "rationale": "Optimizer (run7-best): _base_left gui (Base key: Left GUI)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 4,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 7,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 7,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard G",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+G",
    "rationale": "Optimizer (run7-best): Ctrl+G (Go to line)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 7,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
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
    "label": "coach_travel_off",
    "rationale": "Optimizer (run7-best): _base_coach_travel_off (Base key: coach_travel_off)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard PageUp",
    "modifiers": [],
    "label": "Page Up",
    "rationale": "Optimizer (run7-best): Page Up (Previous slide)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard RightArrow",
    "modifiers": [
      "L GUI",
      "L Shift"
    ],
    "label": "Win+Shift+Right",
    "rationale": "Optimizer (run7-best): Win+Shift+Right (Move to right monitor)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F6",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+F6",
    "rationale": "Optimizer (run7-best): Ctrl+F6 (Previous section)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 8,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard Home",
    "modifiers": [],
    "label": "home_combo",
    "rationale": "Optimizer (run7-best): _base_home_combo (Base key: Home)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard M",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+M",
    "rationale": "Optimizer (run7-best): Win+M (Minimize all windows)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard E",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+E",
    "rationale": "Optimizer (run7-best): Win+E (File Explorer)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 8,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F4",
    "modifiers": [
      "L GUI",
      "L Ctrl"
    ],
    "label": "Win+Ctrl+F4",
    "rationale": "Optimizer (run7-best): Win+Ctrl+F4 (Close current desktop)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 0,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 0,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 0,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 10,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard P",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+P",
    "rationale": "Optimizer (run7-best): Win+P (Project / display mode)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard V",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+V",
    "rationale": "Optimizer (run7-best): Win+V (Clipboard history)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+A",
    "rationale": "Optimizer (run7-best): Win+A (Quick settings / Action center)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 11,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard N",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+N",
    "rationale": "Optimizer (run7-best): Win+N (Notification center)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard S",
    "modifiers": [
      "L GUI",
      "L Shift"
    ],
    "label": "Win+Shift+S",
    "rationale": "Optimizer (run7-best): Win+Shift+S (Screenshot (Snip))",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard T",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+T",
    "rationale": "Optimizer (run7-best): Win+T (Cycle taskbar apps)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 12,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 12,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 12,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 1,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 1,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+B",
    "rationale": "Optimizer (run7-best): Win+B (Focus system tray)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 2 and At",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+2",
    "rationale": "Optimizer (run7-best): Win+2 (Open/switch pinned app 2)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 1,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 2,
    "y": 1,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "coach_base",
    "rationale": "Optimizer (run7-best): _base_coach_base (Base key: coach_base)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard 3 and Hash",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+3",
    "rationale": "Optimizer (run7-best): Win+3 (Open/switch pinned app 3)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 2,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+H",
    "rationale": "Optimizer (run7-best): Win+H (Voice typing)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 3,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+Space",
    "rationale": "Optimizer (run7-best): Win+Space (Switch input language)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 4,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 8,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard F21",
    "modifiers": [],
    "label": "f21",
    "rationale": "Optimizer (run7-best): _base_f21 (Base key: F21)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard C",
    "modifiers": [
      "L GUI"
    ],
    "label": "Win+C",
    "rationale": "Optimizer (run7-best): Win+C (Open Copilot)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 8,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 8,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 9,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 9,
    "y": 2,
    "behavior": "Momentary Layer",
    "parameter": "Layer::6",
    "modifiers": [],
    "label": "Momentary Layer",
    "rationale": "Optimizer (run7-best): _base_momentary_layer_layer::6 (Base key: Layer::6)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 9,
    "x": 9,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 0,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 0,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 0,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 0,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 10,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 10,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Backslash and Pipe",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+\\",
    "rationale": "Optimizer (run7-best): Ctrl+\\ (Split editor)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 10,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Right Brace",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+]",
    "rationale": "Optimizer (run7-best): Ctrl+] (Indent line)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 10,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard H",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+H",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+H (Hang up / end call)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 11,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 11,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Grave Accent and Tilde",
    "modifiers": [],
    "label": "grave accent_combo",
    "rationale": "Optimizer (run7-best): _base_grave accent_combo (Base key: Grave Accent and Tilde)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 11,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Comma and LessThan",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+,",
    "rationale": "Optimizer (run7-best): Ctrl+, (Open settings)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 11,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+Up",
    "rationale": "Optimizer (run7-best): Shift+Alt+Up (Copy line up)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 12,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 12,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+Enter",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+Enter (Insert line above)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 12,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 12,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 1,
    "y": 0,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+F5",
    "rationale": "Optimizer (run7-best): Shift+F5 (Stop debugging)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 1,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 1,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Left Brace",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+[",
    "rationale": "Optimizer (run7-best): Ctrl+[ (Outdent line)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 1,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 2,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 2,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard B",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+B",
    "rationale": "Optimizer (run7-best): Ctrl+B (Bold)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 2,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard LeftArrow",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+Left",
    "rationale": "Optimizer (run7-best): Shift+Alt+Left (Shrink selection)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 2,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard F5",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+F5",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+F5 (Restart debugging)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 3,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
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
    "rationale": "Optimizer (run7-best): Shift+Alt+Right (Expand selection)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 3,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Return Enter",
    "modifiers": [
      "L Shift"
    ],
    "label": "Shift+Enter",
    "rationale": "Optimizer (run7-best): Shift+Enter (New line in message)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 3,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard M",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+M",
    "rationale": "Optimizer (run7-best): Ctrl+M (Add to favorites)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 3,
    "y": 4,
    "behavior": "coach_base",
    "parameter": "",
    "modifiers": [],
    "label": "coach_base",
    "rationale": "Optimizer (run7-best): _base_coach_base (Base key: coach_base)",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard Escape",
    "modifiers": [],
    "label": "Escape",
    "rationale": "Optimizer (run7-best): Escape (Close / go back)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Backslash and Pipe",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+\\",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+\\ (Jump to matching bracket)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard O",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+O",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+O (Toggle camera)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 4,
    "behavior": "Key Press",
    "parameter": "Keyboard D",
    "modifiers": [
      "L Alt",
      "L Shift"
    ],
    "label": "Alt+Shift+D",
    "rationale": "Optimizer (run7-best): Alt+Shift+D (Split pane (auto))",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 4,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 5,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 1,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 2,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 3,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 7,
    "y": 5,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Cleared by optimizer (run7-best)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Shift",
      "L Alt"
    ],
    "label": "Shift+Alt+A",
    "rationale": "Optimizer (run7-best): Shift+Alt+A (Toggle block comment)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard Spacebar",
    "modifiers": [],
    "label": "Space",
    "rationale": "Optimizer (run7-best): Space (Scroll down one screen)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Ctrl",
      "L Shift"
    ],
    "label": "Ctrl+Shift+A",
    "rationale": "Optimizer (run7-best): Ctrl+Shift+A (Accept call)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 8,
    "y": 4,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 9,
    "y": 0,
    "behavior": "Transparent",
    "parameter": "",
    "modifiers": [],
    "label": "",
    "rationale": "Optimizer (run7-best): unchanged transparent",
    "optimizer_changed": false,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 9,
    "y": 1,
    "behavior": "Key Press",
    "parameter": "Keyboard A",
    "modifiers": [
      "L Ctrl"
    ],
    "label": "Ctrl+A",
    "rationale": "Optimizer (run7-best): Ctrl+A (Select all)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 9,
    "y": 2,
    "behavior": "Key Press",
    "parameter": "Keyboard F8",
    "modifiers": [],
    "label": "F8",
    "rationale": "Optimizer (run7-best): F8 (Go to next problem)",
    "optimizer_changed": true,
    "apply_batch": true
  },
  {
    "layer": 10,
    "x": 9,
    "y": 3,
    "behavior": "Key Press",
    "parameter": "Keyboard UpArrow",
    "modifiers": [],
    "label": "Up",
    "rationale": "Optimizer (run7-best): Up (Edit last sent message)",
    "optimizer_changed": true,
    "apply_batch": true
  }
];
  const layers = [0, 1, 2, 3, 4, 5, 6, 8, 9, 10];
  const accessReport = window.CHARYBDIS_LAYER_ACCESS_REPORT || {};

  // --- Layer selection (mirrors apply script) ---

  function findLayerButton(layer) {
    const layerList = document.querySelector('[aria-label="Keymap Layer"]');
    return layerList?.querySelector('[role="option"][data-key="' + layer + '"]')
      || qa('[role="option"]', layerList || document).find(el => clean(el.textContent) === String(layer));
  }

  function selectedLayer() {
    const selected = document.querySelector('[aria-label="Keymap Layer"] [role="option"][aria-selected="true"]');
    return clean(selected?.textContent || "");
  }

  async function selectLayer(layer) {
    if (selectedLayer() === String(layer)) return true;
    const el = findLayerButton(layer);
    if (!el) {
      console.error("Layer " + layer + " not found in ZMK Studio layer list");
      return false;
    }
    el.click();
    await sleep(650);
    if (selectedLayer() !== String(layer)) {
      console.error("Failed to switch to layer " + layer + " (stuck on " + selectedLayer() + ")");
      return false;
    }
    return true;
  }

  // --- Key selection (mirrors apply script) ---

  function findKeyElement(x, y) {
    const holder = document.querySelector('[x="' + x + '"][y="' + y + '"]');
    return holder?.querySelector("button") || holder;
  }

  async function selectKey(x, y) {
    const el = findKeyElement(x, y);
    if (!el) return false;
    (el.closest("button") || el).click();
    await sleep(220);
    return true;
  }

  // --- Read current key state ---

  function visibleSelects() {
    return qa("select").filter(s => s.offsetParent !== null);
  }

  function isBehaviorSelect(s) {
    return [...s.options].some(o => clean(o.textContent) === "Key Press")
      && [...s.options].some(o => clean(o.textContent) === "Transparent");
  }

  function isZoomSelect(s) {
    return [...s.options].some(o => clean(o.textContent) === "Auto")
      && [...s.options].some(o => clean(o.textContent) === "100%");
  }

  function isDefaultTransformSelect(s) {
    return [...s.options].some(o => clean(o.textContent) === "default_transform")
      && s.options.length <= 3;
  }

  function readCurrent() {
    const allSelects = visibleSelects();
    const bSel = allSelects.find(isBehaviorSelect);
    const behavior = bSel ? clean(bSel.options[bSel.selectedIndex]?.textContent) : "";

    const combobox = qa("input").find(i => i.offsetParent !== null && i.getAttribute("role") === "combobox");
    let parameter = combobox ? clean(combobox.value) : "";

    if (!parameter) {
      const paramSelect = allSelects.find(s =>
        s !== bSel && !isBehaviorSelect(s) && !isZoomSelect(s) && !isDefaultTransformSelect(s)
      );
      if (paramSelect) {
        parameter = clean(paramSelect.options[paramSelect.selectedIndex]?.textContent) || "";
      }
    }

    if (behavior === "Bluetooth" && (parameter === "Select Profile" || parameter === "Disconnect Profile")) {
      const numInput = qa("input[type=number]").find(i => i.offsetParent !== null);
      if (numInput) {
        parameter = "BT_SEL " + clean(numInput.value);
      }
    }

    const checkboxes = qa("input[type=checkbox]").filter(c => c.offsetParent !== null && c.checked);
    const modifiers = checkboxes.map(c => {
      const label = c.closest("label")?.textContent || c.parentElement?.textContent || "";
      return clean(label);
    }).filter(Boolean);
    return { behavior, parameter, modifiers };
  }

  // --- Main verify loop ---

  console.log("Verifying " + expected.length + " evolved keys across layers " + JSON.stringify(layers) + "...");
  let passed = 0, failed = 0, skipped = 0;
  const failures = [];
  let currentLayer = null;

  let skipped = 0;
  for (const key of expected) {
    if (!layers.includes(key.layer)) continue;
    if (key.studio_skip) { skipped++; continue; }

    if (currentLayer !== key.layer) {
      const switched = await selectLayer(key.layer);
      if (!switched) {
        failures.push({ layer: key.layer, x: key.x, y: key.y, label: key.label, issues: ["could not switch to layer " + key.layer], expected: key, actual: {} });
        failed++;
        continue;
      }
      currentLayer = key.layer;
      console.log("Verifying layer " + key.layer + "...");
    }

    const found = await selectKey(key.x, key.y);
    if (!found) {
      failures.push({ layer: key.layer, x: key.x, y: key.y, label: key.label, issues: ["key not found in Studio UI"], expected: key, actual: {} });
      failed++;
      continue;
    }

    const actual = readCurrent();
    const issues = [];

    if (actual.behavior !== key.behavior) {
      issues.push("behavior: expected " + key.behavior + ", got " + actual.behavior);
    }

    if (key.parameter && actual.parameter) {
      const expNorm = clean(key.parameter).replace("Keyboard ", "").toUpperCase();
      const actNorm = clean(actual.parameter).replace("Keyboard ", "").toUpperCase();
      if (expNorm !== actNorm) {
        issues.push("parameter: expected \"" + key.parameter + "\", got \"" + actual.parameter + "\"");
      }
    } else if (key.parameter && !actual.parameter) {
      issues.push("parameter: expected \"" + key.parameter + "\", got empty");
    }

    const expMods = (key.modifiers || []).sort().join("+");
    const actMods = actual.modifiers.sort().join("+");
    if (expMods !== actMods) {
      issues.push("modifiers: expected \"" + expMods + "\", got \"" + actMods + "\"");
    }

    if (issues.length > 0) {
      failures.push({ layer: key.layer, x: key.x, y: key.y, label: key.label, issues, expected: key, actual });
      failed++;
      console.warn("FAIL L" + key.layer + " (" + key.x + "," + key.y + ") " + (key.label || "") + ": " + issues.join("; "));
    } else {
      passed++;
    }
  }

  console.log("\n" + "=".repeat(50));
  console.log("LAYER ACCESS");
  console.log("Valid expected graph: " + (accessReport.valid ? "YES" : "NO"));
  if (accessReport.required_layers) console.log("Required layers: " + accessReport.required_layers.join(", "));
  if (accessReport.reachable_layers) console.log("Reachable layers: " + accessReport.reachable_layers.join(", "));
  if (accessReport.access_cost !== undefined) console.log("Total access cost: " + accessReport.access_cost);
  if (accessReport.errors && accessReport.errors.length) console.error("Access errors: " + accessReport.errors.join("; "));
  console.log("-".repeat(50));
  if (failed === 0) {
    console.log("PASSED: All " + passed + " keys verified correctly." + (skipped ? " (" + skipped + " firmware-only keys skipped)" : ""));
  } else {
    console.error("FAILED: " + failed + " of " + (passed + failed) + " keys mismatch." + (skipped ? " (" + skipped + " firmware-only skipped)" : ""));
    console.table(failures.map(f => ({
      position: "L" + f.layer + " (" + f.x + "," + f.y + ")",
      label: f.label || "",
      issues: f.issues?.join("; ") || f.issue || ""
    })));
  }
  console.log("=".repeat(50));
})();

