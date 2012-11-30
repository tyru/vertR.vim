
" Test: :source %
" TODO: automate using feedkeys()


" Test cases
function! s:vertr_R_case1()
    new
    call s:setup_text1()
    :1
    redraw

    let options = {
    \   'virtual_replace': 0,
    \   'exclusive': 0,
    \}
    call vertr#R(options)
    quit!
endfunction

function! s:vertr_R_case2()
    new
    call s:setup_text2()
    :1
    redraw

    let options = {
    \   'virtual_replace': 0,
    \   'exclusive': 0,
    \}
    call vertr#R(options)
    quit!
endfunction

function! s:vertr_R_case3()
    new
    call s:setup_text1()
    :1
    redraw

    let options = {
    \   'virtual_replace': 1,
    \   'exclusive': 0,
    \}
    call vertr#R(options)
    quit!
endfunction

function! s:vertr_R_case4()
    new
    call s:setup_text2()
    :1
    redraw

    let options = {
    \   'virtual_replace': 1,
    \   'exclusive': 0,
    \}
    call vertr#R(options)
    quit!
endfunction



" Fixtures
function! s:setup_text1()
    a
vimvimvim
vimvimvim
vimvimvim
emacsemacsemacs
emacsemacsemacs
emacsemacsemacs
.
endfunction

function! s:setup_text2()
    a
aimvimvim
aimvimvim
bimvimvim
smacsemacsemacs
dmacsemacsemacs
smacsemacsemacs
.
endfunction



" Run tests.
call s:vertr_R_case1()
call s:vertr_R_case2()
call s:vertr_R_case3()
call s:vertr_R_case4()
