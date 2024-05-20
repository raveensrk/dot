#!/usr/bin/env python3
"""
Some shortcuts and functions since I am lazy
"""

import sys
import os
import subprocess
from my_logging import log, log_plain, header
from flatten_list import flatten_list


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
    log_plain.info(output)
    log.info("=================")
    if result == 0:
        log.info("PASS: %0s", cmd)
    else:
        log.critical("FAIL: %0s", cmd)
        sys.exit(2)
    log.info("=================")
    return result


def execute_cmd2(cmd: list[str]) -> int:
    """
    Execute the command and return the results
    """
    cmd = flatten_list(cmd)
    cmd_as_string: str = " ".join(cmd)
    log.info("================================")
    log.info("CMD: %0s", cmd_as_string)
    log.info("================================")
    result = subprocess.run(cmd, check=False, capture_output=True)
    log.info("Return code = %0d", result.returncode)
    log.info("================================")
    log.info("STDOUT")
    log.info("================================")
    log_plain.info(result.stdout.decode())
    log.info("================================")
    log.info("STDERR")
    log.info("================================")
    log_plain.info(result.stderr.decode())
    log.info("================================")
    if result.returncode == 0:
        log.info("PASS: %0s", cmd_as_string)
    else:
        log.critical("FAIL: %0s", cmd_as_string)
        sys.exit(2)
    log.info("================================")
    return result
