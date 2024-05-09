#!/usr/bin/env python3
"""
This script finds all files under the given directory
"""

import tempfile
import sys
import os
import glob
import subprocess


def main():
    """
    This function get all the files and pipes it to fzf
    """
    with open(os.path.expanduser("~/script/fff_list.txt")) as f:
        dirs = f.readlines()

    dirs = [x.strip() for x in dirs]
    found = [glob.glob(x + "/**/*", recursive=True) for x in dirs]
    files = []
    found_dirs = []
    for file in found:
        for f in file:
            if ".git" in f:
                continue
            if os.path.isfile(f):
                files.append(f)
            elif os.path.isdir(f):
                found_dirs.append(f)
            else:
                print(f"Not file or directory : {f}")
                sys.exit(2)

    tmp = tempfile.NamedTemporaryFile()
    with open(tmp.name, "w", encoding="UTF-8") as f:
        for line in files:
            f.write(line + "\n")

    tmp_dirs = tempfile.NamedTemporaryFile()
    with open(tmp_dirs.name, "w", encoding="UTF-8") as f:
        for line in found_dirs:
            f.write(line + "\n")

    if len(sys.argv) != 1:
        if sys.argv[1] != "--dir":
            print(f"Unknown argument = {sys.argv = }")
            sys.exit(2)
        cmd = os.path.abspath(tmp_dirs.name)
    else:
        cmd = f"{os.path.abspath(tmp.name)}"

    cat_process = subprocess.Popen(["cat", cmd], stdout=subprocess.PIPE, text=True)
    fzf_process = subprocess.Popen(["fzf"], stdin=cat_process.stdout, stdout=subprocess.PIPE, text=True)
    cat_process.stdout.close()  # Close unused end of the pipe
    output, _ = fzf_process.communicate()
    if output:
        print(output.strip())
    else:
        print("Error while getting the output = {output.strip()}")
        sys.exit(2)

if __name__ == "__main__":
    main()
