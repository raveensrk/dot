" Contains all my abbreviations
" --------------------------------

iab abang, #!/usr/bin/env bash
iab aif if [ "$choice" = "Y" ]; then<CR>elif [ ]; then<CR>else<CR>fi
iab aask echo -e "${BLUE}Do you want to ? [Y/n]:${NC}"<CR>read -r choice<CR>unset choice<CR>
iab awhile while [ "$1" ]; do<CR>case "$1" in<CR>--help\|-h)<CR>help<CR>exit 0<CR>;;<CR>*)<CR>echo -e "${RED}Wrong option!${NC}"<CR>exit 2<CR>;;<CR>esac<CR>shift<CR>done
iab amo, # {{{
iab amc, # }}}
