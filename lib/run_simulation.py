#!/usr/bin/env python3
"""
This script runs the give system verilog file
"""

import sys
import os
import subprocess
import shutil
import filecmp
from lazy import expand, execute_cmd2
from ndiff import main as show_diff
from flatten_list import flatten_list
from my_logging import create_logger

log = create_logger()


def main(file: str, args2: list) -> int:
    """
    Run tests
    """
    os.chdir(os.path.dirname(expand(file)))
    path = shutil.which("xrun")
    if path is None:
        # log.info("Executable xrun not found. Trying verilator...")
        path = shutil.which("verilator")
        if path is None:
            log.critical("Executable verilator and xrun not found.")
            sys.exit(2)
        else:
            executable = shutil.which("verilator")
            args1 = [
                "--binary",
                "--trace",
                "--trace-params",
                "--trace-structs",
                "--trace-depth",
                "1",
                "--timing",
                "-DTEST",
                "--error-limit",
                "1",
                "--assert",
            ]
    else:
        executable = shutil.which("xrun")
        args1 = [
            "-define",
            "TEST",
            "-define",
            "DEBUG",
            "+access+r",
            "-errormax",
            "1",
        ]

    result = simulate_file(executable, args1, file, args2)

    return result


def simulate_file(executable: str, args1: list, file: str, args2: list) -> int:
    """
    This takes 3 arguments, executable, args, and file
    as string and tries to simulate
    """
    os.makedirs("./expected", exist_ok=True)
    os.makedirs("./observed", exist_ok=True)
    cmd: list = flatten_list([executable, args1, file, args2])
    result = execute_cmd2(cmd)

    name, _ = os.path.splitext(os.path.basename(file))
    cmd2 = f"./obj_dir/V{name}"

    if "verilator" in executable:
        result = execute_cmd2([cmd2])
    return result


def copy_file_if_not_exists(path1: str, path2: str):
    """
    Copy path1 to path2 if path2 doesn't exist
    """
    path1 = expand(path1)
    path2 = expand(path2)
    if not os.path.exists(path2):
        log.info(
            f"{path2} does not exist. Do you want to copy {path1} to {path2}? Y/n:"
        )
        choice = input()
        if choice == "Y":
            shutil.copy(path1, path2)
        else:
            sys.exit(2)


def compare_2_files(path1: str, path2: str):
    """
    Compare and check if 2 files differ
    """
    path1 = expand(path1)  # observed
    path2 = expand(path2)  # expected
    copy_file_if_not_exists(path1, path2)
    if not filecmp.cmp(path1, path2):
        show_diff([path1, path2])
        log.info("Expected and observed differ")
        log.info(f"Do you want to copy {path1} to {path2}? Y/n: ")
        choice = input()
        if choice == "Y":
            shutil.copy(path1, path2)
        sys.exit(2)


def run_sim(file: str, args4: list = None) -> int:
    """
    Run simulation
    """
    args2 = []
    if args4 is not None:
        args2.extend(args4)
    file = expand(file)
    log.info("Running sim:")
    file = os.path.abspath(file)
    log.info(file)
    _ = main(file, args2)
    name, _ = os.path.splitext(os.path.basename(file))
    expected = f"./expected/{name}.log"
    observed = f"./observed/{name}.log"
    if os.path.exists(observed):
        compare_2_files(observed, expected)
    return 0


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        "Run a test using xrun or verilator and compare the results."
    )
    parser.add_argument(
        "--source-file",
        type=str,
        required=True,
        help="Source file. Usually .sv",
    )
    parser.add_argument(
        "--args",
        nargs="+",
        required=False,
        help="Arguments to the simulator, each argument quoted and seperated by space",
    )
    args = parser.parse_args()
    source_file: str = args.source_file
    args3: list[str] = args.args
    _ = run_sim(source_file, args3)
