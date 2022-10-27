#!/bin/bash

fzf --preview-window follow --preview 'for i in $(seq 100000); do
                             echo "$i"
                             sleep 0.01
                             (( i % 300 == 0 )) && printf "\033[2J"
                           done'
