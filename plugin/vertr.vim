" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if (exists('g:loaded_vertr') && g:loaded_vertr) || &cp
    finish
endif
let g:loaded_vertr = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" vertr#R({virtual_replace}, {exclusive}, [{virtualedit}])
nnoremap <Plug>vertR->R    :<C-u>call vertr#R(0, 0)<CR>
nnoremap <Plug>vertR->gR   :<C-u>call vertr#R(1, 0)<CR>

if !exists('g:vertr_no_default_keymappings')
\   || !g:vertr_no_default_keymappings
    if !hasmapto('<Plug>vertR->R')
        nmap <unique> <Leader>R   <Plug>vertR->R
    endif
    if !hasmapto('<Plug>vertR->gR')
        nmap <unique> <Leader>gR  <Plug>vertR->gR
    endif
endif


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
