#!/usr/bin/env python3

"""End-to-end tests for the :TodoState vim plugin."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
VIM_DIR = ROOT / "config" / "vim"
PLUGIN = VIM_DIR / "ftplugin" / "markdown" / "todo_state.vim"
CONFIG = ROOT / "config" / "todo.toml"

STATES = ["TODO", "IN_PROGRESS", "OPTIONAL", "DONE", "OBSOLETE"]


class TodoStateTest(unittest.TestCase):
    def run_vim(self, command: str, text: str) -> str:
        with tempfile.TemporaryDirectory(prefix="todo-state-test.") as tmp:
            target = Path(tmp) / "input.md"
            target.write_text(text)
            subprocess.run(
                [
                    "vim",
                    "-N",
                    "-u",
                    "NONE",
                    "-i",
                    "NONE",
                    "-Es",
                    # todo_state.vim calls into autoload/todo.vim.
                    "--cmd",
                    f"set runtimepath^={VIM_DIR}",
                    "-S",
                    str(PLUGIN),
                    "-c",
                    command,
                    "-c",
                    "wq!",
                    str(target),
                ],
                check=True,
                timeout=30,
                stdin=subprocess.DEVNULL,
                capture_output=True,
                # Pin the state vocabulary the plugin reads.
                env={**os.environ, "TODO_CONFIG": str(CONFIG)},
            )
            return target.read_text()

    def test_forward_cycle_walks_every_state_then_strips_it(self) -> None:
        line = "- Buy milk\n"
        for state in STATES:
            line = self.run_vim("TodoState", line)
            self.assertEqual(line, f"- {state}: Buy milk\n")
        self.assertEqual(self.run_vim("TodoState", line), "- Buy milk\n")

    def test_backward_cycle_reverses_the_ring(self) -> None:
        self.assertEqual(
            self.run_vim("TodoStateBack", "- Buy milk\n"),
            "- OBSOLETE: Buy milk\n",
        )
        self.assertEqual(
            self.run_vim("TodoStateBack", "- TODO: Buy milk\n"),
            "- Buy milk\n",
        )
        self.assertEqual(
            self.run_vim("TodoStateBack", "- DONE: Buy milk\n"),
            "- OPTIONAL: Buy milk\n",
        )

    def test_metadata_and_bullet_style_are_preserved(self) -> None:
        self.assertEqual(
            self.run_vim(
                "TodoState",
                "- TODO: Pay rent +Finance @home due:2026-08-05 recurring:monthly (A)\n",
            ),
            "- IN_PROGRESS: Pay rent +Finance @home due:2026-08-05 recurring:monthly (A)\n",
        )
        self.assertEqual(
            self.run_vim("TodoState", "* TODO: starred\n"),
            "* IN_PROGRESS: starred\n",
        )
        self.assertEqual(
            self.run_vim("TodoState", "    - TODO: nested\n"),
            "    - IN_PROGRESS: nested\n",
        )

    def test_non_list_lines_are_left_alone(self) -> None:
        for text in ("plain prose\n", "# A heading\n", "\n"):
            self.assertEqual(self.run_vim("TodoState", text), text)

    def test_explicit_state_argument_sets_it_directly(self) -> None:
        self.assertEqual(
            self.run_vim("TodoState OBSOLETE", "- TODO: drop this\n"),
            "- OBSOLETE: drop this\n",
        )
        self.assertEqual(
            self.run_vim("TodoState done", "- Buy milk\n"),
            "- DONE: Buy milk\n",
        )
        self.assertEqual(
            self.run_vim("TodoState NONE", "- DONE: Buy milk\n"),
            "- Buy milk\n",
        )

    def test_unknown_state_argument_changes_nothing(self) -> None:
        self.assertEqual(
            self.run_vim("TodoState NOPE", "- TODO: keep me\n"),
            "- TODO: keep me\n",
        )

    def test_range_applies_to_every_list_line(self) -> None:
        result = self.run_vim(
            "%TodoState",
            "- TODO: a\n* IN_PROGRESS: b\nprose\n    - OBSOLETE: c\n",
        )
        self.assertEqual(
            result,
            "- IN_PROGRESS: a\n* OPTIONAL: b\nprose\n    - c\n",
        )

    def test_comma_x_cycles_the_current_line(self) -> None:
        self.assertEqual(
            self.run_vim("normal gg,x", "- TODO: a\n- TODO: b\n"),
            "- IN_PROGRESS: a\n- TODO: b\n",
        )

    def test_comma_x_cycles_a_visual_selection(self) -> None:
        self.assertEqual(
            self.run_vim("normal ggVG,x", "- TODO: a\n- TODO: b\n"),
            "- IN_PROGRESS: a\n- IN_PROGRESS: b\n",
        )

    def test_checkbox_items_are_left_to_the_checkbox_toggle(self) -> None:
        for text in ("- [ ] a checkbox item\n", "- [x] a done checkbox\n"):
            self.assertEqual(self.run_vim("TodoState", text), text)


if __name__ == "__main__":
    unittest.main()
