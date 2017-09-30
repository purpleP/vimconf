if !exists('g:LanguageClient_serverCommands')
    let g:LanguageClient_serverCommands = {}
endif

let g:LanguageClient_serverCommands['rust'] = ['rustup', 'run', 'nightly', 'rls']
LanguageClientStart
