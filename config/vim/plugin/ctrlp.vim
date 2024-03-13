            let g:yankring_replace_n_pkey = '<m-p>'
            let g:yankring_replace_n_nkey = '<m-n>'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
  let g:ctrlp_by_filename = 1
  let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'
  let g:ctrlp_switch_buffer = 'Et'
  let g:ctrlp_reuse_window = 'netrw\|help\|quickfix'
  let g:ctrlp_tabpage_position = 'ac'
  let g:ctrlp_working_path_mode = 'ra'
  let g:ctrlp_root_markers = ['.root']
  let g:ctrlp_use_caching = 1
  let g:ctrlp_clear_cache_on_exit = 0
  let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
  let g:ctrlp_show_hidden = 0
  let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
  let g:ctrlp_max_files = 10000
  let g:ctrlp_max_depth = 40
  let g:ctrlp_max_history = &history
  let g:ctrlp_user_command = ''
  let g:ctrlp_open_new_file = 'v'
  let g:ctrlp_open_multiple_files = '2vjr'
  let g:ctrlp_arg_map = 1
  let g:ctrlp_follow_symlinks = 0
  let g:ctrlp_lazy_update = 1
  let g:ctrlp_default_input = 0
  let g:ctrlp_match_current_file = 1
  let g:ctrlp_types = ['fil', 'buf', 'mru']
  let g:ctrlp_abbrev = {}
  let g:ctrlp_key_loop = 0
  let g:ctrlp_prompt_mappings = {
    \ 'PrtBS()':              ['<bs>', '<c-]>'],
    \ 'PrtDelete()':          ['<del>'],
    \ 'PrtDeleteWord()':      ['<c-w>'],
    \ 'PrtClear()':           ['<c-u>'],
    \ 'PrtSelectMove("j")':   ['<c-j>', '<down>'],
    \ 'PrtSelectMove("k")':   ['<c-k>', '<up>'],
    \ 'PrtSelectMove("t")':   ['<Home>', '<kHome>'],
    \ 'PrtSelectMove("b")':   ['<End>', '<kEnd>'],
    \ 'PrtSelectMove("u")':   ['<PageUp>', '<kPageUp>'],
    \ 'PrtSelectMove("d")':   ['<PageDown>', '<kPageDown>'],
    \ 'PrtHistory(-1)':       ['<c-n>'],
    \ 'PrtHistory(1)':        ['<c-p>'],
    \ 'AcceptSelection("e")': ['<cr>', '<2-LeftMouse>'],
    \ 'AcceptSelection("h")': ['<c-x>', '<c-cr>', '<c-s>'],
    \ 'AcceptSelection("t")': ['<c-t>'],
    \ 'AcceptSelection("v")': ['<c-v>', '<RightMouse>'],
    \ 'ToggleFocus()':        ['<s-tab>'],
    \ 'ToggleRegex()':        ['<c-r>'],
    \ 'ToggleByFname()':      ['<c-d>'],
    \ 'ToggleType(1)':        ['<c-f>', '<c-up>'],
    \ 'ToggleType(-1)':       ['<c-b>', '<c-down>'],
    \ 'PrtExpandDir()':       ['<tab>'],
    \ 'PrtInsert("c")':       ['<MiddleMouse>', '<insert>'],
    \ 'PrtInsert()':          ['<c-\>'],
    \ 'PrtCurStart()':        ['<c-a>'],
    \ 'PrtCurEnd()':          ['<c-e>'],
    \ 'PrtCurLeft()':         ['<c-h>', '<left>', '<c-^>'],
    \ 'PrtCurRight()':        ['<c-l>', '<right>'],
    \ 'PrtClearCache()':      ['<F5>'],
    \ 'PrtDeleteEnt()':       ['<F7>'],
    \ 'CreateNewFile()':      ['<c-y>'],
    \ 'MarkToOpen()':         ['<c-z>'],
    \ 'OpenMulti()':          ['<c-o>'],
    \ 'PrtExit()':            ['<esc>', '<c-c>', '<c-g>'],
    \ }
  let g:ctrlp_line_prefix = '> '
  let g:ctrlp_open_single_match = ['buffer tags', 'buffer']
  fu! <SID>tagsUnderCursor()
    try
      let default_input_save = get(g:, 'ctrlp_default_input', '')
      let g:ctrlp_default_input = expand('<cword>')
      CtrlPBufTagAll
    finally
      if exists('default_input_save')
        let g:ctrlp_default_input = default_input_save
      endif
    endtry
  endfu
  let g:ctrlp_mruf_max = 250
  let g:ctrlp_mruf_exclude = '/tmp/.*\|/temp/.*' " MacOSX/Linux
  let g:ctrlp_mruf_include = ''
  let g:ctrlp_tilde_homedir = 0
  let g:ctrlp_mruf_relative = 0
  let g:ctrlp_mruf_default_order = 0
  let g:ctrlp_mruf_case_sensitive = 1
  let g:ctrlp_mruf_save_on_update = 1
  let g:ctrlp_bufname_mod = ':t'
  let g:ctrlp_bufpath_mod = ':~:.:h'
  let g:ctrlp_open_func = {}
  let g:ctrlp_use_readdir = 1
  let g:ctrlp_path_nolim = 0
  let g:ctrlp_compare_lim = 100
  let g:ctrlp_extensions = ['tag', 'buffertag', 'quickfix', 'dir', 'rtscript',
                          \ 'undo', 'line', 'changes', 'mixed', 'bookmarkdir']
    augroup CtrlPDirMRU
      autocmd!
      autocmd FileType * if &modifiable | execute 'silent CtrlPBookmarkDirAdd! %:p:h' | endif
    augroup END
  let g:ctrlp_buftag_ctags_bin = ''
  let g:ctrlp_user_command_async = 1
