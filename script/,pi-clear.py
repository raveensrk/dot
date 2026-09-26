#!/usr/bin/env python3
# ,pi-clear.sh - delete all pi data, keep pi configs. (Python, dry-run first.)
#
# Deletes (everything regenerable):
#   $PI_CODING_AGENT_DIR/sessions            session transcripts
#   $PI_CODING_AGENT_DIR/npm                 installed packages, pi reinstalls
#                                            them from settings.json on start
#   $PI_CODING_AGENT_DIR/web-search-cache    search cache
#   $PI_CODING_AGENT_DIR/models-store.json   model metadata cache
#   ~/.pi/*                                  leftovers (browser profile, ...)
#
# Keeps: settings.json, AGENTS.md, auth.json, pi-accounts.json, extensions/,
# bin/, git/, file-diff.json, missions/ (not confirmed regenerable, 40KB).
#
# Pass 1: dry-run, lists targets with sizes. Pass 2: delete after confirm.
# Refuses to run while pi is running.

import os
import shutil
import subprocess
import sys

AGENT = os.environ.get("PI_CODING_AGENT_DIR", os.path.expanduser("~/dot/config/pi/agent"))
HOME_PI = os.path.expanduser("~/.pi")

TARGETS = [os.path.join(AGENT, p) for p in ("sessions", "npm", "web-search-cache", "models-store.json")] + [HOME_PI]


def size_mb(path):
    if not os.path.exists(path):
        return 0
    if os.path.isfile(path):
        return os.path.getsize(path) // (1024 * 1024)
    total = 0
    for root, _dirs, files in os.walk(path, onerror=lambda e: None):
        for f in files:
            try:
                total += os.path.getsize(os.path.join(root, f))
            except OSError:
                pass
    return total // (1024 * 1024)


def main():
    if subprocess.run(["pgrep", "-x", "pi"], capture_output=True).returncode == 0:
        print("pi is running - quit it first.", file=sys.stderr)
        sys.exit(1)

    # Pass 1: dry-run
    print("Would delete:")
    found = False
    for t in TARGETS:
        if os.path.exists(t):
            print(f"  {size_mb(t):>6} MB  {t}")
            found = True
    if not found:
        print("  nothing - all targets already gone.")
        return

    keep = os.path.join(AGENT, "*")  # configs: settings.json, AGENTS.md, auth, extensions/...
    print(f"Keeps:  {keep}")
    try:
        answer = input("Delete these? [y/N] ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        return
    if answer != "y":
        print("Aborted, nothing deleted.")
        return

    # Pass 2: delete
    freed = 0
    for t in TARGETS:
        if not os.path.exists(t):
            continue
        freed += size_mb(t)
        if os.path.isdir(t) and not os.path.islink(t):
            shutil.rmtree(t, ignore_errors=True)
        else:
            try:
                os.remove(t)
            except OSError:
                pass
    print(f"pi-clear: freed {freed} MB (kept configs in {AGENT}).")


if __name__ == "__main__":
    main()
