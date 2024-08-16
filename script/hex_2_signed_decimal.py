#!/usr/bin/env python3
def hex_to_signed_decimal(hex_str):
    # Convert hex string to integer
    num = int(hex_str, 16)
    
    # Check if the number is signed (considering 32-bit signed integer)
    if num >= 2**31:
        num -= 2**32
    
    return num

# Get input from user
hex_str = input("Enter a hexadecimal value: ")
signed_decimal = hex_to_signed_decimal(hex_str)
print(f"Hexadecimal: {hex_str} -> Signed Decimal: {signed_decimal}")

