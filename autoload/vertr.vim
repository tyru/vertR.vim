" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



function! vertr#R()
    return s:vertR(0)
endfunction

function! vertr#gR()
    return s:vertR(1)
endfunction

function! s:vertR(virtual)
    " Highlight a current cursor position.
    highlight link VertRCurrentCursor Cursor

    " Join undo-history when all histories after a first action
    let firstinput = 1
    " Save a deleted position.
    " 1. A position exists or not
    " 2. A replaced character
    let delstack = []
    " 'r' command to be used.
    let r_cmd = (a:virtual ? 'g' : '').'r'
    " Debug or not
    let debug = 0

    try
        while 1
            echohl ModeMsg
            echon '--- vertical '.(a:virtual ? 'V' : '').'REPLACE ---'.(debug ? (' firstinput = '.firstinput.', delstack = '.string(delstack)) : '')
            let c = s:getchar()

            if c ==# "\<Esc>"
                break
            elseif c ==# "\<BS>" || c ==# "\<C-h>"
                if line('.') isnot 1
                    " Go backward.
                    normal! k
                    " Restore a replaced character.
                    if !empty(delstack)
                        let last = remove(delstack, -1)
                        if !firstinput | undojoin | endif
                        execute 'normal!' r_cmd.last['char']
                        if last.appended
                            execute line('.')+1 'delete _'
                        endif
                        " Redraw a replace character, highlight.
                        call s:redraw()
                    endif
                endif
            else
                let deleted_position = {'char': '', 'appended': 0}
                " Push a character to 'delstack'.
                let reg_x     = getreg('x', 1)
                let regtype_x = getregtype('x')
                normal! "xyl
                let deleted_position.char = @x
                call setreg('x', reg_x, regtype_x)
                " Replace a current character.
                if !firstinput | undojoin | endif
                execute 'normal!' r_cmd.c
                " Go forward.
                if line('.') is line('$')
                    call append(line('.'), '')
                    let deleted_position.appended = 1
                endif
                normal! j
                " Redraw a replace character, highlight.
                call s:redraw()

                call add(delstack, deleted_position)
            endif
            let firstinput = 0
        endwhile
    finally
        echohl None
        call s:clear_matches()
    endtry
endfunction

function! s:getchar(...)
    let c = call('getchar', a:000)
    return type(c) is type("") ? c : nr2char(c)
endfunction

function! s:redraw()
    " Delete all vertR matches.
    call s:clear_matches()
    call matchadd('VertRCurrentCursor', '\%'.col('.').'c'.'\%'.line('.').'l')

    " Redraw a replaced character, current cursor highlight.
    redraw
endfunction

function! s:clear_matches()
    for _ in getmatches()
        if _.group ==# 'VertRCurrentCursor'
            call matchdelete(_.id)
        endif
    endfor
endfunction



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

