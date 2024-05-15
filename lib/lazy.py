#!/usr/bin/env python3
"""
Some shortcuts and functions since I am lazy
"""

import argparse
import logging
from time import sleep
import sys
import os
import shutil
import re
import subprocess
from rich_logging import *
from rich.traceback import install
from rich import print
from rich.console import Console
console = Console()
install(show_locals=False)


def expand(path: str) -> str:
    """
    Expand paths
    """
    return os.path.expanduser(os.path.expandvars(path))


def execute_cmd(cmd) -> int:
    if sys.platform == 'darwin':
        cmd="echo '"+ cmd+"'"
    info(cmd)
    result, output = subprocess.getstatusoutput(cmd)
    info(result)
    info(output)
    if result != 0:
        critical("Command Failed")
    return result
