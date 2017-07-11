let s:outputs = {}
let b:results_window
fu! s:ShowResults(jobid, data, event)
    exe 'sview /tmp/queries/' . a:data[0]
    setlocal nowrap
    nnoremap <buffer> q :q<CR>
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
    let l:query_hash = system('md5sum ' . l:temp . ' | cut -d" " -f1')
    let l:jobid = jobstart('inotifywait -q -e create /tmp/queries/ | cut -d" " -f3' , {'on_stdout': function('s:ShowResults')})
    call system('tmux load-buffer -b ' . l:temp . ' ' . l:temp)
    call system('tmux paste-buffer -b ' . l:temp . ' -t .' . l:pane)
    call system('tmux delete-buffer -b ' . l:temp)
    call setreg('"', l:save_reg)
endfu

nnoremap <silent> <buffer> <CR> :call <SID>SendToMysql()<CR>
