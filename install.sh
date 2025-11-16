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
mkdir -p ~/.config/ghostty
rm -rf ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
rm -rf ~/.config/ghostty/themes
ln -sf ~/dotfiles/ghostty/themes ~/.config/ghostty/themes
rm -rf ~/.config/ghostty/shaders
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
mkdir -p ~/.config
ln -sf ~/dotfiles/aerospace ~/.config/aerospace
mkdir -p ~/.claude
rm -rf ~/.claude/commands
ln -sf ~/dotfiles/claude/commands ~/.claude/commands
rm -rf ~/.claude/agents
ln -sf ~/dotfiles/claude/agents ~/.claude/agents
rm -f ~/.claude/settings.local.json
ln -sf ~/dotfiles/claude/settings.local.json ~/.claude/settings.local.json

# Install CodeRabbit CLI
if ! command -v coderabbit &> /dev/null; then
    echo "Installing CodeRabbit CLI..."
    curl -fsSL https://cli.coderabbit.ai/install.sh | sh
else
    echo "CodeRabbit CLI is already installed"
fi

