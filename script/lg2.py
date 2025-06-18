#!/usr/bin/env python3
"""
Read a file containing list of git repositories and run lazygit in that
"""

import subprocess
import os

list_of_repositories = os.path.expanduser("~/script/list_of_repositories.txt")

with open(list_of_repositories, "r", encoding="UTF-8") as file_pointer:
    repos = file_pointer.readlines()


for repo in repos:
    repo = os.path.expandvars(os.path.expanduser(repo.rstrip()))
    print(f"Repo: {repo}")
    os.chdir(repo)
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        check=True,
        capture_output=True,
        text=True,
    )
    # print(type(result))
    # stdout = result.stdout
    lines = result.stdout.split("\n")
    lines = [line for line in lines if line.strip()]
    print("Number of lines: %0d" % len(lines))
    if len(lines) != 0:
        subprocess.run(["lazygit"], check=True)

    subprocess.run(["git", "pull"], check=True)
    subprocess.run(["git", "push"], check=True)
