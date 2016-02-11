source ~/dotfiles/.zshrc.alias
[ -f ~/.zshrc.secret ] && source ~/.zshrc.secret

# node
[ -d ~/.nvm ] && source ~/.nvm/nvm.sh

# powerline
[ -d ~/.vim/bundle/powerline ] && source ~/.vim/bundle/powerline/powerline/bindings/zsh/powerline.zsh

if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

export SVN_EDITOR=vim
export EDITOR=vim

# 環境変数
export LC_ALL=ja_JP.UTF-8
export LANG=ja_JP.UTF-8
export LC_CTYPE=ja_JP.UTF-8

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

REPORTTIME=10

# for zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# 補完機能を有効にする
autoload -Uz compinit
compinit -u

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

# OS 別の設定
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        #Linux用の設定
        ;;
esac

# cdコマンド実行後、lsを実行する
function cd() {
  builtin cd $@ && ls;
}

# iTerm2のタブ名を変更する
function title {
  echo -ne "\033]0;"$*"\007"
}

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
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

function find-pr() {
  local parent=$2||'master'
  git log $1..$2 --merges --ancestry-path --reverse --oneline | head -n1
}

function find-pr-open() {
  local pr="$(find-pr $1 $2 | awk '{print substr($5, 2)}')"
  local repo="$(git config --get remote.origin.url | sed 's/git@github.com://' | sed 's/\.git$//')"
  open "https://github.com/${repo}/pull/${pr}"
}

function agvim () {
  vim $(ag $@ | peco --query "$LBUFFER" | awk -F : '{print "-c " $2 " " $1}')
}
alias agv='agvim'

function peco-find-file() {
    if git rev-parse 2> /dev/null; then
        source_files=$(git ls-files)
    else
        source_files=$(find . -type f)
    fi
    selected_files=$(echo $source_files | peco --prompt "[find file]")

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

_orig_bundle=$(which bundle)
function bundle() {
    if [ "$1" = "cd" ]; then
        local gem
        if [ "$2" ]; then
            gem=$2
        else
            gem=$($_orig_bundle list | awk '{ print $2 }' | percol)
        fi
        cd $($_orig_bundle show $gem)
    else
        $_orig_bundle $*
    fi
}

if [ -z $TMUX ]; then
  tm
fi

[ -d /usr/local/share/zsh-syntax-highlighting ] && source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
