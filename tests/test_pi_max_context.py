#!/usr/bin/env python3
"""Pi's maximum-context policy preserves provider behavior and fails safely."""

import json
import os
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXT = ROOT / "config/pi/extensions/max_context.ts"
NODE = shutil.which("node")
CATALOG = Path.home() / ".pi/agent/models-store.json"

PROBE = r"""
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const {default: extension, maximize} = await import(process.env.EXT);
const clone = value => structuredClone(value);
let raw = [
  {id:'sol', provider:'openai-codex', contextWindow:272000, maxTokens:128000},
  {id:'old', provider:'openai-codex', contextWindow:272000, maxTokens:128000},
  {id:'unknown', provider:'openai-codex', contextWindow:131072, maxTokens:16384},
  {id:'image', provider:'openai-codex', type:'image'},
];
const initial = clone(raw);
raw[0].contextWindow = 872000; // A prior static override must not become the catalog baseline.
let stored;
let account = 'account_one';
let network = true;
let status = 200;
let body = {models:[
  {slug:'sol', context_window:272000, max_context_window:872000},
  {slug:'old', context_window:272000, max_context_window:272000},
]};
let calls = 0;
let cancelled = false;
const warnings = [];
const base = {
  id:'openai-codex', baseUrl:'https://chatgpt.com/backend-api',
  auth:{oauth:{}}, stream:() => 'original stream', streamSimple:() => 'original simple',
  getModels:() => raw.filter(model => !model.type || model.type === 'chat'),
  getAllModels:() => raw,
  refreshModels:async context => {
    if (context.stored) raw = clone(context.stored.models);
    await context.publish({persist:{models:raw, etag:'"fresh"', checkedAt:42, lastModified:21}});
  },
};
globalThis.fetch = async (url, options) => {
  calls++;
  assert.equal(new URL(url).origin, 'https://chatgpt.com');
  assert.equal(options.headers.Authorization, 'Bearer oauth_fixture');
  assert.equal(options.headers['ChatGPT-Account-ID'], account);
  assert.ok(options.signal instanceof AbortSignal);
  if (status === 'throw') throw new Error('oauth_fixture must never reach logs');
  return new Response(JSON.stringify(body), {status});
};
const context = () => ({
  stored:clone(stored), allowNetwork:network,
  credential:{type:'oauth', access:'oauth_fixture', accountId:account},
  signal:cancelled ? AbortSignal.abort() : new AbortController().signal,
  publish:async publication => {
    if (cancelled) return false;
    if (publication.persist !== undefined) stored = clone(publication.persist);
    publication.update?.();
    return true;
  },
});
const provider = maximize(base, message => warnings.push(message));
const refresh = () => provider.refreshModels(context());
const cap = id => provider.getModels().find(model => model.id === id).contextWindow;
assert.equal(provider.auth, base.auth);
assert.equal(provider.stream, base.stream);
assert.equal(provider.streamSimple, base.streamSimple);
await refresh();
assert.equal(cap('sol'), 872000);
assert.equal(cap('old'), 272000);
assert.equal(cap('unknown'), 131072);
assert.equal(provider.getModels().find(model => model.id === 'sol').maxTokens, 128000);
assert.deepEqual(provider.getAllModels().find(model => model.id === 'image'), initial[3]);
assert.equal(stored.etag, '"fresh"', 'preserve latest native catalog validator');
assert.equal(stored.checkedAt, 42);
assert.equal(stored.lastModified, 21);
assert.equal(stored.models.find(model => model.id === 'sol').context_base, 272000);
assert.ok(!JSON.stringify(stored).includes('oauth_fixture'));
assert.ok(!JSON.stringify(stored).includes('account_one'));

network = false;
const offline = maximize(base, message => warnings.push(message));
const before = calls;
await offline.refreshModels(context());
assert.equal(calls, before);
assert.equal(offline.getModels().find(model => model.id === 'sol').contextWindow, 872000);
assert.equal(warnings.length, 0, 'cache-only initialization with verified maxima needs no warning');

network = true;
stored.models.push({id:'future', provider:'openai-codex', contextWindow:500000, maxTokens:32000});
body.models.push({slug:'future', context_window:500000, max_context_window:1600000});
await refresh();
assert.equal(cap('future'), 1600000, 'newly discovered models need no hardcoded ID');
body.models[0].max_context_window = 700000;
await refresh();
assert.equal(cap('sol'), 700000, 'honor reduced live maxima too');

for (const bad of [0, -1, '900000', 272000.5, Number.MAX_SAFE_INTEGER + 1, 100]) {
  body.models[0].max_context_window = bad;
  await refresh();
  assert.equal(cap('sol'), 700000, 'invalid metadata must not replace last verified maximum');
}
body = {models:[{slug:'sol', context_window:272000, max_context_window:700000}]};
for (const code of [401, 429, 500, 'throw']) {
  status = code;
  await refresh();
  assert.equal(cap('sol'), 700000);
}
assert.ok(warnings.every(message => !message.includes('oauth_fixture')));
status = 200;
body = {models:[
  {slug:'sol', context_window:272000, max_context_window:700000},
  {slug:'sol', context_window:272000, max_context_window:872000},
]};
await refresh();
assert.equal(cap('sol'), 700000);
body = {unexpected:true};
await refresh();
assert.equal(cap('sol'), 700000);
body = {models:[{slug:'sol', context_window:272000, max_context_window:700000}]};

account = 'account_two';
network = false;
await refresh();
assert.equal(cap('sol'), 272000, 'never reuse another account maximum');
network = true;
await refresh();
assert.equal(cap('sol'), 700000);
cancelled = true;
const saved = clone(stored);
const count = calls;
await refresh();
assert.equal(calls, count);
assert.deepEqual(stored, saved);
cancelled = false;

const handlers = new Map();
let registered = base;
const selected = [];
const pi = {
  on:(event, handler) => handlers.set(event, handler),
  registerProvider:value => {registered = value;},
  setModel:async model => {selected.push(model); return true;},
};
const ctx = {
  hasUI:true, ui:{notify:message => warnings.push(message)},
  model:{provider:'openai-codex', id:'sol'},
  modelRegistry:{
    getProvider:() => registered,
    refresh:async () => {await registered.refreshModels(context()); return {errors:new Map()};},
    find:(_provider, id) => registered.getModels().find(model => model.id === id),
  },
};
extension(pi);
await handlers.get('session_start')({reason:'resume'}, ctx);
assert.equal(selected.at(-1).contextWindow, 700000);
await handlers.get('session_shutdown')({reason:'reload'}, ctx);
assert.equal(registered, base, 'restore original provider rather than nest wrappers');
await handlers.get('session_start')({reason:'reload'}, ctx);
assert.equal(selected.at(-1).contextWindow, 700000);
await handlers.get('session_shutdown')({reason:'exit'}, ctx);
ctx.model = {provider:'openrouter', id:'other'};
const selection = selected.length;
await handlers.get('session_start')({reason:'new'}, ctx);
assert.equal(selected.length, selection, 'do not switch sessions using other providers');
await handlers.get('session_shutdown')({}, ctx);
registered = {...base, baseUrl:'https://proxy.example.invalid'};
const proxycalls = calls;
await handlers.get('session_start')({}, ctx);
assert.equal(registered.baseUrl, 'https://proxy.example.invalid');
assert.equal(calls, proxycalls, 'never send credentials to an unverified gateway');

if (process.env.CATALOG) {
  const catalogs = JSON.parse(readFileSync(process.env.CATALOG, 'utf8'));
  let checked = 0;
  for (const [id, catalog] of Object.entries(catalogs)) {
    const baseline = clone(catalog.models);
    for (const model of baseline) {
      if (model.type && model.type !== 'chat') continue;
      assert.ok(Number.isSafeInteger(model.contextWindow) && model.contextWindow > 0, `${id}/${model.id}`);
      checked++;
    }
    assert.deepEqual(catalog.models, baseline, 'catalogs remain unchanged by policy tests');
  }
  console.log(`Validated ${checked} cached chat model entries`);
}
console.log('Maximum context policy checks passed');
"""


@unittest.skipIf(NODE is None, "node is not installed")
class MaximumContextTest(unittest.TestCase):
    def test_provider_maxima_fallback_and_lifecycle(self):
        env = {**os.environ, "EXT": EXT.as_uri()}
        if CATALOG.exists():
            env["CATALOG"] = str(CATALOG)
        out = subprocess.run(
            [NODE, "--experimental-strip-types", "--input-type=module", "-e", PROBE],
            env=env, capture_output=True, text=True, timeout=30,
        )
        self.assertEqual(out.returncode, 0, out.stdout + out.stderr)
        self.assertIn("Maximum context policy checks passed", out.stdout)


if __name__ == "__main__":
    unittest.main()
