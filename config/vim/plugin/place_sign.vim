function! PlaceSign (string, sign_name, sign_highlight, linehl, test) abort
    let line=line(".")
    let col=col(".")
    let nmatch = execute("%s/" .. a:string .."//gnle")
    let nmatch = split(nmatch)
    " echomsg nmatch
    if len(nmatch)==0
        return
    endif
    let match_count = nmatch[3]
    let rows=[]
    while match_count!=0
        let current_line = searchpos(a:string, "c")
        let rows += [current_line[0]]
        let next_line = current_line[0] + 1
        call cursor(next_line, 0)
        let match_count = match_count - 1
        " echom match_count
    endwhile
    " echom rows
    call cursor(line, col)
    let nplace=0
    for row in rows
        let nplace=nplace+1
        let define = "sign define "
                    \..a:sign_name
                    \.." "
                    \.."text=>> texthl="
                    \..a:sign_highlight
                    \.." "
                    \.."numhl=ToolbarButton"
                    \.." "
                    \.."linehl="
                    \..a:linehl
        let place = "sign place " ..
                    \ nplace ..
                    \ " line=" ..
                    \ row ..
                    \ " name=" ..
                    \ a:sign_name ..
                    \ " file=" .. expand("%:p")

        if a:test
            echomsg nplace row 
            echomsg define
            echomsg place
        else
            try
                execute define
                execute place
            catch
                return
            endtry
        endif
    endfor
endfunction

if 1
    call PlaceSign("what", "sign_what", "ToolbarButton", "WildMenu", "0")
    " call PlaceSign("WHAT", "WHAT", "ToolbarButton", "WildMenu", "1")
    call PlaceSign("present", "WHAT", "ToolbarButton", "WildMenu", "0")
    let test_string =<< trim eval END
        WHAT
        WHAT 2
        IS
        THIS
    END
endif

