#!/usr/bin/env python3
"""
This script cleans my home directory
"""

import os
import glob
import itertools
import shutil
from color_codes import Color

color = Color()


def delete_junk_files(paths: list[str]):
    """
    Some main function
    """

    files = ["*#*", "*~*", "*.dcv", ".DS_Store", "*.SVM", ".*~"]

    found = []
    for path, pattern in list(itertools.product(paths, files)):
        glob_path = os.path.expanduser(path) + "/**/" + pattern
        # glob_path=os.path.expanduser(path)+"/"+pattern
        # print(glob_path)
        found = glob.glob(
            os.path.expanduser(glob_path),
            recursive=True,  # include_hidden=True
        )
        if len(found) != 0:
            print(f"Found junk files: {found = }")
            print("Press any key twice to delete junk files...")
            input()
            input()
            for file in found:
                if os.path.isdir(file):
                    shutil.rmtree(os.path.abspath(file))
                else:
                    os.remove(file)


def delete_empty_directories(paths: list):
    """
    This function will find and delete_empty_directories
    in a given path recursive
    """
    ignore = [".git"]

    for root in paths:
        found = glob.glob(
            os.path.abspath(os.path.expanduser(root) + "/**/*"),
            recursive=True,
            # include_hidden=True,
        )
        
        for path in found:
            present = False
            for i in ignore:
                if i in path:
                    present = True
            if not present:
                if os.path.isdir(os.path.abspath(path)):
                    if not os.listdir(path):
                        print(f"Press any key twice to remove empty directory {path = }")
                        input()
                        input()
                        os.removedirs(path)


if __name__ == "__main__":
    paths1 = [
        "~/Desktop",
        "~/Documents",
        "~/Downloads",
        "~/Mail",
        "~/bin",
        "~/dot",
        "~/icloud",
        "~/personal_repo",
        "~/project",
        "~/python_venv",
        "~/script",
        "~/tmp",
        "~/work",
        "~/Notes",
    ]
    delete_junk_files(paths1)
    delete_empty_directories(paths1)
