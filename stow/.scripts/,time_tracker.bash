#!/usr/bin/env bash

# This script will tell me how much time I have spent on my computer.
# It will also tell me how much time I have left to work today.

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

stop_session () {
    echo -e "${RED}Stopping work...${NC}"
    echo -e "${RED}Stopped work at $(date +%H:%M:%S)${NC}"
    stop_time=$(date +%s)
    echo "stop, $(date)" >> ~/.my_logs/sessions.txt
}


# Ask user if he wants to start work, stop work, or check time.
echo -e "What would you like to do?\n"
echo -e "1. Start work"
echo -e "2. Stop work"
echo -e "3. Check time"
echo -e "4. Exit"
read -p "Enter your choice: " choice

# If ~/.my_logs does not exist, create it.
if [ ! -d ~/.my_logs ]; then
    mkdir ~/.my_logs
fi

if [ ! -f ~/.my_logs/sessions.txt ]; then
    touch ~/.my_logs/sessions.txt
fi

last_session_status="$(cat ~/.my_logs/sessions.txt | tail -1 | cut -d ',' -f 2)"

echo "Last session status: $last_session_status"

if [ "$last_session_status" = "start" ]; then
    echo -e "${RED}Session still running...${NC}"
    read -p "Do you want to stop session? (y/n): " stop_session
    if [ "$stop_session" = "y" ]; then
        stop_session
    fi
fi


if [[ "${choice}" == "1" ]]; then
    echo -e "${GREEN}Starting work...${NC}"
    echo -e "${GREEN}Started work at $(date +%H:%M:%S)${NC}"
    start_time=$(date +%s)
    echo "$session_id, start, $(date)" >> ~/.my_logs/sessions.txt
elif [[ "${choice}" == "2" ]]; then
    stop_session
elif [[ "${choice}" == "3" ]]; then
    echo -e "${GREEN}Checking time...${NC}"
    start_time=$(cat "$HOME/.my_logs/sessions.txt" | grep start | tail -1 | cut -d, -f3)
    stop_time=$(cat "$HOME/.my_logs/sessions.txt" | grep stop | tail -1 | cut -d, -f3)

    # Check if start and stop session id is the same
    start_session_id=$(cat "$HOME/.my_logs/sessions.txt" | grep start | tail -1 | cut -d, -f1)
    stop_session_id=$(cat "$HOME/.my_logs/sessions.txt" | grep stop | tail -1 | cut -d, -f1)

    echo "start time = $start_time"
    if [[ "$last_session_status" == "start" ]]; then
        echo -e "${RED}Session still running...${NC}"    
        total_time=$(date -d @$(( $(date -d "$(date +%s)" +%s) - $(date -d "$start_time" +%s) )) -u +'%H:%M:%S')
        echo -e "${GREEN}Total time this session = ${total_time} ${NC}"
    else
        echo "stop time = $stop_time"
        total_time=$(date -d @$(( $(date -d "$stop_time" +%s) - $(date -d "$start_time" +%s) )) -u +'%H:%M:%S')
        echo -e "${GREEN}Total time last session = ${total_time} ${NC}"
    fi    
fi