#!/usr/bin/env python3
"""
This is a module for logging messages
"""

import logging
from rich.logging import RichHandler
from rich.traceback import install

install(show_locals=False)

# new = logging.FileHandler("/tmp/myapp.log")
logging.basicConfig(
    level=logging.DEBUG,
    # handlers=[RichHandler(), logging.FileHandler("/tmp/myapp.log2")],
    format="%(filename)s: %(message)s",
    handlers=[RichHandler()],
    # format="%(asctime)s %(name)-12s %(levelname)-8s %(message)s",
    # datefmt="%m-%d %H:%M",
)

log = logging.getLogger("rich")
# log.addHandler(RichHandler())

info= log.info
debug=log.debug
warning=   log.warning
error= log.error
critical=log.critical

if __name__ == "__main__":
    log.info("Jackdaws love my big sphinx of quartz.")
    log.debug("Quick zephyrs blow, vexing daft Jim.")
    log.info("How quickly daft jumping zebras vex.")
    log.warning("Jail zesty vixen who grabbed pay from quack.")
    log.error("The five boxing wizards jump quickly.")
