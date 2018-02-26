let s:showed_diagnostics = 0

fu! s:ShowDiagnostics()
    silent! augroup! ShowDiagnostics
    if mode() == 'i'
        augroup ShowDiagnostics
            au! InsertLeave call s:ShowDiagnostics()
        augroup END
    else
        let l:winid = win_getid()
        let l:view = winsaveview()
        let l:num_errors = len(getqflist())
        if l:num_errors > 0
            exe 'belowright copen ' . string(min([l:num_errors, &lines / 2]))
            call win_gotoid(l:winid)
        else
            cclose
        endif
        call winrestview(l:view)
        let s:showed_diagnostics = 1
    endif
endfu


fu! s:HideDiagnostics()
    if &buftype != 'quickfix' && s:showed_diagnostics
        cclose
        let s:showed_diagnostics = 0
    endif
endfu


augroup LanguageClientDiagnosticPopUp
    au!
    au User LanguageClientDiagnosticsChanged call s:ShowDiagnostics()
    au CursorMoved,CursorMovedI,InsertEnter * call s:HideDiagnostics()
augroup END
