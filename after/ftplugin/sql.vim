fu! s:Reload(jobid, data, event)
    let l:result_buffer = bufwinnr('/tmp/queries/q1.txt')
    if l:result_buffer > 0
        exe l:result_buffer . ' wincmd w'
        edit
    else
        sp /tmp/queries/q1.txt
        edit
        setlocal nowrap
        nnoremap <buffer> q :q<CR>
    endif
endfu

fu! s:SendToMysql()
    let l:pane = system("tmux list-panes -F '#{pane_index} #{pane_current_command}' | grep mysql | cut -d' ' -f1")
    if l:pane == ''
        call system("tmux split-window; tmux send -t .1 '!mysql' Enter; tmux select-pane -t .1")
        echom 'create pane first'
        return
    endif
    let l:save_reg = getreg('"')
    normal! yip
    let l:temp = tempname()
    let l:lines = split(getreg('"'), '\n')
    let l:lines[len(l:lines) - 1] = l:lines[len(l:lines) - 1] . ';'
    call writefile(l:lines, l:temp)
    call jobstart(['inotifywait', '-e', 'move_self', 'create', '/tmp/queries/q1.txt' ], {'on_exit': function('s:Reload')})
    call system('tmux load-buffer -b ' . l:temp . ' ' . l:temp)
    call system('tmux paste-buffer -b ' . l:temp . ' -t .' . l:pane)
    call system('tmux delete-buffer -b ' . l:temp)
    call setreg('"', l:save_reg)
endfu

nnoremap <silent> <buffer> <CR> :call <SID>SendToMysql()<CR>
