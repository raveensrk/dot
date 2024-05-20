"""
Changes permissions of a directory and its subdirectories recursively.
"""

# coding: utf-8
import os


def change_permissions_recursive(path, mode=0o750):
    """
    Changes permissions of a directory and its subdirectories recursively.

    Args:
        path (str): The path to the directory.
        mode (int): The permissions mode
        (e.g., 0o755 for owner:rwx, group:rx, others:r).
    """
    for entry in os.listdir(path):
        full_path = os.path.join(path, entry)
        if os.path.isdir(full_path):
            change_permissions_recursive(full_path, mode)  # Recursive call
        else:
            os.chmod(full_path, mode)


if __name__ == "__main__":
    # Example usage
    TARGET_DIR = "/Users/raveenkumarwork/tmp/"
    NEW_PERMISSIONS = 0o700  # Change to your desired permissions
    change_permissions_recursive(TARGET_DIR, NEW_PERMISSIONS)
