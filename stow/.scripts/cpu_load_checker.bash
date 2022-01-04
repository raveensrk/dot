#!/bin/bash

# This will print the current cpu usage

top -d 0.125 -b -i -n 20  | grep Cpu | awk -F ":" '{print $2}' | awk -F " " '{print $1}' | awk -F "." '{print $1}' | sort -n | tail -1
