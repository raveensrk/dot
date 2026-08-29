"""Headless-Vim test for ftplugin/markdown/todo_help.vim."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VIM_DIR = ROOT / "config" / "vim"
PLUGIN = VIM_DIR / "ftplugin" / "markdown" / "todo_help.vim"
CONFIG = ROOT / "config" / "todo.toml"


class TodoHelpTest(unittest.TestCase):
    def run_help(self) -> str:
        with tempfile.TemporaryDirectory(prefix="todo-help-test.") as tmp:
            out = Path(tmp) / "out.txt"
            subprocess.run(
                [
                    "vim", "-N", "-u", "NONE", "-i", "NONE", "-Es",
                    "--cmd", f"set runtimepath^={VIM_DIR}",
                    "-S", str(PLUGIN),
                    "-c", "redir! > " + str(out),
                    "-c", "TodoHelp",
                    "-c", "redir END",
                    "-c", "qa!",
                ],
                check=True,
                timeout=30,
                stdin=subprocess.DEVNULL,
                capture_output=True,
                env={**os.environ, "TODO_CONFIG": str(CONFIG)},
            )
            return out.read_text()

    def test_cheat_sheet_lists_commands_and_live_states(self) -> None:
        text = self.run_help()
        self.assertIn("TODO > IN_PROGRESS > OPTIONAL > LATER > DONE > OBSOLETE > (none)", text)
        for token in (":TodoState", ":TodoShiftDue", ":TodoFilterDue", ":Todo!", ",?"):
            self.assertIn(token, text)


if __name__ == "__main__":
    unittest.main()
