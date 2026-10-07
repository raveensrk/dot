#!/usr/bin/env python3
"""Checks for script/iterm2_prefs_redact. No network.

    timeout 120 python3 -m pytest tests/test_iterm2_prefs_redact.py
"""
from __future__ import annotations

import plistlib
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / "script" / "iterm2_prefs_redact"

# One machine-local key of each kind the redactor must refuse to publish.
RAW = {
    "New Bookmarks": [{"Name": "Default", "Working Directory": "/Users/someone"}],
    "Elsewhere": {"Path": "/home/someone/proj"},
    "ReportRightClick": True,
    "PrefsCustomFolder": "~/dot/config/iterm2",
    "LoadPrefsFromCustomFolder": True,
    "AppVersion": "3.7.3",
    "Secure Input": True,
    "NoSyncSomething": 1,
    "NSWindow Frame herdr": "1 2 3 4",
    "SUFeedURL": "https://example.com/appcast.xml",
    "UKObserved": 1,
    "CodeReviewSavedPrompts": b"\x00\x01prompt",
    "Workgroups": b"\x00\x01group",
}


def run(*args: str, stdin: bytes | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *args],
        input=stdin,
        capture_output=True,
    )


class Redact(unittest.TestCase):
    def setUp(self) -> None:
        self.dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.dir.cleanup)
        self.path = Path(self.dir.name) / "com.googlecode.iterm2.plist"
        self.path.write_bytes(plistlib.dumps(RAW, fmt=plistlib.FMT_XML))

    def prefs(self) -> dict:
        return plistlib.loads(self.path.read_bytes())

    def test_keeps_only_what_iterm2_syncs(self) -> None:
        self.assertEqual(run(str(self.path)).returncode, 0)
        self.assertEqual(sorted(self.prefs()), ["Elsewhere", "New Bookmarks", "ReportRightClick"])

    def test_rewrites_home_paths(self) -> None:
        run(str(self.path))
        prefs = self.prefs()
        self.assertEqual(prefs["New Bookmarks"][0]["Working Directory"], "~")
        self.assertEqual(prefs["Elsewhere"]["Path"], "~/proj")

    def test_drops_every_blob(self) -> None:
        run(str(self.path))
        self.assertNotIn("CodeReviewSavedPrompts", self.prefs())
        self.assertNotIn("Workgroups", self.prefs())

    def test_second_run_changes_nothing(self) -> None:
        run(str(self.path))
        once = self.path.read_bytes()
        result = run(str(self.path))
        self.assertEqual(self.path.read_bytes(), once)
        self.assertIn("dropped 0", result.stdout.decode())

    def test_check_passes_on_a_published_copy(self) -> None:
        run(str(self.path))
        result = run("--check", str(self.path))
        self.assertEqual(result.returncode, 0, result.stderr.decode())

    def test_check_names_the_fix_on_a_raw_copy(self) -> None:
        result = run("--check", str(self.path))
        self.assertEqual(result.returncode, 1)
        self.assertIn("fix:", result.stderr.decode())

    def test_clean_stream_is_the_filter_protocol(self) -> None:
        result = run("--clean", stdin=plistlib.dumps(RAW, fmt=plistlib.FMT_XML))
        self.assertEqual(result.returncode, 0, result.stderr.decode())
        cleaned = plistlib.loads(result.stdout)
        self.assertNotIn("NoSyncSomething", cleaned)
        self.assertEqual(cleaned["New Bookmarks"][0]["Working Directory"], "~")

    def test_help_exits_zero(self) -> None:
        for flag in ("-h", "--help"):
            result = run(flag)
            self.assertEqual(result.returncode, 0, flag)
            self.assertIn("iterm2_prefs_redact", result.stdout.decode())


if __name__ == "__main__":
    unittest.main()
