#!/usr/bin/env python3
"""
This script cleans my home directory
"""

import os
import glob
import itertools
import shutil
from rich.console import Console

console = Console()

def main():
    """
    Some main function
    """

    paths = [
        "~/Desktop",
        "~/Documents",
        "~/Downloads",
        "~/Mail",
        "~/bin",
        "~/bookmarks.md",
        "~/capture.md",
        "~/done.txt",
        "~/dot",
        "~/fcu2",
        "~/icloud",
        "~/personal_repo",
        "~/project",
        "~/projects.txt",
        "~/python_venv",
        "~/script",
        "~/tmp",
        "~/work",
    ]

    files = ["*#*", "*~*", "*.dcv", ".DS_Store", "*.SVM"]

    found=[]
    with console.status("Deleting junk files...", spinner="dots12"):
        for path, pattern in list(itertools.product(paths, files)):
            glob_path=os.path.expanduser(path)+"/**/"+pattern
            # glob_path=os.path.expanduser(path)+"/"+pattern
            # print(glob_path)
            found=glob.glob(os.path.expanduser(glob_path), recursive=True, include_hidden=True)
            if len(found) != 0:
                print(found)
                for file in found:
                    if os.path.isdir(file):
                        shutil.rmtree(os.path.abspath(file))
                    else:
                        os.remove(file)



def delete_empty_directories():
    """
    This function will find and delete_empty_directories in a given path recursive
    """
    paths = [
        "~/Desktop",
        "~/Documents",
        "~/Downloads",
        "~/Mail",
        "~/bin",
        "~/bookmarks.md",
        "~/capture.md",
        "~/done.txt",
        "~/dot",
        "~/fcu2",
        "~/icloud",
        "~/personal_repo",
        "~/project",
        "~/projects.txt",
        "~/python_venv",
        "~/script",
        "~/tmp",
        "~/work",
    ]

    ignore = [
            '.git'
            ]

    for root in paths:
        found=glob.glob(os.path.abspath(os.path.expanduser(root)+"/**/*"), recursive=True, include_hidden=True)
        for path in found:
            present=False
            for i in ignore:
                if i in path:
                    present=True
            if not present:
                if os.path.isdir(os.path.abspath(path)):
                    if not os.listdir(path):
                        print(f'{path=}')
                        os.removedirs(path)


if __name__ == "__main__":
    main()
    with console.status("Deleting empty directories...", spinner="dots12"):
        delete_empty_directories()
# find_broken_symlinks "$HOME" TODO
