#!/bin/bash

main () {
    local path
    path="$1"
    if [ "$path" = "" ]; then
        path="."
    fi

    # local file=$(fd --hidden --exclude '.git' --exclude '.hg' . "$path" | fzf)
    local file
    file=$(find "$path" -not -path '*/.git/*' -not -path '*/.hg/*' | fzf)
    if [ "$file" = "" ]; then
        echo -e "${RED}❌ERROR! Empty string${NC}"
    else
        echo -e "${BLUE}The following command is executed...${NC}"
        echo -e "${YELLOW}'vim' \"$file\" ${NC}"
        vim "$file"
    fi
}

main "$1"
