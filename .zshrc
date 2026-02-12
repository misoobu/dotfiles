# Sources
source ~/.zshrc.alias
source ~/.zshrc.prompt
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# General
export EDITOR="nvim"    # use nvim as default editor
export LESS='-iMR'      # less: smart case search, verbose prompt, keep colors
HISTFILE=~/.zsh_history # zsh history file location
HISTSIZE=1000000        # max history entries kept in memory
SAVEHIST=1000000        # max history entries written to disk
disable r               # disable `r` history rerun shortcut

# Options
stty stop undef             # disable terminal XOFF binding on Ctrl-S
setopt no_flow_control      # keep Ctrl-S/Ctrl-Q for shell keybindings
setopt auto_cd              # `dir` behaves like `cd dir`
setopt share_history        # share history across all open zsh sessions
setopt hist_ignore_all_dups # remove older duplicates when adding history
setopt hist_ignore_space    # do not save commands that start with a space

# Functions

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

# Utils
if type brew &>/dev/null; then
  # Completion
  autoload -Uz compinit && compinit # https://docs.brew.sh/Shell-Completion
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive

  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
