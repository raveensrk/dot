#!/usr/bin/env python3

"""The powerline openrouter segment: A must be the account balance.

A is what openrouter.ai/settings/credits calls "Total available":
GET /api/v1/credits -> total_credits - total_usage. It is not the per-key
cap, which is /api/v1/key -> limit. See
https://openrouter.ai/docs/api-reference/limits
"""

import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXT = ROOT / "config" / "pi" / "extensions" / "openrouter-spend.ts"
NODE = shutil.which("node")

PROBE = f"""
import {{ formatSpend }} from {json.dumps(str(EXT))};
const cases = [
  [{{ usage: 11.350662497, limit_remaining: 3.649337503 }}, {{ total_credits: 25, total_usage: 12.220717341 }}],
  [{{ usage: 1.5, limit_remaining: 0.5 }}, undefined],
  [{{ usage: 1 }}, undefined],
];
console.log(JSON.stringify(cases.map(([k, c]) => formatSpend(k, c))));
"""


@unittest.skipIf(NODE is None, "node is not installed")
class OpenrouterSpendTest(unittest.TestCase):
    def test_builds_key_remaining_and_account_available(self):
        with tempfile.TemporaryDirectory() as tmp:
            probe = Path(tmp) / "probe.ts"
            probe.write_text(PROBE)
            out = subprocess.run(
                [NODE, "--experimental-strip-types", str(probe)],
                capture_output=True,
                text=True,
                timeout=60,
                check=True,
            )
        self.assertEqual(
            json.loads(out.stdout),
            [
                "[U:$11.35|L:$3.65|A:$12.78]",
                "[U:$1.50|L:$0.50|A:$2.00]",
                "[U:$1.00]",
            ],
        )

    def test_extension_self_check(self):
        out = subprocess.run(
            [NODE, "--experimental-strip-types", str(EXT)],
            capture_output=True,
            text=True,
            timeout=60,
            check=True,
        )
        self.assertIn("openrouter-spend self-check ok", out.stdout)


if __name__ == "__main__":
    unittest.main()
