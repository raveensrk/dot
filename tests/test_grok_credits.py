import json
import os
import sys
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "script"))
import grok_credits


SAMPLE_GRPC_WEB_HEX = (
    "000000003c"
    "0a3a0d8988083e12001a0022060880dacfcf062a06088097f3d006"
    "32090a0508ea0f1004120032090a0508ea0f1003120032090a0508ea0f10021200"
    "800000000f677270632d7374617475733a300d0a"
)


class GrokCreditsParserTest(unittest.TestCase):
    def test_decode_and_parse_sample_meter(self):
        payload = grok_credits._decode_grpc_web_response(bytes.fromhex(SAMPLE_GRPC_WEB_HEX), {})
        report = grok_credits.parse_get_grok_credits_config_response(payload)

        self.assertEqual(report["plan"], "SuperGrok Heavy")
        self.assertAlmostEqual(report["credit_usage_percent"], 0.13333334028720856)
        self.assertEqual(report["credit_usage_display"], "<1% used")
        self.assertEqual(report["billing_period_start"]["iso_utc"], "2026-05-01T00:00:00+00:00")
        self.assertEqual(report["billing_period_end"]["iso_utc"], "2026-06-01T00:00:00+00:00")
        self.assertFalse(report["on_demand_enabled"])
        self.assertNotIn("history", report)

    def test_widget_line(self):
        now = datetime(2026, 5, 16, tzinfo=timezone.utc)
        report = {
            "credit_usage_display": "12% used",
            "credit_usage_percent": 12.0,
            "reset_display": "Jun 1",
            "billing_period_start": {"iso_utc": "2026-05-01T00:00:00+00:00"},
            "billing_period_end": {"iso_utc": "2026-06-01T00:00:00+00:00"},
        }
        self.assertEqual(
            grok_credits.widget_line(report, now),
            "Grok 12%/48% · 16d",
        )

    def test_refuses_non_grok_endpoint_by_default(self):
        token = "x" * 64
        with self.assertRaises(grok_credits.GrokCreditsError) as cm:
            grok_credits.call_get_grok_credits_config(
                "https://example.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig",
                token,
                0.01,
            )

        message = str(cm.exception)
        self.assertIn("non-grok.com endpoint", message)
        self.assertNotIn(token, message)

    def test_error_redaction(self):
        redact = getattr(grok_credits, "_redact_sensitive")
        redacted = redact("Authorization: Bearer " + ("a" * 64))
        self.assertEqual(redacted, "Authorization: Bearer [REDACTED]")

    def test_resolve_cookie_from_env(self):
        cookie = "sso=abc; sso-rw=def"
        env = {k: v for k, v in os.environ.items() if k not in ("GROK_TOKEN", "GROK_COOKIE")}
        env["GROK_COOKIE"] = cookie
        with mock.patch.dict("os.environ", env, clear=True):
            creds = grok_credits.resolve_auth()
        self.assertEqual(creds.cookie, cookie)
        self.assertEqual(creds.source, "GROK_COOKIE")

    def test_resolve_auth_missing(self):
        env = {
            k: v
            for k, v in os.environ.items()
            if k not in ("GROK_TOKEN", "GROK_COOKIE", "GROK_HAR")
        }
        missing = Path("/tmp/grok_credits_missing.har")
        with mock.patch.dict("os.environ", env, clear=True):
            with mock.patch.object(grok_credits, "DEFAULT_HAR", missing):
                with self.assertRaises(grok_credits.GrokCreditsError) as cm:
                    grok_credits.resolve_auth()
        self.assertIn("GROK_COOKIE", str(cm.exception))
        self.assertNotIn("abc", str(cm.exception))

    def test_cookie_from_har(self):
        payload = {
            "log": {
                "entries": [
                    {
                        "request": {
                            "url": "https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig",
                            "headers": [{"name": "Cookie", "value": "sso=abc; sso-rw=def"}],
                        }
                    }
                ]
            }
        }
        with tempfile.NamedTemporaryFile("w", suffix=".har", delete=False) as fh:
            json.dump(payload, fh)
            path = Path(fh.name)
        try:
            creds = grok_credits.resolve_auth(har=str(path))
            self.assertEqual(creds.cookie, "sso=abc; sso-rw=def")
            self.assertEqual(creds.source, "--har")
        finally:
            path.unlink()


if __name__ == "__main__":
    unittest.main()
