#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "Enter the script name:"
read -e name
echo "name = $name"

echo "Set location:"
location=$(find $HOME/my_repos -type d -iname ".scripts" | fzf)
echo "Location = $location"

echo "Ok? Press any key twice to continue..."
read
read

touch "$location/$name"
chmod +x "$location/$name"
$EDITOR "$location/$name"
