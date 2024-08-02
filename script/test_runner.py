#!/usr/bin/env python3
"""
A script to run tests. Read a file from --tests or -t and execute each line one
by one. Run asynchronously when possible. Test file must be a json file.
"""

import json
import subprocess
import argparse
import os

parser = argparse.ArgumentParser("Simple test runner")
parser.add_argument("--tests", type=str, required=True, help="tests.json file")
args = parser.parse_args()

with open(args.tests, "r", encoding="UTF-8") as file_pointer:
    tests = json.load(file_pointer)

for obj in tests:
    subprocess.run(os.path.expanduser(os.path.expandvars(obj["cmd"])).split(), check=True)
