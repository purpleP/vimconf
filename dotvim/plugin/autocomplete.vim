let g:UltiSnipsMappingsToIgnore = ['autocomplete']

augroup Autocomplete
    au!
    au! User UltiSnipsEnterFirstSnippet
    au User UltiSnipsEnterFirstSnippet let g:expansion_active = 1
    au! User UltiSnipsExitLastSnippet
    au User UltiSnipsExitLastSnippet let g:expansion_active = 0
augroup END
