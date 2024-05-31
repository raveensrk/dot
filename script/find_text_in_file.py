#!/usr/bin/env python3
"""
This file has the function to find a text in a file and return the file name, line number, column_number of said text
"""

import re

def find_text_in_file(file_path, search_text):
    """
    Find the location of a text in a file and return,
    file_path line_number column_number
    """
    matches=[]
    with open(file_path, "r") as file:
        for line_number, line in enumerate(file, start=1):
           for match in re.finditer(search_text, line):
                column_number = match.start() + 1
                matches.append((line.strip(), file_path, line_number, column_number))

    # If the text is not found, return None
    return matches
