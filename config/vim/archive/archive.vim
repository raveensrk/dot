" let g:ale_virtualtext_cursor=1
" autocmd BufEnter *.md ALEDisableBuffer
" autocmd BufEnter,WinEnter * highlight ALEInfoLine ctermfg=3 ctermbg=black
" autocmd BufEnter,WinEnter * highlight ALEInfo ctermfg=white ctermbg=black
" autocmd BufEnter,WinEnter * highlight ALEWarning ctermbg=black ctermfg=1
" autocmd BufEnter,WinEnter * highlight ALEWarningLine ctermbg=black ctermfg=white
" autocmd BufEnter,WinEnter * highlight ALEError ctermbg=black ctermfg=red
" autocmd BufEnter,WinEnter * highlight ALEErrorLine ctermbg=black ctermfg=white
" execute 'ALEDisableBuffer'
" let g:ale_verilog_verilator_options="-sv 
" 			\ --timing 
" 			\ --trace 
" 			\ --trace-params
" 			\ --trace-structs 
" 			\ --trace-depth 1 \
" 			\ --timing"
" let g:ale_sh_shellcheck_options = '-x'
" let g:ale_sh_shellcheck_exclusions = 'SC2034'
" let g:ale_sh_shfmt_options =''
" let b:ale_linters = ['pylint']
" let b:ale_python_pylint_options= '--max-line-length 300'
" let g:ale_python_flake8_options = '--ignore=L001'
" ! git clone "https://github.com/dense-analysis/ale" 
