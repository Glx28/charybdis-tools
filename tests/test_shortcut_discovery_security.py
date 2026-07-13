from __future__ import annotations

import importlib
import socket
import sys
import unittest
from pathlib import Path
from unittest import mock


MODULE_DIR = Path(__file__).resolve().parents[1] / "runtime" / "evolved_v2_export"
sys.path.insert(0, str(MODULE_DIR))
discovery = importlib.import_module("shortcut_discovery")


class ShortcutDiscoverySecurityTests(unittest.TestCase):
    def test_candidate_filename_cannot_escape_directory(self) -> None:
        self.assertEqual(discovery._candidate_filename("../private.exe"), "private.json")
        self.assertEqual(discovery._candidate_filename("ACME App.exe"), "acme_app.json")

    def test_rejects_credentials_and_non_http_schemes(self) -> None:
        self.assertFalse(discovery._is_public_http_url("file:///etc/passwd"))
        self.assertFalse(discovery._is_public_http_url("http://user:pass@example.com/"))

    @mock.patch.object(socket, "getaddrinfo")
    def test_rejects_private_destinations(self, getaddrinfo) -> None:
        getaddrinfo.return_value = [(socket.AF_INET, socket.SOCK_STREAM, 6, "", ("127.0.0.1", 80))]
        self.assertFalse(discovery._is_public_http_url("http://example.test/"))

    @mock.patch.object(socket, "getaddrinfo")
    def test_accepts_public_destinations(self, getaddrinfo) -> None:
        getaddrinfo.return_value = [(socket.AF_INET, socket.SOCK_STREAM, 6, "", ("93.184.216.34", 443))]
        self.assertTrue(discovery._is_public_http_url("https://example.test/docs"))


if __name__ == "__main__":
    unittest.main()
