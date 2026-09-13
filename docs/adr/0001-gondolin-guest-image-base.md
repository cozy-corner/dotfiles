# 1. gondolin のゲスト image を Debian ベースにする

- 状態: 採用
- 日付: 2026-09-12 (2026-09-13 改訂)

## 背景

pi のツール実行を隔離している gondolin VM の既定 image (`alpine-base:latest`) は
開発用途に足りず、起動ごとに `apk add` で穴埋めしていた。これを image に焼き込むにあたり、
rootfs の作り方に2つの選択肢があった。

1. **Alpine 拡張** — `build-config.json` の `alpine.rootfsPackages` を増やす。
   Docker も Dockerfile も不要で、macOS arm64 ではコンテナを介さずネイティブにビルドされる
2. **OCI ベース** — 自前の OCI image を rootfs の材料にする (`oci.image`)。
   image の取得と展開に Docker か podman が要る

構成の単純さでは 1 が明確に優る。管理するファイルは JSON 1つで、image も小さい
(既定の Alpine image 316MB に対し、当初作成した Debian image は 926MB)。

## 決定

**2 (OCI ベース、Debian) を採用する。**

決め手は libc。Alpine は musl、Debian は glibc で、npm のネイティブモジュールが配布する
prebuilt バイナリは glibc 前提のものが多い。Node を使うリポジトリの依存を確認すると、

| リポジトリ | ネイティブバイナリを含む依存 |
| --- | --- |
| fish-mcp-server | better-sqlite3, sharp |
| loverese | better-sqlite3, next, tailwindcss |
| kakeizu-explorer | next, tailwindcss |
| revolving-puyo | vite |

ホストの macOS 向け node_modules はゲストで動かないため、ゲストでビルドやテストを
走らせるには VM 内で `npm install` することになり、そこで musl だとソースビルドに
落ちるか失敗する。「VM 内で npm install しない」運用に倒せば libc の差は効かなくなるが、
その場合エージェントはコードの読み書きと git 操作しかできなくなる。

なお glibc が効くのは Node に限らない。Rust の prebuilt や JVM の配布物も
glibc 前提のものが主流で、この選択は他の言語にもそのまま効く。

## パッケージの入れ方

当初は手書きの Dockerfile に `apt-get install` を並べていたが、**devcontainer の
Features で宣言する方式に変更した**。`devcontainer build --image-name` が出力する
OCI image をそのまま `oci.image` に渡せる。

```jsonc
"features": {
  "ghcr.io/devcontainers/features/node:1": { "version": "24" },
  "ghcr.io/devcontainers/features/go:1": { "version": "1.25" },
  "ghcr.io/devcontainers/features/rust:1": {},
  "ghcr.io/devcontainers/features/github-cli:1": {}
}
```

手書き時代に必要だった手作業 (gh のために GitHub の apt リポジトリ鍵を curl して
sources.list に追記する等) が消え、バージョン指定も Features の設定値として書ける。
image の組み立てだけ devcontainer のエコシステムに任せ、実行時の隔離
(認証情報を渡さない、egress 制限、SSH 終端) は gondolin のままにできる。

`postBuild.commands` は使えない。macOS では OCI ベースとの併用が禁止されている
(`build/index.js:50-54`)。

## 結果

- ビルドに Docker の常駐と `mke2fs` (`brew install e2fsprogs`) が必要。
  後者は Alpine 方式でも同じく必要
- image は 3.69GB、ビルドは約5分。rootfs は `rootfs.sizeMb` で 10GB を明示する必要がある。
  増分の内訳は条件を揃えて測定した。`devcontainers/base` をベースにすると zsh / oh-my-zsh /
  man / locale など対話用の一式が付いてきて 620MB 増えるため、ベースは `debian:bookworm-slim`
  にし、git も apt 版 (2.39.5) を使う。残る 3.69GB の大半は言語 toolchain で、rust が
  1.47GB、go が 414MB を占める
- ゲストは Debian 12 / glibc 2.36 / node v24.21.0 / go 1.25.14 / rustc 1.98.1 /
  gh 2.100 になり、GNU 系ツールの挙動もホストの macOS と揃う
- **OCI image の ENV は gondolin の rootfs に引き継がれない。** Features はツールの
  配置だけでなく ENV でパスを通すため、転記しないと動かないものが出る (`RUSTUP_HOME`
  が無く rustc が起動しなかった)。`build.sh` が `docker image inspect` の結果を
  `build-config.json` の `env` へ自動転記して対処している

## 入れる言語の範囲

エージェントを実際に動かしているリポジトリで判断した。pi と Claude Code の
セッション履歴に現れるのは Node / Rust / Go と、shell や markdown だけ。
`~/code` には Gradle のリポジトリが4つあるが、エージェントを動かした形跡が無いため
JVM は入れていない。必要になれば Features に1行足して焼き直せばよい。

(`~/code` 全体の内訳は 47 リポジトリ中 Node 10 / Gradle 4 / Rust 3 / Python 3 /
Go 2。Node が多数派というわけではない。)

## 前提が変わる条件

VM 内で `npm install` しない運用に切り替えるなら、この決定の根拠は消える。
その場合は Alpine 拡張に戻すほうが構成が軽い。
