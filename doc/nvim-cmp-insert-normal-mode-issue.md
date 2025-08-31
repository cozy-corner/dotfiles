# nvim-cmpと挿入ノーマルモード（C-o）の問題

## 問題の症状

### 現象
- 挿入モードで`C-o`を押すと正常に挿入ノーマルモード（`-- insert --`）に入る
- しかし、その後の2文字コマンド（`zz`、`dd`、`gg`など）が実行されず、文字として挿入される
- 1文字コマンド（`j`、`k`、`x`など）は正常動作

### 影響を受けるコマンド例
- `C-o zz` - 画面中央へのスクロール（動作せず、"zz"が挿入される）
- `C-o dd` - 行削除（動作せず、"dd"が挿入される）  
- `C-o gg` - ファイル先頭への移動（動作せず、"gg"が挿入される）

## 調査過程

### 1. 切り分けテスト

#### テスト1: 最小構成（プラグインなし）
```bash
nvim -u test_minimal_long.vim
```
**結果**: `C-o zz`が正常動作 ✓

#### テスト2: nvim-cmpのみ
```bash
nvim -u test_cmp_only.lua test_minimal_long.vim
```
**結果**: `zz`が文字として挿入される ✗

#### テスト3: nvim-cmpを除外した設定
```bash
nvim -u test_without_cmp.lua test_minimal_long.vim
```
**結果**: `C-o zz`が正常動作 ✓

### 2. 原因の特定
- **確定**: nvim-cmpが原因
- **パターン**: 1文字コマンドは動作、2文字コマンドは動作しない

## 試した解決策と結果

### 1. `mapping.preset.insert()`を`cmp.mapping()`に置き換え
```lua
cmp.setup({
  mapping = cmp.mapping({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
})
```
**結果**: 効果なし ✗

### 2. 挿入ノーマルモードでnvim-cmpを無効化
```lua
enabled = function()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match('^ni') then
    return false
  end
  return true
end,
```
**結果**: 効果なし ✗

### 3. 自動補完を無効化
```lua
completion = {
  autocomplete = false,
},
```
**結果**: 効果なし ✗

### 4. パフォーマンス設定の調整
```lua
performance = {
  debounce = 0,
  throttle = 0,
  fetching_timeout = 200,
},
```
**結果**: 効果なし ✗

## 根本原因

### わかっていること
1. nvim-cmpが挿入ノーマルモードでの2文字コマンドを妨害している
2. プラグインを除外すれば正常動作する
3. 設定変更では解決できない

### わかっていないこと
- **なぜ**nvim-cmpが2文字コマンドを妨害するのか
- **どのコード**が実際に干渉しているのか
- **なぜ**設定変更が効果がないのか

### 推測（未確認）
- `mapping.preset.insert()`の隠れたキーマッピングが原因？
- `TextChangedI`イベント処理が干渉？
- nvim-cmpの内部的なキー入力処理メカニズムの問題？

## 関連情報

### 参考にしたGitHub Issues
- [Issue #895: Discussion: why removing default mappings?](https://github.com/hrsh7th/nvim-cmp/issues/895)
- [Issue #463: Custom key mappings not merged with default mappings](https://github.com/hrsh7th/nvim-cmp/issues/463)
- [Issue #459: <Plug>(cmp.utils.keymap.recursive: ) is written on <Tab>](https://github.com/hrsh7th/nvim-cmp/issues/459)
- [LazyVim Discussion #3744: Keybindings for nvim-cmp automatically added?](https://github.com/LazyVim/LazyVim/discussions/3744)

**注**: `C-o zz`の具体的な問題を扱ったissueは見つからなかった

### web上の情報
- [Do you know Vim can execute normal mode command while in insert mode?](https://dev.to/iggredible/vim-do-you-know-that-you-can-execute-normal-mode-command-while-in-insert-mode-1ipb)
  - この記事では`C-o zz`が動作すると記載されている（素のVimでは正常動作することを示唆）

## 代替プラグインの選択肢

nvim-cmpの代わりに検討できる補完プラグイン：

1. **mini.completion** - ミニマルで軽量、設定がシンプル
2. **coq_nvim** - 高機能だがPython依存
3. **ddc.vim** - Denoベース、日本製
4. **coc.nvim** - VSCode風だが重い
5. **YouCompleteMe** - 老舗だがインストールが複雑

## 現在の状況

2024年8月31日時点で、この問題は**未解決**。nvim-cmpを使い続ける場合は、挿入ノーマルモードでの2文字コマンドが使えないことを受け入れるか、代替プラグインへの移行を検討する必要がある。

## 回避策

現時点での回避策：
1. `Esc`でノーマルモードに完全に戻ってからコマンドを実行
2. 2文字コマンドの代わりに別のキーマッピングを定義
3. nvim-cmpを他の補完プラグインに置き換える