#!/usr/bin/env python3
"""
This script finds all files under the given directory
"""
import subprocess

subprocess.run("vim $(ffl.py | fzf -m)", check=True, shell=True)
