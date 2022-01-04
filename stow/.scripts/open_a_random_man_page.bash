#!/bin/bash

# Copied from distro tube. This will open a random manpage

function main() { # Not used just for reference
    # An array of options to choose.
    local _options=( "Search manpages" "Random manpage" "Quit")
    # Piping the above array into dmenu.
    # We use "printf '%s\n'" to format the array one item to a line.
    choice=$(printf '%s\n' "${_options[@]}" | ${DMENU} 'Manpages:' "$@")

    # What to do when/if we choose one of the options.
    case "$choice" in
        'Search manpages')
            # shellcheck disable=SC2086
            man -k . | awk '{$3="-"; print $0}' | \
                ${DMENU} 'Search for:' | \
                awk '{print $2, $1}' | tr -d '()' | xargs $DMTERM man
            ;;
        'Random manpage')
            # shellcheck disable=SC2086
            man -k . | cut -d' ' -f1 | shuf -n 1 | \
                ${DMENU} 'Random manpage:' | xargs $DMTERM man
            ;;
        'Quit')
            echo "Program terminated." && exit 0
            ;;
        *)
            exit 0
            ;;
    esac

}


# man -k . | awk '{print $1}' | shuf | head -1 | xargs man
# find /usr/share/man/man1 -type f |
# ls /usr/share/man/man7


read -p "Man page category: " opt
man -k . | awk '{$3="-"; print $0}' | awk '{print $2, $1}' | tr -d '()' | grep ^$opt | awk '{print $2}' | shuf | head -1 | xargs man
