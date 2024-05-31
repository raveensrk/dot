#!/usr/bin/env python3
"""
This script runs the give system verilog file
"""

import os
import shutil
import logging as log
from fcu2.scripts.lazy import expand, execute_cmd2


def run_simulation(file: str, args2: list, simulation_name: str) -> int:
    """
    Run tests
    """
    file: str = expand(file)
    path: str = shutil.which("xrun")
    if path is None:
        # log.info("Executable xrun not found. Trying verilator...")
        path = shutil.which("verilator")
        assert path is not None, "Executable verilator and xrun not found."
        executable: str = path
        args1: list[str] = [
            "--binary",
            "--trace",
            "--trace-params",
            "--trace-structs",
            "--trace-depth",
            "1",
            "--timing",
            "--error-limit",
            "1",
            "--assert",
            "--relative-includes",
        ]
    else:
        executable: str = path
        args1: list[str] = [
            "+access+r",
            "-errormax",
            "1",
        ]

    simulate_file(executable, args1, file, args2, simulation_name)


def simulate_file(
    executable: str, args1: list, file: str, args2: list, simulation_name: str
):
    """
    This takes 3 arguments, executable, args, and file
    as string and tries to simulate
    """

    # print(type(executable),
    #       type(args1),
    #       type(file),
    #       type(args2),
    #       type(simulation_name))

    cmd: list[str] = []
    cmd.append(executable)
    cmd.extend(args1)
    cmd.append(file)
    cmd.extend(args2)

    name, _ = os.path.splitext(os.path.basename(file))

    if "verilator" in executable:
        cmd2 = [f"./obj_dir/V{name}"]
        execute_cmd2(cmd, f"SIMULATION: {simulation_name}")
        execute_cmd2(cmd2, f"SIMULATION: {simulation_name}")
    else:
        execute_cmd2(cmd, f"SIMULATION: {simulation_name}")


def copy_file_if_not_exists(path1: str, path2: str):
    """
    Copy path1 to path2 if path2 doesn't exist
    """
    path1 = expand(path1)
    path2 = expand(path2)
    if not os.path.exists(path2):
        log.info(
            "%s does not exist. Do you want to copy %s to %s? Y/n:",
            path2,
            path1,
            path2,
        )
        choice = input()
        log.info("Choice = %s", choice)
        if choice == "Y":
            log.info("Copying...")
            shutil.copy(path1, path2)
        log.info("Not Copying...")


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
        "--simulation-name",
        type=str,
        required=True,
        help="Simulation name",
    )
    parser.add_argument(
        "--args",
        nargs="+",
        required=True,
        help="""
        Arguments to the simulator, each argument quoted and seperated by space
        """,
    )
    args = parser.parse_args()
    source_file: str = args.source_file
    args3: list[str] = args.args
    simulation_name1: str = args.simulation_name
    run_simulation(source_file, args3, simulation_name1)
