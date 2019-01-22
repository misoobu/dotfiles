export RBENV_ROOT=/usr/local/var/rbenv # TODO: not needed normally...
if which rbenv  > /dev/null; then eval "$(rbenv init -)";  fi
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi
if which pyenv  > /dev/null; then eval "$(pyenv init -)";  fi

source ~/dotfiles/.zshrc.alias
[ -f ~/.zshrc.secret ] && source ~/.zshrc.secret

export EDITOR=vim
export LESS='-iMR'
export CLICOLOR=1
export LANG=ja_JP.UTF-8

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

REPORTTIME=10

bindkey -e

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# フローコントロールを無効にする
setopt no_flow_control

# '#' 以降をコメントとして扱う
setopt interactive_comments

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd

# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

# = の後はパス名として補完する
setopt magic_equal_subst

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 補完候補が複数あるときに自動的に一覧表示する
setopt auto_menu

# 高機能なワイルドカード展開を使用する
setopt extended_glob

# ls after cd
function chpwd() { ls -F }

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

function peco-ssh() {
  SSH=$(grep "^\s*Host " ~/.ssh/config | sed s/"[\s ]*Host "// | grep -v "^\*$" | sort | peco)
  ssh $SSH
}

function ggvim () {
  found=$(git grep --line-number -e $1 | peco --prompt '[select line to open]')
  if [ -n "$found" ]; then
    vim $(print "$found" | awk -F : '{print "-c " $2 " " $1}')
  fi
}

function bundle_cd() {
  local gem
  if [ "$1" ]; then
    gem=$1
  else
    gem=$(bundle list | awk '{ print $1 }' | peco)
  fi
  cd $(bundle show $gem)
}

if [ -e ~/.zsh/zsh-completions ]; then
  fpath=(~/.zsh/zsh-completions/src $fpath)
fi
[ -d ~/.zsh/zsh-autosuggestions ]     && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -d ~/.zsh/zsh-syntax-highlighting ] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Visual
autoload -Uz colors # black red green yellow blue magenta cyan white
colors
setopt prompt_subst

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
