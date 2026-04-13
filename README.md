# dotfiles

macOS 向けの個人用 dotfiles。キーボード駆動の操作と Catppuccin Mocha テーマで統一。

## セットアップ

```bash
git clone git@github.com:cozy-corner/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` は各設定ファイルへのシンボリックリンクを作成する。

## 構成

| ディレクトリ / ファイル | 内容 |
|---|---|
| `.zshrc` | Zsh 設定。fzf / zoxide / atuin / direnv / mise 連携、git 関連関数群 |
| `.tmux.conf` | tmux 設定。prefix は `Ctrl-Q`、Vi キーバインド |
| `.gitconfig` | Git 設定。delta (side-by-side diff) |
| `.ideavimrc` | JetBrains IdeaVim 設定 |
| `user-abbreviations` | zsh-abbr の略語定義 |
| [`nvim/`](nvim/) | Neovim 設定 ([詳細](nvim/README.md)) |
| `ghostty/` | Ghostty ターミナル設定、カスタムカーソルシェーダー、テーマ |
| `aerospace/` | AeroSpace ウィンドウマネージャ設定 |
| `atuin/` | Atuin シェル履歴設定 |
| `claude/` | Claude Code の設定・カスタムコマンド・エージェント定義 |
| `gh/` | GitHub CLI 設定 |
| `tealdeer/` | tealdeer (tldr クライアント) 設定 |
| `doc/` | 技術メモ |

## 主なツール

- **シェル**: Zsh + [zsh-abbr](https://github.com/olets/zsh-abbr) + [fzf](https://github.com/junegunn/fzf) + [zoxide](https://github.com/ajeetdsouza/zoxide) + [atuin](https://github.com/atuinsh/atuin)
- **ターミナル**: [Ghostty](https://ghostty.org)
- **エディタ**: [Neovim](https://neovim.io)
- **ウィンドウマネージャ**: [AeroSpace](https://github.com/nikitabobko/AeroSpace)
- **Git**: [delta](https://github.com/dandavison/delta) + [CodeRabbit](https://coderabbit.ai)
- **AI**: [Claude Code](https://claude.ai/claude-code) (カスタムエージェント・コマンド付き)
- **その他**: mise, direnv, eza, tealdeer

