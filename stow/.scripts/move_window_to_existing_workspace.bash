#!/bin/bash

workspace=$(i3-msg -t get_workspaces | tr "," "\n" | grep name | cut -d ":" -f 2 | sed "s/\"//g" | dmenu)
i3-msg "move window to workspace \"$workspace\"; mode \"default\""
