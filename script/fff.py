#!/usr/bin/env python3
"""
This script finds all files under the given directory
"""

import sys
import os
import glob
import subprocess
import argparse
import re
from simple_term_menu import TerminalMenu
from rich import inspect


def find_matching(file: str, pattern1: str) -> tuple[list, list]:
    """
    This function finds list of files and directories matching a given pattern
    """
    with open(
        os.path.expandvars(os.path.expanduser(file)),
        mode="r",
        encoding="UTF-8",
    ) as f:
        dirs3 = f.readlines()

    f.close()

    # inspect(dirs3)
    dirs4: list[str] = [
        os.path.expandvars(os.path.expandvars(x.strip())) for x in dirs3
    ]
    # inspect(dirs4)
    found = [glob.glob(x + "/**/*", recursive=True) for x in dirs4]
    # inspect(found)
    files = []
    found_dirs = []
    for file1 in found:
        for line in file1:
            if not re.search(pattern1, line):
                continue
            if pattern not in line:
                continue
            if ".git" in line:
                continue
            if os.path.isfile(line):
                files.append(line)
            elif os.path.isdir(line):
                found_dirs.append(line)
            else:
                print(f"Not file or directory : {f}")
                sys.exit(2)
    # inspect(files, title="files")
    # inspect(found_dirs, title="found_dirs")
    return files, found_dirs


def menu(options: list[str], multi_select: bool) -> str | list[str]:
    """
    Display the list as menu
    """
    if len(options) == 0:
        print("Number of options is zero")
    terminal_menu = TerminalMenu(
        options,
        multi_select=multi_select,
        title="Select a file or directory to open",
    )
    menu_entry_index: int | tuple = terminal_menu.show()
    # inspect(menu_entry_index, title="menu_entry_index")

    selected_list: list[str] = []
    selected: str = "None"
    if isinstance(menu_entry_index, int):
        selected = options[menu_entry_index]
        # inspect(selected, title="Selected")
        # inspect(options, title="Options")
        return selected

    for index in menu_entry_index:
        selected_list.append(options[index])
    # inspect(selected_list, title="Selected List")
    return selected_list


def open_in_vim(files: list[str] | str):
    """
    Open the files in vim
    """
    args2 = ["vim"]
    args2.extend(files)
    # inspect(args2, title="args")
    subprocess.run(args2, check=True)


def open_with_cd(dirs: str):
    """
    Print a cd command with selection
    """
    # cd_cmd = "cd " + dirs
    cd_cmd = dirs
    # inspect(cd_cmd)
    print(cd_cmd)


def test_me():
    """
    Run test
    """
    files1, dirs = find_matching("~/script/fff_list.txt", ".")
    files_to_open = menu(files1, multi_select=True)
    dir_to_open = menu(dirs, multi_select=False)
    # inspect(files_to_open, title="files_to_open")
    # inspect(dir_to_open, title="dir_to_open")
    open_in_vim(files_to_open)
    assert isinstance(dir_to_open, str)
    open_with_cd(dir_to_open)


def main(find_dir: bool, pattern1: str):
    """
    Run test
    """
    files1, dirs = find_matching("~/script/fff_list.txt", pattern1)
    # inspect(files_to_open, title="files_to_open")
    # inspect(dir_to_open, title="dir_to_open")
    if find_dir is True:
        if len(dirs) == 0:
            print("Number of dirs found = 0")
            sys.exit(2)
        dir_to_open = menu(dirs, multi_select=False)
        assert isinstance(dir_to_open, str)
        open_with_cd(dir_to_open)
    else:
        if len(files1) == 0:
            print("Number of files found = 0")
            sys.exit(2)
        files_to_open = menu(files1, multi_select=True)
        open_in_vim(files_to_open)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        "Script that lists files and directores and promps the user for selection"
    )
    parser.add_argument(
        "--dirs",
        required=False,
        action='store_true',
        help="Only lists directory",
    )
    parser.add_argument(
        "--test",
        required=False,
        action='store_true',
        help="Only lists directory",
    )
    parser.add_argument(
        "--interactive",
        required=False,
        action='store_true',
        help="Run interactively",
    )
    parser.add_argument(
        "--pattern",
        type=str,
        required=False,
        default=".",
        help="Only lists directory",
    )
    args = parser.parse_args()
    dirs1 = args.dirs
    test = args.test
    interactive = args.interactive
    # inspect(interactive, title="Interactive")
    if interactive:
        pattern=input("Enter pattern to search: ")
    else:
        pattern = args.pattern
    # inspect(dirs1, title="DIR")
    # inspect(test, title="TEST")
    if test:
        test_me()
    else:
        main(dirs1, pattern)
