let g:haskell_classic_highlighting = 1 
set conceallevel=2 concealcursor=nvi

if !exists('g:LanguageClient_serverCommands')
    let g:LanguageClient_serverCommands = {}
endif
let g:LanguageClient_serverCommands['haskell'] = ['hie', '--lsp']
LanguageClientStart
