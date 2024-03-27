command! SnippetRead call fzf#run({'dir': '~/dot/config/vim/snippet', 'source': 'find . -type f', 'sink': 'read'})
inoremap <expr> <c-x>s fzf#vim#complete({'dir': '~/dot/config/vim/snippet', 'source': 'find . -type f', 'reducer': { lines -> join(readfile(lines[0]))}})
