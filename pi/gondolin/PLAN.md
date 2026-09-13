# gondolin 開発環境の整備計画

pi のツール実行を micro VM に隔離する構成 (`index.ts`) で、実際の開発作業を
妨げていた2点を解消する。両方とも実装は済み、記録と後始末が残っている。

## Phase 1: カスタム image (実装済み)

起動ごとの `apk add` を廃止し、必要なものを image に焼き込んだ。判断の経緯は
`docs/adr/0001-gondolin-guest-image-base.md`。

当初は手書きの Dockerfile で組む想定だったが、devcontainer の Features で
宣言する方式に変更した。`devcontainer build --image-name` が出力する OCI image を
gondolin の `oci.image` に渡す形で、image の組み立てだけ devcontainer の
エコシステムに任せ、実行時の隔離は gondolin のままにできる。

- 宣言: `guest/.devcontainer/devcontainer.json` (node / go / rust / github-cli)。
  ベースは `debian:bookworm-slim`。`devcontainers/base` は対話用の一式で 620MB 増えるため使わない
- ビルド: `guest/build.sh` (Docker と `brew install e2fsprogs` が必要)
- 選択: `~/.zshrc_local` の `GONDOLIN_DEFAULT_IMAGE=pi-dev:latest`
- 結果: Debian 12 / glibc 2.36 / node v24.21.0 / go 1.25.14 / rustc 1.98.1 / gh 2.100

**落とし穴**: OCI image の ENV は gondolin の rootfs に引き継がれない。Features は
ツールの配置だけでなく ENV でパスを通すため、転記しないと動かないものが出る
(`RUSTUP_HOME` が無く rustc が起動しなかった)。`build-config.json` の `env` に
`docker image inspect` の結果を `build.sh` が自動転記して解決している。

## Phase 2: node_modules の分離 (実装済み)

`/workspace` はホストの実ディレクトリなので、macOS 向けにビルドされたネイティブ
モジュールは Linux ゲストで動かない。逆に VM 内で `npm install` するとホスト側が
Linux 用に上書きされ、ホストが壊れる。

`ShadowProvider` でホストの node_modules を隠し、書き込みはプロジェクトごとの
キャッシュ (`~/.cache/gondolin-pi/node_modules/<key>`) へ逃がす。

検証: loverese でゲスト内 `npm install` が 557 パッケージ成功し、
`better_sqlite3.node` の Linux バイナリが生成された。ホストの node_modules は無変更。

## 残作業

- [ ] `index.ts` の node_modules 分離をコミットする
- [ ] push する
