#!/usr/bin/env python3
"""Checks for script/yt-wl. No network: yt-dlp never runs here.

    python3 -m pytest tests/test_yt_wl.py
"""
from __future__ import annotations

import hashlib
import importlib.machinery
import importlib.util
import io
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parent.parent / "script" / "yt-wl"
spec = importlib.util.spec_from_loader(
    "yt_wl", importlib.machinery.SourceFileLoader("yt_wl", str(SCRIPT))
)
ytwl = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ytwl)

PAYLOAD = {
    "id": "WL",
    "entries": [
        {"id": "aaa", "title": "First", "channel": "Chan", "duration": 158},
        {"id": "bbb", "title": "Second", "uploader": "Other"},
        None,
        {"id": "ccc", "title": "Third", "url": "https://www.youtube.com/watch?v=ccc"},
    ],
}


class NormalizeTest(unittest.TestCase):
    def test_rows_keep_playlist_order_and_skip_empty(self) -> None:
        rows = ytwl.normalize(PAYLOAD)
        self.assertEqual([r["n"] for r in rows], [1, 2, 3])
        self.assertEqual([r["id"] for r in rows], ["aaa", "bbb", "ccc"])

    def test_channel_falls_back_to_uploader_and_url_to_id(self) -> None:
        first, second, third = ytwl.normalize(PAYLOAD)
        self.assertEqual(first["channel"], "Chan")
        self.assertEqual(second["channel"], "Other")
        self.assertEqual(second["url"], "https://www.youtube.com/watch?v=bbb")
        self.assertEqual(third["url"], "https://www.youtube.com/watch?v=ccc")
        self.assertIsNone(second["duration"])

    def test_empty_playlist_is_empty_list(self) -> None:
        self.assertEqual(ytwl.normalize({"entries": []}), [])
        self.assertEqual(ytwl.normalize({}), [])


class HmsTest(unittest.TestCase):
    def test_formats(self) -> None:
        self.assertEqual(ytwl.hms(None), "")
        self.assertEqual(ytwl.hms(0), "")
        self.assertEqual(ytwl.hms(59), "0:59")
        self.assertEqual(ytwl.hms(158), "2:38")
        self.assertEqual(ytwl.hms(3600), "1:00:00")
        self.assertEqual(ytwl.hms(3725), "1:02:05")


class AuthHeaderTest(unittest.TestCase):
    def test_signature_is_sha1_of_timestamp_sapisid_origin(self) -> None:
        expected = hashlib.sha1(b"1700000000 SAPISID https://www.youtube.com").hexdigest()
        self.assertEqual(
            ytwl.auth_header("SAPISID", ts=1700000000),
            f"SAPISIDHASH 1700000000_{expected}",
        )

    def test_signature_changes_with_the_cookie(self) -> None:
        self.assertNotEqual(
            ytwl.auth_header("one", ts=1700000000),
            ytwl.auth_header("two", ts=1700000000),
        )


class AskTest(unittest.TestCase):
    def test_closed_stdin_never_deletes(self) -> None:
        with patch("builtins.input", side_effect=EOFError):
            self.assertFalse(ytwl.ask("delete?"))

    def test_ctrl_c_never_deletes(self) -> None:
        with patch("builtins.input", side_effect=KeyboardInterrupt):
            self.assertFalse(ytwl.ask("delete?"))

    def test_empty_answer_takes_the_default(self) -> None:
        with patch("builtins.input", return_value=""):
            self.assertTrue(ytwl.ask("delete?"))
        with patch("builtins.input", return_value="n"):
            self.assertFalse(ytwl.ask("delete?"))


class PlaylistIdTest(unittest.TestCase):
    def test_named_playlists_map_to_innertube_ids(self) -> None:
        self.assertEqual(ytwl.playlist_id(":ytwatchlater:"), "WL")
        self.assertEqual(ytwl.playlist_id(":ytfav:"), "LL")
        self.assertEqual(ytwl.playlist_id(":ythistory:"), "HL")
        self.assertEqual(ytwl.playlist_id("PLabc123"), "PLabc123")


class ResolveTargetsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.rows = ytwl.normalize(PAYLOAD)

    def test_accepts_row_numbers_and_video_ids(self) -> None:
        picked = ytwl.resolve_targets(self.rows, ["2", "ccc"])
        self.assertEqual([r["id"] for r in picked], ["bbb", "ccc"])

    def test_duplicates_are_deleted_once(self) -> None:
        picked = ytwl.resolve_targets(self.rows, ["1", "aaa"])
        self.assertEqual([r["id"] for r in picked], ["aaa"])

    def test_unknown_target_stops_before_any_delete(self) -> None:
        with self.assertRaises(SystemExit):
            ytwl.resolve_targets(self.rows, ["1", "999"])


class LineTest(unittest.TestCase):
    def test_line_is_numbered_and_drops_empty_parts(self) -> None:
        rows = ytwl.normalize(PAYLOAD)
        self.assertEqual(
            ytwl.line(rows[0]),
            "1. 2:38 First - Chan - https://www.youtube.com/watch?v=aaa",
        )
        # duration stays on the title; no duration and no channel leaves no stray separator
        self.assertEqual(ytwl.line(rows[1]), "2. Second - Other - https://www.youtube.com/watch?v=bbb")
        self.assertEqual(ytwl.line(rows[2]), "3. Third - https://www.youtube.com/watch?v=ccc")

    def test_print_list_one_line_per_entry(self) -> None:
        buf = io.StringIO()
        with redirect_stdout(buf):
            ytwl.print_list(ytwl.normalize(PAYLOAD))
        lines = buf.getvalue().splitlines()
        self.assertEqual(len(lines), 3)
        self.assertTrue(lines[0].startswith("1. 2:38 First"))
        self.assertIn("https://www.youtube.com/watch?v=ccc", lines[2])

    def test_empty_playlist_says_so(self) -> None:
        buf = io.StringIO()
        with redirect_stdout(buf):
            ytwl.print_list([])
        self.assertIn("empty", buf.getvalue())


if __name__ == "__main__":
    unittest.main()
