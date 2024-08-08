#!/usr/bin/env python3


import subprocess
import time
from rich.progress import Progress


def run_subprocess_with_progress(command, duration):
    with Progress() as progress:
        task = progress.add_task("Running", total=duration)

        process = subprocess.Popen(command, shell=True)

        start_time = time.time()
        while not progress.finished:
            elapsed = time.time() - start_time
            progress.update(task, completed=elapsed)
            time.sleep(1)
            if elapsed >= duration or process.poll() is not None:
                break

        process.wait()  # Ensure the subprocess finishes

    # Print final status
    if process.returncode == 0:
        print("Subprocess finished successfully.")
    else:
        print(f"Subprocess failed with return code {process.returncode}.")


# Example usage
command = "sleep 8"
duration = 10  # replace with the known duration in seconds
run_subprocess_with_progress(command, duration)
