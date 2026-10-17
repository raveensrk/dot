#!/usr/bin/env python3
"""Show Gemini / Antigravity subscription usage limits for the powerline.

Data sources (first available wins):
1. gemini.google.com web session via browser cookies (Firefox / Chrome / GEMINI_COOKIE).
   Returns the exact 5h and weekly usage limits as shown on gemini.google.com/usage.
2. Cloud Code API (retrieveUserQuotaSummary) via Pi Antigravity OAuth.
"""

from __future__ import annotations

import argparse
import base64
import json
import math
import os
import re
import sqlite3
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

__version__ = "0.3.0"

DEFAULT_ENDPOINT = "https://cloudcode-pa.googleapis.com"
FALLBACK_ENDPOINT = "https://daily-cloudcode-pa.sandbox.googleapis.com"
ENDPOINT_FALLBACKS = [DEFAULT_ENDPOINT, FALLBACK_ENDPOINT]
AUTH_FILE = Path.home() / ".pi/agent/auth.json"
AUTH_LABEL = "~/.pi/agent/auth.json"
COOKIE_FILE = Path.home() / ".local/share/gemini_usage/cookie"
TOKEN_URL = "https://oauth2.googleapis.com/token"

CLIENT_ID = base64.b64decode(
    b"MTA3MTAwNjA2MDU5MS10bWhzc2luMmgyMWxjcmUyMzV2dG9sb2poNGc0MDNlc"
    b"C5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbQ=="
).decode("utf-8")
CLIENT_SECRET = base64.b64decode(
    b"R09DU1BYLUs1OEZXUjQ4NkxkTEoxbUxCOHNYQzR6NnFEQWY="
).decode("utf-8")

TIER_NAMES = {
    1: "Free",
    2: "PRO",
    3: "Ultra",
}


class GeminiUsageError(RuntimeError):
    """User-facing error for auth or network failures."""


def _redact(msg: object, secret: str = "") -> str:
    text = str(msg)
    if secret and len(secret) > 8:
        text = text.replace(secret, "[REDACTED]")
    return text


# ---------------------------------------------------------------------------
# Web Session (gemini.google.com) Scraper
# ---------------------------------------------------------------------------

def find_browser_cookies() -> Optional[str]:
    """Find valid Google cookies from env, local cookie file, or Firefox."""
    env_cookie = os.environ.get("GEMINI_COOKIE")
    if env_cookie:
        return env_cookie.strip()

    if COOKIE_FILE.is_file():
        try:
            val = COOKIE_FILE.read_text(encoding="utf-8").strip()
            if val:
                return val
        except OSError:
            pass

    ff_dir = Path.home() / "Library/Application Support/Firefox/Profiles"
    if ff_dir.is_dir():
        for profile in sorted(ff_dir.iterdir(), key=lambda p: p.stat().st_mtime, reverse=True):
            cookie_db = profile / "cookies.sqlite"
            if not cookie_db.is_file():
                continue
            try:
                con = sqlite3.connect(f"file:{cookie_db}?immutable=1", uri=True)
                cur = con.cursor()
                cur.execute(
                    "SELECT name, value FROM moz_cookies WHERE host LIKE '%.google.com'"
                )
                rows = cur.fetchall()
                cookies = {r[0]: r[1] for r in rows}
                if "__Secure-1PSID" in cookies:
                    return "; ".join(f"{k}={v}" for k, v in cookies.items())
            except Exception:
                continue

    return None


def fetch_web_usage(cookie_str: str, timeout: float = 12.0) -> Dict[str, Any]:
    """Call gemini.google.com batchexecute RPC jSf9Qc to get exact 5h and weekly usage."""
    headers = {
        "Cookie": cookie_str,
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:130.0) Gecko/20100101 Firefox/130.0",
    }
    # 1. Fetch /app to extract SNlM0e (CSRF token), cfb2h (build label), FdrFJe (session id)
    req_init = urllib.request.Request("https://gemini.google.com/app", headers=headers)
    try:
        with urllib.request.urlopen(req_init, timeout=timeout) as resp:
            html = resp.read().decode("utf-8")
    except Exception as exc:
        raise GeminiUsageError(f"Failed to connect to gemini.google.com: {exc}") from exc

    m_snlm = re.search(r"\"SNlM0e\":\"([^\"]+)\"", html)
    m_cfb = re.search(r"\"cfb2h\":\"([^\"]+)\"", html)
    m_fdr = re.search(r"\"FdrFJe\":\"([^\"]+)\"", html)
    if not m_snlm or not m_cfb or not m_fdr:
        raise GeminiUsageError("Could not extract Gemini web session tokens from page HTML")

    snlm0e = m_snlm.group(1)
    cfb2h = m_cfb.group(1)
    fdrfje = m_fdr.group(1)

    # 2. Invoke batchexecute with RPC jSf9Qc
    rpc_id = "jSf9Qc"
    req_payload = [[[rpc_id, "[]", None, "generic"]]]
    post_data = urllib.parse.urlencode({
        "f.req": json.dumps(req_payload),
        "at": snlm0e,
    }).encode("utf-8")

    query = urllib.parse.urlencode({
        "rpcids": rpc_id,
        "source-path": "/app",
        "bl": cfb2h,
        "f.sid": fdrfje,
        "hl": "en",
        "_reqid": "100000",
        "rt": "c",
    })
    url = f"https://gemini.google.com/_/BardChatUi/data/batchexecute?{query}"
    req_rpc = urllib.request.Request(
        url,
        data=post_data,
        headers={
            **headers,
            "Content-Type": "application/x-www-form-urlencoded;charset=utf-8",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req_rpc, timeout=timeout) as resp:
            raw = resp.read().decode("utf-8")
    except Exception as exc:
        raise GeminiUsageError(f"batchexecute request failed: {exc}") from exc

    # Parse response lines for jSf9Qc
    for line in raw.split("\n"):
        if "jSf9Qc" in line:
            try:
                data = json.loads(line)
                for item in data:
                    if isinstance(item, list) and len(item) > 2 and item[1] == "jSf9Qc":
                        payload = json.loads(item[2])
                        tier_code = payload[0] if isinstance(payload, list) and len(payload) > 0 else 0
                        tier_name = TIER_NAMES.get(tier_code, "PRO")
                        windows = payload[1] if isinstance(payload, list) and len(payload) > 1 else []

                        five_hour_info = None
                        weekly_info = None

                        for win in windows:
                            if not isinstance(win, list) or len(win) < 4:
                                continue
                            remaining, frac, kind, resets = win[0], win[1], win[2], win[3]
                            reset_ts = resets[0][0] if resets and resets[0] else None
                            pct = round(float(frac) * 100)
                            info = {"used_pct": pct, "reset_ts": reset_ts}
                            if kind == 1:
                                five_hour_info = info
                            elif kind == 2:
                                weekly_info = info

                        return {
                            "source": "gemini.google.com",
                            "tier": tier_name,
                            "five_hour": five_hour_info,
                            "weekly": weekly_info,
                        }
            except Exception:
                continue

    raise GeminiUsageError("jSf9Qc RPC payload not found in response")


# ---------------------------------------------------------------------------
# Cloud Code (Antigravity OAuth) Fallback
# ---------------------------------------------------------------------------

def refresh_token(refresh: str, timeout: float = 15.0) -> Tuple[str, int]:
    """Call Google OAuth to refresh access token."""
    data = urllib.parse.urlencode({
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "refresh_token",
        "refresh_token": refresh,
    }).encode("utf-8")
    req = urllib.request.Request(
        TOKEN_URL,
        data=data,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = json.loads(resp.read().decode("utf-8"))
    except Exception as exc:
        raise GeminiUsageError(f"OAuth refresh failed: {exc}") from exc

    access = body.get("access_token")
    expires_in = body.get("expires_in", 3600)
    if not isinstance(access, str) or not access:
        raise GeminiUsageError("OAuth refresh response missing access_token")
    expires_ms = int((time.time() + float(expires_in) - 300) * 1000)
    return access, expires_ms


def save_refreshed_auth(access: str, expires_ms: int, path: Path = AUTH_FILE) -> None:
    """Update antigravity entry in ~/.pi/agent/auth.json."""
    if not path.is_file():
        return
    try:
        doc = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(doc, dict) or "antigravity" not in doc:
            return
        doc["antigravity"]["access"] = access
        doc["antigravity"]["expires"] = expires_ms
        dir_name = path.parent
        with tempfile.NamedTemporaryFile("w", dir=dir_name, delete=False, encoding="utf-8") as tf:
            json.dump(doc, tf, indent=2)
            tmp_name = tf.name
        os.replace(tmp_name, path)
    except Exception:
        pass


def resolve_auth(path: Path = AUTH_FILE, timeout: float = 15.0) -> Tuple[str, str]:
    """Return (access_token, project_id)."""
    env_token = os.environ.get("PI_ANTIGRAVITY_ACCESS") or os.environ.get("PI_GEMINI_ACCESS")
    env_proj = os.environ.get("PI_ANTIGRAVITY_PROJECT") or os.environ.get("PI_GEMINI_PROJECT")
    if env_token:
        return env_token.strip(), (env_proj or "").strip()

    if not path.is_file():
        raise GeminiUsageError(f"No auth found. Run /login antigravity in Pi. ({AUTH_LABEL} absent)")

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise GeminiUsageError(f"Cannot read Pi auth file: {AUTH_LABEL}") from exc

    cred = data.get("antigravity")
    if not isinstance(cred, dict):
        raise GeminiUsageError(f"No antigravity OAuth in {AUTH_LABEL}. Run /login antigravity.")

    access = cred.get("access")
    refresh = cred.get("refresh")
    expires = cred.get("expires")
    project = cred.get("projectId") or ""

    now_ms = time.time() * 1000
    if expires and isinstance(expires, (int, float)) and now_ms >= expires and refresh:
        access, new_expires = refresh_token(str(refresh), timeout=timeout)
        save_refreshed_auth(access, new_expires, path)

    if not isinstance(access, str) or not access:
        raise GeminiUsageError(f"Incomplete antigravity credentials in {AUTH_LABEL}.")

    return access, str(project)


def fetch_cloud_code_usage(token: str, project_id: str, timeout: float = 15.0) -> Dict[str, Any]:
    """Fetch 5h and weekly quota summary from Google Cloud Code retrieveUserQuotaSummary."""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "User-Agent": "antigravity/1.0.5 darwin/arm64",
        "X-Goog-Api-Client": "google-api-nodejs-client/9.15.1",
        "Client-Metadata": json.dumps({"ideType": "ANTIGRAVITY"}),
    }
    payload = json.dumps({"project": project_id} if project_id else {}).encode("utf-8")
    last_err: Optional[Exception] = None

    for endpoint in ENDPOINT_FALLBACKS:
        url = f"{endpoint}/v1internal:retrieveUserQuotaSummary"
        req = urllib.request.Request(url, data=payload, headers=headers, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                if resp.status == 200:
                    data = json.loads(resp.read().decode("utf-8"))
                    if isinstance(data, dict):
                        return _parse_cloud_code_summary(data)
        except Exception as exc:
            last_err = exc
            continue

    msg = f"Failed to fetch quota summary from Cloud Code API: {_redact(last_err, token)}"
    raise GeminiUsageError(msg)


def _parse_cloud_code_summary(raw: Dict[str, Any]) -> Dict[str, Any]:
    groups = raw.get("groups") or []
    gemini_group = next(
        (g for g in groups if "gemini" in (g.get("displayName") or "").lower()),
        groups[0] if groups else {},
    )

    five_hour_info = None
    weekly_info = None

    for b in gemini_group.get("buckets") or []:
        frac = b.get("remainingFraction", 1.0)
        # Cloud code returns remainingFraction (1 = 100% remaining).
        # Convert to used_pct so it matches gemini.google.com semantics.
        used_pct = round((1.0 - float(frac)) * 100)
        reset_iso = b.get("resetTime")
        reset_ts = None
        if reset_iso:
            try:
                dt = datetime.fromisoformat(reset_iso.replace("Z", "+00:00"))
                reset_ts = int(dt.timestamp())
            except ValueError:
                pass

        info = {"used_pct": used_pct, "reset_ts": reset_ts}
        if b.get("window") == "5h":
            five_hour_info = info
        elif b.get("window") == "weekly":
            weekly_info = info

    return {
        "source": "cloudcode-pa.googleapis.com",
        "tier": "Antigravity",
        "five_hour": five_hour_info,
        "weekly": weekly_info,
    }


# ---------------------------------------------------------------------------
# Formatting & Presentation
# ---------------------------------------------------------------------------

def format_time_diff(diff_secs: float, is_weekly: bool = False) -> str:
    if diff_secs <= 0:
        return "resets soon"
    if is_weekly:
        days = math.ceil(diff_secs / 86400)
        return f"{days}d"
    hours = int(diff_secs // 3600)
    minutes = int((diff_secs % 3600) // 60)
    if hours > 0:
        return f"{hours}h {minutes}m" if minutes > 0 else f"{hours}h"
    return f"{max(1, minutes)}m"


def build_report(timeout: float = 12.0) -> Dict[str, Any]:
    # 1. Try browser cookies first (matches gemini.google.com/usage exactly)
    cookies = find_browser_cookies()
    if cookies:
        try:
            return fetch_web_usage(cookies, timeout=timeout)
        except Exception:
            pass

    # 2. Fall back to Cloud Code API (Antigravity OAuth)
    token, project = resolve_auth(timeout=timeout)
    return fetch_cloud_code_usage(token, project, timeout=timeout)


def widget_line(report: Dict[str, Any], now: Optional[datetime] = None) -> str:
    now_ts = (now or datetime.now(timezone.utc)).timestamp()
    parts = []

    five = report.get("five_hour")
    if five and "used_pct" in five:
        used = five["used_pct"]
        reset_ts = five.get("reset_ts")
        if reset_ts:
            diff = reset_ts - now_ts
            time_str = format_time_diff(diff, is_weekly=False)
            parts.append(f"5h {used}% ({time_str})")
        else:
            parts.append(f"5h {used}%")

    weekly = report.get("weekly")
    if weekly and "used_pct" in weekly:
        used = weekly["used_pct"]
        reset_ts = weekly.get("reset_ts")
        if reset_ts:
            diff = reset_ts - now_ts
            time_str = format_time_diff(diff, is_weekly=True)
            parts.append(f"wk {used}% ({time_str})")
        else:
            parts.append(f"wk {used}%")

    return " · ".join(parts)


def print_readable(report: Dict[str, Any], now: Optional[datetime] = None) -> None:
    now_ts = (now or datetime.now(timezone.utc)).timestamp()
    tier = report.get("tier", "PRO")
    source = report.get("source", "gemini.google.com")
    print(f"Plan: {tier} (Source: {source})")

    five = report.get("five_hour")
    if five and "used_pct" in five:
        used = five["used_pct"]
        reset_ts = five.get("reset_ts")
        if reset_ts:
            dt_local = datetime.fromtimestamp(reset_ts).astimezone()
            reset_clock = dt_local.strftime("%-I:%M %p")
            diff_str = format_time_diff(reset_ts - now_ts, is_weekly=False)
            print(f"Current usage (5h): {used}% used (resets at {reset_clock}, in {diff_str})")
        else:
            print(f"Current usage (5h): {used}% used")

    weekly = report.get("weekly")
    if weekly and "used_pct" in weekly:
        used = weekly["used_pct"]
        reset_ts = weekly.get("reset_ts")
        if reset_ts:
            dt_local = datetime.fromtimestamp(reset_ts).astimezone()
            reset_clock = dt_local.strftime("%b %-d at %-I:%M %p")
            diff_str = format_time_diff(reset_ts - now_ts, is_weekly=True)
            print(f"Weekly limit: {used}% used (resets on {reset_clock}, in {diff_str})")
        else:
            print(f"Weekly limit: {used}% used")


def _long_help() -> str:
    return (
        f"{__doc__}\n"
        "Env: GEMINI_COOKIE, PI_ANTIGRAVITY_ACCESS, PI_ANTIGRAVITY_PROJECT.\n"
        f"Reads: Firefox cookies.sqlite, {COOKIE_FILE}, {AUTH_LABEL}.\n"
        f"Writes: {AUTH_LABEL} (only when OAuth access token is refreshed on expiry).\n"
        "Exit: 0 ok, 1 auth/network/parse error, 2 bad arguments.\n"
        "Example: python3 ~/dot/script/gemini_usage.py --widget\n"
    )


def main(argv: Optional[List[str]] = None) -> int:
    args_in = sys.argv[1:] if argv is None else argv
    if args_in[:1] == ["help"]:
        print(_long_help())
        return 0

    parser = argparse.ArgumentParser(description="Show Gemini 5h and weekly subscription usage limits for the powerline")
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    parser.add_argument("--timeout", type=float, default=12.0, help="request timeout in seconds (default 12)")
    parser.add_argument("--widget", action="store_true", help="print single powerline status line")
    parser.add_argument("--json", action="store_true", help="output structured JSON")

    args = parser.parse_args(args_in)

    try:
        report = build_report(timeout=args.timeout)
    except GeminiUsageError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(report, indent=2))
        return 0

    if args.widget:
        line = widget_line(report)
        if not line:
            return 1
        print(line)
        return 0

    print_readable(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
