call plug#begin()

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'easymotion/vim-easymotion'
Plug 'scrooloose/nerdcommenter'

call plug#end()

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
" nnoremap tg :call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ", fzf#vim#with_preview())<C-F>26<Left><C-c>
nnoremap tg :Rg<cr>
nnoremap tn :bnext<cr>
nnoremap tp :bprevious<cr>
nnoremap tf :Files<cr>
" nnoremap ta :Ag<cr>
nnoremap gb :Git blame<cr>
nnoremap gc :Git commit<cr>
nnoremap <silent> ;; :set list!<CR>
nnoremap <nowait><silent> <C-l> :noh<CR>:let @/ = ""<CR>
nnoremap <C-i> i_<Esc>r
nnoremap <C-x> :bd<CR>
nnoremap <C-o> :put _<CR>
nnoremap <C-8> *''

" Disable Arrow keys in Normal mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" File associations
au BufRead,BufNewFile *.triage setfiletype log

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

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=? -complete=dir GFiles
    \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
    \   fzf#vim#with_preview(), <bang>0)
