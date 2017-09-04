if exists('g:loaded_autohighlight')
    finish
endif
let g:loaded_autohighlight = 1

let s:disable = 0

augroup AutoHighlight
    au!
    au OptionSet hlsearch call <SID>AutoHighlight(v:option_old, v:option_new)
augroup END

fu! s:HlSearch()
    if s:disable
        let s:disable = 0
        return
    endif
    silent! if !search('\%#\zs'.@/,'cnW')
        call <SID>StopHL()
    endif
endfu

fu! s:StopHL()
    if v:hlsearch && mode() is 'n'
        sil call feedkeys("\<Plug>(StopHL)", 'm')
    endif
endfu

fu! s:TurnOffOrKeepHL()
    if matchstr(@", @/) == @"
        let s:disable = 1
    elseif search('\%#\zs'.@/,'cnW')
        call <SID>StopHL()
    endif
endfu

fu! s:AutoHighlight(old, new)
    if a:old == 0 && a:new == 1
        noremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
        noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
        au AutoHighlight CursorMoved * call <SID>HlSearch()
        au AutoHighlight TextYankPost * call <SID>TurnOffOrKeepHL()
    elseif a:old == 1 && a:new == 0
        nunmap <Plug>(StopHL)
        unmap! <expr> <Plug>(StopHL)
        au! AutoHighlight CursorMoved
        au! AutoHighlight TextYankPost
    else
        return
    endif
endfu

if v:hlsearch
    call <SID>AutoHighlight(0, 1)
endif
