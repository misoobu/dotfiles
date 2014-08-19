" クリップボードを共有
set clipboard+=unnamed

" 100ミリ秒以内に入力がないと、単体の入力として判定する
set timeoutlen=100

" 検索の時に大文字小文字を区別しない
" ただし大文字小文字の両方が含まれている場合は大文字小文字を区別する
set ignorecase
set smartcase

" 検索時にファイルの最後まで行ったら最初に戻る
set wrapscan

" インクリメンタルサーチ
set incsearch

" 検索文字の強調表示
set hlsearch

" 行番号表示
set number

" インデント
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent

" ハイライトを有効にする
syntax on

" カッコの対応を表示
set showmatch

" 末尾の空白削除
autocmd BufWritePre * :%s/\s\+$//e

" macのクリップボードを使う
set clipboard+=unnamed
set clipboard=unnamed

" 文字がない場所にもカーソルを移動できるようにする
set virtualedit=all

" 256色
set t_Co=256

" neobundle
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif
call neobundle#rc(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
filetype plugin on
NeoBundleCheck

NeoBundle 'alpaca-tc/alpaca_powertabline'

NeoBundle 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}
set laststatus=2
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
let g:Powerline_symbols = 'fancy'
set noshowmode

NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc'

NeoBundle 'scrooloose/syntastic.git'
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2

NeoBundle 'tpope/vim-fugitive'

