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

fu! OpenErrors(job_id, data, event)
    let l:winid = win_getid()
    let l:output = split(a:data[0])
    echom l:output[0] . l:output[2]
    let l:view = winsaveview()
    exe 'silent! cfile! ' . escape(l:output[0] . l:output[2], '%#/')
    call winrestview(l:view)
    if len(getqflist()) > 0
        copen
    else
        cclose
    endif
    call win_gotoid(l:winid)
endfu

if !exists('g:error_job')
    let g:lint_job = jobstart('~/vimconf/scripts/lint_monitor ' . getcwd() . ' py flake8', {}) 
    let g:error_job = jobstart('inotifywait -m -r -q -e close_write /tmp/lint', {'on_stdout': function('OpenErrors')})
endif
augroup Close
    au!
    au VimLeave * call jobstop(g:lint_job) | call jobstop(g:lint_job)
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
