#!/usr/bin/env python3
"""
List all files under the specified directory
"""

import os
import argparse
import json

parser = argparse.ArgumentParser("Description of the code here...")
parser.add_argument("--config", type=str, required=False, default=True, help="HALP...")
args = parser.parse_args()


def list_files(directory: list):
    """
    List all files under directory list
    """
    files_list = []
    for d in directory:
        d = os.path.expanduser(d)
        d = os.path.expandvars(d)
        for root, dirs, files in os.walk(d):
            for file in files:
                path = os.path.join(root, file)
                if ".git" in path:
                    continue
                if "sos" in path:
                    continue
                files_list.append(path)
    return sorted(files_list)


with open(args.config, "r", encoding="UTF-8") as file_pointer:
    directory_paths = json.load(file_pointer)

# print(directory_paths)

# Example usage
all_files = list_files(directory_paths)
for file in all_files:
    print(file)
