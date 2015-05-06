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

NeoBundle 'scrooloose/syntastic.git'
" let g:syntastic_enable_signs=1
" let g:syntastic_auto_loc_list=2
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['ruby', 'javascript'] }
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_javascript_checkers = ['jsxhint']

NeoBundle 'scrooloose/nerdtree'
let NERDTreeShowHidden = 1 " 隠しファイルをデフォルトで表示させる
nnoremap <silent><C-e> :NERDTreeToggle<CR> " Ctrl+eで開く

NeoBundle 'Shougo/unite.vim'
" insert modeで開始
let g:unite_enable_start_insert = 1
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
" grep検索
nnoremap <silent> ,g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
" カーソル位置の単語をgrep検索
nnoremap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
" grep検索結果の再呼出
nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>
" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif

NeoBundle 'tpope/vim-rails'
autocmd User Rails nmap :<C-u>Econtroller :<C-u>Ec
autocmd User Rails nmap :<C-u>Emodel :<C-u>Em
autocmd User Rails nmap :<C-u>Eview :<C-u>Ev
autocmd User Rails nmap :<C-u>RScontroller :<C-u>RSc
autocmd User Rails nmap :<C-u>RSmodel :<C-u>RSm
autocmd User Rails nmap :<C-u>RSview :<C-u>RSv
autocmd User Rails nmap :<C-u>RVcontroller :<C-u>RVc
autocmd User Rails nmap :<C-u>RVmodel :<C-u>RVm
autocmd User Rails nmap :<C-u>RVview :<C-u>RVv

NeoBundle 'godlygeek/tabular' " for vim-markdown
NeoBundle 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled=1

NeoBundle 'Shougo/neomru.vim'
" NeoBundle 'tomasr/molokai'
NeoBundle 'chriskempson/vim-tomorrow-theme'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'slim-template/vim-slim'
NeoBundle 'digitaltoad/vim-jade'
NeoBundle 'wavded/vim-stylus'
NeoBundle 'rking/ag.vim'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'vim-scripts/dbext.vim'
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'szw/vim-tags'
NeoBundle 'basyura/unite-rails'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'tyru/open-browser-github.vim'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'mxw/vim-jsx'

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
colorscheme Tomorrow-Night-Bright

" 256色
set t_Co=256

set noswapfile

" インサートモード時にバックスペースを使う
set backspace=indent,eol,start

