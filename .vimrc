" Visual
syntax enable
set number " show line numbers
set cursorline
set breakindent

" Indent
set autoindent
set shiftwidth=2
set expandtab
set tabstop=2

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Util
nnoremap q :q<CR>
nnoremap <C-s> :w<CR>
nnoremap <C-k> i<CR><ESC>

" Grep
set shellpipe=> " default: '2>&1| tee'
set grepprg=git\ grep\ -I\ --line-number\ -e
nnoremap <C-g> :silent grep! <cword> \| cw \| redraw!<CR>
command! -nargs=+ GG silent grep! <q-args> | cw | redraw!

" Netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 20
nnoremap <C-e> :Vexplore<CR>

" QuickFix
highlight link QuickFixLine Normal
augroup QuickFixCmd
  autocmd!
  autocmd! FileType qf nnoremap <buffer> <C-x> <C-w><CR> " this is like ctrlp
augroup END

" Misc
set noswapfile
set backspace=indent,eol,start " Make backspace usable at insert mode
set clipboard+=unnamed " Share clipboard with OS
augroup StripTrailingSpaces
  autocmd!
  autocmd BufWritePre * :%s/\s\+$//e
augroup END
augroup GitSpellCheck
  autocmd!
  autocmd FileType gitcommit setlocal spell
augroup END

" Plugin
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Please exec :PlugInstall after added plugins

Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

Plug 'airblade/vim-gitgutter'
set updatetime=100

Plug 'tpope/vim-fugitive'

Plug 'itchyny/lightline.vim'
set laststatus=2
set noshowmode
set timeoutlen=50 " for lightline
" default -> one, filename -> absolutepath, [fileformat, fileencoding, filetype] -> []
let g:lightline = {
\  'colorscheme': 'one',
\  'active': {
\    'left': [ [ 'mode', 'paste' ], [ 'readonly', 'absolutepath', 'modified' ] ],
\    'right': [ [ 'lineinfo' ], [ 'percent' ], [] ]
\  }
\}

Plug 'itchyny/vim-cursorword'

Plug 'fortes/vim-escuro'

Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['typescript']

Plug 'HerringtonDarkholme/yats.vim'

Plug 'w0rp/ale'
let g:ale_completion_enabled = 1
let g:ale_lint_on_text_changed = 'never' " run linters only when save files
let g:ale_linters_explicit = 1
" npm install -g typescript-language-server && gem install solargraph && solargraph download-core
let g:ale_linters = {
\ 'typescript': ['tsserver'],
\ 'javascript': ['tsserver'],
\ 'ruby': ['ruby', 'solargraph'],
\}
set completeopt=menu,menuone,preview,noselect,noinsert " https://github.com/w0rp/ale/commit/399a0d3c988381d2436d066e1fe74ef688947f28
nnoremap <C-h> :ALEHover<CR>
nnoremap <C-i> :split \| :ALEGoToDefinition<CR>

Plug 'Quramy/tsuquyomi'
let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_completion_detail = 1 " This option may make completion slow
augroup TypeScriptCmd
  autocmd!
  autocmd BufRead,BufNewFile tsconfig.json set filetype=javascript " tsconfig has js-style comments
  autocmd FileType typescript,typescript.tsx setlocal completeopt-=preview
  autocmd FileType typescript,typescript.tsx nnoremap <buffer> <C-h> :echo tsuquyomi#hint()<CR>
  autocmd FileType typescript,typescript.tsx nnoremap <buffer> <C-i> :split \| :TsuDefinition<CR>
  autocmd FileType typescript,typescript.tsx let g:ale_lint_on_enter = 0 " I use tsuquyomi for ts, so not needed
  autocmd FileType typescript,typescript.tsx let g:ale_lint_on_save = 0
augroup END

call plug#end()

colorscheme escuro
