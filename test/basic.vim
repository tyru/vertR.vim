
" Test: :source %


function! s:open_test_buffer_R_case1()
    new
    a
vimvimvim
vimvimvim
vimvimvim
emacsemacsemacs
emacsemacsemacs
emacsemacsemacs
.

    :1
    redraw

    call vertr#R()
endfunction

function! s:open_test_buffer_R_case2()
    new
    a
aimvimvim
aimvimvim
bimvimvim
smacsemacsemacs
dmacsemacsemacs
smacsemacsemacs
.

    :1
    redraw

    call vertr#R()
endfunction

function! s:open_test_buffer_gR_case1()
    new
    a
vimvimvim
vimvimvim
vimvimvim
emacsemacsemacs
emacsemacsemacs
emacsemacsemacs
.

    :1
    redraw

    call vertr#gR()
endfunction

function! s:open_test_buffer_gR_case2()
    new
    a
aimvimvim
aimvimvim
bimvimvim
smacsemacsemacs
dmacsemacsemacs
smacsemacsemacs
.

    :1
    redraw

    call vertr#gR()
endfunction

call s:open_test_buffer_R_case1()
call s:open_test_buffer_gR_case1()
call s:open_test_buffer_R_case2()
call s:open_test_buffer_gR_case2()
