fu! s:ShowResults(query_hash, jobid, data, event)
    unlet s:jobid
    let l:b = bufwinnr('/tmp/queries/*')
    if l:b > 0
        exe b.'wincmd w'
    else
        split
    endif
    exe 'view /tmp/queries/' . a:query_hash
    setlocal nowrap
    nnoremap <buffer> q :q<CR>
endfu

fu! s:SendToMysql()
    let l:pane = system("tmux list-panes -F '#{pane_index} #{pane_current_command}' | grep mysql | cut -d' ' -f1")[0:-2]
    if l:pane == ''
        call system("tmux split-window; tmux send -t:+1 '!mysql' Enter")
        echom 'create pane first'
        return
    endif
    let l:save_reg = getreg('"')
    normal! yip
    let l:temp = tempname()
    let l:lines = split(getreg('"'), '\n')
    let l:lines[len(l:lines) - 1] = l:lines[len(l:lines) - 1] . ';'
    call writefile(l:lines, l:temp)
    let l:query_hash = system('md5sum ' . l:temp . ' | cut -d" " -f1')[0:-2]
    let l:full_path = '/tmp/queries/' . l:query_hash
    if filereadable(l:full_path)
        call system('mv ' . l:full_path . ' ' . l:full_path . '_$(date -r ' . l:full_path . ' +%s)')
    endif
    call system('touch ' . l:full_path)
    let l:Cb = function('s:ShowResults', [l:query_hash])
    if exists('s:jobid')
        call jobstop(s:jobid)
        call system('find /tmp/queries --maxdepth 1 -empty -type f -delete')
    endif
    let l:cmd = 'inotifywait -q -e close ' . l:full_path
    let s:jobid = jobstart(l:cmd, {'on_exit': l:Cb})
    let l:cmd = 'tmux send-keys -t .' . l:pane . ' -l "pager cat > /tmp/queries/' . l:query_hash . '"'
    call system(l:cmd)
    call system('tmux send-keys -t .' . l:pane . ' Enter')
    call system('tmux load-buffer -b ' . l:temp . ' ' . l:temp)
    call system('tmux paste-buffer -b ' . l:temp . ' -t .' . l:pane)
    call system('tmux delete-buffer -b ' . l:temp)
    call setreg('"', l:save_reg)
endfu

nnoremap <silent> <buffer> <CR> :call <SID>SendToMysql()<CR>
