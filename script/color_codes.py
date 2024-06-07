#!/usr/bin/env python3
"""
This script / module contains all the color codes for printing
Run command:
term python %
"""

class Color:
    """
    Class color containing all color attributes
    """

    blink = "\033[5m"
    blue = "\033[38;5;75m"
    bold = "\033[1m"
    cyan = "\033[36m"
    dim = "\033[2m"
    green = "\033[38;5;2m"
    hidden = "\033[8m"
    inverse = "\033[7m"
    italic = "\033[3m"
    magenta = "\033[35m"
    nocolor = "\033[0m"
    red = "\033[38;5;1m"
    reset = "\033[0m"
    strikethrough = "\033[9m"
    underline = "\033[4m"
    yellow = "\033[38;5;11m"

    def __init__(self):
        print("Initialized Color class object")
        self.nocolor = self.reset
        self.info = self.cyan
        self.warning = self.yellow
        self.error = self.red
        self.fatal = self.error


if __name__ == "__main__":
    color = Color()
    print(dir(color))
    print(f"{color.green}Hello{color.reset}")
    print(f"{color.fatal}World{color.reset}")
