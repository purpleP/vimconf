if exists('g:autocomplete_loaded')
    finish
else
    let g:autocomplete_loaded = 1
endif
let g:UltiSnipsMappingsToIgnore = ['autocomplete']

let g:expansion_active = 0
let g:ulti_jump_backwards_res = 0
let g:ulti_jump_forwards_res = 0
let g:ulti_expand_res = 0

augroup Autocomplete
    au!
    au! User UltiSnipsEnterFirstSnippet
    au User UltiSnipsEnterFirstSnippet let g:expansion_active = 1 | setlocal fo-=a
    au! User UltiSnipsExitLastSnippet
    au User UltiSnipsExitLastSnippet let g:expansion_active = 0 | setlocal fo+=a
augroup END

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
            return a:forward ? "\<C-N>" : "\<C-P>"
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
