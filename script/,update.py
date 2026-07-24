#!/usr/bin/env python3
"""Hands-off system update & maintenance manager.

Runs each known updater, catching failures and skipping missing tools, then
prints a colored per-tool summary and a final roll-up.

Output format:  <LEVEL>: <emoji>: <tool>: <message>
  LEVEL  INFO (green) / WARNING (yellow) / ERROR (red)
  emoji  ✅ ok/updated · ❌ failed · ⚠️ skipped/attention · 🔍 working

Current updaters (v1):
  - brew    : brew update -> brew upgrade -> brew cleanup
  - claude  : claude update            (npm global @anthropic-ai/claude-code)
  - codex   : brew upgrade --cask codex (OpenAI Codex CLI)
  - agy     : agy update               (~/.local/bin/agy)

Adding a new app later = append one Updater(...) to UPDATERS. If it needs a
non-standard flow, write a small update_x(u) function like update_brew and point
the entry's `run` at it. No other code changes are required.

Usage:
  ,update.py                run all updaters
  ,update.py --only agy     run a subset (repeatable: --only agy --only brew)
  ,update.py --list         list known updaters and exit

Exit code 0 when nothing failed, 2 if any tool failed (repo convention).
"""

import argparse
import shutil
import subprocess
import sys
import os

# --- colors ---------------------------------------------------------------
_USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None
GREEN = "\033[0;32m" if _USE_COLOR else ""
RED = "\033[0;31m" if _USE_COLOR else ""
YELLOW = "\033[0;33m" if _USE_COLOR else ""
NOCOLOR = "\033[0m" if _USE_COLOR else ""

PASS = "✅"
FAIL = "❌"
WARN = "⚠️"
SCAN = "🔍"

# --- tally ----------------------------------------------------------------
counts = {"updated": 0, "uptodate": 0, "skipped": 0, "failed": 0}
results = []  # list of (level, color, emoji, tool, message)


def _line(level, color, emoji, tool, message):
    print(f"{color}{level}{NOCOLOR}: {emoji}: {tool}: {message}")


def info(emoji, tool, message):
    _line("INFO", GREEN, emoji, tool, message)


def warning(tool, message):
    _line("WARNING", YELLOW, WARN, tool, message)


def error(tool, message):
    _line("ERROR", RED, FAIL, tool, message)


def record(level, color, emoji, tool, message):
    """Store a per-tool outcome for the end-of-run summary."""
    results.append((level, color, emoji, tool, message))


def run_cmd(argv, capture=True):
    """Run a command. Returns (returncode, stdout, stderr).

    capture=True  -> collect output (for version probes / parsing).
    capture=False -> inherit the terminal so interactive prompts (e.g. sudo
                     password for a cask) and live progress work; stdout/stderr
                     come back empty.
    """
    if not capture:
        result = subprocess.run(argv)
        return result.returncode, "", ""
    result = subprocess.run(argv, capture_output=True, text=True)
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def have(cmd):
    return shutil.which(cmd) is not None


def probe_version(version_argv):
    """Best-effort version string; empty if the probe fails."""
    if not version_argv:
        return ""
    rc, out, err = run_cmd(version_argv)
    if rc != 0:
        return ""
    return (out or err).splitlines()[0].strip() if (out or err) else ""


# --- updaters -------------------------------------------------------------
class Updater:
    def __init__(self, name, probe_cmd, run):
        self.name = name
        self.probe_cmd = probe_cmd
        self.run = run


def simple(u, update_argv, version_argv):
    """Generic updater: version-before, run update, version-after, classify."""
    before = probe_version(version_argv)
    info(SCAN, u.name, "updating…")
    rc, _, _ = run_cmd(update_argv, capture=False)
    if rc != 0:
        counts["failed"] += 1
        record("ERROR", RED, FAIL, u.name, "update failed — see output above")
        return
    after = probe_version(version_argv)
    if before and after and before != after:
        counts["updated"] += 1
        record("INFO", GREEN, PASS, u.name, f"{before} → {after} (updated)")
    else:
        counts["uptodate"] += 1
        ver = after or before
        suffix = f" ({ver})" if ver else ""
        record("INFO", GREEN, PASS, u.name, f"already up to date{suffix}")


def update_brew(u):
    """brew update -> brew upgrade -> brew cleanup, reporting what changed."""
    info(SCAN, u.name, "updating…")

    rc, _, _ = run_cmd(["brew", "update"], capture=False)
    if rc != 0:
        counts["failed"] += 1
        record("ERROR", RED, FAIL, u.name, "brew update failed — see output above")
        return

    # What is outdated *before* the upgrade, so we can report a count.
    _, outdated, _ = run_cmd(["brew", "outdated", "--quiet"])
    n_outdated = len([x for x in outdated.splitlines() if x.strip()])

    # Inherit the terminal so a cask that needs a sudo password can prompt.
    rc, _, _ = run_cmd(["brew", "upgrade"], capture=False)
    if rc != 0:
        counts["failed"] += 1
        record("ERROR", RED, FAIL, u.name, "brew upgrade failed — see output above")
        return

    # cleanup is best-effort — a cleanup hiccup shouldn't mark the upgrade failed.
    run_cmd(["brew", "cleanup"], capture=False)

    if n_outdated:
        counts["updated"] += 1
        record("INFO", GREEN, PASS, u.name, f"{n_outdated} package(s) upgraded, cleaned")
    else:
        counts["uptodate"] += 1
        record("INFO", GREEN, PASS, u.name, "already up to date, cleaned")


UPDATERS = [
    Updater("brew",   "brew",   update_brew),
    Updater("claude", "claude", lambda u: simple(u, ["claude", "update"], ["claude", "--version"])),
    Updater("codex",  "codex",  lambda u: simple(u, ["brew", "upgrade", "--cask", "codex"], ["codex", "--version"])),
    Updater("agy",    "agy",    lambda u: simple(u, ["agy", "update"], ["agy", "--version"])),
]


# --- driver ---------------------------------------------------------------
def run_updater(u):
    if not have(u.probe_cmd):
        counts["skipped"] += 1
        record("WARNING", YELLOW, WARN, u.name, "not installed — skipped")
        warning(u.name, "not installed — skipped")
        return
    try:
        u.run(u)
    except Exception as exc:  # keep going on unexpected failure
        counts["failed"] += 1
        record("ERROR", RED, FAIL, u.name, f"unexpected error — {exc}")
        error(u.name, f"unexpected error — {exc}")


def print_summary():
    print()
    for level, color, emoji, tool, message in results:
        _line(level, color, emoji, tool, message)

    total = len(results)
    parts = [
        f"{counts['updated']} updated",
        f"{counts['uptodate']} up-to-date",
        f"{counts['skipped']} skipped",
        f"{counts['failed']} failed",
    ]
    if counts["failed"]:
        emoji, color = FAIL, RED
    elif counts["skipped"]:
        emoji, color = WARN, YELLOW
    else:
        emoji, color = PASS, GREEN
    print()
    _line("INFO", color, emoji, f"{total} tool(s)", ", ".join(parts))


def main():
    parser = argparse.ArgumentParser(
        description="Hands-off system update & maintenance manager.",
    )
    parser.add_argument("--only", action="append", default=[], metavar="NAME",
                        help="run only this updater (repeatable)")
    parser.add_argument("--list", action="store_true",
                        help="list known updaters and exit")
    args = parser.parse_args()

    if args.list:
        for u in UPDATERS:
            status = "installed" if have(u.probe_cmd) else "not installed"
            print(f"{u.name}\t({status})")
        return 0

    selected = UPDATERS
    if args.only:
        wanted = set(args.only)
        selected = [u for u in UPDATERS if u.name in wanted]
        unknown = wanted - {u.name for u in UPDATERS}
        for name in sorted(unknown):
            counts["skipped"] += 1
            record("WARNING", YELLOW, WARN, name, "unknown updater — skipped")
            warning(name, "unknown updater — skipped")

    for u in selected:
        run_updater(u)

    print_summary()
    return 2 if counts["failed"] else 0


if __name__ == "__main__":
    sys.exit(main())
