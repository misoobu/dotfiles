" NeoBundle Scripts ----------------------------------------------------------

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle 'Shougo/vimproc.vim', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'linux' : 'make',
\     'unix' : 'gmake',
\    },
\ }

NeoBundle 'Lokaltog/powerline'
set laststatus=2
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
let g:Powerline_symbols = 'fancy'
set noshowmode

NeoBundle 'tomasr/molokai'

NeoBundle 'Shougo/unite.vim'

NeoBundle 'scrooloose/syntastic.git'
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2

NeoBundle 'tpope/vim-fugitive'

" gitの差分を表示するぜ
NeoBundle 'airblade/vim-gitgutter'
" nnoremap <silent> ,gg :<C-u>GitGutterToggle<CR>
" nnoremap <silent> ,gh :<C-u>GitGutterLineHighlightsToggle<CR>

NeoBundle 'scrooloose/nerdtree'
let NERDTreeShowHidden = 1 " 隠しファイルをデフォルトで表示させる
nnoremap <silent><C-e> :NERDTreeToggle<CR> " Ctrl+eで開く

" NeoBundle 'lambdalisue/unite-grep-vcs'
" NeoBundle 'alpaca-tc/alpaca_powertabline'
" NeoBundle 'Shougo/neosnippet.vim'
" NeoBundle 'Shougo/neosnippet-snippets'
" NeoBundle 'ctrlpvim/ctrlp.vim'
" NeoBundle 'flazz/vim-colorschemes'

" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck


" その他設定 ----------------------------------------------------------

" クリップボードを共有
" set clipboard+=unnamed
" macのクリップボードを使う
" set clipboard=unnamed

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
set autoindent   " 開業時の半角スペース
set shiftwidth=2 " 改行時の半カススペースの文字数
set expandtab    " ソフトタブを有効にする
set tabstop=2    " ソフトタブは、半角スペース2文字

" ハイライトを有効にする
syntax enable

" カッコの対応を表示
set showmatch

" 末尾の空白削除
autocmd BufWritePre * :%s/\s\+$//e


" 文字がない場所にもカーソルを移動できるようにする
" set virtualedit=all

" カラースキーマ
colorscheme molokai

" 256色
set t_Co=256
