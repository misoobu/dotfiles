" Visual
syntax enable
set number
set cursorline
set breakindent
set list
set listchars=tab:␉·

" Indent
set autoindent
set shiftwidth=2
set expandtab
set tabstop=4

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch
set shortmess-=S

" Util
nnoremap q :q<CR>
nnoremap <C-k> i<CR><ESC>
nnoremap <C-s> :w<CR>
nnoremap <C-c> :PrettierAsync<CR>
inoremap <C-s> <ESC>

" Grep
set shellpipe=>
set grepprg=git\ grep\ -I\ --line-number\ -e
nnoremap <C-g> :silent grep! <cword> \| cw \| redraw!<CR>
command! -nargs=+ GG silent grep! <q-args> | cw | redraw!

" Misc
set noswapfile
set backspace=indent,eol,start
set clipboard+=unnamed
" prevent @@@ for long line
set display=lastline
set completeopt=menu,menuone,popup,noselect,noinsert
set previewheight=6

let g:polyglot_disabled = ['csv']

" Plugin
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'

Plug 'itchyny/lightline.vim'
Plug 'sheerun/vim-polyglot'
Plug 'rhysd/vim-color-spring-night'

Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'for': ['javascript', 'typescript', 'typescriptreact', 'css', 'scss', 'json', 'markdown', 'yaml', 'ruby'] }

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-git', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-rust-analyzer', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-solargraph', {'do': 'yarn install --frozen-lockfile'}
Plug 'weirongxu/coc-explorer', {'do': 'yarn install --frozen-lockfile'}
call plug#end()

" Ctrlp
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_working_path_mode = 'w'

" Lightline
set laststatus=2
set noshowmode
set timeoutlen=50
let g:lightline = {
\  'colorscheme': 'one',
\  'active': {
\    'left': [ [ 'mode', 'paste' ],
\              [ 'readonly', 'filename' ],
\              [ 'modified' ] ],
\    'right': [ [ 'percent' ],
\               [ 'filetype' ],
\               [ 'cocstatus' ]],
\  },
\  'component_function': {
\    'filename': 'LightlineFilename',
\    'cocstatus': 'coc#status',
\  },
\}
function LightlineFilename()
  let path = expand('%:p')
  let path_len = strchars(path)
  let max_len = 45
  if path_len <= max_len
    return path
  endif
  return '⌇' . strcharpart(path, path_len-max_len, max_len)
endfunction

let g:prettier#config#print_width = 100

" Coc
set signcolumn=number
set updatetime=300
nnoremap <C-h> :call CocAction('doHover')<CR>
nmap <C-j> <Plug>(coc-definition)
command! -nargs=0 TypeDefinition :execute "normal \<Plug>(coc-type-definition)"
command! -nargs=0 Implementation :execute "normal \<Plug>(coc-implementation)"
command! -nargs=0 References :execute "normal \<Plug>(coc-references)"
command! -nargs=0 Rename :execute "normal \<Plug>(coc-rename)"
command! -nargs=0 Format :call CocAction('format')
call coc#config('coc.preferences', {
\  'jumpCommand': 'split',
\})
" for jsx/tsx syntax
call coc#config('typescript', {
\  'suggest.completeFunctionCalls': v:false,
\})
nmap <silent> <C-n> <Plug>(coc-diagnostic-next)
nmap <silent> <C-m> <Plug>(coc-diagnostic-prev)
nnoremap <C-e> :CocCommand explorer<CR>
call coc#config('explorer', {
\  'file.showHiddenFiles': v:true,
\})
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
let g:coc_user_config['suggest.noselect'] = v:true

" Autocmd
augroup MyAutocmds
  autocmd!
  " like ctrlp
  autocmd! FileType qf nnoremap <buffer> <C-x> <C-w><CR>
  " strip trailing spaces
  autocmd BufWritePre * :%s/\s\+$//e
  autocmd FileType gitcommit setlocal spell
  autocmd ColorScheme * call MyHighlights()
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END

" Color
function! MyHighlights() abort
  highlight Comment ctermfg=5
  highlight Pmenu ctermbg=238
  highlight link QuickFixLine Normal
  highlight! link Todo Comment
  highlight CocHighlightText ctermbg=17
  highlight CocWarningSign ctermfg=7
  " alacritty inverts cursor color
  highlight MatchParen ctermfg=yellow ctermbg=black
endfunction
colorscheme spring-night
