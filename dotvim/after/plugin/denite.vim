call denite#custom#source(
    \ 'file_rec', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert',  '<C-p>',  '<denite:move_to_previous_line>',  'noremap')
call denite#custom#map('insert', '<DOWN>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert',  '<UP>',  '<denite:move_to_previous_line>',  'noremap')
let cmd = 'find -L :directory -type d -path */.* -prune -o -type f -print -type l -print'
call denite#custom#var('file_rec', 'command', split(cmd))
call denite#custom#source('grep', 'matchers', ['matcher_fuzzy'])
call denite#custom#var('grep', 'default_opts', ['-Hn', '--exclude-dir=.*'])
call denite#custom#var('grep', 'pattern_opt', ['-P'])
call denite#custom#var('grep', 'final_opts', [':directory'])
