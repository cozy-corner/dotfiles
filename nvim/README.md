# Neovim

プラグインマネージャは [lazy.nvim](https://github.com/folke/lazy.nvim)。Leader キーは `Space`。

## プラグイン

| プラグイン | 用途 |
|---|---|
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | カラースキーム (Mocha) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | シンタックスハイライト (auto_install 有効) |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | ファジーファインダー |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP クライアント設定 |
| [mason.nvim](https://github.com/williamboman/mason.nvim) + mason-lspconfig | LSP サーバー管理 |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | 補完エンジン (LSP + パス) |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | ファイルエクスプローラー |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | キーバインドヘルプ表示 |
| [flash.nvim](https://github.com/folke/flash.nvim) | 高速カーソル移動 |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | 囲み文字の操作 |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | コメントトグル |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Markdown リッチ表示 |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | ブラウザプレビュー (Mermaid 対応) |
| [csvview.nvim](https://github.com/hat0uma/csvview.nvim) | CSV テーブル表示 |

## LSP サーバー (Mason)

`lua_ls`, `ts_ls`, `pyright`, `rust_analyzer`, `kotlin_language_server`, `fsautocomplete`

## キーバインド

### 一般

| キー | 動作 |
|---|---|
| `jj` (Insert) | ESC |
| `kj` (Visual) | ESC |
| `[b` / `]b` | 前/次のバッファ |
| `%%` (コマンドライン) | 現在のファイルのディレクトリに展開 |

### Telescope (`<Leader>f` グループ)

| キー | 動作 |
|---|---|
| `<Leader>ff` | ファイル検索 |
| `<Leader>fg` | テキスト検索 (live grep) |
| `<Leader>fb` | バッファ一覧 |
| `<Leader>fh` | ヘルプタグ |
| `<Leader>fr` | 最近のファイル |
| `<Leader>/` | 現在のバッファ内検索 |

### Git (`<Leader>g` グループ)

| キー | 動作 |
|---|---|
| `<Leader>gc` | コミット履歴 |
| `<Leader>gs` | Git status |
| `<Leader>gb` | ブランチ一覧 |

### LSP

| キー | 動作 |
|---|---|
| `gd` / `gD` | 定義 / 宣言にジャンプ |
| `gi` / `gr` | 実装 / 参照一覧 |
| `K` | ホバー情報 |
| `<Leader>rn` | リネーム |
| `<Leader>ca` | コードアクション |
| `<Leader>cf` | フォーマット |
| `[d` / `]d` | 前/次の診断 |

### ファイルエクスプローラー

| キー | 動作 |
|---|---|
| `<Leader>e` | NvimTree トグル |
| `<Leader>fe` | 現在のファイルを表示 |

### Flash

| キー | 動作 |
|---|---|
| `s` | Flash ジャンプ |
| `S` | Flash Treesitter |

### Markdown

| キー | 動作 |
|---|---|
| `<Leader>mp` | ブラウザプレビュー開始 |
| `<Leader>ms` | プレビュー停止 |
