from __future__ import annotations

import unittest

from python import coach_beacon_listener as listener


class CoachBeaconLayerKeyHintTests(unittest.TestCase):
    def setUp(self) -> None:
        self.original_rows = listener.LAYOUT_ROWS
        listener.LAYOUT_ROWS = [
            {"layer": "0", "x": "7", "y": "4", "behavior": "coach_l2_hold", "visual_label": "L2"},
            {"layer": "2", "x": "3", "y": "4", "behavior": "coach_l2_hold", "visual_label": "L2"},
        ]

    def tearDown(self) -> None:
        listener.LAYOUT_ROWS = self.original_rows

    def test_hold_hint_uses_layer_where_hold_was_pressed(self) -> None:
        hint = listener.layout_key_hint("hold", "2", source_layer="2")

        self.assertEqual((hint["layer"], hint["x"], hint["y"]), ("2", "3", "4"))


if __name__ == "__main__":
    unittest.main()
