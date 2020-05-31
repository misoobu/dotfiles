#!/bin/sh -ex

ln -sf ~/dotfiles/.alacritty.yml ~/.alacritty.yml
mkdir -p ~/.bundle
ln -sf ~/dotfiles/.bundle_config ~/.bundle/config
ln -sf ~/dotfiles/.gemrc ~/.gemrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.gitignore ~/.gitignore
ln -sf ~/dotfiles/.tigrc ~/.tigrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.tmux.split.conf ~/.tmux.split.conf
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.zshrc.alias ~/.zshrc.alias

# You should install homebrew (https://brew.sh/), and run `brew bundle install`
