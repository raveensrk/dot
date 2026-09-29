# Agent config

Pi is the only supported harness today. Skills and settings work is being
structured to extend to other harnesses later.

Run [`,agent_config.py`](../script/,agent_config.py) manually:

```bash
,agent_config.py          # preview only
,agent_config.py --apply  # register, prune, migrate matching links
```

Run `/reload` in Pi afterward. Python 3.9+ and PyYAML are required. The script
uses the existing Python environment; it never installs dependencies or runs
scripts from discovered repositories.

## Selection

Skills opt in through `SKILL.md` frontmatter:

```yaml
---
name: example
description: Explain when to use this skill.
metadata:
  scope: global
---
```

Unmarked skills and `scope: local` stay local. Scan roots are `~/dot` and
`~/repos`, recursively, including nested repositories, submodules, and hidden
skill directories. Symlinked directories and symlinked `SKILL.md` files are
not followed. Dependency/generated directories named `.git`, `node_modules`,
`.venv`, `venv`, `__pycache__`, `.cache`, `vendor`, `dist`, and `build` are skipped.
This is a directory exclusion policy, not Git authorship detection.

Duplicate names among selected source skills, malformed frontmatter, unknown
scope values, missing scan roots, and read errors abort before configuration
or symlink changes. Package skills and standalone skills outside the scan
roots remain unmanaged; Pi handles collisions with those resources.

## Machine-local Pi settings

Live [settings.json](../config/pi/agent/settings.json) is gitignored. Provider,
model, skill paths, and changes made inside Pi stay on this computer. The
tracked [settings.example.json](../config/pi/agent/settings.example.json)
contains reusable defaults, without provider/model selections, discovered
skill paths, or changelog state.

On a new machine, initialize once without overwriting an existing config:

```bash
cd ~/dot
cp -n config/pi/agent/settings.example.json config/pi/agent/settings.json
,agent_config.py --apply
```

Choose that machine's model in Pi. Pi saves the selection in its local live
settings. Template edits do not automatically update existing machines;
copy desired changes manually. Do not force-add live settings to Git.

To publish shared changes from this computer back to the template:

```bash
,agent_config.py --export          # preview changed keys, without printing values
,agent_config.py --export --apply  # update settings.example.json
```

Export replaces the template with live settings minus `defaultProvider`,
`defaultModel`, `skills`, and `lastChangelogVersion`. It preserves live
settings, backs up the old template to `settings.example.json.bak.skills`,
and does not scan or sync skills. Both files live in the selected Pi agent
directory. Missing or invalid live settings abort the export. Repeated
exports without changes do not rewrite the template or backup.

Export is a four-key filter, not a secret scanner: review the template diff
before committing, especially custom fields and local package/extension paths.

Existing clones: back up their tracked settings before pulling the commit
that untracks this file, then restore that backup as their ignored live
settings. Git may otherwise remove a clean tracked copy during the update.

## Native registration

The script adds individual source directories to `skills` in Pi's user
`settings.json`, using `PI_CODING_AGENT_DIR` when set and Pi's default agent
directory otherwise. It preserves other settings and pre-existing manual
skill entries. Existing resource filters remain in force.

Ownership lives under `$XDG_STATE_HOME/pi_skills/`, falling back to the
standard user state directory. Each agent directory gets a separate ledger.
Only exact entries previously added by this script can be pruned. Rewriting
an entry yourself (for example to a relative path or `+path`) makes it manual;
the script deliberately releases ownership rather than deleting your edit.
Do not delete the ledger unless you want existing entries treated as manual.

Apply takes a process lock. Before updating settings, it saves the previous
text to `settings.json.bak.skills`, writes ownership ahead, then atomically
replaces settings. Successful completion trims the ownership ledger.
Interrupted writes can be retried. A settings symlink remains a symlink.
Avoid editing Pi settings concurrently; the script checks for changes during
its scan, but cannot lock unrelated editors or Pi itself.

## Migration

After native registration succeeds, apply removes only direct symlinks in
the shared agent skills directory whose resolved targets match selected
global sources. Real directories, unrelated links, package installs, and
other agents' skill directories remain untouched. This also removes those
shared links from Codex discovery; this setup intentionally targets Pi only.

Do not run the old multi-agent symlink installer for these skills. If it
recreates matching shared links, the next apply migrates them again.

The initial seven global skills are `agent-usage-report`,
`cheap-model-research`, `git-report`, `migrate-todo`, `privacy-scan`,
`hello-engineering`, and `req-grill`. Standalone `no-ai-slop` stays untouched.

## Verify

```bash
cd ~/dot
python3 -m unittest discover -s tests -p test_agent_config.py
,agent_config.py
```

Output is a human-readable tree with skill status, source paths, skip reasons,
and totals. Home paths shorten to `~/`; the settings destination appears once.
Errors go to stderr. Apply prints its plan first and confirms completion only
after all operations succeed.

```text
Pi skills - preview (no changes)
|-- Settings: ~/dot/config/pi/agent/settings.json
|-- [KEEP] git-report
|   `-- Source: ~/repos/ai/docs/agents/skills/git-report
`-- Summary: 1 global, 0 to add, 0 to remove, 0 links to migrate
```

A second apply without source changes performs no settings or ledger writes.
