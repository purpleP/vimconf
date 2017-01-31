fu! s:Custom()
    call denite#custom#source(
        \ 'file_rec', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])
    call denite#custom#var('file_rec', 'command',
        \ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
    call denite#custom#map('insert', '<C-j>', '<denite:move_to_next_line>', 'noremap')
    call denite#custom#map('insert', '<C-k>', '<denite:move_to_previous_line>', 'noremap')
endfu

nnoremap <C-p> :Denite file_rec<CR>

augroup Custom
    au!
    au VimEnter * call s:Custom()
augroup END
