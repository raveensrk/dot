" Contains all my abbreviations
" --------------------------------

" Bash {{{
ab 21  2>&1
ab ba bash

ab blue ${LIGHT_BLUE}
ab green ${GREEN}
ab red ${RED}
ab yellow ${YELLOW}
ab nc ${NC}

ab cc $((count++))
ab tcc term_$((count++)).log

ab ecb echo -e "${BLUE}${NC}"
ab ecg echo -e "${GREEN}${NC}"
ab ecr echo -e "${RED}${NC}"
ab ecy echo -e "${YELLOW}${NC}"
ab pf printf
ab ec echo
ab if, if [ "$choice" = "Y" ]; then<CR>elif [ ]; then<CR>else<CR>fi
iab ask, echo -e "${BLUE}Do you want to ? [Y/n]:${NC}"<CR>read -r choice<CR>unset choice<CR>
iab while, while [ "$1" ]; do<CR>case "$1" in<CR>--help\|-h)<CR>help<CR>exit 0<CR>;;<CR>*)<CR>echo -e "${RED}Wrong option!${NC}"<CR>exit 2<CR>;;<CR>esac<CR>shift<CR>done
" }}}
" Emojis {{{
ab efail ❌
ab enote ❕
ab epass ✅
" }}}
" Vim {{{
ab mmo # {{{
ab mmc # }}}
" }}}
" Words {{{
ab t the
ab tn then
ab dl download
ab ul upload
" }}}
