#!/usr/bin/env python3
"""
Some shortcuts and functions since I am lazy
"""

import os
import subprocess
import hashlib
from typing import Union
from my_logging import log, log_pass, log_fail
from flatten_list import flatten_list


def expand(path: str) -> str:
    """
    Expand paths
    """
    return os.path.abspath(os.path.expanduser(os.path.expandvars(path)))


def execute_cmd2(cmd: list[str], name: str, strict: bool = True) -> int:
    """
    Execute the command and return the results
    """
    cmd = flatten_list(cmd)
    # log.info("COMMAND: %s", cmd)
    cmd_as_string: str = " ".join(cmd)
    log.info("COMMAND: %s", cmd_as_string)
    result = subprocess.run(cmd, check=False, capture_output=True)
    log.info("STDOUT:")
    log.info(result.stdout.decode())
    if len(result.stderr.decode()) != 0:
        log.error("STDERR:")
        log.error(result.stderr.decode())
    if result.returncode == 0:
        log.info("RESULT: PASS: %s: %s", name, cmd_as_string)
        log_pass.info("%s: %s", name, cmd_as_string)
    else:
        log.critical("RESULT: FAIL: %s: %s", name, cmd_as_string)
        log_fail.info("%s: %s", name, cmd_as_string)
    if strict:
        assert result.returncode == 0


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
    log.info("Testing lazy.py...")
