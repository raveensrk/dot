#!/usr/bin/env python3
"""
This is a module for logging messages
"""

import logging
import os

def create_logger(logname: str = "my_logging.log"):
    """
    Create a logger
    Returns: logger object
    """
    format_string="%(levelname)8s: %(module)12s: %(funcName)10s: %(message)s"
    logger = logging.getLogger(__name__)
    logging.basicConfig(
        encoding="utf-8",
        format=format_string,
        level=logging.DEBUG,
    )

    formatter = logging.Formatter(format_string)
    if os.path.exists(logname):
        os.remove(logname)
    file_handler = logging.FileHandler(logname)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger


log = create_logger()

if __name__ == "__main__":
    log.debug("This message should go to the log file")
    log.info("So should this")
    log.warning("And this, too")
    log.error("And non-ASCII stuff, too, like resund and Malm")
