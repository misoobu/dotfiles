# xxenv
export RBENV_ROOT=/usr/local/var/rbenv # TODO: not needed normally...
if which rbenv  > /dev/null; then eval "$(rbenv init -)";  fi
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi
if which pyenv  > /dev/null; then eval "$(pyenv init -)";  fi

# Source
source ~/dotfiles/.zshrc.alias
[ -f ~/.zshrc.secret ] && source ~/.zshrc.secret

# General
export EDITOR=vim
export LESS='-iMR'
export CLICOLOR=1
export LANG=en_US.UTF-8
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
TIMEFMT='elapsed time: %E, cpu percentage: %P'
REPORTTIME=10
bindkey -e

# Completion
if type brew &>/dev/null; then
  # https://docs.brew.sh/Shell-Completion
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi
if [ -e ~/.zsh/zsh-completions ]; then
  fpath=(~/.zsh/zsh-completions/src $fpath)
fi
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive

# Option
stty stop undef           # reclaim ctrl-q and ctrl-s
setopt no_flow_control    # reclaim ctrl-q and ctrl-s
setopt auto_cd            # cd if the command is the name of a directory
setopt auto_pushd         # automatically pushd when cd
setopt pushd_ignore_dups
setopt hist_reduce_blanks # remove unnecessary blanks when save history
setopt share_history
setopt prompt_subst       # for showing git info (see below)

# Function
function chpwd() { ls -aF } # ls after cd

function peco-select-history() {
  local tac
  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi
  BUFFER=$(\history -n 1 | \
    eval $tac | \
    awk '!a[$0]++' | \
    peco --query "$LBUFFER" --prompt '[select history]')
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N peco-select-history
bindkey '^r' peco-select-history

function _peco-find-file() {
  if git rev-parse 2> /dev/null; then
    source_files=$(git ls-files -co --exclude-standard)
  else
    source_files=$(find . -type f)
  fi
  echo $source_files | peco --prompt "[$1]"
}

function peco-find-file() {
  selected_files=$(_peco-find-file "select file")

  result=''
  for file in $selected_files; do
    result="${result}$(echo $file | tr '\n' ' ')"
  done

  BUFFER="${BUFFER}${result}"
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N peco-find-file
bindkey '^p' peco-find-file

function peco-find-file-and-open-with-vim() {
  file=$(_peco-find-file "select file for vim")
  if [ -n "$file" ]; then
    BUFFER="vim $file"
    zle accept-line
  fi
}
zle -N peco-find-file-and-open-with-vim
bindkey '^v' peco-find-file-and-open-with-vim

function peco-select-ghq() {
  selected_repo=$(ghq list | peco --prompt '[select ghq repo]')
  if [ -n "$selected_repo" ]; then
    BUFFER="${BUFFER}$(ghq root)/${selected_repo}"
    CURSOR=$#BUFFER
  fi
  zle redisplay
}
zle -N peco-select-ghq
bindkey '^g' peco-select-ghq

function git-grep-vim () {
  found=$(git grep -I --line-number -e $1 | peco --prompt '[select line to open]')
  if [ -n "$found" ]; then
    vim $(print "$found" | awk -F : '{print "-c " $2 " " $1}')
  fi
}

# Util
[ -d ~/.zsh/zsh-autosuggestions ]     && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -d ~/.zsh/zsh-syntax-highlighting ] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Git info
autoload -Uz colors && colors
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{green}+%f" # => %c
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+%f" # => %u
zstyle ':vcs_info:*' formats "%F{white}%b%f%c%u "
zstyle ':vcs_info:*' actionformats "%F{magenta}[%b|%a]%f "
precmd () { vcs_info }
PROMPT='%{$fg[yellow]%}%~ %{$reset_color%}${vcs_info_msg_0_}%{$fg[yellow]%}%# %{$reset_color%}'

# Lunch tmux on startup
[ -z $TMUX ] && tmn
