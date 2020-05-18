" Visual
syntax enable
set number " show line numbers
set cursorline
set breakindent
set list
set listchars=tab:␉·

" Indent
set autoindent
set shiftwidth=2
set expandtab

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

" QuickFix
augroup QuickFixCmd
  autocmd!
  autocmd! FileType qf nnoremap <buffer> <C-x> <C-w><CR> " this is like ctrlp
augroup END

" Misc
set noswapfile
set backspace=indent,eol,start " Make backspace usable at insert mode
set clipboard+=unnamed " Share clipboard with OS
set display=lastline " prevent @@@ for long line
set completeopt=menu,menuone,popup,noselect,noinsert
set previewheight=6
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
Plug 'preservim/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'itchyny/lightline.vim'
Plug 'rhysd/vim-color-spring-night'
Plug 'sheerun/vim-polyglot'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-git', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-rls', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-solargraph', {'do': 'yarn install --frozen-lockfile'}
call plug#end()

augroup TypeScriptCmd
  autocmd!
  autocmd BufRead,BufNewFile tsconfig.json set filetype=javascript " tsconfig has js-style comments
augroup END

function! MyHighlights() abort
  highlight Comment ctermfg=5
  highlight Pmenu ctermbg=238
  highlight link QuickFixLine Normal
  highlight! link Todo Comment
  highlight CocHighlightText ctermbg=17
  highlight CocWarningSign ctermfg=7
endfunction

augroup MyColors
  autocmd!
  autocmd ColorScheme * call MyHighlights()
augroup END

colorscheme spring-night

" lightline
set laststatus=2
set noshowmode
set timeoutlen=50
let g:lightline = {
\  'colorscheme': 'one',
\  'active': {
\    'left': [ [ 'mode', 'paste' ],
\              [ 'readonly', 'filename', 'modified', 'cocstatus' ] ]
\  },
\  'component_function': {
\    'filename': 'LightlineFilename',
\    'cocstatus': 'coc#status'
\  },
\}
function LightlineFilename()
  let path = expand('%:p')
  let path_len = strchars(path)
  let max_len = 35
  if path_len <= max_len
    return path
  endif
  return '≈' . strcharpart(path, path_len-max_len, max_len)
endfunction
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" coc
nnoremap <C-h> :call CocAction('doHover')<CR>
nmap <C-j> <Plug>(coc-definition)
command! -nargs=0 TypeDefinition :execute "normal \<Plug>(coc-type-definition)"
command! -nargs=0 Implementation :execute "normal \<Plug>(coc-implementation)"
command! -nargs=0 References :execute "normal \<Plug>(coc-references)"
command! -nargs=0 Rename :execute "normal \<Plug>(coc-rename)"
autocmd CursorHold * silent call CocActionAsync('highlight')
let g:coc_user_config = {}
let g:coc_user_config['coc.preferences.jumpCommand'] = 'split'
nmap <silent> <C-n> <Plug>(coc-diagnostic-next-error)
set signcolumn=yes
set updatetime=300

" others
map <C-e> :NERDTreeToggle<CR>
let g:NERDTreeShowHidden=1
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
