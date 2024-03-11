function! IsScrollBind()
    if (&scrollbind)
        return "BIND"
    else
        return ""
    endif
endfunction

function! IsWinFixBuf()
    if (&winfixbuf)
        return "FIX"
    else
        return ""
    endif
endfunction

function! WhichDirectory()
    let cwd = getcwd()
    let cwd = getcwd()
    let cwdl = split(cwd, '/')
    let parent = cwdl[-1]
    return "PWD: " . parent
endfunction

let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ }

let g:lightline = {
            \ 'colorscheme': 'default',
            \ 'active': {
            \ 'left': [ [ 'paste' ],
            \             ['whichdirectory'],
            \           [ 'readonly', 'filename', 'modified' ]
            \         ],
            \ 'right': [ ['bufnum'], 
            \             [ 'isscrollbind2' ], 
            \             [ 'iswinfixbuf2' ], 
            \             [ 'lineinfo' ],
            \            [ 'percent' ]
            \          ] 
            \},
            \ 'inactive': {
            \ 'left': [ 
            \             ['whichdirectory'],
            \ [ 'filename' ]
            \         ],
            \ 'right': [ ['bufnum'] ,
            \             [ 'isscrollbind2' ],
            \             [ 'iswinfixbuf2' ],
            \             [ 'lineinfo' ],
            \            [ 'percent' ] ] },
            \ 'component' : {
            \   'iswinfixbuf2': '%{IsWinFixBuf()}',
            \   'isscrollbind2': '%{IsScrollBind()}',
            \   'whichdirectory': '%{WhichDirectory()}'
            \ }
            \}

