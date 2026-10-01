#!/usr/bin/env python3
"""CLI for the grok.com SuperGrok credit meter.

Auth is grok.com Cookie from GROK_COOKIE, --cookie, --har, or
~/.local/share/grok_credits/session.har. GROK_TOKEN is an optional Bearer
only when a cookie is also set.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import struct
import sys
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

DEFAULT_ENDPOINT = "https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig"
HAR_LABEL = "~/.local/share/grok_credits/session.har"
DEFAULT_HAR = Path.home() / ".local/share/grok_credits/session.har"
PLAN_NAME = "SuperGrok Heavy"
__version__ = "0.1.0"

_SENSITIVE_PATTERNS = [
    re.compile(r"Bearer\s+[A-Za-z0-9._~+/-]{20,}=*", re.IGNORECASE),
    re.compile(r"([?&](?:access_token|refresh_token|id_token|token)=)[^&\s]+", re.IGNORECASE),
    re.compile(r"((?:^|[;\s])(?:sso|sso-rw)=)[^;\s]+", re.IGNORECASE),
]


class GrokCreditsError(RuntimeError):
    """User-facing error for auth/network/protobuf failures."""


@dataclass
class OAuthCredentials:
    token: str
    source: str
    cookie: str = ""


def _redact_sensitive(value: object) -> str:
    """Return a string safe to show in terminal errors."""
    text = str(value)
    for pattern in _SENSITIVE_PATTERNS:
        if pattern.pattern.startswith("Bearer"):
            text = pattern.sub("Bearer [REDACTED]", text)
        else:
            text = pattern.sub(r"\1[REDACTED]", text)
    return text


def cookie_from_har(path: Path) -> str:
    """Read Cookie from the GetGrokCreditsConfig request in a HAR export."""
    with path.open(encoding="utf-8") as fh:
        har = json.load(fh)
    for entry in har.get("log", {}).get("entries", []):
        url = entry.get("request", {}).get("url", "")
        if "GetGrokCreditsConfig" not in url:
            continue
        for header in entry.get("request", {}).get("headers", []):
            if header.get("name", "").lower() != "cookie":
                continue
            value = (header.get("value") or "").strip()
            if value:
                return value
    raise GrokCreditsError("No Cookie on GetGrokCreditsConfig in HAR.")


def resolve_auth(
    token: Optional[str] = None,
    cookie: Optional[str] = None,
    har: Optional[str] = None,
) -> OAuthCredentials:
    """Cookie, then HAR. Never log secrets."""
    cki = (cookie or os.environ.get("GROK_COOKIE") or "").strip()
    tok = (token or os.environ.get("GROK_TOKEN") or "").strip()
    if cki:
        src = "--cookie" if (cookie or "").strip() else "GROK_COOKIE"
        return OAuthCredentials(token=tok, source=src, cookie=cki)
    har_arg = (har or os.environ.get("GROK_HAR") or "").strip()
    path = Path(har_arg).expanduser() if har_arg else DEFAULT_HAR
    if har_arg and not path.is_file():
        raise GrokCreditsError("HAR not found")
    if path.is_file():
        src = "--har" if (har or "").strip() else ("GROK_HAR" if har_arg else HAR_LABEL)
        return OAuthCredentials(token="", source=src, cookie=cookie_from_har(path))
    raise GrokCreditsError("No auth. Set GROK_COOKIE or pass --har.")


# ---------------------------------------------------------------------------
# gRPC-web transport
# ---------------------------------------------------------------------------


def _validate_endpoint(endpoint: str, allow_non_grok_endpoint: bool) -> None:
    """Avoid sending the OAuth token to another host."""
    parsed = urllib.parse.urlparse(endpoint)
    if parsed.scheme == "https" and parsed.hostname == "grok.com":
        return
    if allow_non_grok_endpoint:
        return
    raise GrokCreditsError(
        "Refusing to send the OAuth token to a non-grok.com endpoint. "
        "Use --allow-non-grok-endpoint only for deliberate local debugging."
    )


def call_get_grok_credits_config(
    endpoint: str,
    token: str,
    timeout: float,
    *,
    allow_non_grok_endpoint: bool = False,
    cookie: str = "",
) -> bytes:
    """Call grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig via gRPC-web.

    google.protobuf.Empty is encoded as a zero-length protobuf message inside a
    gRPC-web data frame: 1 flag byte + 4-byte big-endian length.
    """
    _validate_endpoint(endpoint, allow_non_grok_endpoint)
    body = b"\x00\x00\x00\x00\x00"
    headers = {
        "Content-Type": "application/grpc-web+proto",
        "Accept": "application/grpc-web+proto",
        "X-Grpc-Web": "1",
        "Origin": "https://grok.com",
        "Referer": "https://grok.com/?_s=usage",
        "User-Agent": "grok-credits-tracker/0.1",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    if cookie:
        headers["Cookie"] = cookie
    req = urllib.request.Request(
        endpoint,
        data=body,
        method="POST",
        headers=headers,
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            status = getattr(resp, "status", 200)
            response_headers = dict(resp.headers.items())
            response_body = resp.read()
    except urllib.error.HTTPError as exc:
        err_body = _redact_sensitive(exc.read().decode("utf-8", "replace")[:500])
        raise GrokCreditsError(f"HTTP {exc.code} from grok.com credit endpoint: {err_body}") from exc
    except urllib.error.URLError as exc:
        raise GrokCreditsError(f"Network error calling grok.com credit endpoint: {_redact_sensitive(exc)}") from exc

    if status != 200:
        raise GrokCreditsError(f"HTTP {status} from grok.com credit endpoint")

    return _decode_grpc_web_response(response_body, response_headers)


def _decode_grpc_web_response(body: bytes, headers: Dict[str, str]) -> bytes:
    if not body:
        grpc_status = headers.get("grpc-status") or headers.get("Grpc-Status")
        grpc_message = headers.get("grpc-message") or headers.get("Grpc-Message")
        if grpc_status and grpc_status != "0":
            raise GrokCreditsError(f"gRPC status {grpc_status}: {grpc_message or ''}")
        raise GrokCreditsError("Empty gRPC response from grok.com credit endpoint")

    messages: List[bytes] = []
    trailers: Dict[str, str] = {}
    i = 0
    while i < len(body):
        if i + 5 > len(body):
            raise GrokCreditsError("Malformed gRPC-web frame: truncated header")
        flags = body[i]
        length = int.from_bytes(body[i + 1 : i + 5], "big")
        i += 5
        payload = body[i : i + length]
        if len(payload) != length:
            raise GrokCreditsError("Malformed gRPC-web frame: truncated payload")
        i += length
        is_trailer = bool(flags & 0x80)
        if is_trailer:
            text = payload.decode("utf-8", "replace")
            for line in text.splitlines():
                if ":" in line:
                    k, v = line.split(":", 1)
                    trailers[k.strip().lower()] = v.strip()
        else:
            messages.append(payload)

    status = trailers.get("grpc-status")
    if status and status != "0":
        raise GrokCreditsError(f"gRPC status {status}: {trailers.get('grpc-message', '')}")
    if not messages:
        raise GrokCreditsError("gRPC response contained no message frames")
    if len(messages) > 1:
        # Unary response; concatenate defensively if a proxy splits frames.
        return b"".join(messages)
    return messages[0]


# ---------------------------------------------------------------------------
# Minimal protobuf decoding for grok_api_v2.GetGrokCreditsConfigResponse
# ---------------------------------------------------------------------------

Field = Tuple[int, int, Any]


def _read_varint(data: bytes, pos: int) -> Tuple[int, int]:
    value = 0
    shift = 0
    while True:
        if pos >= len(data):
            raise GrokCreditsError("Malformed protobuf: truncated varint")
        b = data[pos]
        pos += 1
        value |= (b & 0x7F) << shift
        if not (b & 0x80):
            return value, pos
        shift += 7
        if shift > 70:
            raise GrokCreditsError("Malformed protobuf: varint too long")


def _iter_fields(data: bytes) -> Iterable[Field]:
    pos = 0
    while pos < len(data):
        key, pos = _read_varint(data, pos)
        number = key >> 3
        wire = key & 0x07
        if wire == 0:  # varint
            value, pos = _read_varint(data, pos)
            yield number, wire, value
        elif wire == 1:  # fixed64
            if pos + 8 > len(data):
                raise GrokCreditsError("Malformed protobuf: truncated fixed64")
            yield number, wire, data[pos : pos + 8]
            pos += 8
        elif wire == 2:  # length-delimited
            length, pos = _read_varint(data, pos)
            if pos + length > len(data):
                raise GrokCreditsError("Malformed protobuf: truncated bytes")
            yield number, wire, data[pos : pos + length]
            pos += length
        elif wire == 5:  # fixed32
            if pos + 4 > len(data):
                raise GrokCreditsError("Malformed protobuf: truncated fixed32")
            yield number, wire, data[pos : pos + 4]
            pos += 4
        else:
            raise GrokCreditsError(f"Unsupported protobuf wire type {wire}")


def _first_message(data: bytes, field_no: int) -> Optional[bytes]:
    for number, wire, value in _iter_fields(data):
        if number == field_no and wire == 2:
            return value
    return None


def _parse_float32(value: bytes) -> float:
    return struct.unpack("<f", value)[0]


def _parse_cent(message: Optional[bytes]) -> int:
    if message is None:
        return 0
    if message == b"":
        return 0
    for number, wire, value in _iter_fields(message):
        if number != 1:
            continue
        if wire == 0:
            return int(value)
        if wire == 2:
            try:
                return int(value.decode("utf-8"))
            except ValueError:
                return 0
    return 0


def _parse_timestamp(message: Optional[bytes]) -> Optional[Dict[str, Any]]:
    if not message:
        return None
    seconds = 0
    nanos = 0
    for number, wire, value in _iter_fields(message):
        if number == 1 and wire == 0:
            seconds = int(value)
        elif number == 2 and wire == 0:
            nanos = int(value)
    if not seconds:
        return None
    dt = datetime.fromtimestamp(seconds + nanos / 1_000_000_000, timezone.utc)
    local = dt.astimezone()
    return {
        "seconds": seconds,
        "nanos": nanos,
        "iso_utc": dt.isoformat(),
        "iso_local": local.isoformat(),
        "display_local": _month_day(local),
    }


def parse_get_grok_credits_config_response(payload: bytes) -> Dict[str, Any]:
    config_msg = _first_message(payload, 1)
    if config_msg is None:
        raise GrokCreditsError("GetGrokCreditsConfigResponse missing config field")

    credit_usage_percent = 0.0
    on_demand_cap_cents = 0
    on_demand_used_cents = 0
    billing_period_start = None
    billing_period_end = None

    for number, wire, value in _iter_fields(config_msg):
        if number == 1 and wire == 5:
            credit_usage_percent = _parse_float32(value)
        elif number == 2 and wire == 2:
            on_demand_cap_cents = _parse_cent(value)
        elif number == 3 and wire == 2:
            on_demand_used_cents = _parse_cent(value)
        elif number == 4 and wire == 2:
            billing_period_start = _parse_timestamp(value)
        elif number == 5 and wire == 2:
            billing_period_end = _parse_timestamp(value)

    return {
        "plan": PLAN_NAME,
        "credit_usage_percent": credit_usage_percent,
        "credit_usage_display": format_usage_display(credit_usage_percent),
        "billing_period_start": billing_period_start,
        "billing_period_end": billing_period_end,
        "reset_display": billing_period_end["display_local"] if billing_period_end else None,
        "on_demand_cap_cents": on_demand_cap_cents,
        "on_demand_cap_usd": on_demand_cap_cents / 100.0,
        "on_demand_used_cents": on_demand_used_cents,
        "on_demand_used_usd": on_demand_used_cents / 100.0,
        "on_demand_enabled": on_demand_cap_cents > 0,
    }


# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------


def _month_day(dt: datetime) -> str:
    return f"{dt.strftime('%b')} {dt.day}"


def format_usage_display(percent: float) -> str:
    if percent > 0 and percent < 1:
        return "<1% used"
    return f"{math.ceil(percent)}% used"


DAY_MS = 86_400_000


def _left(iso: Optional[str], now: datetime) -> str:
    if not iso:
        return ""
    try:
        end = datetime.fromisoformat(iso)
    except ValueError:
        return ""
    ms = (end - now).total_seconds() * 1000
    if ms <= 0:
        return " · 0d"
    days = math.ceil(ms / DAY_MS)
    return f" · {days}d"


def _even(start_iso: Optional[str], end_iso: Optional[str], now: datetime) -> Optional[int]:
    """Percent of the billing window elapsed. That is the even pace."""
    if not start_iso or not end_iso:
        return None
    try:
        start = datetime.fromisoformat(start_iso)
        end = datetime.fromisoformat(end_iso)
    except ValueError:
        return None
    span = (end - start).total_seconds() * 1000
    if not span > 0:
        return None
    expected = max(0.0, min(100.0, ((now - start).total_seconds() * 1000 / span) * 100))
    return round(expected)


def widget_line(report: Dict[str, Any], now: Optional[datetime] = None) -> str:
    """One status line. Empty when usage display is missing.

    Usage is used/even, for example 0%/2%. The second number is the even pace.
    """
    used = str(report.get("credit_usage_display") or "").replace(" used", "")
    if not used:
        return ""
    now = now or datetime.now(timezone.utc)
    end = (report.get("billing_period_end") or {}).get("iso_utc")
    start = (report.get("billing_period_start") or {}).get("iso_utc")
    even = _even(start, end, now)
    head = f"{used}/{even}%" if even is not None else used
    return f"Grok {head}{_left(end, now)}"


def build_report(
    endpoint: str,
    timeout: float,
    *,
    allow_non_grok_endpoint: bool = False,
    token: Optional[str] = None,
    cookie: Optional[str] = None,
    har: Optional[str] = None,
) -> Dict[str, Any]:
    creds = resolve_auth(token=token, cookie=cookie, har=har)
    payload = call_get_grok_credits_config(
        endpoint=endpoint,
        token=creds.token,
        timeout=timeout,
        allow_non_grok_endpoint=allow_non_grok_endpoint,
        cookie=creds.cookie,
    )
    parsed = parse_get_grok_credits_config_response(payload)
    parsed["source"] = {"auth": creds.source, "endpoint": endpoint}
    return parsed


def print_plain(report: Dict[str, Any]) -> None:
    reset = report.get("reset_display") or "unknown"
    start = (report.get("billing_period_start") or {}).get("iso_local", "unknown")
    end = (report.get("billing_period_end") or {}).get("iso_local", "unknown")
    print(f"Free credits with {report['plan']}")
    print(f"{report['credit_usage_display']} · Resets {reset}")
    print(f"Credit usage percent: {report['credit_usage_percent']:.6g}")
    print(f"Billing window: {start} → {end}")
    if report.get("on_demand_enabled"):
        print(
            "Pay-as-you-go: "
            f"${report['on_demand_used_usd']:.2f} used of ${report['on_demand_cap_usd']:.2f} cap"
        )
    else:
        print("Pay-as-you-go: disabled")
    print(f"Source: {report['source']['auth']} → {report['source']['endpoint']}")


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Show grok.com SuperGrok credit usage")
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    parser.add_argument(
        "--har",
        default=None,
        metavar="FILE",
        help=f"HAR with grok.com Cookie. Default {HAR_LABEL} if present.",
    )
    parser.add_argument(
        "--cookie",
        default=None,
        help="grok.com Cookie header. Prefer GROK_COOKIE; --cookie shows in ps.",
    )
    parser.add_argument(
        "--token",
        default=None,
        help="OAuth bearer. Prefer GROK_TOKEN; --token shows in ps.",
    )
    parser.add_argument("--endpoint", default=DEFAULT_ENDPOINT, help="gRPC-web endpoint to call")
    parser.add_argument(
        "--allow-non-grok-endpoint",
        action="store_true",
        help="allow --endpoint hosts other than https://grok.com (debug only; sends the OAuth token)",
    )
    parser.add_argument("--timeout", type=float, default=15.0, help="HTTP timeout in seconds")
    parser.add_argument("--json", action="store_true", help="print machine-readable JSON")
    parser.add_argument("--widget", action="store_true", help="print one status line")
    args = parser.parse_args(argv)

    try:
        report = build_report(
            endpoint=args.endpoint,
            timeout=args.timeout,
            allow_non_grok_endpoint=args.allow_non_grok_endpoint,
            token=args.token,
            cookie=args.cookie,
            har=args.har,
        )
    except GrokCreditsError as exc:
        print(f"error: {_redact_sensitive(exc)}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
        return 0
    if args.widget:
        line = widget_line(report)
        if not line:
            return 1
        print(line)
        return 0
    print_plain(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
