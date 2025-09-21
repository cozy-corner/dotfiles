#!/bin/bash

ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.ssh ~/.ssh
ln -sf ~/dotfiles/.ideavimrc ~/.ideavimrc
mkdir -p ~/.config/nvim
rm -f ~/.config/nvim/init.vim  # 古い設定を削除
ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/themes ~/.config/ghostty/themes
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/commands ~/.claude/commands

