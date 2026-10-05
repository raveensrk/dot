#!/usr/bin/env python3
"""Stow dotfiles packages into $HOME. Dry-run by default; pass --apply to write.

Examples:
  script/install.py                 # show the plan for every package
  script/install.py --apply         # stow every package
  script/install.py pi --apply      # stow only Pi config
  script/uninstall.py               # show what would be removed
  script/uninstall.py --apply       # remove stow links

Package mappings:
  Defined in script/dot_stow.py as PACKAGES: package name ->
  (source directory inside this repo, target directory inside $HOME).
  Pi maps config/pi/ to ~/.pi/agent/.
  Add a package there; both install.py and uninstall.py pick it up.
  Stow links source entries with:
    stow -d SOURCE_PARENT -t TARGET SOURCE_NAME

Install behavior:
  Conflicts abort before writing unless --backup or --adopt is given.
  --backup renames conflicting targets to *.bak.<timestamp>.
  --adopt imports existing target files into the package; it changes repo files.
  These flags are mutually exclusive.
  Absolute symlinks into the package are replaced with relative links.
  Already-owned relative links stay in place. Stow -R links the package
  and cleans stale links.

Ignore rules:
  config/pi/.stow-local-ignore excludes agent/ (frozen pre-stow state)
  and macOS metadata. A local ignore file REPLACES Stow's built-in list,
  so defaults are copied into it; dot_stow.DEFAULT_IGNORE mirrors them
  for the dry-run planner.

Uninstall:
  script/uninstall.py removes symlinks under the target that resolve into
  the package, then runs stow -D. Real files and target directories stay.
  Dry-run is the default; --apply is required to remove links.

Tests:
  tests/test_dot_stow.py checks install/uninstall in temporary directories:
    timeout 60 python3 -m pytest tests/test_dot_stow.py

History:
  Pi formerly stored its whole agent directory under config/pi/agent via
  PI_CODING_AGENT_DIR=~/dot/config/pi/agent. That setting was removed from
  config/bashrc and ~/.zshrc. Live state now stays in ~/.pi/agent/;
  only configuration is stowed from config/pi/.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import dot_stow  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    summary, notes = __doc__.split("\n\n", 1)
    parser = argparse.ArgumentParser(
        description=summary, epilog=notes,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("packages", nargs="*", help="package names (default: all)")
    parser.add_argument("--apply", action="store_true", help="make changes (default: dry-run)")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--backup", action="store_true",
                       help="rename conflicting targets to *.bak.<timestamp>")
    group.add_argument("--adopt", action="store_true",
                       help="import existing target files into the package (stow --adopt)")
    args = parser.parse_args(argv)

    try:
        packages = dot_stow.resolve(args.packages)
    except KeyError as error:
        parser.error(str(error))

    failed = False
    for package in packages.values():
        try:
            plan = dot_stow.install(package, apply=args.apply, backup=args.backup,
                                    adopt=args.adopt)
        except dot_stow.ConflictError as error:
            for line in dot_stow.format_plan(error.plan, applied=False):
                print(line)
            failed = True
            continue
        except dot_stow.StowError as error:
            print(f"`-- {package.name}: {error}", file=sys.stderr)
            failed = True
            continue
        for line in dot_stow.format_plan(plan, applied=args.apply):
            print(line)
        if plan.conflicts:
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
