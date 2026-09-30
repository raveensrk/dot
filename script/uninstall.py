#!/usr/bin/env python3
"""Remove the stow links created by install.py. Dry-run by default; pass --apply to write."""

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
    args = parser.parse_args(argv)

    try:
        packages = dot_stow.resolve(args.packages)
    except KeyError as error:
        parser.error(str(error))

    failed = False
    for package in packages.values():
        try:
            plan = dot_stow.uninstall(package, apply=args.apply)
        except dot_stow.StowError as error:
            print(f"`-- {package.name}: {error}", file=sys.stderr)
            failed = True
            continue
        for line in dot_stow.format_plan(plan, applied=args.apply):
            print(line)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
