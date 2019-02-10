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
nnoremap m :w<CR>
nnoremap <C-k> i<CR><ESC>
inoremap <C-f> <ESC>

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

Plug 'Shougo/vimproc.vim', {'do' : 'make'}

Plug 'ctrlpvim/ctrlp.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'itchyny/lightline.vim'
Plug 'fortes/vim-escuro'

Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['typescript']
Plug 'HerringtonDarkholme/yats.vim'

Plug 'Quramy/tsuquyomi'

call plug#end()

let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_show_hidden = 1 " This is used when it is not a git repo (fallback)

set laststatus=2
set noshowmode
set timeoutlen=50 " for lightline
" color: default -> one, file: filename -> absolutepath
let g:lightline = {
\  'colorscheme': 'one',
\  'active': { 'left': [ [ 'mode', 'paste' ], [ 'readonly', 'absolutepath', 'modified' ] ] }
\}

colorscheme escuro

let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_completion_detail = 1 " This option may make completion slow
augroup TypeScriptCmd
  autocmd!
  autocmd BufRead,BufNewFile tsconfig.json set filetype=javascript         " tsconfig has js-style comments
  autocmd FileType typescript,typescript.tsx setlocal completeopt-=preview " because I can see details from menu (see below)
  autocmd FileType typescript,typescript.tsx nnoremap <buffer> <C-h> :echo tsuquyomi#hint()<CR>
  autocmd FileType typescript,typescript.tsx nnoremap <buffer> <C-i> :split \| :TsuDefinition<CR>
augroup END

let g:asyncomplete_smart_completion = 1
let g:asyncomplete_remove_duplicates = 1
if executable('typescript-language-server') " npm install -g typescript-language-server
  au User lsp_setup call lsp#register_server({
    \ 'name': 'typescript-language-server',
    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
    \ 'whitelist': ['typescript', 'typescript.tsx', 'javascript', 'javascript.jsx'],
    \ })
endif
if executable('solargraph') " gem install solargraph && solargraph download-core
  au User lsp_setup call lsp#register_server({
    \ 'name': 'solargraph',
    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
    \ 'initialization_options': {"diagnostics": "true"},
    \ 'whitelist': ['ruby'],
    \ })
endif
augroup RubyCmd
  autocmd!
  autocmd FileType ruby setlocal completeopt-=preview
augroup END
