#!/usr/bin/env python3
"""
This is a snippet to create a spinner in python
"""
import subprocess
import sys
import textwrap
from rich.console import Console
from rich import print
from rich.progress import Progress
from rich_logging import log

console = Console()


def main(cmds: list, barr: bool = True) -> bool:
    """
    This function takes a list of lists as input and executes it with subprocess.run
    """
    progress = Progress(auto_refresh=True, expand=True)

    if barr is False:
        for task in cmds:
            description = f"{" ".join(task)}"
            description = textwrap.shorten(description, 50)
            description = str(description).ljust(50)
            log.info(f"Running {task = }")
            subprocess.run(task, check=True)
            # with console.status(" ".join(task)[0:50].rjust(50)):
            #     # print(task)
            #     subprocess.run(task, check=True)
    else:
        task = progress.add_task("Tasks Running...", total=100.0)
        with progress:
            for job in cmds:
                # print(job)
                description = f"{" ".join(job)}"
                description = textwrap.shorten(description, 50)
                description = str(description).ljust(50)
                progress.update(task, description=description)
                # print(job)
                advance = 100.0 / len(cmds)
                console.rule("Result")
                try:
                    result = subprocess.run(job, check=True)
                    if result.returncode == 0:
                        # print(count, len(cmds))
                        progress.advance(task, advance)
                    else:
                        log.fatal(f"Unusual exit... {result = }")
                        sys.exit(2)
                except KeyboardInterrupt:
                    continue
    return True


if __name__ == "__main__":
    list_of_tasks = [
        ["python", "-c", f"from time import sleep; sleep({x * 0.1})"] for x in range(10)
    ]
    # print(list_of_tasks)
    main(list_of_tasks, barr=True)
    main(list_of_tasks, barr=False)
    print("Tasks Completed...")
