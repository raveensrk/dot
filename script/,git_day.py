#!/usr/bin/env python3
"""Start- and end-of-day git check: which repos need a pull or a push.

Scans ~/dot and every git repo directly under ~/repos, fetches each one
(20 s cap, 8 at a time), and reports per repo: commits waiting on the remote
(pull), local commits not on the remote (push) with their subjects, and
uncommitted files. It never pulls, pushes or merges; that stays your call.

The rule it serves (agent1 git.md): commit freely, push at the end of the day
(about 23:00), pull at the start (about 07:00). launchd runs it at both times
with --notify.

Examples:
  ,git_day.py               # report, fetch first
  ,git_day.py -n            # report without fetching (offline, instant)
  ,git_day.py --notify      # also post a macOS notification with the counts
  ,git_day.py --install     # (re)install the 07:00 and 23:00 launchd job
  ,git_day.py --uninstall   # remove that job
  ,git_day.py -h, --help    # this text (also: ,git_day.py help)
"""
from __future__ import annotations

import argparse
import concurrent.futures
import os
import plistlib
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
SKIP = {"odysseus"}  # not the user's repo
LABEL = "com.raveenkumar.git_day"
PLIST = HOME / "Library" / "LaunchAgents" / f"{LABEL}.plist"
LOG = HOME / "Library" / "Logs" / "git_day.log"
TIMES = [(7, 0), (23, 0)]


def repos() -> list[Path]:
    found = [HOME / "dot"]
    found += sorted(p for p in (HOME / "repos").iterdir()
                    if p.name not in SKIP and (p / ".git").exists())
    return [p for p in found if git(p, "remote").strip()]


def git(repo: Path, *args: str, timeout: int = 20) -> str:
    try:
        proc = subprocess.run(["git", "-C", str(repo), *args], capture_output=True,
                              text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return ""
    return proc.stdout if proc.returncode == 0 else ""


def state(repo: Path, fetch: bool) -> dict:
    fetched = True
    if fetch:
        try:
            fetched = subprocess.run(["git", "-C", str(repo), "fetch", "-q"], capture_output=True,
                                     timeout=20, env={**os.environ, "GIT_TERMINAL_PROMPT": "0"}
                                     ).returncode == 0
        except subprocess.TimeoutExpired:
            fetched = False
    upstream = git(repo, "rev-parse", "--abbrev-ref", "@{u}").strip()
    ahead = git(repo, "log", "--format=%h %an: %s", "@{u}..HEAD").splitlines() if upstream else []
    behind = git(repo, "rev-list", "--count", "HEAD..@{u}").strip() if upstream else ""
    dirty = len(git(repo, "status", "--porcelain").splitlines())
    return {"name": repo.name, "fetched": fetched, "upstream": upstream,
            "ahead": ahead, "behind": int(behind or 0), "dirty": dirty}


def install() -> int:
    script = Path(__file__).resolve()
    job = {
        "Label": LABEL,
        "ProgramArguments": [sys.executable, str(script), "--notify"],
        "StartCalendarInterval": [{"Hour": h, "Minute": m} for h, m in TIMES],
        "StandardOutPath": str(LOG),
        "StandardErrorPath": str(LOG),
    }
    uninstall(quiet=True)
    PLIST.parent.mkdir(parents=True, exist_ok=True)
    with open(PLIST, "wb") as fh:
        plistlib.dump(job, fh)
    subprocess.run(["launchctl", "bootstrap", f"gui/{os.getuid()}", str(PLIST)], check=True)
    print(f"installed {PLIST} (runs at 07:00 and 23:00; log {LOG})")
    return 0


def uninstall(quiet: bool = False) -> int:
    subprocess.run(["launchctl", "bootout", f"gui/{os.getuid()}/{LABEL}"], capture_output=True)
    if PLIST.exists():
        PLIST.unlink()
    if not quiet:
        print(f"removed {PLIST}")
    return 0


def main(argv: list[str] | None = None) -> int:
    summary, notes = __doc__.split("\n\n", 1)
    parser = argparse.ArgumentParser(description=summary, epilog=notes,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-n", "--no-fetch", action="store_true", help="skip git fetch")
    parser.add_argument("--notify", action="store_true", help="post a macOS notification")
    parser.add_argument("--install", action="store_true", help="install the launchd job")
    parser.add_argument("--uninstall", action="store_true", help="remove the launchd job")
    args = sys.argv[1:] if argv is None else argv
    if args[:1] == ["help"]:
        parser.print_help()
        return 0
    opts = parser.parse_args(args)
    if opts.install:
        return install()
    if opts.uninstall:
        return uninstall()

    with concurrent.futures.ThreadPoolExecutor(8) as pool:
        rows = list(pool.map(lambda r: state(r, not opts.no_fetch), repos()))

    push = [r for r in rows if r["ahead"]]
    pull = [r for r in rows if r["behind"]]
    dirty = [r for r in rows if r["dirty"]]
    for r in rows:
        if not (r["ahead"] or r["behind"] or r["dirty"] or not r["fetched"]):
            continue
        bits = []
        if r["behind"]:
            bits.append(f"pull {r['behind']}")
        if r["ahead"]:
            bits.append(f"push {len(r['ahead'])}")
        if r["dirty"]:
            bits.append(f"{r['dirty']} uncommitted")
        if not r["fetched"]:
            bits.append("fetch failed")
        print(f"{r['name']}: {', '.join(bits)}")
        for line in r["ahead"]:
            print(f"    {line}")
    line = f"{len(pull)} to pull, {len(push)} to push, {len(dirty)} uncommitted, of {len(rows)} repos"
    print(line)

    if opts.notify and (push or pull):
        names = ", ".join(sorted({r["name"] for r in push + pull}))[:200]
        script = f'display notification "{names}" with title "git: {line}"'
        subprocess.run(["osascript", "-e", script], capture_output=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
