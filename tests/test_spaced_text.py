#!/usr/bin/env python3

"""End-to-end tests for the spaced-text vim plugin."""

from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
PLUGIN = ROOT / "config" / "vim" / "plugin" / "spaced_text.vim"


class SpacedTextTest(unittest.TestCase):
    def run_vim(self, command: str, text: str) -> str:
        with tempfile.TemporaryDirectory(prefix="spaced-text-test.") as tmp:
            target = Path(tmp) / "input.txt"
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
            )
            return target.read_text()

    def test_space_text(self) -> None:
        result = self.run_vim("%SpaceText", "This is the style i want to write.\n")
        self.assertEqual(
            result,
            "T h i s    i s    t h e    s t y l e    i    w a n t    t o    w r i t e .\n",
        )

    def test_space_text_multiple_lines(self) -> None:
        result = self.run_vim("%SpaceText", "one two\nthree\n")
        self.assertEqual(result, "o n e    t w o\nt h r e e\n")

    def test_unspace_text(self) -> None:
        result = self.run_vim(
            "%UnspaceText",
            "T h i s    i s    t h e    s t y l e\n",
        )
        self.assertEqual(result, "This is the style\n")

    def test_round_trip(self) -> None:
        original = "The quick brown fox, obviously.\n"
        spaced = self.run_vim("%SpaceText", original)
        restored = self.run_vim("%UnspaceText", spaced)
        self.assertEqual(restored, original)


if __name__ == "__main__":
    unittest.main()
