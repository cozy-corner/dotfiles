# gondolin 開発環境の整備計画

pi のツール実行を micro VM に隔離する構成 (`index.ts`) で、実際の開発作業を
妨げている2点を解消する。

## Phase 1: OCI ベースのカスタム image (完了)

Debian ベースの image を焼き、起動ごとの `apk add` を廃止した。判断の経緯は
`docs/adr/0001-gondolin-guest-image-base.md` を参照。

- ビルド: `pi/gondolin/guest/build.sh` (Docker と `brew install e2fsprogs` が必要)
- 選択: `~/.zshrc_local` の `GONDOLIN_DEFAULT_IMAGE=pi-dev:latest` (マシン固有のため)
- 結果: Debian 12 / glibc 2.36 / GNU coreutils / node v24.21.0 / git / gh / jq / rg / cc / make

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
