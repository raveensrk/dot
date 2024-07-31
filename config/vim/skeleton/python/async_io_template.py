#!/usr/bin/env python3
"""
This is just a template code to create a program with asyncio processing
"""

import asyncio
import logging
import timeit

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(name)s: %(message)s")
logging.getLogger("asyncio").setLevel(logging.WARNING)
log = logging.getLogger("ASYNCIO_TEMPLATE")
# log.setLevel(logging.INFO)


async def create_task(job):
    """
    Create async tasks from the tests list
    """

    proc = await asyncio.create_subprocess_shell(job, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
    stdout, stderr = await proc.communicate()
    code = proc.returncode
    log.info(f"{stdout.decode() = }")
    log.info(f"{stderr.decode() = }")
    log.info(f"{code = }")


async def main():
    """
    Main function that gathers all the asyncio coroutines
    """

    jobs = ["sleep 1", "sleep 2", "sleep 3", "sleep 1.5", "Jobbernaut"]
    coroutines = []
    for job in jobs:
        coroutines.append(create_task(job))

    log.info("Starting all jobs...")
    await asyncio.gather(*coroutines)
    log.debug(type(jobs))


if __name__ == "__main__":
    start_time = timeit.default_timer()
    asyncio.run(main())
    end_time = timeit.default_timer()
    total_time_taken = end_time - start_time
    log.info(f"{total_time_taken = }")
