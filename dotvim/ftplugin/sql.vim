fu! s:ShowResults(query_hash, jobid, data, event)
    call s:OpenResults(a:query_hash)
endfu

fu! s:OpenResults(query_hash)
    let l:id = bufwinid('/tmp/results/*')
    if l:id > 0
        call win_gotoid(l:id)
    else
        split
    endif
    exe 'view /tmp/results/' . a:query_hash
    setlocal nowrap
    nnoremap <buffer> q :q<CR>
    nnoremap <buffer> <CR> :call <SID>Refresh()<CR>
endfu

fu! s:SaveQueryAndHash()
    let l:save_reg = getreg('"')
    normal! yip
    let l:temp = tempname()
    let l:lines = split(getreg('"'), '\n')
    call setreg('"', l:save_reg)
    let l:lines[len(l:lines) - 1] = l:lines[len(l:lines) - 1] . ';'
    call writefile(l:lines, l:temp)
    let l:hash = system('md5sum ' . l:temp . ' | cut -d" " -f1')[0:-2]
    call system('cp ' . l:temp . ' /tmp/queries/' . l:hash)
    return l:hash
endfu

fu! s:OpenLastResults()
    let l:hash = s:SaveQueryAndHash()
    call s:OpenResults(l:hash)
endfu

fu! s:Refresh()
    call s:ExecuteQuery(expand('%:t'))
endfu

fu! s:ExecuteQuery(hash)
    let l:pane = system("tmux list-panes -F '#{pane_index} #{pane_current_command}' | grep mysql | cut -d' ' -f1")[0:-2]
    if l:pane == ''
        call system("tmux split-window; tmux send -t:+1 '!mysql' Enter")
        echom 'create pane first'
        return
    endif
    let l:query = '/tmp/queries/' . a:hash
    let l:result = '/tmp/results/' . a:hash
    if filereadable(l:result)
        call system('mv ' . l:result . ' ' . l:result . '_$(date -r ' . l:result . ' +%s)')
    endif
    call system('touch ' . l:result)
    let l:Cb = function('s:ShowResults', [a:hash])
    call system('find /tmp/results --maxdepth 1 -empty -type f -delete')
    let l:cmd = 'inotifywait -q -e close ' . l:result
    let s:jobid = jobstart(l:cmd, {'on_exit': l:Cb})
    let l:cmd = 'tmux send-keys -t .' . l:pane . ' -l "pager cat > ' . l:result . '"'
    call system(l:cmd)

    call system('tmux send-keys -t .' . l:pane . ' Enter')
    call system('tmux load-buffer -b ' . l:query . ' ' . l:query)
    call system('tmux paste-buffer -b ' . l:query . ' -t .' . l:pane)
    call system('tmux delete-buffer -b ' . l:query)
endfu

fu! s:SendToMysql()
    call s:ExecuteQuery(s:SaveQueryAndHash())
endfu

nnoremap <silent> <buffer> <CR> :call <SID>SendToMysql()<CR>
nnoremap <silent> <buffer> <leader>o :call <SID>OpenLastResults()<CR>
if executable('sqlint')
    packadd ale
endif
