#!/bin/bash

# This script will find the most used words from a text file

cat $1 | grep -oi "[a-z]\+" | sort | uniq -c | sort -nr

