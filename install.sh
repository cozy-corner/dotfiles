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
ln -sf ~/dotfiles/nvim/markdown.css ~/.config/nvim/markdown.css
mkdir -p ~/.config/ghostty
rm -rf ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
rm -rf ~/.config/ghostty/themes
ln -sf ~/dotfiles/ghostty/themes ~/.config/ghostty/themes
rm -rf ~/.config/ghostty/shaders
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
mkdir -p ~/.config
rm -rf ~/.config/aerospace
ln -sf ~/dotfiles/aerospace ~/.config/aerospace
mkdir -p ~/.config/gh
rm -f ~/.config/gh/config.yml
ln -sf ~/dotfiles/gh/config.yml ~/.config/gh/config.yml
mkdir -p ~/.claude
rm -f ~/.claude/commands
ln -sf ~/dotfiles/claude/commands ~/.claude/commands
rm -f ~/.claude/agents
ln -sf ~/dotfiles/claude/agents ~/.claude/agents
rm -f ~/.claude/rules
ln -sf ~/dotfiles/claude/rules ~/.claude/rules
rm -f ~/.claude/settings.json
ln -sf ~/dotfiles/claude/settings.json ~/.claude/settings.json
rm -f ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
rm -f ~/.claude/statusline-command.sh
ln -sf ~/dotfiles/claude/statusline-command.sh ~/.claude/statusline-command.sh

# tealdeer
mkdir -p ~/.config/tealdeer
rm -f ~/.config/tealdeer/config.toml
ln -sf ~/dotfiles/tealdeer/config.toml ~/.config/tealdeer/config.toml

# atuin
mkdir -p ~/.config/atuin
rm -f ~/.config/atuin/config.toml
ln -sf ~/dotfiles/atuin/config.toml ~/.config/atuin/config.toml

# zsh-abbr: .zshrcでABBR_USER_ABBREVIATIONS_FILEを直接指定するためsymlinkは不要

# Install CodeRabbit CLI
if ! command -v coderabbit &> /dev/null; then
    echo "Installing CodeRabbit CLI..."
    curl -fsSL https://cli.coderabbit.ai/install.sh | sh
else
    echo "CodeRabbit CLI is already installed"
fi

