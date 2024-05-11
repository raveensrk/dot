#!/usr/bin/env python3
"""
This script runs the give system verilog file
"""

import sys
import os
import subprocess
import shutil
import filecmp
from ndiff import main as show_diff
from rich.traceback import install
from rich.console import Console

console = Console()
install(show_locals=False)


def main(file):
    """
    Run tests
    """
    os.chdir(os.path.dirname(file))
    path = shutil.which("xrun")
    if path is None:
        print("Executable xrun not found. Trying verilator...")
        path = shutil.which("verilator")
        if path is None:
            print("Executable verilator not found.")
            sys.exit(2)
        else:
            executable = shutil.which("verilator")
            args = " " + " ".join(
                [
                    "--binary",
                    "--trace",
                    "--trace-params",
                    "--trace-structs",
                    "--trace-depth",
                    "1",
                    "--timing ",
                    "-DTEST",
                ]
            )
    else:
        executable = shutil.which("xrun")
        args = " -define TEST -define DEBUG "

    simulate_file(executable, args, file)


def simulate_file(executable, args, file):
    """
    This takes 3 arguments, executable, args, and file as string and tries to simulate
    """
    os.makedirs("./expected", exist_ok=True)
    os.makedirs("./observed", exist_ok=True)
    cmd = executable + " " + args + " " + file
    print(f"{cmd = }")
    name, _ = os.path.splitext(os.path.basename(file))
    print(f"{name = }")
    cmd2 = f"./obj_dir/V{name}"
    print(f"{cmd2 = }")
    result, out = subprocess.getstatusoutput(cmd)
    print(f"{result = }")
    print(out)

    if result != 0:
        print("Test failed: " + f"{cmd = }")
        sys.exit(2)

    if "verilator" in executable:
        result2, out2 = subprocess.getstatusoutput(cmd2)
        print(f"{result2 = }")
        print(out2)
        if result2 != 0:
            print("Test failed: " + cmd2)
            sys.exit(2)


if __name__ == "__main__":
    print(f"Running {__file__ = }")
    source_file = os.path.abspath(sys.argv[1])
    main(source_file)
    name, _ = os.path.splitext(os.path.basename(source_file))
    if not filecmp.cmp(f"./expected/{name}.log", f"./observed/{name}.log"):
        show_diff([f"./expected/{name}.log", f"./observed/{name}.log"])
        print(f"Expected and observed differ for {source_file =}")
        sys.exit(2)
    else:
        print(f"Expected and observed are same for {source_file =}")
