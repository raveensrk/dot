" Filetype for ,elim journals (*.elim); syntax in syntax/elim.vim.
" Here, not in ftdetect/: vimrc_example.vim turns filetype detection on before
" config/vimrc adds this runtimepath, so ftdetect/ here is never read. This
" runs after the built-in detection, which guesses `conf` from the leading `#`
" lines, so it sets the filetype outright.
augroup elim_filetype
  autocmd!
  autocmd BufRead,BufNewFile *.elim set filetype=elim
augroup END
