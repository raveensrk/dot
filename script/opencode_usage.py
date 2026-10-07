#!/usr/bin/env python3
"""One-line opencode Go limit + zen balance status for the pi powerline."""

import json
import sys
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

AUTH = Path.home() / ".local/share/opencode/auth.json"
ENDPOINT = "https://opencode.ai/zen/go/v1/usage"
LABELS = {"rolling": "5h", "weekly": "wk", "monthly": "mo"}
COOKIE_FILE = Path.home() / ".local/share/opencode_usage/zen_cookie"
# ponytail: hardcoded workspace id; re-fetch orgs via /console/api/orgs if you add workspaces
ORG = "wrk_01M2MV43M69KXZJY076CABZB7G"
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36"
# Console money unit: 100,000,000 microcents = $1 (console billing docs and the
# console bundle's dollars<->microcents helpers). Not 1e6; that is microcents per cent.
MICROCENTS_PER_DOLLAR = 100_000_000


def format_zen(microcents: object) -> str:
    """Console microcents -> "$12.34". None or junk -> "$0.00"."""
    return f"${int(microcents or 0) / MICROCENTS_PER_DOLLAR:.2f}"


def zen_balance() -> str | None:
    """Console session cookie -> prepaid wallet balance. Absent cookie = None."""
    try:
        value = COOKIE_FILE.read_text().strip()
    except OSError:
        return None
    if not value:
        return None
    if "=" in value:
        cookie = value
    else:
        cookie = f"__Host-console_session={value}"
    headers = {"Cookie": cookie, "User-Agent": UA, "Accept": "application/json", "x-org-id": ORG}
    try:
        req = urllib.request.Request("https://opencode.ai/console/api/billing/status", headers=headers)
        with urllib.request.urlopen(req, timeout=15) as res:
            data = json.loads(res.read())
        return format_zen(data.get("availableMicroCents"))
    except Exception:
        return "?"


def main() -> int:
    try:
        providers = json.loads(AUTH.read_text())
        key = providers["opencode-go"]["key"]
    except (OSError, KeyError, ValueError) as exc:
        print(f"opencode key: {exc}", file=sys.stderr)
        return 1
    req = urllib.request.Request(
        ENDPOINT,
        headers={"Authorization": f"Bearer {key}", "User-Agent": "pi-opencode-usage/0.1"},
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as res:
            usage = json.loads(res.read())["usage"]
    except Exception as exc:
        print(f"opencode usage: {exc}", file=sys.stderr)
        return 1
    parts = []
    for window in ("rolling", "weekly", "monthly"):
        entry = usage.get(window)
        if not entry:
            continue
        left = 100 - entry["percent"]
        part = f"{LABELS[window]} {left}%"
        if entry["status"] == "rate-limited":
            reset = datetime.fromisoformat(entry["resetsAt"].replace("Z", "+00:00"))
            days = (reset - datetime.now(timezone.utc)).days
            part += f" (resets {reset:%b %-d}" + (f", {days}d" if days > 0 else "") + ")"
        parts.append(part)
    zen = zen_balance()
    print("Go " + " · ".join(parts) + (f" · zen {zen}" if zen and zen != "?" else " · zen: console only"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
