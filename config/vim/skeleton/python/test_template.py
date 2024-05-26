#!/usr/bin/env python3
"""
DOCSTRING
"""

import inspect
import argparse
import logging
from time import sleep
import pytest
import sys
import os
import shutil
import re
import subprocess

parser = argparse.ArgumentParser("Description of the code here...")
parser.add_argument("--my-arg", type=str, required=True, help="HALP...")
args = parser.parse_args()
my_arg = args.my_arg


class Student:
    """
    Class Docstring
    """

    def __init__(self, name, age, gender, level, grades=None):
        """

        Args:
            name:
            age:
            gender:
            level:
            grades:

        """
        self.name = name
        self.age = age
        self.gender = gender
        self.level = level
        self.grades = grades or {}

    def setGrade(self, course, grade):
        """

        Args:
            course:
            grade:

        """
        self.grades[course] = grade

    def getGrade(self, course):
        """

        Args:
            course:

        Returns:


        """
        return self.grades[course]

    def getGPA(self):
        """

        Returns:


        """
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


@pytest.mark.parametrize("num", [(1), (2), (100)])
@pytest.mark.skipif(sys.platform == 'darwin', reason="Does not work in this platform")
def test_some_function():
    """
    ABC
    """
    pass

if __name__ == "__main__":
    main()
    for _ in range(2):
        print("Sleeping...")
        sleep(0.5)
    print(
        """
        Run Command:
    Dispatch ./test_generate_toby_tests.py --my-arg "ABC"
    """
    )
