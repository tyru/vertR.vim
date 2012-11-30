" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" TODO:
" - Test input including <Tab> character.

function! vertr#R(virtual_replace, exclusive, ...)
    " Highlight a current cursor position.
    highlight link VertRCurrentCursor Cursor

    " Debug or not
    let debug = 0
    " Join undo-history when all histories after a first action
    let firstinput = 1
    " Save a deleted position.
    " 1. A position exists or not
    " 2. A replaced character
    let delstack = []
    " 'r' command to be used.
    let r_cmd = (a:virtual_replace ? 'g' : '').'r'
    " 'j' command to be used.
    let j_cmd = (a:exclusive       ? 'g' : '').'j'
    " 'k' command to be used.
    let k_cmd = (a:exclusive       ? 'g' : '').'k'

    if debug
        PP! [a:virtual_replace, a:exclusive]
    endif

    if a:0 && type(a:1) is type("")
    \   && a:1 =~# '^\%(block\|insert\|all\|onemore\)\%(,\%(block\|insert\|all\|onemore\)\)*$'
        let prev_virtualedit = &l:virtualedit
        let &l:virtualedit = a:1
    endif

    try
        while 1
            echohl ModeMsg
            let modemsg = '--- vertical '.(a:virtual_replace ? 'V' : '').'REPLACE ---'
            if debug
                let modemsg .= ' firstinput = '.firstinput.', delstack = '.string(delstack)
            endif
            echon modemsg
            let c = s:getchar()

            if c ==# "\<Esc>"
                break
            elseif c ==# "\<BS>" || c ==# "\<C-h>"
                if line('.') isnot 1
                    " Go backward.
                    execute 'normal!' k_cmd
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
                execute 'normal!' j_cmd
                " Redraw a replace character, highlight.
                call s:redraw()

                call add(delstack, deleted_position)
            endif
            let firstinput = 0
        endwhile
    finally
        echohl None
        call s:clear_matches()
        if exists('prev_virtualedit')
            let &l:virtualedit = prev_virtualedit
        endif
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

