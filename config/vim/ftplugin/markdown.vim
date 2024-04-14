let g:vim_markdown_folding_disabled = 1
set conceallevel=2
let g:vim_markdown_borderless_table = 1
set formatprg=mdformat\ -

silent command! -range=% Format <line1>,<line2>!mdformat --wrap 78 -
silent autocmd BufWritePre *.md Format
