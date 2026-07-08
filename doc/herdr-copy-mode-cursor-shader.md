# herdr のコピーモードで Ghostty カーソルシェーダー（smear）が効かない

## 環境

### システム
- **OS**: macOS (Darwin 24.6.0, Apple Silicon)

### 関連ツール
- **Ghostty**: `custom-shader = ~/.config/ghostty/shaders/cursor_smear_fade.glsl`（`ghostty/config`）
- **herdr**: 0.7.3（Homebrew, stable）
- **tmux**: prefix = `C-q`, `mode-keys vi`（`.tmux.conf`）
- **ペイン内で動かすもの**: Claude Code

### 調査日
- 2026年7月8日

## 問題の症状

herdr のペイン内で、Ghostty のカーソルシェーダー（smear）が **コピーモードのときだけ効かない**。通常モードでは効く。

| 環境 | 通常時 | コピーモード（prefix+`[`） |
|---|---|---|
| tmux + Claude Code | ✅ 出る | ✅ 出る |
| herdr + Claude Code（0.7.3） | ✅ 出る | ❌ 出ない |

- tmux はコピーモードでも smear が出る。
- herdr はコピーモードに入ると smear が消える。これは 0.7.3 更新前から。

## 切り分けの経緯

観測データを消去法で整理:

- **tmux + Claude Code → ✅**: Claude Code は「見える・動く実カーソル」を持つ。→「Claude Code がカーソルを隠すから」説は誤り。
- **herdr + vim（通常編集）→ ✅**: herdr は実カーソルをホスト Ghostty に転送できている。→「herdr の再描画が常にカーソルを潰す」説も誤り。
- **herdr + Claude Code 通常時 → ✅ / コピーモード → ❌**: 壊れるのは **herdr のコピーモード固有**。

（途中で疑った「Claude Code が `?25l` でカーソルを隠す説」「vim ノーマルモード（ctrl+[）説」はいずれも的外れだった。`ctrl+[` は `prefix+[` = コピーモード起動の意味だった。）

## 根本原因

コピーモードで動いているカーソルの「実体」が tmux と herdr で違う。

### 通常モード（両者共通）
見えているカーソル = 内側プログラム（Claude Code）が端末に出している本物のカーソル。herdr はそのペインのカーソル位置/表示状態をホスト端末の実カーソルに中継する経路を持つ（`write_host_cursor_state` 系, 参照: herdr #149）。→ ホスト実カーソルが動く → シェーダーが animate する。

### tmux のコピーモード
コピーモードのキャレットを **実端末のハードウェアカーソルそのもの**として実装。ナビゲート時に実際にカーソルを移動・表示する。→ 通常時と同じく実カーソルが動く → シェーダー ✅。

### herdr のコピーモード
コピーモードのキャレットは、内側プログラムのカーソルではなく **herdr の UI レイヤーだけに存在する選択キャレット**。herdr は合成フレーム内に「ハイライトしたセル」として描画するだけで、**ホスト端末の実カーソルには反映しない**（通常ペインのカーソル転送経路とは別コードパスで、そこに繋がっていない）。→ ホスト実カーソルが動かない → シェーダーが掴む対象が無い → ❌。

### まとめ

| | カーソルの実体 | ホスト実カーソル | shader |
|---|---|---|---|
| 通常モード（両者） | 内側プログラムの端末カーソル | 反映される | ✅ |
| tmux コピーモード | 実端末カーソルそのもの | 動く | ✅ |
| herdr コピーモード | herdr UI 内のキャレット（描画物） | 反映されない | ❌ |

設計思想の差。tmux は「コピーモードのカーソル = 実カーソル」、herdr は「コピーモードのカーソル = 自前描画の UI 要素」。herdr がフルスクリーン合成レンダラで全部自分で描く構造ゆえ、herdr ネイティブのコピーモードのキャレットをホスト実カーソルまで橋渡しする実装が（まだ）入っていない。

## 現在の状況（未解決 / ユーザ側では直せない）

herdr 側の対応待ち。Ghostty / ghostty config / neovim 側では直せない（実カーソルをホストに出すのは herdr の責務）。

参考: herdr の関連 issue は「コピーモードの単語境界・CJK・選択挙動」ばかりで、**「コピーモードのカーソルをホストに転送して cursor shader を効かせる（tmux 同等）」という issue は未提出**。立てる価値あり。骨子:

> **Title:** Copy-mode cursor not forwarded to host terminal — breaks Ghostty cursor shaders (tmux parity)
> **Current:** In copy mode, herdr paints its own highlighted-cell cursor and doesn't move the host terminal's real cursor, so Ghostty custom cursor shaders (smear/blaze) don't animate. Normal (non-copy) mode works.
> **Expected:** Like tmux copy-mode-vi, forward the copy-mode cursor position to the host real cursor so cursor shaders animate.
> **Repro:** Ghostty + `custom-shader = cursor_smear_fade.glsl`; enter copy mode (prefix+`[`), move with vi keys → no smear. Same in tmux copy-mode → smear works.

## 関連情報

- herdr #149: Optional IME anchor exposure for inner panes that hide the native cursor（herdr が `?25l`・カーソル状態をホストへ転送する仕組みの根拠）
- herdr #696 / #695: Cursor shape (DECSCUSR) not forwarded to host terminal（カーソル状態の非転送系統の前例）
- herdr #930 / #967: agent 稼働中のカーソルフリッカ（synchronized output 未対応）→ v0.7.2 / v0.7.3 で修正。※本件（コピーモード）とは別問題
- Ghostty カーソルシェーダー: https://github.com/KroneCorylus/ghostty-shader-playground
