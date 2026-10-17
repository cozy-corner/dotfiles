#!/bin/bash
# Gleam の Tree-sitter parser とハイライトクエリを入れる（Nvim 本体に同梱されていないため）。
# 置き場の stdpath("data")/site は lazy.nvim の rtp リセット後も runtimepath に残る
set -euo pipefail

# nvim-treesitter (main) の parsers.lua が固定しているリビジョンに合わせる
PARSER_REV=fa6d0d94804f1b342e175865a3dbeb316ee5115e
QUERIES_REV=ca581c3436fc2b236847f5b739ebc263739e5ca6

site=~/.local/share/nvim/site
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "https://github.com/gleam-lang/tree-sitter-gleam/archive/$PARSER_REV.tar.gz" | tar -xz -C "$tmp" --strip-components 1
mkdir -p "$site/parser" "$site/queries/gleam"
cc -shared -fPIC -O2 -I"$tmp/src" "$tmp/src/parser.c" "$tmp/src/scanner.c" -o "$site/parser/gleam.so"

# クエリは Nvim のキャプチャ名に合わせてある nvim-treesitter 版を使う
curl -fsSL -o "$site/queries/gleam/highlights.scm" \
  "https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/$QUERIES_REV/runtime/queries/gleam/highlights.scm"
