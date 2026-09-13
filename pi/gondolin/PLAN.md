# gondolin 開発環境の整備計画

pi のツール実行を micro VM に隔離する構成 (`index.ts`) で、開発作業を妨げていた
2点を解消する。判断の経緯は `docs/adr/0001-gondolin-guest-image-base.md`。

## Phase 1: カスタム image

起動ごとの `apk add` をやめ、必要なものを image に焼き込む。

- [x] macOS + Docker で `gondolin build` が通るか確認 (`brew install e2fsprogs` が必要だった)
- [x] devcontainer の Features で組む方式に変更 (`devcontainer build --image-name` の
      出力を `oci.image` に渡す)。手書き Dockerfile は廃止
- [x] ベースを `debian:bookworm-slim` にする。`devcontainers/base` は zsh / oh-my-zsh /
      man / locale など対話用の一式で 620MB 増えるため使わない
- [x] OCI image の ENV が rootfs に引き継がれない問題に対処。Features は ENV でパスを
      通すため、転記しないと動かないものが出る (`RUSTUP_HOME` が無く rustc が起動しない)。
      `build.sh` が `docker image inspect` の結果を `build-config.json` へ自動転記する
- [x] `rootfs.sizeMb` を 10GB に明示 (既定の 872MB では JDK すら入らない)
- [x] `GONDOLIN_DEFAULT_IMAGE=pi-dev:latest` を `~/.zshrc_local` に設定
- [x] `index.ts` の起動時 `apk add` を削除

結果: Debian 12 / glibc 2.36 / node v24.21.0 / go 1.25.14 / rustc 1.98.1 / gh 2.100 / 3.69GB。
ビルドは `guest/build.sh` (Docker と `brew install e2fsprogs` と `jq` が必要)。

## Phase 2: node_modules の分離

`/workspace` はホストの実ディレクトリなので、macOS 向けにビルドされたネイティブ
モジュールは Linux ゲストで動かない。逆に VM 内で `npm install` するとホスト側が
Linux 用に上書きされ、ホストが壊れる。

- [x] マウントを分ける方法を調査 → ネストではなく `ShadowProvider` が使えると判明
- [x] `index.ts` に実装。ホストの node_modules を隠し、書き込みは
      `~/.cache/gondolin-pi/node_modules/<key>` へ逃がす。パスに `node_modules`
      セグメントを含むものが対象なので、モノレポの `packages/*/node_modules` も同様
- [x] 検証。loverese でゲスト内 `npm install` が 557 パッケージ成功し、
      `better_sqlite3.node` の Linux バイナリが生成された。ホストの node_modules は無変更
