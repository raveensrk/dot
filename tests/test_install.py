"""Tests for script/install.py: the harness config installer, against a temp home.

    timeout 60 python3 -m pytest tests/test_install.py
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

DOT = Path(__file__).resolve().parent.parent
SCRIPT = DOT / "script" / "install.py"
AGENT1 = Path.home() / "repos" / "agent1"
sys.path.insert(0, str(DOT / "script"))

import install  # noqa: E402

# Records nothing and changes nothing: the plugin registry is install_lib's
# concern, tested in agent1. Here it only has to succeed.
FAKE_CLAUDE = "#!/bin/sh\nexit 0\n"


class Merge(unittest.TestCase):
    def test_dict_merges_key_by_key_and_keeps_runtime_keys(self):
        live = {"runtime": 1, "nested": {"a": 1, "b": 2}}
        self.assertEqual(install.merge(live, {"nested": {"b": 3}}),
                         {"runtime": 1, "nested": {"a": 1, "b": 3}})

    def test_list_gains_missing_items_only(self):
        self.assertEqual(install.merge({"p": ["a", "x"]}, {"p": ["a", "b"]}), {"p": ["a", "x", "b"]})

    def test_expand_makes_tilde_paths_absolute(self):
        self.assertEqual(install.expand({"c": ["~/bin/x", "y"]}),
                         {"c": [os.path.join(install.HOME, "bin/x"), "y"]})


@unittest.skipUnless((AGENT1 / "harness" / "install_lib.py").exists(), "agent1 not cloned")
class Installer(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.home = Path(os.path.realpath(tmp.name))
        for folder in (".pi/agent", ".claude", ".Trash"):
            (self.home / folder).mkdir(parents=True)
        cli = self.home / "claude"
        cli.write_text(FAKE_CLAUDE)
        cli.chmod(0o755)
        self.env = {**os.environ, "HOME": str(self.home), "AGENT1": str(AGENT1), "CLAUDE_BIN": str(cli)}

    def run_script(self, *args):
        return subprocess.run([sys.executable, str(SCRIPT), *args], env=self.env,
                              capture_output=True, text=True, timeout=60)

    def test_dry_run_writes_nothing(self):
        done = self.run_script()
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        self.assertFalse((self.home / ".claude" / "CLAUDE.md").exists())
        self.assertFalse((self.home / ".pi" / "agent" / "settings.json").exists())

    def test_apply_writes_real_files(self):
        live = self.home / ".pi" / "agent" / "settings.json"
        live.write_text(json.dumps({"lastChangelogVersion": "9.9.9"}))
        done = self.run_script("--apply")
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)

        settings = json.loads(live.read_text())
        self.assertEqual(settings["lastChangelogVersion"], "9.9.9", "runtime key kept")
        self.assertIn("~/dot/config/pi", settings["packages"])
        agents = (DOT / "config" / "agents" / "AGENTS.md").read_text()
        self.assertEqual((self.home / ".claude" / "CLAUDE.md").read_text(), agents)
        self.assertEqual((self.home / ".pi" / "agent" / "AGENTS.md").read_text(), agents)
        self.assertEqual((self.home / "AGENTS.md").read_text(),
                         (DOT / "config" / "agents" / "home_AGENTS.md").read_text())
        mcp = json.loads((self.home / ".claude.json").read_text())["mcpServers"]["cua-driver"]
        self.assertEqual(mcp["command"], str(self.home / ".local/bin/cua-driver"))
        self.assertTrue((self.home / ".agents" / ".claude-plugin" / "plugin.json").is_file())
        links = [p for p in self.home.rglob("*") if p.is_symlink() and ".Trash" not in p.parts]
        self.assertEqual(links, [], "the installer never makes a symlink")

    def test_help_writes_nothing(self):
        for arg in ("-h", "--help", "help"):
            with self.subTest(arg=arg):
                done = self.run_script(arg)
                self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
                self.assertNotIn("dry run:", done.stdout)
                self.assertFalse((self.home / ".pi" / "agent" / "models.json").exists())

    def test_stow_link_is_replaced_by_a_real_file(self):
        live = self.home / ".pi" / "agent" / "settings.json"
        live.symlink_to(DOT / "config" / "pi" / "settings.json")
        done = self.run_script("--apply")
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        self.assertFalse(live.is_symlink())
        self.assertTrue((self.home / ".Trash" / "settings.json").is_symlink())
        source = json.loads((DOT / "config" / "pi" / "settings.json").read_text())
        packages = json.loads(live.read_text())["packages"]
        self.assertEqual(packages[:len(source["packages"])], source["packages"])

    def test_missing_harness_is_skipped(self):
        (self.home / ".claude").rmdir()
        done = self.run_script("--apply")
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        self.assertFalse((self.home / ".claude").exists())
        self.assertFalse((self.home / ".claude.json").exists())


if __name__ == "__main__":
    unittest.main()
