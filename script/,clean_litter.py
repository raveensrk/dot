#!/usr/bin/env python3
"""Find editor leftovers and empty folders in your main folders, then move them to the Trash.

Dry run by default: it lists what it would move and changes nothing. With
--apply it asks once, then moves each item to the Trash (restore from Finder >
Trash). Nothing is ever deleted outright.

Litter is matched by exact name pattern, files only:
  name~           editor backup (vim, emacs)
  #name#          emacs autosave
  .#name          emacs lock file
  .DS_Store       Finder metadata
  *.dcv  *.SVM    simulator leftovers

Empty folders are left alone unless you pass --empty-folders: some are
placeholders a tool expects. Even then only folders already empty count, never
their parents. App bundles (.app, .framework, .bundle), build output (target,
build, dist), .git, node_modules and virtualenvs are never entered.

Usage:
  ,clean_litter.py                         list litter files that would be moved
  ,clean_litter.py --empty-folders         also list empty folders
  ,clean_litter.py --apply                 ask once, then move them to the Trash
  ,clean_litter.py --apply --empty-folders same, including empty folders
  ,clean_litter.py -h, --help     this summary (full text: ,clean_litter.py help)
"""

import fnmatch
import os
import shutil
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
ROOTS = [
    "Desktop", "Documents", "Downloads", "Mail", "dot", "icloud", "dot_local/script", "tmp", "work",
]
SKIP_DIRS = {".git", "node_modules", ".venv", "venv", "__pycache__", ".Trash", "target", "build", "dist"}
SKIP_SUFFIXES = (".app", ".framework", ".bundle", ".photoslibrary")


def is_litter(name):
    return (
        (name.endswith("~") and len(name) > 1)
        or (name.startswith("#") and name.endswith("#") and len(name) > 2)
        or name.startswith(".#")
        or name == ".DS_Store"
        or fnmatch.fnmatchcase(name, "*.dcv")
        or fnmatch.fnmatchcase(name, "*.SVM")
    )


def scan(roots):
    files, empty_dirs = [], []
    for root in roots:
        # Only folders that are empty now count: one that holds only litter is
        # left for the next run, so a single run never cascades upward.
        for dirpath, dirnames, filenames in os.walk(root, topdown=True, followlinks=False):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.endswith(SKIP_SUFFIXES)]
            for name in filenames:
                if is_litter(name):
                    files.append(Path(dirpath) / name)
            if Path(dirpath) != root and not dirnames and not filenames:
                if not os.listdir(dirpath):
                    empty_dirs.append(Path(dirpath))
    return files, empty_dirs


def tilde(path):
    text = str(path)
    return "~" + text[len(str(HOME)):] if text.startswith(str(HOME)) else text


def main():
    args = sys.argv[1:]
    if args[:1] in (["-h"], ["--help"], ["help"]):
        print(__doc__ if args[0] == "help" else __doc__.split("\n\n")[0])
        return 0
    unknown = [a for a in args if a not in ("--apply", "--empty-folders")]
    if unknown:
        print(f",clean_litter.py: unknown argument {unknown[0]!r} (see --help)", file=sys.stderr)
        return 2
    apply = "--apply" in args

    roots = [HOME / r for r in ROOTS if (HOME / r).is_dir()]
    # ~/icloud is a symlink; walk its target once, by its real path.
    roots = list(dict.fromkeys(Path(os.path.realpath(r)) for r in roots))
    files, empty_dirs = scan(roots)
    if "--empty-folders" not in args:
        empty_dirs = []
    items = files + empty_dirs
    if not items:
        print("No litter found.")
        return 0

    for path in files:
        print(f"file   {tilde(path)}")
    for path in empty_dirs:
        print(f"empty  {tilde(path)}/")
    print(f"\n{len(files)} files, {len(empty_dirs)} empty folders.")

    if not apply:
        print("Dry run: nothing moved. Run with --apply to move these to the Trash.")
        return 0
    if shutil.which("trash") is None:
        print(",clean_litter.py: needs the trash command (brew install trash)", file=sys.stderr)
        return 1
    if not sys.stdin.isatty():
        print(",clean_litter.py: --apply needs a terminal to confirm; nothing moved", file=sys.stderr)
        return 1
    if input("Move all of these to the Trash? [y/N] ").strip().lower() != "y":
        print("Nothing moved.")
        return 0

    failed = [p for p in items if subprocess.run(["trash", str(p)]).returncode != 0]
    print(f"Moved {len(items) - len(failed)} items to the Trash.")
    if failed:
        print("Could not move: " + ", ".join(tilde(p) for p in failed), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
