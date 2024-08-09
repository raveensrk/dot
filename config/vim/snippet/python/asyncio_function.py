#!/usr/bin/env python3
"""
This script converts the matfiles into text files
"""

import asyncio
import logging
import timeit
from time import sleep

SEM_LIMIT = 10 # Limit the number of concurrent tasks

def some_synchronous_blocking_function():
    """
    This function sleeps
    """
    sleep(2)


logging.basicConfig(
    level=logging.INFO, format="%(levelname)s: %(name)s: %(message)s"
)
logging.getLogger("asyncio").setLevel(logging.WARNING)
log = logging.getLogger("ASYNCIO_FUNCTION")
log.setLevel(logging.INFO)


async def create_task(i, sem):
    """
    This creates a coroutine
    """
    async with sem:
        log.info(f"Asynchronously creating a task: {i}")
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, some_synchronous_blocking_function)

async def main():
    """
    Main function that gathers all the asyncio coroutines
    """
    sem = asyncio.Semaphore(SEM_LIMIT)  # Semaphore to limit concurrency

    coroutines = []
    for job in range(1, 65):
        coroutines.append(create_task(job, sem))

    log.info("Starting all jobs...")
    await asyncio.gather(*coroutines)


if __name__ == "__main__":
    start_time = timeit.default_timer()
    asyncio.run(main())
    end_time = timeit.default_timer()
    total_time_taken = end_time - start_time
    log.info(f"{total_time_taken = }")
