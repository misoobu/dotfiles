set -gx GOPATH ~/go
set -gx PATH $GOPATH/bin $PATH
set -gx PATH $HOME/bin $PATH
set -gx EDITOR vim

status --is-interactive; and source (rbenv init -|psub)

function ghq_cd
    ghq list --full-path | peco | read dist
    cd $dist
    commandline -f repaint
end

function peco_select_history
    if set -q $argv
        history | peco | read line; commandline $line
    else
        history | peco --query $argv | read line; commandline $line
    end
    commandline -f repaint
end

function peco_find_file
    if git rev-parse 2> /dev/null
        git ls-files | read -z source_files
    else
        find . -type f | read -z source_files
    end

    echo $source_files | peco | read selected_files

    commandline $selected_files
end

function fish_user_key_bindings
    bind \cg ghq_cd
    bind \cq peco_find_file
    bind \cr peco_select_history
end

alias vim="reattach-to-user-namespace vim"
alias v="vim"
alias e="exit"
alias l="ls -al"
alias c="clear"
alias be="bundle exec"
alias bbe="bin/bundle exec"
alias bber="bin/bundle exec rspec"
alias dk="docker"
alias dkc="docker-compose"

# git
alias g="git"
alias gs="git status"
alias gci="git commit"
alias gco="git checkout"
alias gd="git diff"
alias gdc="git diff --cached"
alias ga="git add"
alias gb="git branch"
alias gcom="git checkout master"
alias gg="git grep --line-number --heading --break -e"
alias gp="git pull"
alias gps="git push"
alias gf="git fetch --prune --all"
alias gcod="git checkout develop"
alias gcp="git cherry-pick"
alias t="tig"
alias grb="git rebase"
alias grbm="git fetch; and git rebase origin/master"
alias gsmu="git submodule update"
alias gpom="git push origin master"
alias gpod="git push origin develop"
alias gx="git add .; and git commit -m 'gx!'; and git reset --hard HEAD~"

# hub
alias h="hub"
alias hb="hub browse"
alias hc="hub compare"

# tmux
alias tmux="tmux -2"
alias tm="tmux"
alias tml="tmux ls"
alias tma="tmux attach -t"
alias tmr="tmux rename -t"

# peco
alias p="peco"

# global
#alias -g GB='`git branch -a | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
#alias -g LR='`git branch -a | peco --query "remotes/ " --prompt "GIT REMOTE BRANCH>" | head -n 1 | sed "s/^\*\s*//" | sed "s/remotes\/[^\/]*\/\(\S*\)/\1 \0/"`'
#alias -g L="| less"
#alias -g G="| grep"
#alias -g J="| jq ."

# mac
alias pbc="pbcopy"
alias pbp="pbpaste"
alias pb="pbpaste | pbcopy"
alias cot="open -a CotEditor"
alias o="open"
alias f="open ."
#alias -g C="| pbcopy"
