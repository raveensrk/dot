#!/bin/bash

# This will remove empty lines from a text file - Top and bottom of
# the file only. Empty lines from the middle of the file is untouched.

vim tmp.txt -c ":execute \"norm gg/.\<CR>\" | execute \"norm kdgg\" | execute \"norm G?.\<CR>jdG\"" -c ":wq"
