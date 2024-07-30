#!/usr/bin/env python
"""
Generate tags for fcu project
"""
import subprocess
import os

subprocess.run(
    [
        "universal-ctags",
        "--verbose",
        "-f",
        os.path.expanduser("~/script/tags"),
        "-R",
        os.path.expanduser("~/dot"),
        os.path.expanduser("~/work"),
    ],
    check=True,
)
