# alias
source ~/dotfiles/.zshrc.alias

# node
[ -d ~/.nvm ] && source ~/.nvm/nvm.sh

# ruby
if which rbenv > /dev/null; then eval "$(rbenv init - zsh)"; fi

# powerline
[ -d ~/.vim/bundle/powerline ] && source ~/.vim/bundle/powerline/powerline/bindings/zsh/powerline.zsh

export SVN_EDITOR=vim
# export EDITOR=vim

# ここから参考: https://gist.github.com/mollifier/4979906

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

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

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

# 全履歴
function history-all {
  history -E 1
}

