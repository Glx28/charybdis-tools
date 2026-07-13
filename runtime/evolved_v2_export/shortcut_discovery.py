"""Automatic shortcut-gap discovery: no per-app manual research, no AI call at
runtime. Finds apps with real, regular usage (from shortcut_usage.jsonl) that
have zero shortcut representation anywhere in the repo, searches the open web
for each one's official/community shortcut docs (DuckDuckGo HTML endpoint,
no API key), and generically extracts key-combo/description pairs from
whatever HTML tables or definition lists it finds - not hardcoded per app,
works the same way for an app we've never seen before.

This never writes into app_shortcut_reference.json or app_shortcut_scores.json
directly - every run only produces/updates a draft file under
shortcut_candidates/<exe>.json with status "needs_review". A human (or a
future stricter auto-merge policy) still approves before it reaches the
optimizer's evaluation pool - see merge_shortcut_candidate.py. Bad shortcut
data silently poisons fitness scoring (CLAUDE.md's optimizer rule: fix the
algorithm/data pipeline, never guess), so discovery is fully automatic but
merge is not.

Called from promote.py's main() (advisory, never blocks). Can also run
standalone: shortcut_discovery.py [min_usage_count]
"""
from __future__ import annotations

import json
import ipaddress
import re
import socket
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path

import usage_mismatch_report as umr

TOOLS_DIR = Path(__file__).resolve().parent.parent.parent
CANDIDATES_DIR = Path(__file__).resolve().parent / "shortcut_candidates"

DEFAULT_MIN_USAGE = 20
MAX_SOURCES_PER_APP = 4
MAX_SHORTCUTS_PER_APP = 40
INTER_APP_DELAY_SECONDS = 4  # DuckDuckGo's HTML endpoint rate-limits bursts
REQUEST_TIMEOUT = 10
MAX_PAGE_BYTES = 2 * 1024 * 1024
CANDIDATE_STALE_DAYS = 14  # re-attempt discovery this often even if a file exists

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"


def _is_public_http_url(url: str) -> bool:
    """Reject credentials, non-HTTP schemes, and local/private destinations."""
    try:
        parsed = urllib.parse.urlsplit(url)
        if parsed.scheme not in {"http", "https"} or not parsed.hostname:
            return False
        if parsed.username is not None or parsed.password is not None:
            return False
        port = parsed.port or (443 if parsed.scheme == "https" else 80)
        addresses = socket.getaddrinfo(parsed.hostname, port, type=socket.SOCK_STREAM)
        return bool(addresses) and all(
            ipaddress.ip_address(item[4][0]).is_global for item in addresses
        )
    except (OSError, ValueError):
        return False


class _PublicRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if not _is_public_http_url(newurl):
            raise urllib.error.HTTPError(newurl, code, "unsafe redirect", headers, fp)
        return super().redirect_request(req, fp, code, msg, headers, newurl)


PUBLIC_OPENER = urllib.request.build_opener(_PublicRedirectHandler())

SPECIAL_KEYS = {
    "esc", "escape", "tab", "enter", "return", "space", "spacebar",
    "up", "down", "left", "right", "pageup", "pagedown", "page up", "page down",
    "home", "end", "delete", "backspace", "insert",
}
FKEY_RE = re.compile(r"^f([1-9]|1[0-9]|2[0-4])$")
KEY_TOKEN_RE = re.compile(r"^[A-Za-z0-9`\-=\[\]\\;',./]+$")


def _now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _candidate_filename(exe: str) -> str:
    stem = re.sub(r"\.exe$", "", exe, flags=re.I).lower()
    stem = re.sub(r"[^a-z0-9._-]+", "_", stem).strip("._-")
    return f"{stem or 'unknown_app'}.json"


def _looks_like_shortcut(text: str) -> bool:
    t = text.strip()
    if not t or len(t) > 60:
        return False
    tokens = t.split()
    if not tokens or len(tokens) > 4:
        return False

    def token_ok(tok: str) -> bool:
        tok = tok.strip(".,:")
        if "+" in tok:
            parts = [p for p in tok.split("+")]
            if len(parts) < 2 or len(parts) > 5:
                return False
            return all(KEY_TOKEN_RE.match(p) for p in parts if p)
        low = tok.lower()
        return low in SPECIAL_KEYS or bool(FKEY_RE.match(low))

    if not all(token_ok(tok) for tok in tokens):
        return False
    return any("+" in tok or tok.lower().strip(".,:") in SPECIAL_KEYS or FKEY_RE.match(tok.lower().strip(".,:")) for tok in tokens)


def _normalize_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


class _GenericShortcutExtractor(HTMLParser):
    """Walks <table>/<tr>/<td|th> and <dl>/<dt>/<dd> generically - no
    per-site assumptions, works on whatever docs page we happened to fetch."""

    def __init__(self) -> None:
        super().__init__()
        self.rows: list[list[str]] = []
        self.dl_pairs: list[tuple[str, str]] = []
        self._cur_row: list[str] | None = None
        self._in_cell = False
        self._cell_buf: list[str] = []
        self._in_dt = False
        self._in_dd = False
        self._dt_buf: list[str] = []
        self._dd_buf: list[str] = []
        self._skip = False

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style"):
            self._skip = True
        elif tag == "tr":
            self._cur_row = []
        elif tag in ("td", "th"):
            self._in_cell = True
            self._cell_buf = []
        elif tag == "dt":
            self._in_dt = True
            self._dt_buf = []
        elif tag == "dd":
            self._in_dd = True
            self._dd_buf = []
        elif tag == "br":
            if self._in_cell:
                self._cell_buf.append(" ")

    def handle_endtag(self, tag):
        if tag in ("script", "style"):
            self._skip = False
        elif tag in ("td", "th"):
            self._in_cell = False
            if self._cur_row is not None:
                self._cur_row.append(_normalize_ws("".join(self._cell_buf)))
        elif tag == "tr":
            if self._cur_row:
                self.rows.append(self._cur_row)
            self._cur_row = None
        elif tag == "dt":
            self._in_dt = False
        elif tag == "dd":
            self._in_dd = False
            if self._dt_buf:
                self.dl_pairs.append((_normalize_ws("".join(self._dt_buf)), _normalize_ws("".join(self._dd_buf))))
            self._dt_buf = []

    def handle_data(self, data):
        if self._skip:
            return
        if self._in_cell:
            self._cell_buf.append(data)
        if self._in_dt:
            self._dt_buf.append(data)
        if self._in_dd:
            self._dd_buf.append(data)


def extract_shortcuts_from_html(html: str) -> list[dict]:
    parser = _GenericShortcutExtractor()
    try:
        parser.feed(html)
    except Exception:
        return []

    found: list[dict] = []
    for row in parser.rows:
        for i, cell in enumerate(row):
            if _looks_like_shortcut(cell):
                action = ""
                for j, other in enumerate(row):
                    if j != i and other.strip():
                        action = other.strip()
                        break
                if action:
                    found.append({"keys": cell, "action": action[:160], "extracted_from": "table"})
                break
    for dt, dd in parser.dl_pairs:
        if _looks_like_shortcut(dt) and dd:
            found.append({"keys": dt, "action": dd[:160], "extracted_from": "definition_list"})
    return found


def search_web(query: str, max_results: int = MAX_SOURCES_PER_APP) -> list[str] | None:
    """DuckDuckGo HTML endpoint, no API key. Returns None (not []) on a
    detected block/rate-limit so callers can distinguish 'no results' from
    'try again later' instead of writing an empty candidate file."""
    url = "https://html.duckduckgo.com/html/?q=" + urllib.parse.quote(query)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with PUBLIC_OPENER.open(req, timeout=REQUEST_TIMEOUT) as resp:
            raw = resp.read(MAX_PAGE_BYTES + 1)
            if len(raw) > MAX_PAGE_BYTES:
                return None
            html = raw.decode("utf-8", errors="replace")
    except (urllib.error.URLError, TimeoutError, OSError):
        return None

    if "anomaly" in html.lower() and "result__a" not in html:
        return None

    urls: list[str] = []
    for href in re.findall(r'class="result__a"[^>]*href="([^"]+)"', html):
        href = href.replace("&amp;", "&")
        if href.startswith("//duckduckgo.com/l/?"):
            qs = urllib.parse.parse_qs(urllib.parse.urlparse("https:" + href).query)
            real = qs.get("uddg", [None])[0]
            if real:
                urls.append(real)
        elif href.startswith("http"):
            urls.append(href)
        if len(urls) >= max_results:
            break
    return urls


def fetch_page(url: str) -> str | None:
    if not _is_public_http_url(url):
        return None
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with PUBLIC_OPENER.open(req, timeout=REQUEST_TIMEOUT) as resp:
            raw = resp.read(MAX_PAGE_BYTES + 1)
            if len(raw) > MAX_PAGE_BYTES:
                return None
            charset = resp.headers.get_content_charset() or "utf-8"
    except (urllib.error.URLError, TimeoutError, OSError, ValueError):
        return None
    return raw.decode(charset, errors="replace")


def _display_name_for_exe(exe: str) -> str:
    stem = re.sub(r"\.exe$", "", exe, flags=re.I)
    words = re.split(r"[_\-]+", stem)
    return " ".join(w.capitalize() for w in words if w)


def find_gap_apps(min_count: int = DEFAULT_MIN_USAGE) -> list[tuple[str, int]]:
    """Regularly-used apps with zero representation anywhere - same logic
    usage_mismatch_report's section 3 uses, reused rather than duplicated."""
    usage_log_path = umr.resolve_usage_log_path()
    real_counts = umr.load_real_usage_counts(usage_log_path)
    if not real_counts:
        return []
    exe_to_app = umr.load_exe_to_app_map()
    known_app_ids = umr.load_known_app_ids()

    exe_totals: Counter = Counter()
    for (exe, _keys), count in real_counts.items():
        exe_totals[exe] += count

    gaps = []
    for exe, count in exe_totals.items():
        if count < min_count or exe in exe_to_app:
            continue
        exe_stem = exe.replace(".exe", "")
        if exe_stem in known_app_ids or exe in known_app_ids:
            continue
        gaps.append((exe, count))
    gaps.sort(key=lambda row: -row[1])
    return gaps


def _existing_candidate_is_fresh(path: Path) -> bool:
    if not path.exists():
        return False
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return False
    if data.get("status") == "approved":
        return True  # never re-clobber something a human already approved
    discovered_at = data.get("discovered_at")
    if not discovered_at:
        return False
    try:
        ts = datetime.strptime(discovered_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    except ValueError:
        return False
    age_days = (datetime.now(timezone.utc) - ts).total_seconds() / 86400
    return age_days < CANDIDATE_STALE_DAYS


def discover_for_app(exe: str, count: int) -> dict:
    display = _display_name_for_exe(exe)
    query = f"{display} keyboard shortcuts"
    urls = search_web(query)

    if urls is None:
        return {
            "app_exe": exe,
            "display_name": display,
            "discovered_at": _now_iso(),
            "usage_count": count,
            "status": "search_blocked",
            "note": "Web search was rate-limited/blocked - will retry on a later run.",
            "sources_tried": [],
            "shortcuts": [],
        }

    all_found: list[dict] = []
    sources_tried: list[str] = []
    for url in urls:
        sources_tried.append(url)
        html = fetch_page(url)
        if not html:
            continue
        for item in extract_shortcuts_from_html(html):
            item["source_url"] = url
            all_found.append(item)
        if len(all_found) >= MAX_SHORTCUTS_PER_APP:
            break

    deduped: dict[str, dict] = {}
    for item in all_found:
        key = item["keys"].lower()
        if key not in deduped:
            deduped[key] = item
    shortcuts = sorted(deduped.values(), key=lambda i: i["keys"])[:MAX_SHORTCUTS_PER_APP]

    return {
        "app_exe": exe,
        "display_name": display,
        "discovered_at": _now_iso(),
        "usage_count": count,
        "status": "needs_review" if shortcuts else "no_shortcuts_found",
        "sources_tried": sources_tried,
        "shortcuts": shortcuts,
    }


def run_discovery_for_gaps(min_count: int = DEFAULT_MIN_USAGE) -> list[Path]:
    """Advisory, never raises past its own boundary - caller (promote.py)
    wraps this in try/except anyway, but network flakiness here shouldn't
    even look like a real error."""
    gaps = find_gap_apps(min_count)
    if not gaps:
        return []

    CANDIDATES_DIR.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    for i, (exe, count) in enumerate(gaps):
        out_path = CANDIDATES_DIR / _candidate_filename(exe)
        if _existing_candidate_is_fresh(out_path):
            continue
        if i > 0:
            time.sleep(INTER_APP_DELAY_SECONDS)
        try:
            candidate = discover_for_app(exe, count)
        except Exception as exc:  # never let one app's fetch failure kill the run
            candidate = {
                "app_exe": exe, "display_name": _display_name_for_exe(exe),
                "discovered_at": _now_iso(), "usage_count": count,
                "status": "error", "note": str(exc), "sources_tried": [], "shortcuts": [],
            }
        out_path.write_text(json.dumps(candidate, indent=2) + "\n", encoding="utf-8")
        written.append(out_path)
    return written


def main() -> None:
    min_count = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_MIN_USAGE
    gaps = find_gap_apps(min_count)
    if not gaps:
        print(f"No unrepresented apps with >= {min_count} real usage events found.")
        return
    print(f"Found {len(gaps)} unrepresented app(s) with real usage: " +
          ", ".join(f"{exe} ({count}x)" for exe, count in gaps))
    written = run_discovery_for_gaps(min_count)
    if not written:
        print("All candidates already fresh (or approved) - nothing to (re)discover.")
        return
    for path in written:
        data = json.loads(path.read_text(encoding="utf-8"))
        print(f"  {path.relative_to(TOOLS_DIR)}: status={data['status']}, "
              f"{len(data.get('shortcuts', []))} shortcut(s) found")


if __name__ == "__main__":
    main()
