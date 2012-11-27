

function! s:open_test_buffer()
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
endfunction

function! s:open_test_buffer2()
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
endfunction

" call s:open_test_buffer()
call s:open_test_buffer2()
