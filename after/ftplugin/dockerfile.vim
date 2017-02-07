function! s:DockerfileReplaceInstruction(original, replacement)
    let syn = synIDtrans(synID(line("."), col(".") - 1, 0))
    if syn != hlID("Comment") && syn != hlID("Constant") && strlen(getline(".")) == 0
        let word = a:replacement
    else
        let word = a:original
    endif
    let g:UnduBuffer = a:original
    return word
endfunction

inoreabbr <silent> <buffer> from <C-R>=<SID>DockerfileReplaceInstruction("from", "FROM")<CR>
inoreabbr <silent> <buffer> maintainer <C-R>=<SID>DockerfileReplaceInstruction("maintainer", "MAINTAINER")<CR>
inoreabbr <silent> <buffer> run <C-R>=<SID>DockerfileReplaceInstruction("run", "RUN")<CR>
inoreabbr <silent> <buffer> cmd <C-R>=<SID>DockerfileReplaceInstruction("cmd", "CMD")<CR>
inoreabbr <silent> <buffer> label <C-R>=<SID>DockerfileReplaceInstruction("label", "LABEL")<CR>
inoreabbr <silent> <buffer> expose <C-R>=<SID>DockerfileReplaceInstruction("expose", "EXPOSE")<CR>
inoreabbr <silent> <buffer> env <C-R>=<SID>DockerfileReplaceInstruction("env", "ENV")<CR>
inoreabbr <silent> <buffer> add <C-R>=<SID>DockerfileReplaceInstruction("add", "ADD")<CR>
inoreabbr <silent> <buffer> copy <C-R>=<SID>DockerfileReplaceInstruction("copy", "COPY")<CR>
inoreabbr <silent> <buffer> entrypoint <C-R>=<SID>DockerfileReplaceInstruction("entrypoint", "ENTRYPOINT")<CR>
inoreabbr <silent> <buffer> volume <C-R>=<SID>DockerfileReplaceInstruction("volume", "VOLUME")<CR>
inoreabbr <silent> <buffer> user <C-R>=<SID>DockerfileReplaceInstruction("user", "USER")<CR>
inoreabbr <silent> <buffer> workdir <C-R>=<SID>DockerfileReplaceInstruction("workdir", "WORKDIR")<CR>
inoreabbr <silent> <buffer> arg <C-R>=<SID>DockerfileReplaceInstruction("arg", "ARG")<CR>
inoreabbr <silent> <buffer> onbuild <C-R>=<SID>DockerfileReplaceInstruction("onbuild", "ONBUILD")<CR>
inoreabbr <silent> <buffer> stopsignal <C-R>=<SID>DockerfileReplaceInstruction("stopsignal", "STOPSIGNAL")<CR>
