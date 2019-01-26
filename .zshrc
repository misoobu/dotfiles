export RBENV_ROOT=/usr/local/var/rbenv # TODO: not needed normally...
if which rbenv  > /dev/null; then eval "$(rbenv init -)";  fi
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi
if which pyenv  > /dev/null; then eval "$(pyenv init -)";  fi

source ~/dotfiles/.zshrc.alias
[ -f ~/.zshrc.secret ] && source ~/.zshrc.secret

export EDITOR=vim
export LESS='-iMR'
export CLICOLOR=1
export LANG=en_US.UTF-8

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

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

# Options
setopt no_flow_control    # I use ^Q for another func (see below)
setopt auto_cd            # cd if the command is the name of a directory
setopt auto_pushd         # automatically pushd when cd
setopt pushd_ignore_dups
setopt hist_reduce_blanks # remove unnecessary blanks when save history
setopt prompt_subst       # for showing git info (see below)

# Functions
function chpwd() { ls -F } # ls after cd

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

function peco-find-file() {
  if git rev-parse 2> /dev/null; then
    source_files=$(git ls-files -co --exclude-standard)
  else
    source_files=$(find . -type f)
  fi
  selected_files=$(echo $source_files | peco --prompt "[select file]")

  result=''
  for file in $selected_files; do
    result="${result}$(echo $file | tr '\n' ' ')"
  done

  BUFFER="${BUFFER}${result}"
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N peco-find-file
bindkey '^q' peco-find-file

function peco-select-ghq() {
  selected_repo=$(ghq list | peco --prompt '[select ghq repo]')
  if [ -n "$selected_repo" ]; then
    BUFFER="$(ghq root)/${selected_repo}"
    CURSOR=$#BUFFER
  fi
  zle redisplay
}
zle -N peco-select-ghq
bindkey '^g' peco-select-ghq

function ggvim () {
  found=$(git grep --line-number -e $1 | peco --prompt '[select line to open]')
  if [ -n "$found" ]; then
    vim $(print "$found" | awk -F : '{print "-c " $2 " " $1}')
  fi
}

# Utils
[ -d ~/.zsh/zsh-autosuggestions ]     && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -d ~/.zsh/zsh-syntax-highlighting ] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Git info
autoload -Uz colors && colors # black red green yellow blue magenta cyan white
autoload -Uz vcs_info # %b ブランチ情報 / %a アクション名(mergeなど) / %c changes / %u uncommit
zstyle ':vcs_info:git:*' check-for-changes true    # formats 設定項目で %c,%u が使用可
zstyle ':vcs_info:git:*' stagedstr "%F{green}!"    # commit されていないファイルがある
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"    # add されていないファイルがある
zstyle ':vcs_info:*' formats "%F{white}%c%u(%b)%f" # 通常
zstyle ':vcs_info:*' actionformats '[%b|%a]'       # rebase 途中,merge コンフリクト等 formats 外の表示
precmd () { vcs_info }
function prompt-git-info-MSB {
  if [ ! -e  ".git" ]; then
    return
  fi
  echo "${vcs_info_msg_0_} " # for this tail-space
}
PROMPT='%{$fg[yellow]%}%~ %{$reset_color%}`prompt-git-info-MSB`%{$fg[yellow]%}%# %{$reset_color%}'

# Lunch tmux on startup
[ -z $TMUX ] && tmux -2
