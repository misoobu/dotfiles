if [ -d $HOME/.nvm ]; then
  source $HOME/.nvm/nvm.sh
fi

export PATH=/usr/local/bin:/usr/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init - zsh)"

export SVN_EDITOR=vim

# 参考 https://gist.github.com/mollifier/4979906
########################################
# 環境変数
export LANG=ja_JP.UTF-8

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# for zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# 補完
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

########################################
# オプション
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

########################################
# キーバインド

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

########################################
# エイリアス

alias mkdir='mkdir -p'
alias r='rails'
alias g='git'
alias cot='open -g -a "CotEditor"'
alias gs='git status'
alias gci='git commit'
alias gco='git checkout'
alias gd='git diff'
alias ga='git add'
alias gb='git branch'
alias gl='git log'
alias gcom='git checkout master'
alias t='tig'
alias v='vim'
alias e='exit'
alias gr="grep -r"
alias o="open"
alias l="ls -al"
alias c="clear"
alias gg="git grep --line-number --heading --break -e"
alias gp="git pull"
alias gf="git fetch --prune"
alias gcod="git checkout develop"
alias gcp="git cherry-pick"

alias tmux="tmux -2"
alias tm="tmux"
alias tml="tmux ls"
alias tma="tmux attach -t"
alias tmr="tmux rename -t"

alias be="bundle exec"

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

# .. で一つ上にいけるので、同じように
alias ...='cd ../..'
alias ....='cd ../../..'

# C で標準出力をクリップボードにコピーする
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if which pbcopy >/dev/null 2>&1 ; then
    # Mac
    alias -g C='| pbcopy'
elif which xsel >/dev/null 2>&1 ; then
    # Linux
    alias -g C='| xsel --input --clipboard'
elif which putclip >/dev/null 2>&1 ; then
    # Cygwin
    alias -g C='| putclip'
fi

########################################
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

#######################################
# iTerm2のタブ名を変更する
function title {
  echo -ne "\033]0;"$*"\007"
}

# かっこよくする！
source ~/.vim/bundle/powerline/powerline/bindings/zsh/powerline.zsh
