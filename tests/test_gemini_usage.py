#!/usr/bin/env python3
"""Tests for gemini_usage.py CLI, web scraping, and widget formatting."""

import json
import os
import subprocess
import sys
import unittest
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "script"))
import gemini_usage


class GeminiUsageFormattingTest(unittest.TestCase):
    def test_format_time_diff_5h(self):
        # 3 hours, 25 minutes = 12300 seconds
        self.assertEqual(gemini_usage.format_time_diff(12300, is_weekly=False), "3h 25m")

    def test_format_time_diff_5h_minutes_only(self):
        # 45 minutes = 2700 seconds
        self.assertEqual(gemini_usage.format_time_diff(2700, is_weekly=False), "45m")

    def test_format_time_diff_weekly(self):
        # 3.5 days = 302400 seconds
        self.assertEqual(gemini_usage.format_time_diff(302400, is_weekly=True), "4d")

    def test_format_time_diff_expired(self):
        self.assertEqual(gemini_usage.format_time_diff(-10, is_weekly=False), "resets soon")

    def test_widget_line_formatting(self):
        now = datetime(2026, 10, 18, 0, 14, 0, tzinfo=timezone.utc)
        now_ts = now.timestamp()
        report = {
            "tier": "PRO",
            "source": "gemini.google.com",
            "five_hour": {"used_pct": 45, "reset_ts": int(now_ts + 7260)},  # 2h 1m
            "weekly": {"used_pct": 2, "reset_ts": int(now_ts + 345600)},     # 4d
        }
        self.assertEqual(
            gemini_usage.widget_line(report, now=now),
            "5h 45% (2h 1m) · wk 2% (4d)",
        )

    def test_widget_line_without_reset_ts(self):
        report = {
            "tier": "PRO",
            "five_hour": {"used_pct": 45},
            "weekly": {"used_pct": 2},
        }
        self.assertEqual(
            gemini_usage.widget_line(report),
            "5h 45% · wk 2%",
        )


class GeminiUsageCloudCodeParserTest(unittest.TestCase):
    def test_parse_cloud_code_summary(self):
        raw = {
            "groups": [
                {
                    "displayName": "Gemini Models",
                    "buckets": [
                        {
                            "window": "5h",
                            "remainingFraction": 0.8,
                            "resetTime": "2026-10-18T04:00:00Z",
                        },
                        {
                            "window": "weekly",
                            "remainingFraction": 0.95,
                            "resetTime": "2026-10-25T00:00:00Z",
                        },
                    ],
                }
            ]
        }
        parsed = gemini_usage._parse_cloud_code_summary(raw)
        self.assertEqual(parsed["source"], "cloudcode-pa.googleapis.com")
        self.assertEqual(parsed["five_hour"]["used_pct"], 20)
        self.assertEqual(parsed["weekly"]["used_pct"], 5)


class GeminiUsageAuthTest(unittest.TestCase):
    def test_env_token_precedence(self):
        os.environ["PI_ANTIGRAVITY_ACCESS"] = "test-token-123"
        os.environ["PI_ANTIGRAVITY_PROJECT"] = "test-proj-456"
        try:
            tok, proj = gemini_usage.resolve_auth(Path("/nonexistent"))
            self.assertEqual(tok, "test-token-123")
            self.assertEqual(proj, "test-proj-456")
        finally:
            os.environ.pop("PI_ANTIGRAVITY_ACCESS", None)
            os.environ.pop("PI_ANTIGRAVITY_PROJECT", None)

    def test_missing_auth_file_raises(self):
        with self.assertRaises(gemini_usage.GeminiUsageError):
            gemini_usage.resolve_auth(Path("/nonexistent/auth.json"))

    def test_token_redacted_in_errors(self):
        err = gemini_usage._redact("failed with secret_token_xyz987 in url", "secret_token_xyz987")
        self.assertNotIn("secret_token_xyz987", err)
        self.assertIn("[REDACTED]", err)


class GeminiUsageCLITest(unittest.TestCase):
    def test_help_command(self):
        script = ROOT / "script" / "gemini_usage.py"
        res = subprocess.run([sys.executable, str(script), "help"], capture_output=True, text=True)
        self.assertEqual(res.returncode, 0)
        self.assertIn("Env:", res.stdout)
        self.assertIn("Reads:", res.stdout)

    def test_short_help(self):
        script = ROOT / "script" / "gemini_usage.py"
        res = subprocess.run([sys.executable, str(script), "-h"], capture_output=True, text=True)
        self.assertEqual(res.returncode, 0)
        self.assertIn("options:", res.stdout.lower())


if __name__ == "__main__":
    unittest.main()
