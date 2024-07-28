#!/usr/bin/env python3

import argparse
import math

def parse_resolution(resolution_str):
    # Define the resolution mappings
    resolutions = {
        '4k': (3840, 2160),
        '5k': (5120, 2880),
        '6k': (6144, 3456),
        '7k': (7680, 4320),
        '8k': (8192, 4320)
    }
    
    # Lookup resolution based on the provided string
    if resolution_str.lower() in resolutions:
        return resolutions[resolution_str.lower()]
    else:
        raise ValueError(f"Unsupported resolution '{resolution_str}'. Supported resolutions are: 4k, 5k, 6k, 7k, 8k.")

def parse_aspect_ratio(aspect_ratio_str):
    try:
        width_ratio, height_ratio = map(int, aspect_ratio_str.split(':'))
        return width_ratio, height_ratio
    except ValueError:
        raise ValueError("Aspect ratio should be in the format 'width:height' (e.g., 16:9).")

def calculate_ppi_display(width_pixels, height_pixels, diagonal_size):
    # Calculate the diagonal pixel count using the Pythagorean theorem
    diagonal_pixels = math.sqrt(width_pixels**2 + height_pixels**2)
    
    # Calculate PPI
    ppi = diagonal_pixels / diagonal_size
    return ppi

def main():
    parser = argparse.ArgumentParser(description="Calculate the PPI of a display.")
    parser.add_argument('--resolution', type=str, required=True, help="Resolution of the display (4k, 5k, 6k, 7k, 8k).")
    parser.add_argument('--aspect-ratio', type=str, default='16:9', help="Aspect ratio of the display (width:height). Default is 16:9.")
    parser.add_argument('--diagonal', type=float, required=True, help="Diagonal size of the display in inches.")
    
    args = parser.parse_args()

    # Parse resolution and aspect ratio
    width_pixels, height_pixels = parse_resolution(args.resolution)
    aspect_width, aspect_height = parse_aspect_ratio(args.aspect_ratio)
    
    # Adjust resolution according to the aspect ratio
    if aspect_width != 16 or aspect_height != 9:
        # Scale resolution based on the aspect ratio
        aspect_ratio = aspect_width / aspect_height
        new_height_pixels = int(width_pixels / aspect_ratio)
        height_pixels = new_height_pixels
    
    # Calculate PPI
    ppi = calculate_ppi_display(width_pixels, height_pixels, args.diagonal)
    print(f"\nThe PPI of the display is: {ppi:.2f}")

if __name__ == "__main__":
    main()

