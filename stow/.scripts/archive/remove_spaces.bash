#!/bin/bash

# This script will change spaces,(,) to _ in a file

orig_name="$1"
echo $orig_name
new_name=$(echo "$orig_name" | sed "s/ /_/g" | sed "s/(/_/g" | sed "s/)/_/g")
echo $new_name

mv "$orig_name" $new_name
