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

fu! MakeCmd(fname)
    let l:cmd = [
        \ $HOME . '/vimconf/scripts/lint',
        \ 'flake8',
        \ '--stdin-display-name=' . a:fname,
        \ '-',
        \ a:fname,
        \ '--stdin',
    \ ]
    return l:cmd
endfu

augroup LintWhen
    au!
    au TextChanged,TextChangedI,BufWinEnter *.py call lint#StartLint(function('MakeCmd'), expand('%:p'))
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
