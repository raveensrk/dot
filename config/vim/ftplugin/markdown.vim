let g:vim_markdown_folding_disabled = 1
set conceallevel=2
let g:vim_markdown_borderless_table = 1
set formatprg=prettier\ --parser\ markdown

silent command! -range=% Format <line1>,<line2>!prettier --parser markdown --prose-wrap always
silent autocmd BufWritePre *.md Format

setlocal wrap

nmap ,t :call mkdx#ToggleCheckboxState()<CR>


