" Contains all my abbreviations
" --------------------------------

" Bash {{{
iab 21  2>&1
iab #!, #!/bin/bash
iab blue ${LIGHT_BLUE}
iab green ${GREEN}
iab red ${RED}
iab yellow ${YELLOW}
iab nc ${NC}
iab cc $((count++))
iab tcc term_$((count++)).log
iab ecb echo -e "${BLUE}${NC}"
iab ecg echo -e "${GREEN}${NC}"
iab ecr echo -e "${RED}${NC}"
iab ecy echo -e "${YELLOW}${NC}"
iab pf printf
iab ec echo
iab if, if [ "$choice" = "Y" ]; then<CR>elif [ ]; then<CR>else<CR>fi
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
