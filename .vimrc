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
nnoremap <C-k> i<CR><ESC>
nnoremap <C-s> :w<CR>
inoremap <C-s> <ESC>

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
set display=lastline " prevent @@@ for long line
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
" exec :PlugInstall after additions of plugins

Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

Plug 'airblade/vim-gitgutter'
set updatetime=100

Plug 'itchyny/lightline.vim'
set laststatus=2
set noshowmode
set timeoutlen=50 " for lightline
let g:lightline = {
\  'colorscheme': 'one',
\  'component_function': {
\    'filename': 'LightlineFilename',
\  }
\}
function! LightlineFilename() " https://github.com/itchyny/lightline.vim/issues/293
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

Plug 'itchyny/vim-cursorword'

Plug 'rhysd/vim-color-spring-night'

Plug 'sheerun/vim-polyglot'

Plug 'w0rp/ale'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_linters_explicit = 1
let g:ale_linters = {
\  'typescript': ['tsserver'],
\  'javascript': ['tsserver'],
\  'ruby': ['ruby', 'solargraph'],
\}
let g:ale_completion_enabled = 1
let g:ale_completion_tsserver_autoimport = 1
let g:ale_open_list = 1
set completeopt=menu,menuone,preview,noselect,noinsert " see https://github.com/w0rp/ale/commit/399a0d3c988381d2436d066e1fe74ef688947f28
nnoremap <C-h> :ALEHover<CR>
nnoremap <C-i> :ALEGoToDefinitionInSplit<CR>

call plug#end()

augroup TypeScriptCmd
  autocmd!
  autocmd BufRead,BufNewFile tsconfig.json set filetype=javascript " tsconfig has js-style comments
augroup END

augroup MyColor
  autocmd!
  autocmd ColorScheme * highlight Comment ctermfg=5
  autocmd ColorScheme * highlight! link Todo Comment
augroup END

colorscheme spring-night
