nnoremap gb :call AddBreakPoint()<cr>

setlocal includeexpr=substitute(v:fname,'\\.','/','g')

setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab

setlocal formatexpr=LanguageClient#textDocument_rangeFormatting_sync()

nnoremap <silent> <buffer> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> <buffer> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> <buffer> gr :call LanguageClient_textDocument_references()<CR>

augroup ClosePreview
    au!
    au CompleteDone * pclose
augroup END

function! AddBreakPoint()
    let l:line = line('.')
    let l:indentChar = ' '
    call append(l:line - 1, repeat(l:indentChar, indent(l:line)) . "import pdb;pdb.set_trace()")
endfunction

fu! StartLint(fname)
    let l:cmd = [
        \ $HOME . '/vimconf/scripts/lint',
        \ 'flake8',
        \ '--stdin-display-name=' . a:fname,
        \ '-',
        \ a:fname,
        \ '--stdin',
    \ ]
    let l:jobid = jobstart(l:cmd)
    call jobsend(l:jobid, join(getbufline(bufnr(a:fname), 1,'$'), "\n"))
    call jobclose(l:jobid, 'stdin')
endfu
