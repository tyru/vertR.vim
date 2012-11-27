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
    " A line number which is appended
    " when a next line does not exist
    let appended_lnum = 0
    " Save detailed state than 'deleted_buf'. (UNUSED)
    " 1. A position exists or not
    " 2. A replaced character
    let delstack = []
    " TODO: Deprecate and use delstack.
    let deleted_buf = ''
    " 'r' command to be used.
    let r_cmd = (a:virtual ? 'g' : '').'r'
    " Debug or not
    let debug = 0

    try
        while 1
            echohl ModeMsg
            echon '--- vertical '.(a:virtual ? 'V' : '').'REPLACE ---'.(debug ? (' firstinput = '.firstinput.', appended_lnum = '.appended_lnum.', deleted_buf = '.string(deleted_buf)) : '')
            let c = s:getchar()

            if c ==# "\<Esc>"
                break
            elseif c ==# "\<BS>" || c ==# "\<C-h>"
                if line('.') isnot 1
                    " Go backward.
                    normal! k
                    " Restore a replaced character.
                    if deleted_buf !=# ''
                        let [deleted_buf, lastchar] = matchlist(deleted_buf, '\(\%([^a]\|a\)*\)\(.\)')[1:2]
                        if !firstinput | undojoin | endif
                        execute 'normal!' r_cmd.lastchar
                        if appended_lnum isnot 0
                        \&& appended_lnum <=# line('.')+1
                            execute line('.')+1 'delete _'
                        endif
                        " Redraw a replace character, highlight.
                        call s:redraw()
                    endif
                endif
            else
                " Push a character to deleted_buf.
                let reg_x     = getreg('x', 1)
                let regtype_x = getregtype('x')
                normal! "xyl
                let deleted_buf .= @x
                call setreg('x', reg_x, regtype_x)
                " Replace a current character.
                if !firstinput | undojoin | endif
                execute 'normal!' r_cmd.c
                " Go forward.
                if line('.') is line('$')
                    call append(line('.'), '')
                    if !appended_lnum
                        let appended_lnum = line('.') + 1
                    endif
                endif
                normal! j
                " Redraw a replace character, highlight.
                call s:redraw()
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

