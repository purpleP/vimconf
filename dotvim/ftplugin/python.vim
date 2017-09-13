nnoremap gb :call AddBreakPoint()<cr>

setlocal includeexpr=substitute(v:fname,'\\.','/','g')

setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab

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

if !exists('g:LanguageClient_serverCommands')
    let g:LanguageClient_serverCommands = {}
endif

let g:LanguageClient_serverCommands['python'] = ['pyls']
LanguageClientStart
