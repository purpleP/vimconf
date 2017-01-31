let g:python_highlight_all = 1
setlocal makeprg=pytest\ --tb=short\ -q

let delimitMate_smart_quotes = '\%([^[:punct:][:space:]ubr]\|\%(\\\\\)*\\\)\%#\|\%#\%([^[:space:][:punct:]ubr]\)'
let b:delimitMate_nesting_quotes = ['"', "'"]
nnoremap gb :call AddBreakPoint()<cr>

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

let b:switch_custom_definitions =
    \ [
    \   {
    \     '\v\.(\w+)': '[''\1'']',
    \     '\v\[''([^'']+)''\]': '.\1',
    \   },
    \   ['==', '!='],
    \   ['True', 'False'],
    \ ]

packadd ale
packadd deoplete-jedi
packadd jedi-vim
packadd python-syntax
packadd switch.vim
packadd ultisnips
packadd vim-python-pep8-indent
