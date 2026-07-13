"""
Static file server for the Charybdis coach, stdlib-only.

Replaces plain `python -m http.server`: adds Cache-Control headers so the
browser never serves a stale cached app.js/styles.css after an update. This
is the actual fix for what the old cache-busting query-string hack
(?v=<commit>, previously rewritten into coach/index.html on every launcher
run) was working around - fixing it here means index.html never needs to be
touched at all, so the tools repo never dirties itself just by starting.

Usage: coach_http_server.py <port> [--bind ADDR] [--dir PATH]
"""
from __future__ import annotations

import argparse
import http.server
import sys


class NoCacheRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def log_message(self, format: str, *args) -> None:  # noqa: A002 - stdlib signature
        sys.stderr.write(f"{self.address_string()} - {format % args}\n")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("port", type=int)
    ap.add_argument("--bind", default="127.0.0.1")
    ap.add_argument("--dir", default=".")
    args = ap.parse_args()

    handler = lambda *a, **kw: NoCacheRequestHandler(*a, directory=args.dir, **kw)
    with http.server.ThreadingHTTPServer((args.bind, args.port), handler) as httpd:
        print(f"Serving {args.dir} on http://{args.bind}:{args.port}", file=sys.stderr)
        httpd.serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main())
