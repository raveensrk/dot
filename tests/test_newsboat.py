#!/usr/bin/env python3

"""Tests for the newsboat config and the open_url helper.

The newsboat tests guard bugs that are silent at parse time and only show
up when a screen is actually drawn:

- A bad filter attribute (`unread` on a feed instead of `unread_count`)
  renders an EMPTY list rather than raising at startup.
- Any `highlight` rule on a list view overrides `listfocus`, so the
  selection bar paints only the blank padding after the row text.

Both are cheap to assert against the config text, so they are.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "config" / "newsboat" / "config"
URLS = ROOT / "config" / "newsboat" / "urls"
OPEN_URL = ROOT / "script" / "open_url"

# newsboat aborts in iconv when the locale is unset, which masks the real
# error message. Every subprocess below runs with a UTF-8 locale.
LOCALE = {"LANG": "en_US.UTF-8", "LC_ALL": "en_US.UTF-8"}


def env(**extra: str) -> dict:
    out = dict(os.environ)
    out.update(LOCALE)
    out.update(extra)
    return out


def config() -> str:
    return CONFIG.read_text(encoding="utf-8")


def directives(name: str) -> list[str]:
    """Every uncommented line starting with `name`."""
    hits = []
    for line in config().splitlines():
        if line.startswith(name):
            hits.append(line)
    return hits


class ConfigTextTest(unittest.TestCase):
    """Assertions on the config source. No newsboat binary needed."""

    def test_no_highlight_rules_on_list_views(self):
        """Regression: these override listfocus and break the selection bar."""
        for name in ("highlight feedlist", "highlight articlelist",
                     "highlight-article", "highlight-feed"):
            self.assertEqual(
                directives(name), [],
                f"`{name}` overrides listfocus and breaks the selection bar",
            )

    def test_feed_filters_use_unread_count(self):
        """`unread` is article-only; on a feed it renders an empty list."""
        for line in directives("highlight-feed"):
            self.assertNotRegex(line, r"\bunread\b(?!_count)")

    def test_feed_order_follows_urls_file(self):
        self.assertIn("feed-sort-order none", config())

    def test_browser_uses_the_portable_helper(self):
        self.assertIn('browser "open_url %u"', config())

    def test_title_formats_start_at_column_zero(self):
        formats = [l for l in config().splitlines()
                   if "-title-format" in l and not l.startswith("#")]
        self.assertTrue(formats, "no title formats found")
        for line in formats:
            value = line.split('"', 1)[1]
            self.assertFalse(
                value.startswith(" "),
                f"leading space in: {line.strip()}",
            )

    def test_list_formats_have_no_marker_or_counts(self):
        """Read/unread is carried by color alone."""
        for name in ("feedlist-format", "articlelist-format"):
            line = directives(name)[0]
            value = line.split('"', 1)[1].rstrip('"')
            self.assertNotIn("%n", value)
            self.assertNotIn("%u", value)
            self.assertFalse(value.startswith(" "), f"leading space: {line}")

    def test_hint_elements_share_the_info_background(self):
        """`default` here punches black holes in the info bar."""
        for line in directives("color hint-"):
            self.assertIn(
                "color23", line,
                f"hint element must share the info bar background: {line}",
            )


@unittest.skipUnless(shutil.which("newsboat"), "newsboat not installed")
class ConfigParseTest(unittest.TestCase):
    """Run the real binary so invalid directives are caught."""

    def setUp(self) -> None:
        tmp = tempfile.TemporaryDirectory(prefix="newsboat-test.")
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.urls = self.dir / "urls"
        self.urls.write_text("https://example.com/feed.xml\n", encoding="utf-8")

    def parse(self, cfg: Path) -> subprocess.CompletedProcess:
        return subprocess.run(
            ["newsboat", "-C", str(cfg), "-u", str(self.urls),
             "-c", str(self.dir / "cache.db"), "-x", "print-unread"],
            capture_output=True, text=True, env=env(),
        )

    def test_config_parses(self):
        done = self.parse(CONFIG)
        self.assertEqual(done.returncode, 0, done.stderr or done.stdout)

    def test_a_bad_directive_is_actually_rejected(self):
        """Guard the guard: prove test_config_parses can fail."""
        bad = self.dir / "bad"
        bad.write_text("color bogus_element color80 default\n", encoding="utf-8")
        done = self.parse(bad)
        self.assertNotEqual(done.returncode, 0)
        self.assertIn("not a valid configuration element",
                      done.stdout + done.stderr)

    def test_a_bad_filter_is_actually_rejected(self):
        bad = self.dir / "badfilter"
        bad.write_text('highlight-article "unread @@ x" color80 default\n',
                       encoding="utf-8")
        done = self.parse(bad)
        self.assertNotEqual(done.returncode, 0)

    def test_urls_file_is_parseable(self):
        done = subprocess.run(
            ["newsboat", "-C", str(CONFIG), "-u", str(URLS),
             "-c", str(self.dir / "real.db"), "-x", "print-unread"],
            capture_output=True, text=True, env=env(),
        )
        self.assertEqual(done.returncode, 0, done.stderr or done.stdout)


class OpenUrlTest(unittest.TestCase):
    """Each browser is stubbed, so no real browser is ever launched."""

    def setUp(self) -> None:
        tmp = tempfile.TemporaryDirectory(prefix="open-url-test.")
        self.addCleanup(tmp.cleanup)
        self.bin = Path(tmp.name)

    def stub(self, name: str) -> Path:
        path = self.bin / name
        path.write_text(f'#!/bin/bash\necho "{name} $1"\n', encoding="utf-8")
        path.chmod(0o755)
        return path

    def run_it(self, *args: str, browser: str = "") -> subprocess.CompletedProcess:
        # PATH is ONLY the stub dir, so a real /usr/bin/open cannot be found
        # and silently satisfy a branch that should have fallen through.
        return subprocess.run(
            ["/bin/bash", str(OPEN_URL), *args],
            capture_output=True, text=True,
            env={"PATH": str(self.bin), "BROWSER": browser},
        )

    def test_browser_env_wins(self):
        self.stub("open")
        firefox = self.stub("firefox")
        done = self.run_it("https://example.com", browser=str(firefox))
        self.assertEqual(done.returncode, 0)
        self.assertIn("firefox https://example.com", done.stdout)

    def test_macos_uses_open(self):
        self.stub("open")
        self.stub("xdg-open")
        done = self.run_it("https://example.com")
        self.assertEqual(done.returncode, 0)
        self.assertIn("open https://example.com", done.stdout)

    def test_linux_falls_back_to_xdg_open(self):
        self.stub("xdg-open")
        done = self.run_it("https://example.com")
        self.assertEqual(done.returncode, 0)
        self.assertIn("xdg-open https://example.com", done.stdout)

    def test_no_browser_exits_127(self):
        done = self.run_it("https://example.com")
        self.assertEqual(done.returncode, 127)
        self.assertIn("no browser found", done.stderr)

    def test_wrong_args_exit_2_with_usage_on_stderr(self):
        done = self.run_it()
        self.assertEqual(done.returncode, 2)
        self.assertIn("Usage:", done.stderr)
        self.assertEqual(done.stdout, "")

    def test_help_exits_0_with_usage_on_stdout(self):
        for flag in ("-h", "--help"):
            done = self.run_it(flag)
            self.assertEqual(done.returncode, 0, flag)
            self.assertIn("Usage:", done.stdout)
            self.assertEqual(done.stderr, "")


if __name__ == "__main__":
    unittest.main()
