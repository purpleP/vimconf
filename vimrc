set nocompatible              " be iMproved, required
filetype on
filetype plugin indent on    " required

set autowrite
set breakindent
set backspace=indent,eol,start
set completeopt=menuone,preview
set confirm
set foldlevel=99
set foldmethod=indent
set lazyredraw
set mouse-=a
set number
set path+=**
set relativenumber
set ruler
set shortmess+=A
set smartcase
set splitbelow
set splitright
set virtualedit=insert
set wildignore+=*.pyc,*.so,*.swp,*.zip,.*/**
set wildmenu

if !has('nvim')
    set encoding=utf-8
    set hlsearch
    set incsearch
endif

if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor\ --vimgrep
endif

if has("persistent_undo")
    set undodir=~/.undodir/
    set undofile
endif

if has('nvim')
    set inccommand=nosplit
endif

syntax enable
silent! colorscheme solarized

let delimitMate_jump_expansion = 0
let delimitMate_expand_space = 1
let delimitMate_expand_cr = 1

let mapleader = "\<Space>"
imap <C-l> <right>
nnoremap <silent> <TAB> :noh<CR>
nnoremap <silent> <leader>* :let @/='\<'.expand('<cword>').'\>' <bar> set hlsearch<CR>

augroup EnterMap
    au!
    au CmdwinEnter * noremap <buffer> <CR> <CR>
    au Filetype qf noremap <buffer> <CR> <CR>
augroup END

cmap w!! w !sudo tee % >/dev/null

augroup myvimrc
    au!
    au BufWritePost .vimrc source $MYVIMRC
    au BufWritePost vimrc source $MYVIMRC
    au BufEnter .vimrc set ft=vim
augroup END

function! ResCur()
    if line("'\"") <= line("$")
        silent normal! g`"
        return 1
    endif
endfunction

augroup resCur
    au!
    au BufWinEnter * call ResCur()
    au BufRead * normal zz
augroup END


" Enable syntax highlighting when buffers are displayed in a window through
" :argdo and :bufdo, which disable the Syntax autocmd event to speed up
" processing.
augroup EnableSyntaxHighlighting
    " Filetype processing does happen, so we can detect a buffer initially
    " loaded during :argdo / :bufdo through a set filetype, but missing
    " b:current_syntax. Also don't do this when the user explicitly turned off
    " syntax highlighting via :syntax off.
    " The following autocmd is triggered twice:
    " 1. During the :...do iteration, where it is inactive, because
    " 'eventignore' includes "Syntax". This speeds up the iteration itself.
    " 2. After the iteration, when the user re-enters a buffer / window that was
    " loaded during the iteration. Here is becomes active and enables syntax
    " highlighting. Since that is done buffer after buffer, the delay doesn't
    " matter so much.
    " Note: When the :...do command itself edits the window (e.g. :argdo
    " tabedit), the BufWinEnter event won't fire and enable the syntax when the
    " window is re-visited. We need to hook into WinEnter, too. Note that for
    " :argdo split, each window only gets syntax highlighting as it is entered.
    " Alternatively, we could directly activate the normally effectless :syntax
    " enable through :set eventignore-=Syntax, but that would also cause the
    " slowdown during the iteration Vim wants to avoid.
    " Note: Must allow nesting of autocmds so that the :syntax enable triggers
    " the ColorScheme event. Otherwise, some highlighting groups may not be
    " restored properly.
    autocmd! BufWinEnter,WinEnter * nested
                \ if exists('syntax_on')
                \ && ! exists('b:current_syntax')
                \ && ! empty(&l:filetype)
                \ && index(split(&eventignore, ','), 'Syntax') == -1
                \| syntax enable |
                \endif

    " The above does not handle reloading via :bufdo edit!, because the
    " b:current_syntax variable is not cleared by that. During the :bufdo,
    " 'eventignore' contains "Syntax", so this can be used to detect this
    " situation when the file is re-read into the buffer. Due to the
    " 'eventignore', an immediate :syntax enable is ignored, but by clearing
    " b:current_syntax, the above handler will do this when the reloaded buffer
    " is displayed in a window again.
    autocmd! BufRead * if exists('syntax_on') && exists('b:current_syntax')
                \ && ! empty(&l:filetype)
                \ && index(split(&eventignore, ','), 'Syntax') != -1
                \| unlet! b:current_syntax |
                \ endif
augroup END

let g:UltiSnipsEditSplit='horizontal'
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_delay=50
let g:deoplete#sources#clang#libclang_path = $LIBCLANG_PATH
let g:deoplete#sources#clang#clang_header = $LIBCLANG_HEADER

let g:in_git_repo = 0

fu! s:DeniteInit(in_git)
    call denite#custom#source(
        \ 'file_rec', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])
    call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
    call denite#custom#map('insert',  '<C-p>',  '<denite:move_to_previous_line>',  'noremap')
    if a:in_git
        call denite#custom#var('file_rec', 'command', ['git', 'ls-files', '-co', '--exclude-standard'])
    endif
endfu

nnoremap <silent> <Esc>f :Denite file_rec<CR>
nnoremap <silent> <Esc>b :Denite buffer<CR>

augroup SmartNumbers
    au!
    au BufEnter,WinEnter * set number | set relativenumber
    au BufLeave,WinLeave * set norelativenumber
    au FocusLost * set norelativenumber
    au FocusGained * set relativenumber
augroup END

set ts=4 sts=4 sw=4 expandtab
augroup indent
    au!
    au FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
    au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    au FileType html setlocal ts=2 sts=2 sw=2 expandtab
    au FileType json setlocal ts=2 sts=2 sw=2 expandtab
    au FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
    au FileType css setlocal ts=2 sts=2 sw=2 expandtab
augroup END

fun! MaximizeOrEqualize()
    if &columns < 170
        wincmd |
        wincmd _
    else
        wincmd =
    endif
endf

fun! MaximizeOrNothing()
    if &columns < 170
        wincmd |
        wincmd _
    endif
endf

augroup Resize
    autocmd!
    au VimResized * call MaximizeOrEqualize()
    au WinEnter * call MaximizeOrNothing()
augroup END

let g:SuperTabDefaultCompletionType = "<c-n>"

augroup ColorColumn
    au!
    autocmd WinEnter,BufEnter *.py\|*.vim\|*vimrc call matchadd('ColorColumn', '\%81v', 100)
augroup END

let g:python3_host_prog = $HOME.'/.venv/bin/python'
let g:jedi#auto_initialization = 0
let g:jedi#force_py_version = 3
let g:jedi#popup_on_dot = 0
let g:jedi#popup_select_first = 0
let g:jedi#completions_enabled = 0
let g:jedi#smart_auto_mappings = 0

noremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]

let s:previous_search_pattern = ''
let s:prev_search_disabled = 0

fu! HlSearch()
    let last_search_pattern = @/
    let new_search = last_search_pattern != s:previous_search_pattern 
    if new_search
       let s:prev_search_disabled = 0
    endif
    if new_search || s:prev_search_disabled == 0
        if v:hlsearch
            silent! if v:hlsearch && !search('\%#\zs'.@/,'cnW')
                call StopHL()
            endif
        endif
    endif
endfu

fu! StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    else
        sil call feedkeys("\<Plug>(StopHL)", 'm')
        let s:prev_search_disabled = 1
    endif
endfu

augroup SearchHighlight
    au!
    au CursorMoved * call HlSearch()
    au InsertEnter * call StopHL()
augroup END

augroup AutoWrite
    au!
    au BufLeave * silent! wall
    au TabLeave * silent! wall
    au FocusLost * silent! wall
    au FocusGained * checktime
augroup END

augroup git
    au!
    au VimEnter * call s:DeniteInit(finddir('.git', ';') != '')
augroup END
