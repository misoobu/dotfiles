" start NeoBundle -----

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

NeoBundle 'bling/vim-airline'
let g:airline#extensions#tabline#enabled=1
let g:airline_theme='laederon'
let g:airline_powerline_fonts=1
set laststatus=2
set noshowmode

NeoBundle 'scrooloose/syntastic.git'
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['ruby', 'javascript'] }
let g:syntastic_ruby_checkers = ['rubocop']
let g:syntastic_javascript_checkers = ['jsxhint']

NeoBundle 'scrooloose/nerdtree'
let NERDTreeShowHidden = 1
nnoremap <silent><C-e> :NERDTreeToggle<CR>

NeoBundle 'Shougo/unite.vim'
let g:unite_enable_start_insert = 1
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1
nnoremap <silent><C-g> :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent><C-c> :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W><CR>
au FileType unite nnoremap <silent> <buffer> <expr> <C-x> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-x> unite#do_action('split')
au FileType unite nnoremap <silent> <buffer> <expr> <C-v> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-v> unite#do_action('vsplit')
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif

NeoBundle 'Yggdroot/indentLine'
let g:indentLine_fileTypeExclude = ['help', 'nerdtree']
let g:indentLine_color_term = 239

NeoBundle 'ctrlpvim/ctrlp.vim'
let g:ctrlp_custom_ignore = {'dir': '\.git$\|\.svn$\|bower_components$\|node_modules$'}

NeoBundle 'elzr/vim-json'
let g:vim_json_syntax_conceal=0

NeoBundle 'Lokaltog/vim-easymotion'
let g:EasyMotion_do_mapping = 0
nmap s <Plug>(easymotion-s2)

NeoBundle 'szw/vim-tags'
let g:vim_tags_project_tags_command = "/usr/local/bin/ctags -f .tags -R . 2>/dev/null"
let g:vim_tags_gems_tags_command = "/usr/local/bin/ctags -R -f .Gemfile.lock.tags `bundle show --paths` 2>/dev/null"
set tags+=.tags
set tags+=.Gemfile.lock.tags
" tagsジャンプの時に複数ある時は一覧表示
nnoremap <C-]> g<C-]>

NeoBundle 'Shougo/neocomplete'
if neobundle#tap('neocomplete')
  call neobundle#config({
  \   'depends': ['Shougo/context_filetype.vim', 'ujihisa/neco-look', 'pocke/neco-gh-issues', 'Shougo/neco-syntax'],
  \ })

  " 起動時に有効化
  let g:neocomplete#enable_at_startup = 1
  " 大文字が入力されるまで大文字小文字の区別を無視する
  let g:neocomplete#enable_smart_case = 1
  " _(アンダースコア)区切りの補完を有効化
  let g:neocomplete#enable_underbar_completion = 1
  let g:neocomplete#enable_camel_case_completion  =  1
  " ポップアップメニューで表示される候補の数
  let g:neocomplete#max_list = 20
  " シンタックスをキャッシュするときの最小文字長
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  " 補完を表示する最小文字数
  let g:neocomplete#auto_completion_start_length = 2
  " preview window を閉じない
  let g:neocomplete#enable_auto_close_preview = 0
  "AutoCmd InsertLeave * silent! pclose!

  let g:neocomplete#max_keyword_width = 10000

  if !exists('g:neocomplete#delimiter_patterns')
    let g:neocomplete#delimiter_patterns= {}
  endif
  let g:neocomplete#delimiter_patterns.ruby = ['::']

  if !exists('g:neocomplete#same_filetypes')
    let g:neocomplete#same_filetypes = {}
  endif
  let g:neocomplete#same_filetypes.ruby = 'eruby'

  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif

  let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
  let g:neocomplete#force_omni_input_patterns.typescript = '[^. \t]\.\%(\h\w*\)\?' " Same as JavaScript
  let g:neocomplete#force_omni_input_patterns.go = '[^. \t]\.\%(\h\w*\)\?'         " Same as JavaScript

  let s:neco_dicts_dir = $HOME . '/dicts'
  if isdirectory(s:neco_dicts_dir)
    let g:neocomplete#sources#dictionary#dictionaries = {
    \   'ruby': s:neco_dicts_dir . '/ruby.dict',
    \   'javascript': s:neco_dicts_dir . '/jquery.dict',
    \ }
  endif
  let g:neocomplete#data_directory = $HOME . '/.vim/cache/neocomplete'

  "call neocomplete#custom#source('look', 'min_pattern_length', 1)

  call neobundle#untap()
endif

NeoBundle 'Lokaltog/powerline'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'chriskempson/vim-tomorrow-theme'
" NeoBundle 'tomasr/molokai'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'tyru/open-browser-github.vim'

NeoBundle 'pangloss/vim-javascript'
NeoBundle 'mxw/vim-jsx'
NeoBundle 'slim-template/vim-slim'
NeoBundle 'digitaltoad/vim-jade'
NeoBundle 'wavded/vim-stylus'

" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck


" end NeoBundle -----

nmap q :q<CR>

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
set autoindent   " 改行時の半角スペース
set shiftwidth=2 " 改行時の半カススペースの文字数
set expandtab    " ソフトタブを有効にする
set tabstop=2    " ソフトタブは、半角スペース2文字

" ハイライトを有効にする
syntax enable

" カッコの対応を表示
set showmatch

" 末尾の空白削除
autocmd BufWritePre * :%s/\s\+$//e

" カラースキーマ
colorscheme Tomorrow-Night-Bright

" 256色
set t_Co=256

set noswapfile

" インサートモード時にバックスペースを使う
set backspace=indent,eol,start

" カーソル行のハイライト
set cursorline

