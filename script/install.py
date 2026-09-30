#!/usr/bin/env python3
"""Stow dotfiles packages into $HOME. Dry-run by default; pass --apply to write."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import dot_stow  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
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
