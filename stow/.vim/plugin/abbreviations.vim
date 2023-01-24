" Contains all my abbreviations
" --------------------------------
iab adn > /dev/null
iab adnn 1> /dev/null 2>&1
iab apushd pushd > /dev/null 
iab apopd popd > /dev/null 
" Read this from right to left
" Std error 2 is redirected to std out 1, std out 1 is redirected to /dev/null
iab abang #!/usr/bin/env bash
iab aif if [ "$choice" = "Y" ]; then<CR>elif [ ]; then<CR>else<CR>fi
iab aask echo -e "${BLUE}Do you want to ? [Y/n]:${NC}"<CR>read -r choice<CR>unset choice<CR>
iab awhile while [ "$1" ]; do<CR>case "$1" in<CR>--help\|-h)<CR>help<CR>exit 0<CR>;;<CR>*)<CR>echo -e "${RED}Wrong option!${NC}"<CR>exit 2<CR>;;<CR>esac<CR>shift<CR>done
iab amo, # {{{
iab amc, # }}}
