#!/usr/bin/env python3
"""Undo script/install.py. Dry-run by default; pass --apply to write.

  script/uninstall.py             show the plan
  script/uninstall.py --apply     do it
  script/uninstall.py -h, --help  this text

Unregisters the ~/.agents plugin from Claude Code, moves the files
install.py copied to the Trash when they still match this repo (an edited
copy stays and is reported), then runs ~/repos/agent1/uninstall.py. Keys merged
into the harness settings files stay: they are the harness's live config now,
and removing them could break it. Edit those files by hand if needed.
"""

from __future__ import annotations

import argparse
import filecmp
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
import install  # noqa: E402
from install_lib import Run  # noqa: E402


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("-a", "--apply", action="store_true", help="make the changes")
    opts = parser.parse_args(argv)

    run = Run(opts.apply)
    if not run.apply:
        print("dry run: nothing will change; pass --apply to write")

    # Unregister first: the CLI reads the marketplace files trashed below.
    install.install_lib.claude(run, install.AGENTS_DIR, True)

    for src, dest, _home in install.COPIES:
        src, dest = os.path.join(install.DOT, src), os.path.expanduser(dest)
        if not os.path.isfile(dest):
            continue
        if filecmp.cmp(src, dest, shallow=False):
            run.trash(dest, "copy of %s" % install.tilde(src))
        else:
            run.say("keep", dest, "edited since install; differs from %s" % install.tilde(src))

    print("\n== agent1", flush=True)
    flags = ["--apply"] if run.apply else []
    agent1 = subprocess.run([sys.executable, os.path.join(install.AGENT1, "uninstall.py"), *flags])
    return 1 if run.conflicts or agent1.returncode else 0


if __name__ == "__main__":
    sys.exit(main())
