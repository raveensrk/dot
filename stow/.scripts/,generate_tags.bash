#!/bin/bash

help () {
    echo "
    -i input directory path for tag generation
    --help|-h for help
    "
}

while [ "$1" ]; do
    case "$1" in
        -i)
            shift
            dir=$(realpath "$1")
            ;;
        --help|-h)
            help
            exit 0
            ;;
        *)
            echo -e "${RED}Wrong option!${NC}"
            exit 2
            ;;
    esac
    shift
done 

[ "$dir" = "" ] && echo -e "${RED}-i option is mandatory...${NC}" && exit 2

pushd "$dir" || exit 2
ctags --exclude="stow_vim_plugins" -R ./*
popd || exit 2
