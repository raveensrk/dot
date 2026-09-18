#!/usr/bin/env python3

"""Guard lazygit config wiring into $DOT/config."""

from __future__ import annotations

import os
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

    def test_script_is_executable(self):
        self.assertTrue(os.access(SCRIPT, os.X_OK))


if __name__ == "__main__":
    unittest.main()
