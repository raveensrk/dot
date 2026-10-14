#!/usr/bin/env python3
"""Print the byte offsets of consecutive 32-bit registers (0, 4, 8, ...) in decimal and hex.

Each register is 4 bytes, so register n sits at byte offset 4*n. Prints the
offsets from 0 to 196.

Usage:
  ,reg_offsets.py
  ,reg_offsets.py -h, --help     this summary (full text: ,reg_offsets.py help)
"""

import sys


def main():
    if sys.argv[1:2] in (["-h"], ["--help"], ["help"]):
        print(__doc__ if sys.argv[1] == "help" else __doc__.split("\n\n")[0])
        return
    print("Each address is 1 byte, 1 32 bit register is 4 bytes, so each register is incremented by 4 bytes address.")
    for i in range(0, 200, 4):
        print(f"{i} in hex is {hex(i)}")

if __name__ == "__main__":
    main()
