#!/usr/bin/env python3
"""Checks for script/bookmark. No network: Jev never runs here.

    python3 -m pytest tests/test_bookmark.py
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / "script" / "bookmark"

WORK = """---
bookmarks:
  scope: work and technical links - agents, FPGA
  default_section: Read Later
  order: newest-last
---

# Bookmarks

## FPGA

- [PeakRDL](https://peakrdl.readthedocs.io/en/latest/style-guide.html)

## Read Later

- [Old Link](https://example.com/old)
"""

NOTES = """---
bookmarks:
  scope: personal reference sites
  default_section: Read Later
  order: newest-first
---

# Bookmarks

## Torrents

- [Bitsearch](https://bitsearch.eu/)
"""


class BookmarkTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.work = self.root / "repos" / "work" / "bookmarks.md"
        self.notes = self.root / "repos" / "notes" / "Bookmarks.md"
        self.work.parent.mkdir(parents=True)
        self.notes.parent.mkdir(parents=True)
        self.work.write_text(WORK)
        self.notes.write_text(NOTES)
        # a candidate with no front matter: never a sink
        (self.root / "repos" / "style" / "bookmark.md").parent.mkdir(parents=True)
        (self.root / "repos" / "style" / "bookmark.md").write_text("# Bookmark\n\n- <https://x.example/>\n")
        os.environ["BOOKMARK_ROOTS"] = str(self.root / "repos")
        os.environ.pop("TYPESAFE_API_KEY", None)

    def tearDown(self):
        self.tmp.cleanup()
        os.environ.pop("BOOKMARK_ROOTS", None)

    def run_bookmark(self, *args: str) -> subprocess.CompletedProcess:
        # only `add` needs --no-jev; list, check and describe take no such flag
        extra = ["--no-jev"] if any(a.startswith("http") for a in args) else []
        return subprocess.run(
            [sys.executable, str(SCRIPT), *args, *extra],
            capture_output=True,
            text=True,
            env={**os.environ, "BOOKMARK_ROOTS": str(self.root / "repos")},
        )

    def test_only_a_self_describing_file_is_a_sink(self):
        done = self.run_bookmark("list")
        self.assertEqual(done.returncode, 0, done.stderr)
        self.assertIn("work/bookmarks.md", done.stdout)
        self.assertIn("notes/Bookmarks.md", done.stdout)
        self.assertNotIn("style/bookmark.md", done.stdout)

    def test_list_json_carries_scope_and_order(self):
        done = self.run_bookmark("list")
        done = subprocess.run(
            [sys.executable, str(SCRIPT), "list", "--json"],
            capture_output=True,
            text=True,
            env={**os.environ, "BOOKMARK_ROOTS": str(self.root / "repos")},
        )
        sinks = json.loads(done.stdout)
        self.assertEqual([s["order"] for s in sinks], ["newest-first", "newest-last"])
        self.assertEqual(sinks[1]["scope"], "work and technical links - agents, FPGA")

    def test_newest_last_appends_at_the_end_of_the_section(self):
        done = self.run_bookmark("https://example.com/new", "--to", "work/bookmarks.md", "--title", "New Thing")
        self.assertEqual(done.returncode, 0, done.stdout)
        text = self.work.read_text()
        self.assertIn("- [PeakRDL]", text.split("## Read Later")[0])
        read_later = text.split("## Read Later")[1]
        self.assertLess(read_later.index("Old Link"), read_later.index("New Thing"))
        # the section is last, so the file must end on the entry with one newline
        self.assertTrue(text.endswith("- [New Thing](https://example.com/new)\n"), repr(text[-60:]))

    def test_newest_first_inserts_under_the_heading(self):
        done = self.run_bookmark(
            "https://example.com/new", "--to", "notes/Bookmarks.md", "--section", "Torrents", "--title", "New Thing"
        )
        self.assertEqual(done.returncode, 0, done.stdout)
        torrents = self.notes.read_text().split("## Torrents")[1]
        self.assertLess(torrents.index("New Thing"), torrents.index("Bitsearch"))

    def test_default_section_is_created_when_missing(self):
        self.notes.write_text(NOTES.replace("## Torrents", "## Misc"))
        done = self.run_bookmark("https://example.com/new", "--to", "notes/Bookmarks.md", "--title", "N")
        self.assertEqual(done.returncode, 0, done.stdout)
        self.assertIn("## Read Later", self.notes.read_text())

    def test_a_missing_section_is_refused_without_the_flag(self):
        done = self.run_bookmark(
            "https://example.com/new", "--to", "work/bookmarks.md", "--section", "Invented"
        )
        self.assertEqual(done.returncode, 2)
        self.assertIn("--new-section", done.stdout + done.stderr)
        self.assertNotIn("Invented", self.work.read_text())

    def test_duplicate_is_refused_and_names_the_location(self):
        done = self.run_bookmark("https://example.com/old/", "--to", "work/bookmarks.md")
        self.assertEqual(done.returncode, 1)
        self.assertIn("already in", done.stdout)
        self.assertIn("work/bookmarks.md:", done.stdout)

    def test_force_adds_a_duplicate(self):
        done = self.run_bookmark("https://example.com/old", "--to", "work/bookmarks.md", "--force", "--title", "Again")
        self.assertEqual(done.returncode, 0, done.stdout)
        self.assertEqual(self.work.read_text().count("example.com/old"), 2)

    def test_a_section_with_a_following_heading_keeps_one_blank_line(self):
        done = self.run_bookmark(
            "https://example.com/new", "--to", "work/bookmarks.md", "--section", "FPGA", "--title", "N"
        )
        self.assertEqual(done.returncode, 0, done.stdout)
        block = self.work.read_text().split("## FPGA")[1].split("## Read Later")[0]
        self.assertTrue(block.rstrip().endswith("- [N](https://example.com/new)"), repr(block))
        self.assertTrue(block.endswith("\n\n"), repr(block[-20:]))

    def test_dry_run_writes_nothing(self):
        before = self.work.read_text()
        done = self.run_bookmark("https://example.com/new", "--to", "work/bookmarks.md", "--dry-run")
        self.assertEqual(done.returncode, 0)
        self.assertIn("dry run", done.stdout)
        self.assertEqual(self.work.read_text(), before)

    def test_reader_without_a_terminal_prints_the_links(self):
        done = self.run_bookmark()
        self.assertEqual(done.returncode, 0, done.stdout)
        self.assertIn("https://example.com/old", done.stdout)
        self.assertIn("https://bitsearch.eu/", done.stdout)
        self.assertIn("No terminal, so nothing was opened", done.stdout)
        # url first, so the output is greppable and copyable
        line = [l for l in done.stdout.splitlines() if "example.com/old" in l][0]
        self.assertTrue(line.startswith("https://example.com/old"), line)

    def test_reader_json_lists_every_link_with_its_file_and_section(self):
        done = self.run_bookmark("--json")
        self.assertEqual(done.returncode, 0, done.stdout)
        links = __import__("json").loads(done.stdout)
        self.assertEqual(len(links), 3, links)
        self.assertEqual({l["section"] for l in links}, {"Read Later", "Torrents", "FPGA"})
        self.assertTrue(all(l["file"].endswith(".md") and l["url"].startswith("http") for l in links))

    def test_no_terminal_and_no_route_stops_with_the_candidates(self):
        done = self.run_bookmark("https://example.com/new")
        self.assertEqual(done.returncode, 2)
        self.assertIn("work/bookmarks.md", done.stdout)

    def test_a_non_http_url_is_refused(self):
        done = self.run_bookmark("ftp://example.com/x", "--to", "work/bookmarks.md")
        self.assertEqual(done.returncode, 2)

    def test_check_is_green_when_only_the_default_section_is_missing(self):
        done = self.run_bookmark("check")
        self.assertEqual(done.returncode, 0, done.stdout)
        self.assertIn("note:", done.stdout)
        self.assertIn("0 findings", done.stdout)

    def test_check_flags_a_duplicate_and_an_empty_scope(self):
        self.notes.write_text(NOTES.replace("scope: personal reference sites", "scope: \"\"").replace(
            "https://bitsearch.eu/", "https://example.com/old"
        ))
        done = self.run_bookmark("check")
        self.assertEqual(done.returncode, 1)
        self.assertIn(": scope is empty", done.stdout)
        self.assertIn("duplicate of", done.stdout)

    def test_describe_writes_front_matter_and_keeps_other_keys(self):
        page = self.root / "repos" / "site" / "Bookmarks.md"
        page.parent.mkdir(parents=True)
        page.write_text(
            "---\n"
            "title: Bookmarks\n"
            "description: 'a long blurb a yaml round trip used to fold and mangle'\n"
            "tags: ['general']\n"
            "---\n\n# Bookmarks\n\n- [x](https://x.example/)\n"
        )
        before = page.read_text()
        done = subprocess.run(
            [sys.executable, str(SCRIPT), "describe", str(page), "--scope", "public library page"],
            capture_output=True,
            text=True,
        )
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        text = page.read_text()
        self.assertIn("bookmarks:", text)
        self.assertIn("scope: public library page", text)
        # every other front matter line survives byte for byte, and no document-end marker appears
        for line in before.splitlines()[1:-1]:
            self.assertIn(line, text.splitlines(), line)
        self.assertNotIn("\n...", text)
        self.assertEqual(text.count("---"), 2)
        done = self.run_bookmark("list")
        self.assertIn("site/Bookmarks.md", done.stdout)

    def test_describe_without_a_scope_changes_nothing(self):
        page = self.root / "repos" / "site" / "Bookmarks.md"
        page.parent.mkdir(parents=True)
        page.write_text("# Bookmarks\n")
        before = page.read_text()
        done = subprocess.run(
            [sys.executable, str(SCRIPT), "describe", str(page)], capture_output=True, text=True
        )
        self.assertEqual(done.returncode, 0)
        self.assertIn("no scope given", done.stdout)
        self.assertEqual(page.read_text(), before)


if __name__ == "__main__":
    unittest.main(verbosity=2)
