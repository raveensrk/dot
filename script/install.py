#!/usr/bin/env python3
"""Install the agent harness config for pi, Claude Code and Codex. Dry-run by default.

No symlinks: each harness reads this repo in place where it can, and gets a
real file or a key merge where it cannot. Then ~/repos/agent1/install.py
registers agent1 (skills, commands, guards) the same way.

Examples:
  script/install.py               # show the plan
  script/install.py --apply       # write it
  script/install.py --check       # exit 1 when a harness drifted from this repo
  script/uninstall.py --apply     # remove the files this wrote
  script/install.py -h, --help    # short help
  script/install.py help          # long help

What goes where:
  config/pi/settings.json      keys merged into ~/.pi/agent/settings.json
  config/pi/package.json       makes config/pi a local pi package: the
                               extensions load from this repo
  config/claude/settings.json  keys merged into ~/.claude/settings.json
  config/agents/AGENTS.md      copied to ~/.pi/agent/AGENTS.md,
                               ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md
  config/agents/mcp.json       mcpServers merged into ~/.pi/agent/mcp.json
                               and ~/.claude.json
  config/agents/claude_plugin  copied to ~/.agents/.claude-plugin and
                               registered with the claude CLI, so Claude loads
                               ~/.agents/skills (pi's Agent Skills dir) as the
                               plugin agents-dir@agents-dir
  powerline theme.json         copied to the fixed path pi-powerline-footer reads

Merge rule: only keys present in the source are touched. A dict merges key
by key, a list gains the items it lacks, anything else is replaced. Keys the
harness writes at runtime stay. A string starting with ~/ is expanded for
Claude, which does not expand it. A harness whose home directory is missing
is skipped.

Migration: a target that is still a symlink into this repo (the old stow
install) is moved to the Trash and replaced with a real file.

Environment: HOME selects the destination root; AGENT1 overrides the agent1 repo.
Exit codes: 0 success; 1 conflict, drift with --check, or agent1 failure;
2 invalid arguments.

Tests: timeout 60 python3 -m pytest tests/test_install.py
"""

from __future__ import annotations

import argparse
import filecmp
import json
import os
import subprocess
import sys

HOME = os.path.expanduser("~")
DOT = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
AGENT1 = os.environ.get("AGENT1") or os.path.join(HOME, "repos", "agent1")
sys.path.insert(0, os.path.join(AGENT1, "harness"))
import install_lib  # noqa: E402
from install_lib import Run, load, tilde  # noqa: E402

AGENTS_DIR = os.path.join(HOME, ".agents")

PI = os.path.join(HOME, ".pi")
CLAUDE = os.path.join(HOME, ".claude")
CODEX = os.path.join(HOME, ".codex")

# (source in this repo, target, harness home that must exist, expand ~/ for it)
MERGES = [
    ("config/pi/settings.json", "~/.pi/agent/settings.json", PI, False),
    ("config/claude/settings.json", "~/.claude/settings.json", CLAUDE, True),
    ("config/agents/mcp.json", "~/.pi/agent/mcp.json", PI, True),
    ("config/agents/mcp.json", "~/.claude.json", CLAUDE, True),
]

# (source in this repo, target, harness home that must exist)
COPIES = [
    ("config/agents/AGENTS.md", "~/.pi/agent/AGENTS.md", PI),
    ("config/agents/AGENTS.md", "~/.claude/CLAUDE.md", CLAUDE),
    ("config/agents/AGENTS.md", "~/.codex/AGENTS.md", CODEX),
    ("config/agents/claude_plugin/marketplace.json", "~/.agents/.claude-plugin/marketplace.json", CLAUDE),
    ("config/agents/claude_plugin/plugin.json", "~/.agents/.claude-plugin/plugin.json", CLAUDE),
    ("config/pi/extensions/powerline-footer/theme.json",
     "~/.pi/agent/extensions/powerline-footer/theme.json", PI),
]

# Links the stow install made, now replaced by the package or by COPIES.
STOW_DIRS = ["~/.pi/agent", "~/.pi/agent/extensions"]


def expand(value):
    """Every "~/..." string in VALUE made absolute."""
    if isinstance(value, str) and value.startswith("~/"):
        return os.path.join(HOME, value[2:])
    if isinstance(value, dict):
        return {k: expand(v) for k, v in value.items()}
    if isinstance(value, list):
        return [expand(v) for v in value]
    return value


def merge(live, source):
    """LIVE with SOURCE's keys laid over it; see the merge rule above."""
    if isinstance(live, dict) and isinstance(source, dict):
        out = dict(live)
        for key, value in source.items():
            out[key] = merge(live[key], value) if key in live else value
        return out
    if isinstance(live, list) and isinstance(source, list):
        return live + [item for item in source if item not in live]
    return source


def into_dot(path):
    """True when PATH, or a directory above it, is a link into this repo."""
    real = os.path.realpath(path)
    return real != os.path.abspath(path) and real.startswith(DOT + os.sep)


def migrate(run):
    """Trash the stow links; the steps below put real files in their place."""
    for folder in STOW_DIRS:
        folder = os.path.expanduser(folder)
        if not os.path.isdir(folder):
            continue
        for name in sorted(os.listdir(folder)):
            path = os.path.join(folder, name)
            if into_dot(path):
                run.trash(path, "stow link -> %s" % tilde(os.path.realpath(path)))


def merge_step(run, src, dest, home, absolute):
    dest = os.path.expanduser(dest)
    if not os.path.isdir(home):
        return run.say("skip", dest, "%s not installed" % tilde(home))
    source = load(os.path.join(DOT, src))
    if absolute:
        source = expand(source)
    # A stow link is trashed by migrate(); in a dry run it still points at the source.
    live = {} if into_dot(dest) else load(dest)
    merged = merge(live, source)
    if merged == live:
        return run.say("ok", dest)
    changed = sorted(k for k in source if merged.get(k) != live.get(k))
    if into_dot(dest):  # dry run only: --apply trashes the link first
        run.changes += 1
        return run.say("update", dest, "real file replaces the stow link")
    run.write(dest, merged, "keys: %s" % ", ".join(changed))


def copy_step(run, src, dest, home):
    src, dest = os.path.join(DOT, src), os.path.expanduser(dest)
    if not os.path.isdir(home):
        return run.say("skip", dest, "%s not installed" % tilde(home))
    if not into_dot(dest) and os.path.isfile(dest) and filecmp.cmp(src, dest, shallow=False):
        return run.say("ok", dest)
    run.changes += 1
    run.say("copy", dest, "from %s" % tilde(src))
    if run.apply:
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(src, "rb") as reader, open(dest, "wb") as writer:
            writer.write(reader.read())


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    if argv == ["help"]:
        print(__doc__)
        return 0
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n", 1)[0],
                                     epilog="Example: script/install.py --check")
    parser.add_argument("-a", "--apply", action="store_true", help="make the changes")
    parser.add_argument("-c", "--check", action="store_true",
                        help="exit 1 when anything would change (drift)")
    opts = parser.parse_args(argv)

    run = Run(opts.apply and not opts.check)
    if not run.apply:
        print("dry run: nothing will change; pass --apply to write")

    migrate(run)
    for src, dest, home, absolute in MERGES:
        merge_step(run, src, dest, home, absolute)
    for src, dest, home in COPIES:
        copy_step(run, src, dest, home)
    install_lib.claude(run, AGENTS_DIR, False)

    print("\n== agent1", flush=True)
    flags = ["--apply"] if run.apply else ["--check"] if opts.check else []
    agent1 = subprocess.run([sys.executable, os.path.join(AGENT1, "install.py"), *flags])

    if run.conflicts or agent1.returncode:
        return 1
    if opts.check and run.changes:
        return 1
    if run.apply and run.changes:
        print("\nrestart pi and Claude Code to load the changes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
