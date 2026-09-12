# 1. gondolin のゲスト image を Debian ベースにする

- 状態: 採用
- 日付: 2026-09-12

## 背景

pi のツール実行を隔離している gondolin VM の既定 image (`alpine-base:latest`) は
開発用途に足りず、起動ごとに `apk add` で穴埋めしていた。これを image に焼き込むにあたり、
rootfs の作り方に2つの選択肢があった。

1. **Alpine 拡張** — `build-config.json` の `alpine.rootfsPackages` を増やす。
   Docker も Dockerfile も不要で、macOS arm64 ではコンテナを介さずネイティブにビルドされる
2. **OCI ベース** — 自前の OCI image を rootfs の材料にする (`oci.image`)。
   image の取得と展開に Docker か podman が要る

構成の単純さでは 1 が明確に優る。管理するファイルは JSON 1つで、image も小さい
(既定の Alpine image 316MB に対し、作成した Debian image は 926MB)。

## 決定

**2 (OCI ベース、Debian) を採用する。**

決め手は libc。Alpine は musl、Debian は glibc で、npm のネイティブモジュールが配布する
prebuilt バイナリは glibc 前提のものが多い。実際に対象リポジトリを確認したところ、

| リポジトリ | ネイティブバイナリを含む依存 |
| --- | --- |
| fish-mcp-server | better-sqlite3, sharp |
| loverese | better-sqlite3, next, tailwindcss |
| kakeizu-explorer | next, tailwindcss |
| revolving-puyo | vite |

主力リポジトリのほとんどが該当する。ホストの macOS 向け node_modules はゲストで動かないため、
ゲストでビルドやテストを走らせるには VM 内で `npm install` することになり、そこで musl だと
ソースビルドに落ちるか失敗する。「VM 内で npm install しない」運用に倒せば libc の差は
効かなくなるが、その場合エージェントはコードの読み書きと git 操作しかできなくなる。

## 結果

- パッケージ導入は `pi/gondolin/guest/Dockerfile` に置く。macOS では OCI ベースと
  `postBuild.commands` を併用できないため (`build/index.js:50-54`)、他に置き場所が無い
- ビルドに Docker の常駐と `mke2fs` (`brew install e2fsprogs`) が必要になる。
  後者は Alpine 方式でも同じく必要
- image は 926MB。既定の Alpine image の約3倍
- ゲストは Debian 12 / glibc 2.36 / GNU coreutils / node v24.21.0 になり、
  ホストの macOS と同じ GNU 系ツールの挙動が得られる

## 前提が変わる条件

VM 内で `npm install` しない運用に切り替えるなら、この決定の根拠は消える。
その場合は Alpine 拡張に戻すほうが構成が軽い。
