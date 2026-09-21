#!/usr/bin/env python3

"""Tests for bin/macos/iterm_open_in_macvim."""

from __future__ import annotations

import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "bin" / "macos" / "iterm_open_in_macvim"


class ItermOpenInMacvimTest(unittest.TestCase):
    def setUp(self) -> None:
        temporary_directory = tempfile.TemporaryDirectory(prefix="iterm-open-in-macvim.")
        self.addCleanup(temporary_directory.cleanup)
        self.fixture = Path(temporary_directory.name)
        self.bin = self.fixture / "bin"
        self.bin.mkdir()
        self.mvim_log = self.fixture / "mvim.log"
        self.open_log = self.fixture / "open.log"
        self.mvim = self._write_logger("mvim", self.mvim_log)
        self.opener = self._write_logger("open", self.open_log)

    def _write_logger(self, name: str, log: Path) -> Path:
        path = self.bin / name
        path.write_text(
            "#!/usr/bin/env bash\n"
            f"printf '%s\\n' \"$@\" > '{log}'\n",
            encoding="utf-8",
        )
        path.chmod(path.stat().st_mode | stat.S_IEXEC)
        return path

    def _run(self, *args: str, extra_path: str | None = None) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["ITERM_OPEN_MVIM"] = str(self.mvim)
        path_parts = [str(self.bin)]
        if extra_path:
            path_parts.append(extra_path)
        path_parts.append(env.get("PATH", ""))
        env["PATH"] = os.pathsep.join(path_parts)
        return subprocess.run(
            [str(SCRIPT), *args],
            env=env,
            cwd=self.fixture,
            text=True,
            capture_output=True,
        )

    def _mvim_args(self) -> list[str]:
        self.assertTrue(self.mvim_log.is_file(), "mvim was not invoked")
        return self.mvim_log.read_text(encoding="utf-8").splitlines()

    def test_no_args_exits_1(self) -> None:
        result = self._run()
        self.assertEqual(result.returncode, 1)

    def test_empty_arg_exits_1(self) -> None:
        result = self._run("")
        self.assertEqual(result.returncode, 1)

    def test_directory_uses_open(self) -> None:
        target = self.fixture / "a directory"
        target.mkdir()
        result = self._run(str(target))
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.open_log.read_text(encoding="utf-8").splitlines(), [str(target)])
        self.assertFalse(self.mvim_log.exists())

    def test_file_url_directory(self) -> None:
        target = self.fixture / "a directory"
        target.mkdir()
        result = self._run("file://" + str(target).replace(" ", "%20"))
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.open_log.read_text(encoding="utf-8").splitlines(), [str(target)])

    def test_existing_file_opens_in_mvim(self) -> None:
        target = self.fixture / "sample.txt"
        target.write_text("line 1\nline 2\nline 3\n", encoding="utf-8")
        result = self._run(str(target))
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self._mvim_args(), ["--remote-silent", str(target)])

    def test_line_number(self) -> None:
        target = self.fixture / "sample.txt"
        target.write_text("line 1\nline 2\nline 3\n", encoding="utf-8")
        result = self._run(str(target), "3")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self._mvim_args(), ["--remote-silent", "+3", str(target)])

    def test_line_zero_skips_jump(self) -> None:
        target = self.fixture / "sample.txt"
        target.write_text("line 1\n", encoding="utf-8")
        result = self._run(str(target), "0")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self._mvim_args(), ["--remote-silent", str(target)])

    def test_file_url_with_spaces(self) -> None:
        target = self.fixture / "file with space.txt"
        target.write_text("ok\n", encoding="utf-8")
        result = self._run("file://" + str(target).replace(" ", "%20"))
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self._mvim_args(), ["--remote-silent", str(target)])

    def test_basename_on_path_opens_real_file(self) -> None:
        tool = self.fixture / "tools"
        tool.mkdir()
        real = tool / "iterm_open_in_macvim"
        real.write_text("#!/usr/bin/env bash\necho real\n", encoding="utf-8")
        real.chmod(real.stat().st_mode | stat.S_IEXEC)
        result = self._run("iterm_open_in_macvim", extra_path=str(tool))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self._mvim_args(), ["--remote-silent", str(real)])

    def test_cwd_file_wins_over_path(self) -> None:
        tool = self.fixture / "tools"
        tool.mkdir()
        real = tool / "iterm_open_in_macvim"
        real.write_text("path copy\n", encoding="utf-8")
        real.chmod(real.stat().st_mode | stat.S_IEXEC)
        local = self.fixture / "iterm_open_in_macvim"
        local.write_text("cwd copy\n", encoding="utf-8")
        result = self._run("iterm_open_in_macvim", extra_path=str(tool))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self._mvim_args(), ["--remote-silent", "iterm_open_in_macvim"])
        self.assertNotEqual(self._mvim_args()[-1], str(real))
        self.assertTrue(local.is_file())

    def test_unknown_basename_still_opens(self) -> None:
        result = self._run("no_such_command_xyz")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self._mvim_args(), ["--remote-silent", "no_such_command_xyz"])


if __name__ == "__main__":
    unittest.main()
