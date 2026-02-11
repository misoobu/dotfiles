# xxenv
if which direnv > /dev/null; then eval "$(direnv hook zsh)"; fi

# Source
source ~/.zshrc.alias
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# General
[[ -z "$EDITOR" ]] && export EDITOR="nvim"
export LESS='-iMR'
export CLICOLOR=1
export LANG=en_US.UTF-8
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
bindkey -e
disable r

# Completion
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}" # https://docs.brew.sh/Shell-Completion
  # FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive

# Option
stty stop undef           # reclaim ctrl-q and ctrl-s
setopt no_flow_control    # reclaim ctrl-q and ctrl-s
setopt auto_cd            # cd if the command is the name of a directory
setopt pushd_ignore_dups
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt prompt_subst       # for showing git info (see below)

# Function

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
    peco --selection-prefix ">" --query "$LBUFFER" --prompt '[select history]')
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
  echo $source_files | peco --selection-prefix ">" --prompt "[$1]"
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

function peco-select-ghq() {
  selected_repo=$(ghq list | peco --selection-prefix ">" --prompt '[select ghq repo]')
  if [ -n "$selected_repo" ]; then
    BUFFER="${BUFFER}$(ghq root)/${selected_repo}"
    CURSOR=$#BUFFER
  fi
  zle redisplay
}
zle -N peco-select-ghq
bindkey '^g' peco-select-ghq

function v () {
  if [ -z $NVIM ]; then
    nvim $1
  else
    case "$1" in
      /*) abs="$1" ;;
      ~*) abs="${HOME}${1#\~}" ;;
      *) abs="$(pwd)/$1" ;;
    esac

    abs="$(cd "$(dirname "$abs")" && pwd)/$(basename "$abs")"
    nvim --server "$NVIM" --remote "$abs"

  fi
}

function git-grep-replace() {
  # for mac
  git grep -I -l -e "$1" | xargs sed -i '' -e "s/$1/$2/g"
}

function ncd() {
  if [ -n "$1" ]; then
    cd "$1" || {
      echo "Failed to change directory to $1"
      return 1
    }
  fi

  nvim --server "$NVIM" --remote-send "<cmd>tcd $(pwd)<cr>"
}

# Util
if type brew &>/dev/null; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Git info
autoload -Uz colors && colors
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{green}+%f" # => %c
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+%f" # => %u
zstyle ':vcs_info:*' formats "%F{white}%b%f%c%u "
zstyle ':vcs_info:*' actionformats "%F{magenta}[%b|%a]%f "
PROMPT='%{$fg[yellow]%}%~ %{$reset_color%}${vcs_info_msg_0_}%{$fg[yellow]%}%# %{$reset_color%}'

function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  vcs_info

  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    if [ "$timer_show" -lt "3" ]; then
      export RPROMPT=""
    else
      export RPROMPT="%F{cyan}${timer_show}s%{$reset_color%}"
    fi
    unset timer
  else
    export RPROMPT=""
  fi
}

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
