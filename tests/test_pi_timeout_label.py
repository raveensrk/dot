#!/usr/bin/env python3

import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "script" / "install_pi_timeout_label.py"
PATCH = ROOT / "config" / "pi" / "patches" / "timeout_label.patch"
EXT = ROOT / "config" / "pi" / "extensions" / "timeout-label-patch.ts"


def load():
    spec = importlib.util.spec_from_file_location("install_pi_timeout_label", SCRIPT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class TimeoutLabelTest(unittest.TestCase):
    def setUp(self):
        self.mod = load()

    def test_pretty_inserts_function_and_rewrites_call(self):
        src = (
            "function formatShellCall(args, prompt) {\n"
            "    const timeout = args?.timeout;\n"
            "    const timeoutSuffix = timeout ? theme.fg(\"muted\", ` (timeout ${timeout}s)`) : \"\";\n"
            "}\n"
        )
        out = self.mod.apply(src)
        self.assertIn("function formatTimeout(timeout)", out)
        self.assertIn("(timeout ${formatTimeout(timeout)})", out)
        self.assertNotIn("(timeout ${timeout}s)", out)
        self.assertLess(out.index("function formatTimeout"), out.index("function formatShellCall"))

    def test_minified_bundle_shape(self):
        src = (
            "function formatShellCall(args,prompt){let timeout=args?.timeout,"
            "timeoutSuffix=timeout?theme.fg(\"muted\",` (timeout ${timeout}s)`):\"\"}"
        )
        out = self.mod.apply(src)
        self.assertTrue(out.startswith("function formatTimeout(timeout){"))
        self.assertIn("timeout>60", out)
        self.assertIn("(timeout ${formatTimeout(timeout)})", out)

    def test_idempotent(self):
        once = self.mod.apply(
            "function formatShellCall(args, prompt) {\n"
            "    const timeoutSuffix = timeout ? theme.fg(\"muted\", ` (timeout ${timeout}s)`) : \"\";\n"
            "}\n"
        )
        self.assertEqual(self.mod.apply(once), once)

    def test_leaves_unrelated_file(self):
        src = "function other(){ return 1 }\n"
        self.assertEqual(self.mod.apply(src), src)

    def test_targets_ignore_prefix_node_modules(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw) / "node_modules" / "pi"
            hit = root / "dist" / "bundle" / "chunk.js"
            skip = root / "dist" / "node_modules" / "dep.js"
            hit.parent.mkdir(parents=True)
            skip.parent.mkdir(parents=True)
            hit.write_text("a")
            skip.write_text("b")
            found = self.mod.targets(root)
            self.assertEqual(found, [hit])

    def test_patch_file_matches_installer_function(self):
        text = PATCH.read_text()
        self.assertIn("function formatTimeout(timeout)", text)
        self.assertIn("(timeout ${formatTimeout(timeout)})", text)
        self.assertIn("timeout > 60", text)

    def test_extension_looks_for_installer_marker(self):
        ext = EXT.read_text()
        self.assertIn("function formatTimeout(", ext)
        self.assertIn("install_pi_timeout_label.py", ext)


if __name__ == "__main__":
    unittest.main()
