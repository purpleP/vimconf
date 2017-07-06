let s:outputs = {}
fu! s:ShowResults(jobid, data, event)
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
    let l:hash = system('md5sum ' . l:temp . ' | cut -d" " -f1') 
    let l:jobid = call jobstart(['inotifywait', '-e', 'create', '/tmp/queries/' ], {'on_stdout': function('s:ShowResults')})
    s:outputs[l:jobid] = l:hash
    call system('tmux load-buffer -b ' . l:temp . ' ' . l:temp)
    call system('tmux paste-buffer -b ' . l:temp . ' -t .' . l:pane)
    call system('tmux delete-buffer -b ' . l:temp)
    call setreg('"', l:save_reg)
endfu

nnoremap <silent> <buffer> <CR> :call <SID>SendToMysql()<CR>
