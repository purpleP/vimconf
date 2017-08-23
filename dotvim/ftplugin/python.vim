nnoremap gb :call AddBreakPoint()<cr>

setlocal includeexpr=substitute(v:fname,'\\.','/','g')

setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab

nnoremap <silent> <buffer> <C-]> :call g:jedi#goto()<CR>
nnoremap <silent> <buffer> K :call jedi#show_documentation()<CR>
nnoremap <silent> <buffer> <leader>u :call jedi#usages()<CR>

augroup jedi_close
    au!
    au CompleteDone * pclose
augroup END

function! AddBreakPoint()
    let l:line = line('.')
    let l:indentChar = ' '
    call append(l:line - 1, repeat(l:indentChar, indent(l:line)) . "import pdb;pdb.set_trace()")
endfunction

fu! OpenErrors(file)
    let l:real_name = substitute(a:file[10:], '%2F', '/', 'g')
    echom l:real_name
    if !bufexists(l:real_name)
        return
    endif
    let l:winid = win_getid()
    let l:view = winsaveview()
    exe 'silent! cgetfile ' . escape(a:file, '%#/')
    let l:num_errors = len(getqflist())
    if l:num_errors > 0
        exe 'belowright copen ' . string(l:num_errors)
        call winrestview(l:view)
        call win_gotoid(l:winid)
    else
        cclose
    endif
endfu

fu! OnErrorsChange(job_id, data, event)
    if mode() is 'n'
        call OpenErrors(a:data[0])
    else
        let s:file = a:data[0]
        augroup PendingOpen
            au!
            au InsertLeave * call OpenErrors(s:file) | au! PendingOpen
        augroup END
    endif
endfu

let s:file = ''
let s:jobs = {}

fu! CheckPending(fname, jobid, data, event)
    if has_key(s:jobs, a:fname)
        remove(s:jobs, a:fname)
        call StartLint(a:fname)
    endif
endfu

fu! StartLint(fname)
    let l:cmd = [
        \ $HOME . '/vimconf/scripts/lint',
        \ 'flake8',
        \ '--stdin-display-name=' . a:fname,
        \ '-',
        \ a:fname,
        \ '--stdin',
    \ ]
    if !has_key(s:jobs, a:fname)
        let l:jobid = jobstart(l:cmd, {'on_exit': function('CheckPending', [a:fname])})
        call jobsend(l:jobid, join(getbufline(bufnr(a:fname), 1,'$'), "\n"))
        call jobclose(l:jobid, 'stdin')
    else
        s:jobs[a:fname] = 1
    endif
endfu

if !exists('g:error_job')
    let g:error_job = jobstart('inotifywait -m -r -q -e close_write --format "%w%f" /tmp/lint', {'on_stdout': function('OnErrorsChange')})
endif

augroup Lint
    au!
    au TextChanged,TextChangedI,BufWinEnter *.py call StartLint(expand('%:p'))
    au VimLeave *.py call jobstop(g:error_job)
augroup END

setlocal efm=%f:%l:%c:\ %t%n\ %m

let b:switch_custom_definitions =
    \ [
    \   {
    \     '\v(^\s*)(<[a-z][a-zA-Z0-9_]* \=)': '\1return',
    \   },
    \   {
    \     '\v(if|elif) ([a-z][a-zA-Z0-9_]*)': '\1 not \2',
    \   },
    \   {
    \     '\v\.(\w+)': '[''\1'']',
    \     '\v\[''([^'']+)''\]': '.\1',
    \   },
    \   ['==', '!='],
    \   ['True', 'False'],
    \ ]

packadd switch.vim
