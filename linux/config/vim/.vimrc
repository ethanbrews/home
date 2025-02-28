let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Basic settings
set nu
set rnu
syntax on
set nocp
filetype plugin on
set hlsearch
set incsearch

set listchars=eol:$,tab:>>,trail:•
" set list

" Keyboard shortcuts
nnoremap <C-s> :w<CR>
nnoremap tl :Buffer<CR>
nnoremap th :History:<CR>
nnoremap tg :Rg<cr>
nnoremap tn :bnext<cr>
nnoremap tp :bprevious<cr>
nnoremap <silent> ;; :set list!<CR>
nnoremap <nowait><silent> <C-l> :noh<CR>:let @/ = ""<CR>

set statusline=%t       "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
