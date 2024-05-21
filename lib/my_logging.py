#!/usr/bin/env python3
"""
This is a module for logging messages
"""

import logging
import os
from rich.logging import RichHandler
from rich.traceback import install
from rich.console import Console

install()

console = Console()


if os.path.exists("run.log"):
    os.remove("run.log")


def header(self, text: str) -> str:
    """
    Print a header in log file
    """
    console.rule(text)
    log.info("%0s", text)


FORMAT_STRING = "%(message)s"
# FORMAT_STRING2 = "%(asctime)s: %(levelname)s: %(module)s: %(funcName)s: %(lineno)d: %(message)s"
FORMAT_STRING2 = (
    "%(asctime)s: %(levelname)s: %(pathname)s:%(lineno)d: %(message)s"
)
logging.RootLogger.header = header
logging.basicConfig(
    encoding="utf-8",
    format=FORMAT_STRING,
    # level=logging.INFO,
    level=logging.DEBUG,
    handlers=[RichHandler(show_time=False, rich_tracebacks=True)],
)
log = logging.getLogger()
formatter = logging.Formatter(FORMAT_STRING2)
file_handler = logging.FileHandler("run.log", "a", encoding="UTF-8")
file_handler.setFormatter(formatter)
log.addHandler(file_handler)
# Add a stream handler
# stream_handler = logging.StreamHandler()
# stream_handler.setFormatter(formatter)
# log.addHandler(stream_handler)


if __name__ == "__main__":
    log.debug("This message should go to the log file")
    log.info("So should this")
    log.warning("And this, too")
    log.error("And non-ASCII stuff, too, like resund and Malm")
    log.debug("This message should go to the log file")
    log.header("1Header")
    log.header("2Header Plain")
