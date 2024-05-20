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
    format_string = "%(levelname)8s: %(module)12s: %(funcName)10s: %(message)s"
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

    # Add a stream handler
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)

    return logger


def create_plain_logger(logname: str = "my_logging2.log"):
    """
    Create a plain logger
    Returns: logger object
    """
    format_string = "%(message)s"
    logger_plain = logging.getLogger(__name__)
    formatter = logging.Formatter(format_string)
    if os.path.exists(logname):
        os.remove(logname)
    file_handler = logging.FileHandler(logname)
    logger_plain.propagate = False
    file_handler.setFormatter(formatter)
    logger_plain.addHandler(file_handler)
    # Add a stream handler
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    logger_plain.addHandler(stream_handler)
    return logger_plain


def header(text: str = "HEADER"):
    """
    Print a header in log file
    """
    length = len(text)
    log.info("=" * (length + 5))
    log.info("%0s", text)
    log.info("=" * (length + 5))


log = create_logger()
log_plain = create_plain_logger()

if __name__ == "__main__":
    log.debug("This message should go to the log file")
    log.info("So should this")
    log.warning("And this, too")
    log.error("And non-ASCII stuff, too, like resund and Malm")
    log_plain.debug("This message should go to the log file")
    log_plain.info("So should this")
    log_plain.warning("And this, too")
    log_plain.error("And non-ASCII stuff, too, like resund and Malm")
