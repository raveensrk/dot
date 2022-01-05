#!/bin/bash

# Cronjob script to be run every minute

minute=$(date "+%M")
if [[ ( $minute = 20 ) || ( $minute = 50 ) ]]; then
    notify-send -t 100000 "It’s $minute minute take a break..." "🍵"
elif [[ ( $minute = 00 ) || ( $minute = 30 ) ]]; then
    notify-send -t 100000 "It’s $minute minute continue work..." "🎯"
fi

