#!/usr/bin/env python3
"""
This script will print hexadecimal addresses of width 32 bits
Run command:
Dispatch pytest %
"""

def main():
    """
    Print
    """
    print("Each address is 1 byte, 1 32 bit register is 4 bytes, so each register is incremented by 4 bytes address.")
    for i in range(0, 200, 4):
        print(f"{i} in hex is {hex(i)}")

if __name__ == "__main__":
    main()
