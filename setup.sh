#!/bin/sh -ex

ln -s ~/dotfiles/.alacritty.toml ~/.alacritty.toml
mkdir -p ~/.bundle
ln -s ~/dotfiles/.bundle_config ~/.bundle/config
ln -s ~/dotfiles/.gemrc ~/.gemrc
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.tmux.split.conf ~/.tmux.split.conf
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.zprofile ~/.zprofile
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zshrc.alias ~/.zshrc.alias
ln -s ~/dotfiles/nvim ~/.config/
ln -s ~/dotfiles/.fdignore ~/.fdignore
mkdir -p ~/.claude
ln -s ~/dotfiles/.CLAUDE_global.md ~/.claude/CLAUDE.md

# You should install homebrew (https://brew.sh/), and run `brew bundle install`
