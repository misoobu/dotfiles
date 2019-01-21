" Visual
syntax enable
set number    " Show line numbers
set showmatch " Show brackets' matches
set cursorline
set breakindent

" Indent
set autoindent   " put spaces after break line
set shiftwidth=2 " the spaces' count
set expandtab    " put spaces when type a tab (soft-tab)
set tabstop=2    " the spaces' count

" Search
set ignorecase " Ignore cases at search
set smartcase  " If the search word contains large and small cases, differentiate them
set wrapscan   " Repeat search after the end of the file
set incsearch  " incremental search
set hlsearch   " Highlight searched-words

" Utils
nnoremap q :q<CR>
nnoremap m :w<CR>
nnoremap <C-c> :vimgrep /<C-r><C-w>/ `git ls-files -co --exclude-standard` \| cw<CR> " grep the current cursor word in git
command -nargs=1 GG :vimgrep /<args>/ `git ls-files -co --exclude-standard` | cw " `:GG word` to grep in git

" Others
set noswapfile
set backspace=indent,eol,start                                   " Make backspace usable at insert mode
set clipboard+=unnamed                                           " Share clipboard with OS
autocmd BufWritePre * :%s/\s\+$//e                               " Remove tail-spaces
autocmd BufRead,BufNewFile tsconfig.json set filetype=javascript " tsconfig has js-style comments

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" After an addition of plugins, exec :PlugInstall

Plug 'Shougo/vimproc.vim', {'do' : 'make'}

Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'itchyny/lightline.vim'
Plug 'fortes/vim-escuro'

Plug 'tomlion/vim-solidity'
Plug 'HerringtonDarkholme/yats.vim'

Plug 'Quramy/tsuquyomi'

call plug#end()

let NERDTreeShowHidden = 1
nnoremap <C-e> :NERDTreeToggle<CR>

let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_show_hidden = 1 " This is used when it is not a git repo (fallback)

set laststatus=2
set noshowmode
let g:lightline = {'colorscheme': 'one'}
set timeoutlen=50 " for lightline

colorscheme escuro

let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_completion_detail = 1                         " This option may make completion slow
autocmd FileType typescript     setlocal completeopt-=preview " because I can see details from menu (see below)
autocmd FileType typescript.tsx setlocal completeopt-=preview
autocmd FileType typescript     nnoremap <C-h> :echo tsuquyomi#hint()<CR>
autocmd FileType typescript.tsx nnoremap <C-h> :echo tsuquyomi#hint()<CR>
autocmd FileType typescript     nnoremap <C-i> :split \| :TsuDefinition<CR>
autocmd FileType typescript.tsx nnoremap <C-i> :split \| :TsuDefinition<CR>

let g:asyncomplete_smart_completion = 1
let g:asyncomplete_remove_duplicates = 1
if executable('typescript-language-server') " npm install -g typescript-language-server
  au User lsp_setup call lsp#register_server({
    \ 'name': 'typescript-language-server',
    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
    \ 'whitelist': ['typescript', 'typescript.tsx'],
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
autocmd FileType ruby setlocal completeopt-=preview
