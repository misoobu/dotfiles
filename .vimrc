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

" Use q to quit vim
nmap q :q<CR>

" Others
set noswapfile
set backspace=indent,eol,start     " Make backspace usable at insert mode
set clipboard+=unnamed             " Share clipboard with OS
autocmd BufWritePre * :%s/\s\+$//e " Remove tail-spaces

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" After an addition of plugin, exec :PlugInstall

Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'itchyny/lightline.vim'
Plug 'fortes/vim-escuro'

Plug 'tomlion/vim-solidity'
Plug 'leafgarland/typescript-vim'

call plug#end()

let NERDTreeShowHidden = 1
nnoremap <silent><C-e> :NERDTreeToggle<CR>
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_show_hidden = 1 " This is used when it is not a git repo (fallback)
set laststatus=2
set noshowmode
let g:lightline = {'colorscheme': 'one'}
set timeoutlen=50 " for lightline
colorscheme escuro
