#!/usr/bin/env python3
"""
This script runs the give system verilog file
"""

import sys
import os
import subprocess
import shutil
import filecmp
from lazy import expand
from ndiff import main as show_diff
from flatten_list import flatten_list


def main(file):
    """
    Run tests
    """
    os.chdir(os.path.dirname(expand(file)))
    path = shutil.which("xrun")
    if path is None:
        # print("Executable xrun not found. Trying verilator...")
        path = shutil.which("verilator")
        if path is None:
            print("Executable verilator and xrun not found.")
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
            ]
    else:
        executable = shutil.which("xrun")
        args1 = ["-define", "TEST", "-define", "DEBUG", "+access+r", "-errormax", "2"]

    simulate_file(executable, args1, file)


def simulate_file(executable, args1, file):
    """
    This takes 3 arguments, executable, args, and file
    as string and tries to simulate
    """
    os.makedirs("./expected", exist_ok=True)
    os.makedirs("./observed", exist_ok=True)
    cmd: list = flatten_list([executable, args1, file])
    print(cmd)
    result = subprocess.run(cmd, check=False, capture_output=True)
    print(result.stdout.decode())
    print(result.stderr.decode())
    print("Return code = ", result.returncode)
    if result.returncode != 0:
        print("Test failed: " + f"{cmd = }")
        sys.exit(2)

    name, _ = os.path.splitext(os.path.basename(file))
    cmd2 = f"./obj_dir/V{name}"

    if "verilator" in executable:
        result = subprocess.run(cmd2, check=False, capture_output=True)
        print(result.stdout.decode())
        print(result.stderr.decode())
        print("Return code = ", result.returncode)
        if result.returncode != 0:
            print("Test failed: ", cmd2)
            sys.exit(2)


def copy_file_if_not_exists(path1: str, path2: str):
    """
    Copy path1 to path2 if path2 doesn't exist
    """
    path1 = expand(path1)
    path2 = expand(path2)
    if not os.path.exists(path2):
        print(f"{path2} does not exist. Do you want to copy {path1} to {path2}? Y/n:")
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
        print("Expected and observed differ")
        print(f"Do you want to copy {path1} to {path2}? Y/n: ")
        choice = input()
        if choice == "Y":
            shutil.copy(path1, path2)
        sys.exit(2)


def run_sim(file: str):
    """
    Run simulation
    """
    file = expand(file)
    print("Running sim:")
    file = os.path.abspath(file)
    print(file)
    main(file)
    name, _ = os.path.splitext(os.path.basename(file))
    expected = f"./expected/{name}.log"
    observed = f"./observed/{name}.log"
    if os.path.exists(observed):
        compare_2_files(observed, expected)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser("Run a test using xrun or verilator and compare the results.")
    parser.add_argument(
        "--source-file",
        type=str,
        required=True,
        help="Source file. Usually .sv",
    )
    args = parser.parse_args()
    source_file: str = args.source_file
    run_sim(source_file)
