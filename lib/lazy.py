#!/usr/bin/env python3
"""
Some shortcuts and functions since I am lazy
"""

import sys
import os
import subprocess
from rich import print


def expand(path: str) -> str:
    """
    Expand paths
    """
    return os.path.expanduser(os.path.expandvars(path))


def execute_cmd(cmd) -> int:
    """
    Execute the command and return the results
    """
    if sys.platform == 'darwin':
        cmd="echo '"+ cmd+"'"
    print(cmd)
    result, output = subprocess.getstatusoutput(cmd)
    print(result)
    print(output)
    if result != 0:
        print("Command Failed")
    return result
