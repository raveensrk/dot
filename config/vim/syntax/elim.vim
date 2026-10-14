" Syntax for ,elim journals (*.elim). Format: ~/repos/elim/PLAN.md, "Data file".
" An entry is a [YYYY-MM-DD] or [YYYY-MM-DD HH:MM] header, `key: value` fields
" up to the first blank line, then free text. `#` lines are comments only
" before the first entry; inside text they are text.
if exists('b:current_syntax')
  finish
endif

" Journals are small; parse from the top so the field chains are always right.
syntax sync fromstart

" Comments: the run of `#` and blank lines at the top of the file.
syntax region elimPreamble start=/\%^/ end=/^\ze\[\d\{4}-\d\d-\d\d\%( \d\d:\d\d\)\?\]$/ contains=elimComment
syntax match elimComment /^#.*$/ contained contains=@Spell

" An entry's header, then its field lines as a chain: each line hands on to
" the next with skipnl, and a blank line (not skipped) ends the chain, so the
" text after it is left unhighlighted.
syntax match elimHeader /^\[\d\{4}-\d\d-\d\d\%( \d\d:\d\d\)\?\]$/ contains=elimDate,elimTime,elimBracket nextgroup=elimBadField,elimField skipnl
syntax match elimBracket /[][]/ contained
syntax match elimDate /\d\{4}-\d\d-\d\d/ contained
syntax match elimTime /\d\d:\d\d/ contained

" A line among the fields that is not a known field is an error in ,elim
" too. Defined before elimField so a known field, defined after, wins.
syntax match elimBadField /^.\+$/ contained nextgroup=elimBadField,elimField skipnl
syntax match elimField /^\%(kind\|item\|goal\|target\|streak\|due\|status\):.*$/ contained contains=elimKey,elimValue nextgroup=elimBadField,elimField skipnl
syntax match elimKey /^\w\+\ze:/ contained
syntax match elimValue /:\s*\zs.*$/ contained contains=elimKind,elimYesNo,elimNumber,elimDueDate
" eliminate, relapse, allow and the statuses get their own colors below;
" keywords would outrank those matches, so only the plain kinds are here.
syntax keyword elimKind contained goal journal
syntax keyword elimYesNo contained yes no
syntax match elimNumber /\<\d\+\>$/ contained
syntax match elimDueDate /\d\{4}-\d\d-\d\d$/ contained

" Kinds and statuses get their own colors, as in the ,elim dashboard.
syntax match elimKindEliminate /\%(^kind:\s*\)\@<=eliminate$/ contained containedin=elimValue
syntax match elimKindRelapse /\%(^kind:\s*\)\@<=relapse$/ contained containedin=elimValue
syntax match elimKindAllow /\%(^kind:\s*\)\@<=allow$/ contained containedin=elimValue
syntax match elimStatusComplete /\%(^status:\s*\)\@<=complete$/ contained containedin=elimValue
syntax match elimStatusIncomplete /\%(^status:\s*\)\@<=incomplete$/ contained containedin=elimValue

highlight default link elimComment Comment
highlight default link elimBracket Delimiter
highlight default link elimDate Title
highlight default link elimTime Number
highlight default link elimKey Identifier
highlight default link elimValue Statement
highlight default link elimKind Type
highlight default link elimKindEliminate String
highlight default link elimKindRelapse WarningMsg
highlight default link elimKindAllow Todo
highlight default link elimStatusComplete String
highlight default link elimStatusIncomplete WarningMsg
highlight default link elimYesNo Boolean
highlight default link elimNumber Number
highlight default link elimDueDate Constant
highlight default link elimBadField Error

let b:current_syntax = 'elim'
