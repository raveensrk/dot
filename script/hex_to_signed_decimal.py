#!/usr/bin/env python3

def hex_to_signed_decimal(hex_str, bit_size):
    # Convert hexadecimal string to an integer
    unsigned_int = int(hex_str, 16)
    
    # Calculate the maximum value for the given bit size
    max_value = 1 << (bit_size - 1)
    
    # If the number is in the range of negative values
    if unsigned_int >= max_value:
        signed_int = unsigned_int - (1 << bit_size)
    else:
        signed_int = unsigned_int
    
    return signed_int

def main():
    # Get bit size and hexadecimal number from the user
    bit_size = int(input("Enter bit size (e.g., 8, 16, 32): "))
    hex_str = input("Enter hexadecimal number (e.g., 'F0'): ").upper()
    
    # Validate hexadecimal input
    if not all(c in '0123456789ABCDEF' for c in hex_str):
        print("Invalid hexadecimal number.")
        return
    
    # Validate bit size
    if bit_size not in [8, 16, 32]:
        print("Unsupported bit size. Please enter 8, 16, or 32.")
        return
    
    # Convert and print the signed decimal number
    signed_decimal = hex_to_signed_decimal(hex_str, bit_size)
    print(f"Hexadecimal '{hex_str}' to signed decimal (for {bit_size}-bit) is {signed_decimal}")

if __name__ == "__main__":
    main()
