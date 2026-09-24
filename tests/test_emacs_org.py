"""Test repository agenda discovery without loading personal packages."""

import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


@unittest.skipUnless(shutil.which("emacs"), "Emacs is required")
class OrgAgendaTest(unittest.TestCase):
    def test_discovery_and_agenda_rebuild(self):
        result = subprocess.run(
            ["emacs", "-Q", "--batch", "-l",
             str(ROOT / "config/emacs/org_agenda.el"), "-l",
             str(ROOT / "tests/emacs_org_test.el"),
             "-f", "ert-run-tests-batch-and-exit"],
            capture_output=True, text=True, timeout=60,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
