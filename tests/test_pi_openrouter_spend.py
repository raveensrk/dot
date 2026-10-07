#!/usr/bin/env python3

"""The powerline openrouter segment: "balance" and "total" are account-wide.

"total" is GET /api/v1/credits -> total_usage, the all-time account spend -
not the key's usage from /api/v1/key.

"balance" is what openrouter.ai/settings/credits calls "Total available":
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
    def test_labels_key_usage_key_cap_account_spend_and_balance(self):
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
                "balance $12.78 · limit $3.65 · used $11.35 · total $12.22",
                "balance $2.00 · limit $0.50 · used $1.50",
                "used $1.00",
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
