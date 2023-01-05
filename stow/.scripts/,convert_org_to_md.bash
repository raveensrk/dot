#!/bin/bash 

for file in  "*.org"; do
    echo $file
    new_name=$(basename -s .org $file)
    pandoc --to=markdown $file --output=$new_name.md
done
