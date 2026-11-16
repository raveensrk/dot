#!/usr/bin/env python3

"""Guard lazygit config wiring into $DOT/config."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "config" / "lazygit.yml"
SCRIPT = ROOT / "config" / "lazygit_pi_commit.sh"
BASHRC = ROOT / "config" / "bashrc"


class LazygitConfigTest(unittest.TestCase):
    def test_config_exists(self):
        self.assertTrue(CONFIG.is_file())

    def test_bashrc_exports_lg_config_file(self):
        text = BASHRC.read_text(encoding="utf-8")
        self.assertIn("export LG_CONFIG_FILE=$DOT/config/lazygit.yml", text)
        self.assertIn("alias lg=lazygit", text)

    def test_config_points_at_pi_commit_script(self):
        text = CONFIG.read_text(encoding="utf-8")
        self.assertIn("lazygit_pi_commit.sh", text)
        self.assertIn("customCommands", text)

    def test_script_calls_pi_print(self):
        text = SCRIPT.read_text(encoding="utf-8")
        self.assertIn("pi -p", text)
        self.assertIn("git diff --cached", text)

    def test_script_prefers_claude(self):
        text = SCRIPT.read_text(encoding="utf-8")
        self.assertIn("claude -p", text)
        self.assertLess(text.index("claude -p"), text.index("pi -p"))

    def test_script_is_executable(self):
        self.assertTrue(os.access(SCRIPT, os.X_OK))


def _git(repo, *args):
    return subprocess.run(["git", "-C", str(repo), *args], check=True,
                          capture_output=True, text=True).stdout


class MessageFlagTest(unittest.TestCase):
    """--message prints the message for the full diff and changes nothing."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        base = Path(self.tmp.name)
        self.bin = base / "bin"
        self.bin.mkdir()
        self.seen = base / "seen.txt"
        # Fake claude: save the diff it got on stdin, print a message.
        claude = self.bin / "claude"
        claude.write_text(f'#!/bin/sh\ncat > "{self.seen}"\necho "feat: fake message"\n')
        claude.chmod(0o755)
        self.repo = base / "repo"
        self.repo.mkdir()
        _git(self.repo, "init", "-q")
        _git(self.repo, "config", "user.email", "t@t")
        _git(self.repo, "config", "user.name", "t")
        (self.repo / "a.txt").write_text("old\n")
        _git(self.repo, "add", "a.txt")
        _git(self.repo, "commit", "-qm", "init")

    def tearDown(self):
        self.tmp.cleanup()

    def run_script(self, *args):
        env = dict(os.environ, PATH=f"{self.bin}{os.pathsep}{os.environ['PATH']}")
        return subprocess.run([str(SCRIPT), *args], cwd=self.repo, env=env,
                              capture_output=True, text=True)

    def test_prints_message_for_tracked_and_untracked(self):
        (self.repo / "a.txt").write_text("new\n")
        (self.repo / "b.txt").write_text("brand new\n")
        status_before = _git(self.repo, "status", "--porcelain")
        head_before = _git(self.repo, "rev-parse", "HEAD")
        r = self.run_script("--message")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout, "feat: fake message\n")
        diff = self.seen.read_text()
        self.assertIn("+new", diff)
        self.assertIn("b.txt", diff)
        self.assertIn("+brand new", diff)
        self.assertEqual(_git(self.repo, "status", "--porcelain"), status_before)
        self.assertEqual(_git(self.repo, "rev-parse", "HEAD"), head_before)

    def test_clean_repo_fails(self):
        r = self.run_script("--message")
        self.assertNotEqual(r.returncode, 0)
        self.assertEqual(r.stdout, "")

    def test_without_flag_still_needs_staged(self):
        (self.repo / "a.txt").write_text("new\n")
        r = self.run_script("-y")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("Nothing staged", r.stdout)

    def test_without_flag_commits_staged(self):
        (self.repo / "a.txt").write_text("new\n")
        (self.repo / "b.txt").write_text("untracked\n")
        _git(self.repo, "add", "a.txt")
        self.run_script("-y")  # exit code comes from the trailing push test
        self.assertEqual(_git(self.repo, "log", "-1", "--format=%s"), "feat: fake message\n")
        self.assertIn("?? b.txt", _git(self.repo, "status", "--porcelain"))

    def test_lazygit_keys_unchanged(self):
        text = CONFIG.read_text(encoding="utf-8")
        self.assertIn('command: "$HOME/dot/config/lazygit_pi_commit.sh"\n', text)
        self.assertIn('command: "$HOME/dot/config/lazygit_pi_commit.sh push -y"', text)


if __name__ == "__main__":
    unittest.main()
