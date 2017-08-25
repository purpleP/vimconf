let g:expansion_active = 0
let g:ulti_jump_backwards_res = 0
let g:ulti_jump_forwards_res = 0
let g:ulti_expand_res = 0

fu! autocomplete#setup_mappings()
    inoremap <silent> <buffer> <TAB> <C-R>=autocomplete#expand_or_jump(1)<CR>
    inoremap <silent> <buffer> <S-TAB> <C-R>=autocomplete#expand_or_jump(0)<CR>
    snoremap <silent> <buffer> <TAB> <Esc>:call autocomplete#expand_or_jump(1)<CR>
    snoremap <silent> <buffer> <S-TAB> <Esc>:call autocomplete#expand_or_jump(0)<CR>
endfu

fu! autocomplete#expand_or_jump(forward)
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            if a:forward
                return "\<C-N>"
            else
                return "\<C-P>"
            endif
        else
            if g:expansion_active
                if a:forward
                    call UltiSnips#JumpForwards()
                    if g:ulti_jump_forwards_res == 0
                        return "\<Tab>"
                    endif
                else
                    call UltiSnips#JumpBackwards()
                endif
            else
                if a:forward
                    return "\<Tab>"
                endif
            endif
        endif
    endif
    return ''
endfu
