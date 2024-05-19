#!/usr/bin/env python3
"""
Some shortcuts and functions since I am lazy
"""

import sys
import os
import subprocess
from my_logging import create_logger

log = create_logger()


def expand(path: str) -> str:
    """
    Expand paths
    """
    return os.path.expanduser(os.path.expandvars(path))


def execute_cmd(cmd) -> int:
    """
    Execute the command and return the results
    """
    if sys.platform == "darwin":
        cmd = "echo '" + cmd + "'"
    log.info("=================")
    log.info("CMD: %0s", cmd)
    log.info("=================")
    result, output = subprocess.getstatusoutput(cmd)
    log.info("=================")
    log.info("Return code = %0d", result)
    log.info("=================")
    log.info("Output")
    log.info("=================")
    log.info(output)
    log.info("=================")
    if result == 0:
        log.info("PASS: %0s", cmd)
    else:
        log.critical("FAIL: %0s", cmd)
        sys.exit(2)
    log.info("=================")
    return result
