import contextlib
import importlib.machinery
import importlib.util
import io
from pathlib import Path
import unittest


PATH = Path(__file__).resolve().parents[1] / "script" / ",repo_visibility"
LOADER = importlib.machinery.SourceFileLoader("repo_visibility", str(PATH))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
APP = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(APP)


class ParseRemoteTest(unittest.TestCase):
    def test_every_remote_shape_in_use(self):
        cases = {
            "git@github.com:raveensrk/agent1.git": ("github.com", "raveensrk", "agent1"),
            "https://github.com/raveensrk/personal.git": ("github.com", "raveensrk", "personal"),
            "ssh://git@github.com/raveensrk/tatami": ("github.com", "raveensrk", "tatami"),
            "git@github.com:raveensrk/work": ("github.com", "raveensrk", "work"),
            "ssh://git@forgejo.example.net:2222/raveensrk/notes.git":
                ("forgejo.example.net", "raveensrk", "notes"),
        }
        for url, expected in cases.items():
            self.assertEqual(APP.parse_remote(url), expected, url)

    def test_unparseable_remote(self):
        self.assertIsNone(APP.parse_remote("nonsense"))


class HelpTest(unittest.TestCase):
    def test_help_command_prints_long_help(self):
        with contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(APP.main(["help"]), 0)
        self.assertIn("Exit codes", output.getvalue())


if __name__ == "__main__":
    unittest.main()
