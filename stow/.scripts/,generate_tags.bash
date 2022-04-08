#!/bin/bash

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
ctags --verbose -R ./*
popd || exit 2
