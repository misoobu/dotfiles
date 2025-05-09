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
    BUFFER="n $file"
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
  found=$(git grep -I --line-number -e $1 | cut -c 1-200 | peco --prompt '[select line to open]')
  if [ -n "$found" ]; then
    nvim $(print "$found" | head -n 1 | awk -F : '{print "-c " $2 " " $1}')
  fi
}

function v () {
  if [ -z $NVIM ]; then
    nvim $1
  else
    nvim --server $NVIM --remote $1
  fi
}

function vt () {
  nvim --server $NVIM --remote-send "<cmd>terminal $*<cr>"
}

function git-grep-replace() {
  # for mac
  git grep -I -l -e "$1" | xargs sed -i '' -e "s/$1/$2/g"
}

# https://github.com/h-matsuo/macOS-trash
function move-to-trash() {
  # for mac
  for NAME in "${@}"; do
    if [ ! -e $NAME ]; then
      echo not found: $NAME
      break
    fi

    TARGET=$(cd $(dirname $NAME); pwd)/$(basename $NAME)

    echo removing: $TARGET

    osascript -e """
    tell application \"Finder\"
        move POSIX file \"${TARGET}\" to trash
    end tell
    """ > /dev/null
  done
}

function ncd() {
  if [ -n "$1" ]; then
    cd "$1" || {
      echo "Failed to change directory to $1"
      return 1
    }
  fi

  nvim --server "$NVIM" --remote-send "<cmd>cd $(pwd)<cr>"
}

# List diagnostics (errors, warnings, etc.) from Neovim for a specific file
ndiagnose() {
  local file=$1
  if [[ -z $file ]]; then
    echo "Usage: ndiagnose <file>" >&2
    return 1
  fi

  local expr
  expr="luaeval(\"(function(path) \
      local bufnr = vim.fn.bufnr(path, true); \
      vim.fn.bufload(bufnr); \
      vim.wait(500, function() return #vim.diagnostic.get(bufnr) > 0 end, 50); \
      local sev={[1]='Error',[2]='Warn',[3]='Info',[4]='Hint'}; \
      local out={}; \
      for _,d in ipairs(vim.diagnostic.get(bufnr)) do \
        table.insert(out, string.format('%s:%d:%d [%s] %s', \
          vim.fn.fnamemodify(path,':.'), d.lnum+1, d.col, \
          sev[d.severity], d.message)); \
      end; \
      return table.concat(out, '\\\\n'); \
    end)('$file')\")"

  local result
  result=$(nvim --headless --server "$NVIM" --remote-expr "$expr")

  if [[ -n $result ]]; then
    printf '%s\n' "$result"
  else
    echo "Success: No diagnostics."
  fi
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

# Lunch tmux/nvim on startup
if [ -z $TMUX ]; then
  tmn
else
  [ -z $NVIM ] && nvim
fi

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
