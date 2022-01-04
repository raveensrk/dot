#!/bin/bash

# This script runs as a cron job and shuts down the computer at 09:00 pm

date "+%H:%M:%S"
time=$(date "+%H")

force_sd=0

if [ $force_sd = 1 ]; then
    if [[ ($time -ge 21) || ($time -le 8)  ]]; then
        # shutdown -h 21:00
        notify-send -t 100000 "Shut down your computer 💻 ..." "It's time to sleep 😴"
        notify-send -t 100000 "Shutting down in 50 seconds..." "Save your work..."

	    # Sleep and shutdown works only when i use full path i dont know
	    # why

        play ~/repos/my-scripts-main/src/sounds/siren.wav 
        /usr/bin/sleep 50
        /usr/sbin/shutdown now
        # TODO: Not shutting down automatically
    fi
else
    if [[ ($time -ge 23) || ($time -le 8)  ]]; then
        # shutdown -h 21:00
        notify-send -t 100000 "Shut down your computer 💻 ..." "It's time to sleep 😴"

	    # Sleep and shutdown works only when i use full path i dont know
	    # why

        #play ~/repos/my-scripts-main/src/sounds/siren.wav 
        
    fi
fi






