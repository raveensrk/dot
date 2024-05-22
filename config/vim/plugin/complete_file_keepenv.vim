" File:        complete_file_keepenv.vim
" Author:      lujh <ljh575@gmail.com> <jinhu.lu@chipup.com>
" Last Change: Dec 28, 2020
"
" Version:     V0.1 - 11/13/2020
"              1) first beta version
"
"              v0.2 - 11/16/2020
"              1) modify inoremap, be compatible for <C-X><C-F>
"              2) search full env with prefix, e.g.: $H<C-F>
"              3) support env format: ${ENV} $(ENV) $env(ENV) 
"
"              v0.3 - 12/1/2020
"              1) fixed base len error when start at middle line
"
"              v0.4 - 12/2/2020
"              1) exclude base start with '[{}()-]'
"              2) remove compatibility with <C-X><C-F>
"
"              v0.5 - 12/28/2020
"              1) add home symbol '~' supported
"              2) exclude base start with '-/'
"              3) fix a bug on vim8
"
"              v0.6 - Sep27,2021
"              1) fix env pattern bug in tcl file
"
"
" Description: complete filename with env
"
" Install:     Drag this file into vim plugin directory. ( ~/.vim/plugin/ )
"           
"
" Usage:   
"              1) Insert mode: <C-F>
"              2) Insert mode: <C-X><C-U>
"                 
"
"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
"
if exists("loaded_complete_file_keepenv") || &cp || version < 700
    finish
endif

let loaded_complete_file_keepenv = 1
let g:cfk_debug_en = 0

if &completefunc == ""
    set completefunc=CompleteFileKeepEnv   " i_Ctrl-X_Ctrl-U
    set completeopt=menu
endif

inoremap <silent><expr> <C-F>  pumvisible() ? 
            \ '<C-N>' : '<C-R>=CompleteFileKeepEnv1()<CR>'

"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
"
function! CompleteFileKeepEnv(findstart,base)
    if a:findstart
        return s:get_start()
    else
        if g:cfk_debug_en | let b:cfk_base = a:base | endif
        return s:get_complist(a:base)
    endif
endfunction

function! CompleteFileKeepEnv1()
    let start = s:get_start()
    let base = s:get_base(start)
    let list = s:get_complist(base)
    let start += 1
    if len(list) > 0
        call complete(start,list)
    endif
    return ''
endfunction

function! s:get_start()
    let line = getline('.')
    let start = col('.')-1
    while start > 0 && line[start - 1] =~ '\%(\w\|[{}().*?$/~-]\)'
        let start -= 1
        if line[start] == '~'
            break
        endif
    endwhile
    " exclude start with '{}()'
    while line[start] =~ '[{}()]'
        let start += 1
    endwhile
    " exclude start with '-/'
    if strpart(line,start) =~ '^-\/'
        let start += 1
    endif
    " exclude start with '-opt'
    let m = matchend(strpart(line,start),'^\%(--\?\w\+\)\+-*')
    if m >= 0
        let start += m
    endif
    if g:cfk_debug_en | let b:cfk_start = start | endif
    return start
endfunction

function! s:get_base(start)
    let len = col('.')-1 - a:start 
    let base = strpart(getline('.'), a:start,len)
    if g:cfk_debug_en | let b:cfk_base = '"'.base.'"' | endif
    return base
endfunction

function! s:get_sysenv(base)
    let base = matchstr(a:base,'$\zs\w\+$')
    if base == ""
        return []
    endif
    let prefix = strpart(a:base,0, strlen(a:base) - strlen(base))
    let sysenv = system("env | grep '^".base."'")
    let list = split(sysenv, '\%(\r\|\n\)\+')
    let n = 0
    while n < len(list)
        let list[n] = substitute(list[n],'=.*$','','')
        let n += 1
    endwhile
    call map(list,'prefix.v:val')
    if g:cfk_debug_en | let b:cfk_sysenv_list = list | endif
    return list
endfunction

function! s:get_envmap(line)
    let map = {}
    let start = 0
    " special home symbol ~
    if a:line =~ '^\~\w\+'
        let word = matchstr(a:line, '^\~\zs\w\+')
        let map['\~'.word] = ['\~'.word, expand('~'.word)]
    elseif a:line =~ '^\~'
        let map['\~'] = [ '\~' , expand('~') ]
    endif
    " normal env start with $
    if &ft == "tcl"
        let pattern = '$\%(\%(env\)\?(\w\+)\|{\w\+}\|\w\+\>\)'
    else
        let pattern = '$\%(\w\+\>\|{\w\+}\|(\w\+)\)'
    endif
    while 1
        let text = strpart(a:line,start)
        let word = matchstr(text,pattern)
        if  word == ""
            break
        else
            let env = '$'.matchstr(word,'\w\+\ze[)}]\?$')
            let eenv = expand(env)
            if env == eenv
                let map[word] = []
            else
                let map[word] = [ env , eenv]
            endif
            let start += matchend(text,pattern)
        endif
    endwhile
    if g:cfk_debug_en | let b:cfk_envmap = map | endif
    return map
endfunction

function! s:get_globlist(base)
    if a:base =~ '\*$'
        let list = s:get_globlist2(a:base)
    else
        let list = s:get_globlist2(a:base.'*')
    endif
    if a:base !~ '/$' && len(a:base) > 0
        call extend(list,s:get_globlist2(a:base.'/*'))
    endif
    if g:cfk_debug_en | let b:cfk_globlist = list | endif
    return list
endfunction

function! s:get_globlist2(base)
    if version >= 704
        let list = glob(a:base,0,1)
    else
        let list = split(glob(a:base),'\%(\n\|\r\)\+')
    endif
    return list
endfunction

function! s:get_expand_base(base,map,flag)
    let base = a:base
    for env in keys(a:map)
        if len(a:map[env])
            if a:flag  " expand env
                let base = substitute(base,env,a:map[env][1],'g')
            else   " convert back
                let base = substitute(base,a:map[env][1],env,'g')
            endif
        endif
    endfor
    if g:cfk_debug_en | echomsg a:base." -> ".base | endif
    return base
endfunction

function! s:get_complist(base)
    let list = s:get_sysenv(a:base)
    " not envvar or  a:base is whole env name
    if len(list) == 0 || count(list,a:base) > 0
        let list = s:get_complist2(a:base)
    endif
    return list
endfunction

function! s:get_complist2(base)
    let complist = []
    let map = s:get_envmap(a:base)
    if len(map)
        let base = s:get_expand_base(a:base,map,1)
        if base != a:base
            for item in s:get_globlist(base)
                call add(complist, s:get_expand_base(item,map,0))
            endfor
        endif
    else
        let complist = s:get_globlist(a:base)
    endif
    if g:cfk_debug_en | let b:cfk_complist = complist | endif
    return complist
endfunction

"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
" vim:ts=4:sw=4:ft=vim

