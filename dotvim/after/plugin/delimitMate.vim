let delimitMate_jump_expansion = 0
let delimitMate_expand_space = 1
let delimitMate_expand_cr = 1
let delimitMate_balance_matchpairs = 1

fu! s:PythonSetup()
    let b:delimitMate_smart_quotes = '\%([^[:punct:][:space:]fubr]\|\%(\\\\\)*\\\)\%#\|\%#\%([^[:space:][:punct:]fubr]\)'
endfu

fu! s:VimLSetup()
    let b:delimitMate_smart_quotes = '\%(\w\|[^[:punct:][:space:]]\|\%(\\\\\)*\\\)\%#\|@\%#\|\%#\%(\w\|[^[:space:][:punct:]]\)'
endfu

augroup DelimitMateFileTypeSettings
    au!
    au FileType python call <SID>PythonSetup()
    au FileType vim call <SID>VimLSetup()
augroup END
