#!/usr/bin/env python
"""
Read a file containing list of git repositories and run lazygit in that
"""

import subprocess
import os

list_of_repositories = os.path.expanduser("~/script/list_of_repositories.txt")

with open(list_of_repositories, "r", encoding="UTF-8") as file_pointer:
    repos = file_pointer.readlines()

for repo in repos:
    repo = os.path.expanduser(repo.rstrip())
    print("Repo: %s" % repo)
    os.chdir(repo)
    subprocess.run(["git", "fetch"], check=True)
    subprocess.run(["lazygit"], check=True)
