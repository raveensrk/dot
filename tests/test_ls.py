import pathlib
import re
import shutil
import subprocess
import tempfile
import unittest


class Listing(unittest.TestCase):
    @unittest.skipUnless(shutil.which("eza"), "eza is not installed")
    def test_directory_argument(self):
        cfg = pathlib.Path(__file__).resolve().parents[1] / "config/bashrc"
        aliases = re.findall(r'^\s*alias (?:ls|l)="(eza [^"]+)"', cfg.read_text(), re.M)
        self.assertGreaterEqual(len(aliases), 2)
        with tempfile.TemporaryDirectory() as directory:
            pathlib.Path(directory, "example.txt").touch()
            for alias in aliases:
                with self.subTest(alias=alias):
                    result = subprocess.run(
                        ["bash", "-c", f'{alias} "$1"', "bash", directory],
                        capture_output=True, text=True,
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn("example.txt", result.stdout)
