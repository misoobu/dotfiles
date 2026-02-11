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

# Prompt colors
typeset -g PROMPT_COLOR_PATH='%F{75}'
typeset -g PROMPT_COLOR_BRANCH='%F{252}'
typeset -g PROMPT_COLOR_STAGED='%F{70}'
typeset -g PROMPT_COLOR_UNSTAGED='%F{214}'
typeset -g PROMPT_COLOR_ACTION='%F{220}'
typeset -g PROMPT_COLOR_ERROR='%F{196}'
typeset -g PROMPT_COLOR_TIMER='%F{81}'
typeset -g PROMPT_COLOR_MARK='%F{244}'

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "${PROMPT_COLOR_STAGED}+%f" # => %c
zstyle ':vcs_info:git:*' unstagedstr "${PROMPT_COLOR_UNSTAGED}+%f" # => %u
zstyle ':vcs_info:*' formats "${PROMPT_COLOR_BRANCH}%b%f%c%u"
zstyle ':vcs_info:*' actionformats "${PROMPT_COLOR_ACTION}[%b|%a]%f"
PROMPT_FULL='${PROMPT_COLOR_PATH}%~%f${vcs_info_msg_0_:+ ${vcs_info_msg_0_}}${prompt_error}${prompt_timer}
${PROMPT_COLOR_MARK}$ %f'
PROMPT_TRANSIENT='${PROMPT_COLOR_MARK}$ %f'
PROMPT="$PROMPT_FULL"

if (( $+widgets[zle-line-init] )); then
  zle -A zle-line-init __prompt_original_zle_line_init
fi
if (( $+widgets[zle-line-finish] )); then
  zle -A zle-line-finish __prompt_original_zle_line_finish
fi

function zle-line-init() {
  if (( $+widgets[__prompt_original_zle_line_init] )); then
    zle __prompt_original_zle_line_init
  fi

  PROMPT="$PROMPT_FULL"
  zle reset-prompt
}
zle -N zle-line-init

function zle-line-finish() {
  if (( $+widgets[__prompt_original_zle_line_finish] )); then
    zle __prompt_original_zle_line_finish
  fi

  PROMPT="$PROMPT_TRANSIENT"
  zle reset-prompt
}
zle -N zle-line-finish

function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  local last_status=$?
  vcs_info
  prompt_error=""
  prompt_timer=""

  if (( last_status != 0 )); then
    prompt_error=" ${PROMPT_COLOR_ERROR}exit:${last_status}%f"
  fi

  if [[ -n $timer ]]; then
    local timer_show=$((SECONDS - timer))
    if (( timer_show >= 3 )); then
      prompt_timer=" ${PROMPT_COLOR_TIMER}${timer_show}s%f"
    fi
    unset timer
  fi
}

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
