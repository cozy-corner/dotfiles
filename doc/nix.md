# Nix (Home Manager) の運用

CLI ツールは `nix/home.nix` の `home.packages`、GUI アプリは `Brewfile` で管理する。
flake は `getEnv` と `currentSystem` を使うため、`home-manager switch` には毎回 `--impure` を付ける。

## 適用

```bash
home-manager switch --impure --flake ~/dotfiles/nix#default
```

flake は Git が追跡しているファイルしか見ない。`nix/` にファイルを追加したら、switch の前に `git add` する。

## パッケージの追加・削除

`nix/home.nix` の `home.packages` を編集して、適用する。unfree のパッケージは、`nix/flake.nix` の `allowUnfreePredicate` に名前を追加する。

## 更新

```bash
nix flake update --flake ~/dotfiles/nix     # nixpkgs / home-manager の lock を更新
home-manager switch --impure --flake ~/dotfiles/nix#default
sudo determinate-nixd upgrade              # Nix 本体
```

更新した `nix/flake.lock` はコミットする。

## ロールバック

```bash
home-manager generations            # 世代の一覧
home-manager switch --rollback      # 直前の世代に戻す
```

lock の更新を取り消すには、`git restore nix/flake.lock`（コミット済みなら `git revert`）を実行してから switch する。

## ガベージコレクション

```bash
home-manager expire-generations "-30 days"   # 30 日より古い世代を削除
nix-collect-garbage -d                       # 参照されなくなった store path を削除
```

`nix-collect-garbage -d` は古い世代をすべて消すので、実行するとそれ以前の世代にはロールバックできなくなる。

## アンインストール

```bash
/nix/nix-installer uninstall
```
