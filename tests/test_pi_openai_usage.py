#!/usr/bin/env python3
"""OpenAI powerline usage requires the selected provider's OAuth login."""

import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXT = ROOT / "config/pi/extensions/openai_usage_gate.ts"
NODE = shutil.which("node")

PROBE = f"""
import assert from 'node:assert/strict';
import gate from {json.dumps(str(EXT))};
const handlers = new Map();
const statuses = new Map();
const original = (key, text) => statuses.set(key, text);
const ui = {{ setStatus: original }};
let model = {{ provider: 'openai-codex' }};
let oauth = false;
const ctx = {{
  hasUI: true,
  ui,
  get model() {{ return model; }},
  modelRegistry: {{ isUsingOAuth: () => oauth }},
}};
gate({{ on: (event, handler) => handlers.set(event, handler) }});
const start = () => handlers.get('session_start')({{}}, ctx);
const stop = () => handlers.get('session_shutdown')({{}}, ctx);
const check = (text, expected) => {{
  ui.setStatus('usage', text);
  assert.equal(statuses.get('usage'), text, 'upstream status stays unchanged');
  assert.equal(statuses.get('openai-usage'), expected);
}};
start();
for (const provider of ['openai', 'openai-codex']) {{
  model = {{ provider }};
  oauth = false;
  for (const text of ['checking', 'auth unavailable', 'codex 70%', 'usage err: expired']) {{
    check(text, undefined);
  }}
  oauth = true;
  check('checking', undefined);
  check('auth unavailable', undefined);
  check('codex 70%', 'codex 70%');
  for (const text of [
    'usage err: Codex usage endpoint returned 401 Unauthorized',
    'usage err: token expired',
    'usage err: Forbidden',
    'usage err: network',
  ]) {{
    check(text, undefined);
  }}
  check(undefined, undefined);
}}
model = {{ provider: 'openai' }};
check('chatgpt usage: web only', 'chatgpt usage: web only');
for (const provider of ['xai', 'openrouter', 'opencode', 'opencode-go']) {{
  model = {{ provider }};
  check('codex 70%', undefined);
}}
model = undefined;
check('codex 70%', undefined);
ui.setStatus('grok-credits', 'grok 80%');
assert.equal(statuses.get('grok-credits'), 'grok 80%');
start();
model = {{ provider: 'openai-codex' }};
check('codex 70%', 'codex 70%');
stop();
assert.equal(ui.setStatus, original, 'shutdown restores UI method');
assert.equal(statuses.get('openai-usage'), undefined);
ctx.hasUI = false;
start();
assert.equal(ui.setStatus, original, 'print mode stays untouched');
stop();
console.log('OpenAI usage gate checks passed');
"""


@unittest.skipIf(NODE is None, "node is not installed")
class OpenaiUsageTest(unittest.TestCase):
    def test_status_gate_and_lifecycle(self):
        out = subprocess.run(
            [NODE, "--experimental-strip-types", "--input-type=module", "-e", PROBE],
            capture_output=True,
            text=True,
            timeout=30,
        )
        self.assertEqual(out.returncode, 0, out.stderr)
        self.assertIn("OpenAI usage gate checks passed", out.stdout)


if __name__ == "__main__":
    unittest.main()
