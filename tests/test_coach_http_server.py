from __future__ import annotations

import http.client
import tempfile
import threading
import unittest
from pathlib import Path

from python.coach_http_server import create_server


class CoachHTTPServerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        root = Path(self.temp.name)
        self.coach = root / "coach"
        self.coach.mkdir()
        (self.coach / "index.html").write_text("coach", encoding="utf-8")
        (self.coach / "app.js").write_text("'use strict';", encoding="utf-8")
        self.state = root / "runtime" / "charybdis_state.json"
        self.state.parent.mkdir()
        self.state.write_text('{"activeLayer":"0"}', encoding="utf-8")
        self.private = root / "private.txt"
        self.private.write_text("must not be served", encoding="utf-8")
        self.server = create_server("127.0.0.1", 0, self.coach, self.state)
        self.port = self.server.server_address[1]
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()

    def tearDown(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.temp.cleanup()

    def request(self, path: str, *, host: str | None = None, method: str = "GET"):
        connection = http.client.HTTPConnection("127.0.0.1", self.port, timeout=2)
        headers = {"Host": host or f"127.0.0.1:{self.port}"}
        connection.request(method, path, headers=headers)
        response = connection.getresponse()
        body = response.read()
        result = response.status, dict(response.getheaders()), body
        connection.close()
        return result

    def test_serves_only_coach_and_state(self) -> None:
        self.assertEqual(self.request("/charybdis-coach/")[0], 200)
        self.assertEqual(self.request("/charybdis-coach/app.js")[0], 200)
        self.assertEqual(
            self.request("/charybdis-tools/runtime/charybdis_state.json")[0], 200
        )

    def test_rejects_parent_files_directories_and_traversal(self) -> None:
        for path in (
            "/private.txt",
            "/",
            "/charybdis-coach/../private.txt",
            "/charybdis-coach/%2e%2e/private.txt",
            "/charybdis-coach/%5c..%5cprivate.txt",
        ):
            with self.subTest(path=path):
                self.assertEqual(self.request(path)[0], 404)

    def test_rejects_dns_rebinding_host(self) -> None:
        self.assertEqual(self.request("/charybdis-coach/", host="attacker.example")[0], 404)

    def test_security_headers_and_methods(self) -> None:
        status, headers, _ = self.request("/charybdis-coach/")
        self.assertEqual(status, 200)
        self.assertEqual(headers["X-Content-Type-Options"], "nosniff")
        self.assertEqual(headers["X-Frame-Options"], "DENY")
        self.assertIn("frame-ancestors 'none'", headers["Content-Security-Policy"])
        self.assertEqual(self.request("/charybdis-coach/", method="POST")[0], 405)


if __name__ == "__main__":
    unittest.main()
