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
            exe 'belowright copen ' . string(l:num_errors)
            call win_gotoid(l:winid)
        else
            cclose
        endif
        call winrestview(l:view)
    endif
endfu


augroup LanguageClientDiagnosticPopUp
    au!
    au User LanguageClientDiagnosticsChanged call s:ShowDiagnostics()
augroup END
