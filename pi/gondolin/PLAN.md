# gondolin 開発環境の整備計画

pi のツール実行を micro VM に隔離する構成 (`index.ts`) で、実際の開発作業を
妨げている2点を解消する。

## Phase 1: OCI ベースのカスタム image

既定のゲスト image (`alpine-base:latest`) は開発用途に足りず、起動ごとの
`apk add` で穴埋めしている。実測した不足は以下。

- `cc` / `make` が無く、ネイティブモジュールをビルドできない
- `rg` / `jq` が無い
- `awk` / `sed` / `grep` が busybox 版で、GNU/BSD 固有オプションが通らない
- node がホスト v23.11.0 / ゲスト v24.14.1 で不一致

gondolin は Alpine minirootfs の代わりに OCI image を rootfs のベースにできる
(`dist/src/build/config.d.ts:61-70`, `129-130`)。

```jsonc
{
  "oci": { "image": "node:24-bookworm", "runtime": "docker" },
  "postBuild": {
    "commands": ["apt-get update && apt-get install -y git jq ripgrep build-essential"]
  }
}
```

- [ ] macOS + Docker で `gondolin build --config ... --tag pi-dev:latest` が通るか確認
      (ビルド自体が Docker/podman に依存する)
- [ ] ゲストで `grep --version` が GNU であること、`cc` / `make` / `jq` / `rg` の存在を確認
- [ ] `GONDOLIN_DEFAULT_IMAGE=pi-dev:latest` を設定し、pi から起動して動作確認
- [ ] `index.ts` の起動時 `apk add` を削除する
- [ ] ビルド設定を dotfiles 管理下に置き、`install.sh` に手順を追加

image に焼くのはどのリポジトリでも使うものに限る。プロジェクト固有の toolchain は
起動時に追加する。

## Phase 2: node_modules の分離

image では解決しない。`/workspace` はホストの実ディレクトリなので、macOS 向けに
ビルドされたネイティブモジュールは Linux ゲストで動かない。逆に VM 内で
`npm install` するとホスト側が Linux 用に上書きされ、ホストが壊れる。

devcontainer の定番対処は node_modules をバインドマウントから外すこと。gondolin にも
`MemoryProvider` と CLI の `--mount-memfs` がある。

- [ ] `RealFSProvider` マウントの内側に別マウントをネストできるか確認
      (`/workspace/node_modules` に memfs を被せられるか)
- [ ] 効く場合: `index.ts` のマウント定義に追加し、ゲストで `npm install` しても
      ホストの node_modules が変化しないことを確認
- [ ] 効かない場合: VM 内で `npm install` しない運用に倒す
