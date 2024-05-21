#!/usr/bin/env python3
"""
Some shortcuts and functions since I am lazy
"""

import sys
import os
import subprocess
import hashlib
from typing import Union
from my_logging import log
from flatten_list import flatten_list


def expand(path: str) -> str:
    """
    Expand paths
    """
    return os.path.expanduser(os.path.expandvars(path))


def execute_cmd2(cmd: list[str]) -> int:
    """
    Execute the command and return the results
    """
    cmd = flatten_list(cmd)
    cmd_as_string: str = " ".join(cmd)

    log.info(f"COMMAND: {cmd_as_string}")
    result = subprocess.run(cmd, check=False, capture_output=True)
    log.info(f"RETURN CODE: {result.returncode}")
    log.info("STDOUT:")
    log.info(result.stdout.decode())
    if len(result.stderr.decode()) != 0:
        log.info("STDERR:")
        log.info(result.stderr.decode())
    if result.returncode == 0:
        log.info("RESULT: PASS: %0s", cmd_as_string)
    else:
        log.critical("RESULT: FAIL: %0s", cmd_as_string)
        sys.exit(2)
    return result


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
        with open(file, "rb") as f:
            for line in f.readlines():
                h.update(line)
    return h.hexdigest()
