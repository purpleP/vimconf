function! s:DockerfileReplaceInstruction(original, replacement)
    let syn = synIDtrans(synID(line("."), col(".") - 1, 0))
    if syn != hlID("Comment") && syn != hlID("Constant") && strlen(getline(".")) == 0
        let word = a:replacement
    else
        let word = a:original
    endif
    return word
endfunction

inoreabbr <expr> <silent> <buffer> from <SID>DockerfileReplaceInstruction("from", "FROM")
inoreabbr <expr> <silent> <buffer> maintainer <SID>DockerfileReplaceInstruction("maintainer", "MAINTAINER")
inoreabbr <expr> <silent> <buffer> run <SID>DockerfileReplaceInstruction("run", "RUN")
inoreabbr <expr> <silent> <buffer> cmd <SID>DockerfileReplaceInstruction("cmd", "CMD")
inoreabbr <expr> <silent> <buffer> label <SID>DockerfileReplaceInstruction("label", "LABEL")
inoreabbr <expr> <silent> <buffer> expose <SID>DockerfileReplaceInstruction("expose", "EXPOSE")
inoreabbr <expr> <silent> <buffer> env <SID>DockerfileReplaceInstruction("env", "ENV")
inoreabbr <expr> <silent> <buffer> add <SID>DockerfileReplaceInstruction("add", "ADD")
inoreabbr <expr> <silent> <buffer> copy <SID>DockerfileReplaceInstruction("copy", "COPY")
inoreabbr <expr> <silent> <buffer> entrypoint <SID>DockerfileReplaceInstruction("entrypoint", "ENTRYPOINT")
inoreabbr <expr> <silent> <buffer> volume <SID>DockerfileReplaceInstruction("volume", "VOLUME")
inoreabbr <expr> <silent> <buffer> user <SID>DockerfileReplaceInstruction("user", "USER")
inoreabbr <expr> <silent> <buffer> workdir <SID>DockerfileReplaceInstruction("workdir", "WORKDIR")
inoreabbr <expr> <silent> <buffer> arg <SID>DockerfileReplaceInstruction("arg", "ARG")
inoreabbr <expr> <silent> <buffer> onbuild <SID>DockerfileReplaceInstruction("onbuild", "ONBUILD")
inoreabbr <expr> <silent> <buffer> stopsignal <SID>DockerfileReplaceInstruction("stopsignal", "STOPSIGNAL")
