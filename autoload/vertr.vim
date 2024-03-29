" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" TODO:
" - Test input including <Tab> character.

function! vertr#R(...)
    " Highlight a current cursor position.
    highlight link VertRCurrentCursor Cursor

    " Options
    let options = a:0 && type(a:1) is type({}) ? a:1 : {}
    let virtual_replace = get(options, 'virtual_replace', 0)
    let exclusive = get(options, 'exclusive', 0)
    let virtualedit = get(options, 'virtualedit', &l:virtualedit)

    " Debug or not
    let debug = 0
    " Join undo-history when all histories after a first action
    let firstinput = 1
    " Save a deleted position.
    " 1. A position exists or not
    " 2. A old character
    let delstack = []
    " 'r' command to be used.
    let r_cmd = (virtual_replace ? 'g' : '').'r'
    " 'j' command to be used.
    let j_cmd = (exclusive       ? 'g' : '').'j'
    " 'k' command to be used.
    let k_cmd = (exclusive       ? 'g' : '').'k'

    if debug
        PP! [virtual_replace, exclusive]
    endif

    if &l:virtualedit !=# virtualedit
    \   && virtualedit =~# '^\%(block\|insert\|all\|onemore\)\%(,\%(block\|insert\|all\|onemore\)\)*$'
        let prev_virtualedit = &l:virtualedit
        let &l:virtualedit = virtualedit
    endif

    try
        call s:redraw()
        while 1
            echohl ModeMsg
            let modemsg = '--- vertical '.(virtual_replace ? 'V' : '').'REPLACE ---'
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
                    " Restore a old character.
                    if !empty(delstack)
                        let last = remove(delstack, -1)
                        if !firstinput | undojoin | endif
                        call setline('.', last['line'])
                        if last.appended
                            execute line('.')+1 'delete _'
                        endif
                    endif
                    " Redraw a replace character, highlight.
                    call s:redraw()
                endif
            else
                let deleted_position = {
                \   'line': '',
                \   'appended': 0,
                \}
                " Save a previous line. (not only an old character)
                " Because whitespaces may be appended
                " before an new character when a previous line is empty.
                let deleted_position.line = getline('.')
                " Replace a current character.
                if !firstinput | undojoin | endif
                let firstinput = 0
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
        endwhile
    finally
        echohl None
        " Erase ModeMsg.
        call s:clear_matches()
        redraw
        echo ''
        " Restore 'virtualedit'.
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

    " Redraw a new character, current cursor highlight.
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

