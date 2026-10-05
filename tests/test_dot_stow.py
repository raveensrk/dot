"""Tests for script/dot_stow.py: install/uninstall against temp dirs."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "script"))

import dot_stow  # noqa: E402


@unittest.skipUnless(shutil.which("stow"), "GNU stow not installed")
class StowEngineTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        base = Path(tmp.name)
        self.home = base / "home"
        self.source = base / "repo" / "config" / "pi"
        self.target = self.home / ".pi" / "agent"
        (self.source / "extensions").mkdir(parents=True)
        (self.source / "extensions" / "foo.ts").write_text("foo\n")
        (self.source / "agent").mkdir()
        (self.source / "agent" / "old.json").write_text("old\n")
        (self.source / "AGENTS.md").write_text("agents\n")
        (self.source / "settings.json").write_text("settings\n")
        (self.source / ".stow-local-ignore").write_text("^/agent$\n")
        self.target.mkdir(parents=True)
        self.package = dot_stow.Package("pi", self.source, self.target)

    def install(self, **kwargs):
        return dot_stow.install(self.package, home=self.home, **kwargs)

    def test_dry_run_makes_no_changes(self):
        plan = self.install()
        self.assertEqual(len(plan.by_kind("link")), 3)
        self.assertFalse((self.target / "AGENTS.md").exists())
        self.assertFalse((self.target / "extensions").exists())

    def test_apply_creates_relative_links_and_ignores(self):
        plan = self.install(apply=True)
        self.assertEqual(plan.conflicts, [])
        self.assertTrue((self.target / "AGENTS.md").is_symlink())
        self.assertFalse(Path(os.readlink(self.target / "AGENTS.md")).is_absolute())
        self.assertTrue((self.target / "extensions" / "foo.ts").exists())
        self.assertFalse((self.target / "agent").exists())
        self.assertFalse((self.target / ".stow-local-ignore").exists())
        self.assertEqual(
            (self.target / "settings.json").resolve(),
            (self.source / "settings.json").resolve(),
        )

    def test_rerun_is_idempotent(self):
        self.install(apply=True)
        plan = self.install(apply=True)
        self.assertEqual(plan.by_kind("link"), [])
        self.assertEqual(plan.conflicts, [])
        self.assertTrue(all(action.kind == "skip" for action in plan.actions))

    def test_absolute_link_is_replaced(self):
        (self.target / "AGENTS.md").symlink_to(self.source / "AGENTS.md")
        plan = self.install(apply=True)
        self.assertEqual(len(plan.by_kind("replace")), 1)
        link = self.target / "AGENTS.md"
        self.assertTrue(link.is_symlink())
        self.assertFalse(Path(os.readlink(link)).is_absolute())
        self.assertEqual(link.resolve(), (self.source / "AGENTS.md").resolve())

    def test_conflict_aborts_without_changes(self):
        (self.target / "settings.json").write_text("machine\n")
        plan = self.install()
        self.assertEqual(len(plan.conflicts), 1)
        with self.assertRaises(dot_stow.ConflictError):
            self.install(apply=True)
        self.assertEqual((self.target / "settings.json").read_text(), "machine\n")
        self.assertFalse((self.target / "AGENTS.md").exists())

    def test_backup_renames_conflict(self):
        (self.target / "settings.json").write_text("machine\n")
        plan = self.install(apply=True, backup=True)
        self.assertEqual(plan.conflicts, [])
        self.assertEqual((self.target / "settings.json").read_text(), "settings\n")
        backups = list(self.target.glob("settings.json.bak.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "machine\n")

    def test_adopt_imports_target_into_package(self):
        (self.target / "settings.json").write_text("machine\n")
        plan = self.install(apply=True, adopt=True)
        self.assertEqual(plan.conflicts, [])
        self.assertEqual((self.source / "settings.json").read_text(), "machine\n")
        self.assertEqual(
            (self.target / "settings.json").resolve(),
            (self.source / "settings.json").resolve(),
        )

    def test_uninstall_removes_links_keeps_real_files(self):
        self.install(apply=True)
        real = self.target / "sessions"
        real.mkdir()
        (real / "s.jsonl").write_text("session\n")
        plan = dot_stow.uninstall(self.package, apply=True)
        self.assertTrue(plan.by_kind("remove"))
        self.assertFalse((self.target / "AGENTS.md").exists())
        self.assertFalse((self.target / "extensions").exists())
        self.assertTrue((real / "s.jsonl").exists())
        self.assertTrue(self.target.is_dir())

    def test_uninstall_removes_manual_absolute_links(self):
        (self.target / "AGENTS.md").symlink_to(self.source / "AGENTS.md")
        dot_stow.uninstall(self.package, apply=True)
        self.assertFalse((self.target / "AGENTS.md").exists())

    def test_uninstall_dry_run_keeps_links(self):
        self.install(apply=True)
        dot_stow.uninstall(self.package)
        self.assertTrue((self.target / "AGENTS.md").is_symlink())


class ResolveTest(unittest.TestCase):
    def test_installer_help_includes_setup_docs(self):
        script = Path(__file__).resolve().parent.parent / "script" / "install.py"
        for flag in ("-h", "--help"):
            with self.subTest(flag=flag):
                out = subprocess.run(
                    [sys.executable, str(script), flag],
                    capture_output=True, text=True, timeout=10,
                )
                self.assertEqual(out.returncode, 0, out.stderr)
                self.assertIn("Examples:\n  script/install.py", out.stdout)
                for text in ("~/.pi/agent/", ".stow-local-ignore", "--backup",
                             "--adopt", "script/uninstall.py", "History:"):
                    self.assertIn(text, out.stdout)

    def test_unknown_package(self):
        with self.assertRaises(KeyError):
            dot_stow.resolve(["nope"])

    def test_resolves_relative_to_repo_and_home(self):
        packages = dot_stow.resolve(["pi"], repo=Path("/repo"), home=Path("/home/user"))
        self.assertEqual(packages["pi"].source, Path("/repo/config/pi"))
        self.assertEqual(packages["pi"].target, Path("/home/user/.pi/agent"))


if __name__ == "__main__":
    unittest.main()
