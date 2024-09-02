#!/usr/bin/env python3
"""
This is a module for logging messages
"""

import logging
import os


FORMAT_STRING = "%(message)s"
FORMAT_STRING2 = "%(levelname)s: %(message)s"

logging.basicConfig(
    encoding="utf-8",
    format=FORMAT_STRING,
    # level=logging.INFO,
    level=logging.DEBUG,
    # handlers=[RichHandler(show_time=False, rich_tracebacks=True)],
)

log = logging.getLogger("root")
formatter = logging.Formatter(FORMAT_STRING2)
file_handler = logging.FileHandler("/tmp/run.log", "w", encoding="UTF-8")
file_handler.setFormatter(formatter)
log.addHandler(file_handler)

log_pass = logging.getLogger("pass")
formatter = logging.Formatter(FORMAT_STRING)
file_handler = logging.FileHandler("/tmp/pass.log", "w", encoding="UTF-8")
file_handler.setFormatter(formatter)
log_pass.addHandler(file_handler)

log_fail = logging.getLogger("fail")
formatter = logging.Formatter(FORMAT_STRING)
file_handler = logging.FileHandler("/tmp/fail.log", "w", encoding="UTF-8")
file_handler.setFormatter(formatter)
log_fail.addHandler(file_handler)

if __name__ == "__main__":
    log.debug("This message should go to the log file")
    log.info("So should this")
    log.warning("And this, too")
    log.error("And non-ASCII stuff, too, like resund and Malm")
    log.debug("This message should go to the log file")
    log_pass.info("This passed")
    log_fail.info("This failed")
