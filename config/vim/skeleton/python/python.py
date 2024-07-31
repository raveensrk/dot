#!/usr/bin/env python3
"""
DOCSTRING
"""

import argparse
import logging
from time import sleep

# import sys
# import os
# import shutil
# import re
# import subprocess

from rich.logging import RichHandler
from rich.traceback import install
from rich import print
from rich.console import Console

console = Console()

install(show_locals=True)

FORMAT = "%(message)s"
logging.basicConfig(
    level="NOTSET", format=FORMAT, datefmt="[%X]", handlers=[RichHandler()]
)

log = logging.getLogger("rich")
log.setLevel("INFO")

parser = argparse.ArgumentParser("Description of the code here...")
parser.add_argument("--my-arg", type=str, required=False, help="HALP...")
args = parser.parse_args()
my_arg = args.my_arg


class Student(object):
    def __init__(self, name, age, gender, level, grades=None):
        self.name = name
        self.age = age
        self.gender = gender
        self.level = level
        self.grades = grades or {}

    def setGrade(self, course, grade):
        self.grades[course] = grade

    def getGrade(self, course):
        return self.grades[course]

    def getGPA(self):
        return sum(self.grades.values()) / len(self.grades)


def main():
    """
    Some main function
    """
    # Define some students
    john = Student("John", 12, "male", 6, {"math": 3.3})
    jane = Student("Jane", 12, "female", 6, {"math": 3.5})

    # Now we can get to the grades easily
    print(john.getGPA())
    print(jane.getGPA())


if __name__ == "__main__":
    with console.status(f"Running {__file__ = }"):
        main()
        for _ in range(20):
            sleep(0.1)
