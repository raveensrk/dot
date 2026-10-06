#!/usr/bin/env python3
"""reinstall.py - find and run install.py files across ~/dot and ~/repos.

Modes (see -h/--help):
  reinstall.py             install: run every registered installer
  reinstall.py --discover  walk ~/dot and ~/repos, offer each install.py found
  reinstall.py --install   same as default
  reinstall.py --dry-run   print what install would run, execute nothing

Config: ~/dot_local/reinstall.json - JSON array of absolute installer paths.
First run with no config starts --discover automatically, then stops.
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

ROOTS = [Path("~/dot"), Path("~/repos")]
SKIP_DIRS = {".venv", "venv", "node_modules", ".git", "__pycache__", ".Trash", ".cache"}
CONFIG = Path("~/dot_local/reinstall.json").expanduser()


def find_installers():
    """Walk both roots, skipping vendor/dep dirs, return sorted install.py paths."""
    found = []
    for root in ROOTS:
        root = root.expanduser()
        if not root.is_dir():
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            if "install.py" in filenames:
                found.append(Path(dirpath) / "install.py")
    return sorted(found)


def load_config():
    """Return list of registered paths, [] if empty, None if no config yet."""
    if not CONFIG.exists():
        return None
    try:
        data = json.loads(CONFIG.read_text())
    except (json.JSONDecodeError, OSError) as err:
        sys.exit(f"error: cannot read {CONFIG}: {err}")
    if not isinstance(data, list):
        sys.exit(f"error: {CONFIG} must be a JSON array of paths")
    return [Path(p) for p in data]


def save_config(paths):
    CONFIG.parent.mkdir(parents=True, exist_ok=True)
    CONFIG.write_text(json.dumps([str(p) for p in paths], indent=2) + "\n")


def discover():
    found = find_installers()
    if not found:
        print("no install.py found in ~/dot or ~/repos")
        return
    print(f"found {len(found)} install.py file(s)\n")
    registered = []
    for path in found:
        try:
            if input(f"register {path}? [y/N] ").strip().lower() == "y":
                registered.append(path)
        except (EOFError, KeyboardInterrupt):
            print("\nstopped; keeping what was confirmed so far")
            break
    save_config(registered)
    print(f"\n{len(registered)} registered -> {CONFIG}")
    print("run 'reinstall.py' to install")


def run_one(path):
    """Run one installer: directly if executable, else via python3."""
    if os.access(path, os.X_OK):
        return subprocess.run([str(path)]).returncode
    return subprocess.run([sys.executable, str(path)]).returncode


def install(dry_run=False):
    config = load_config()
    if config is None:
        if dry_run:
            print("no config yet; run 'reinstall.py --discover' first")
            return 1
        discover()
        return 0
    if not config:
        print("no installers registered; run 'reinstall.py --discover'")
        return 1

    registered = {p.resolve() for p in config}
    for path in find_installers():
        if path.resolve() not in registered:
            print(f"warning: unregistered installer (not run): {path}", file=sys.stderr)

    failures = 0
    for path in config:
        if not path.exists():
            print(f"FAIL  {path}  (missing)", file=sys.stderr)
            failures += 1
            continue
        if dry_run:
            print(f"would run: {path}")
            continue
        print(f"running: {path}", flush=True)
        code = run_one(path)
        if code != 0:
            print(f"FAIL  {path}  (exit {code})", file=sys.stderr)
            failures += 1

    print(f"\n{len(config) - failures}/{len(config)} ok")
    return 1 if failures else 0


def main():
    parser = argparse.ArgumentParser(description="Find and run install.py files across ~/dot and ~/repos.")
    parser.add_argument("--discover", action="store_true", help="walk ~/dot and ~/repos, offer each install.py found")
    parser.add_argument("--install", action="store_true", help="run registered installers (default)")
    parser.add_argument("--dry-run", action="store_true", help="print what install would run, execute nothing")
    args = parser.parse_args()

    if args.discover:
        discover()
        return 0
    return install(dry_run=args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
