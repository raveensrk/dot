#!/usr/bin/env python3
"""
Some shortcuts and functions since I am lazy
"""

import os
import subprocess
import hashlib
from typing import Union


def expand(path: str) -> str:
    """
    Expand paths
    """
    return os.path.abspath(os.path.expanduser(os.path.expandvars(path)))


def execute_cmd2(cmd: list[str], name: str) -> int:
    """
    Execute the command and return the results
    """
    print("COMMAND: ", cmd)
    try:
        subprocess.run(cmd, check=True)
        print(f"PASS: {name}")
    except:
        print(f"FAIL: Unable to run {name}")


def check_hash(filename: Union[str, list[str]]) -> str:
    """
    Input: Filename or a list of filnames
    Output: sha256 hash
    """
    h = hashlib.sha256()
    if isinstance(filename, list):
        for file in filename:
            file = expand(file)
            with open(file, "rb") as f:
                for line in f.readlines():
                    h.update(line)
    else:
        with open(filename, "rb") as f:
            for line in f.readlines():
                h.update(line)
    return h.hexdigest()


if __name__ == "__main__":
    execute_cmd2(["echo", "hello"], "Hello")
    execute_cmd2(["grep", "abc", "./box.sh"], "Grep")
