function! Display2Info()
    normal mm
    s/$display/`uvm_info(get_name(), $psprintf/
    " TODO: Fix duplicate UVM_NONE created if there is error
    s/);/, UVM_NONE);/
    normal `m
endfunction

function! Info2Display()
    normal mm
    s/`uvm_info(get_name(), $psprintf/$display/
    s/, UVM_NONE);/);/
    normal `m
endfunction

function! SwapDisplayAndInfo()
    try
        call Display2Info()
    catch /E486:/
        call Info2Display()
    endtry
endfunction


nnoremap <leader>vd2i :call Display2Info()<cr>
nnoremap <leader>vi2d :call Info2Display()<cr>
nnoremap <leader>vx   :call SwapDisplayAndInfo()<cr>


" TODO:

function! SwapSelectX()
    " Select first swap seection
    normal mx
    " Put in register
    normal "Xy
    return normal "Xp
endfunction

function! SwapSelectY()
    " Select second swap selection
    normal my
    " Put in register
    normal "Xy
endfunction

function! SwapSelectXY()
    " swap 2
    " Replace X with Y
    normal `x
    normal diw
    normal "Yp
    " Replace Y with X
    normal `y
    normal diw
    normal "Xp
endfunction


vnoremap <leader>sx   :call SwapSelectX()<cr>
vnoremap <leader>sy   :call SwapSelectY()<cr>
vnoremap <leader>sz   :call SwapSelectXY()<cr>
