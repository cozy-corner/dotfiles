#!/bin/bash
# SessionStart: リポジトリの README を全文コンテキストに流し込む。
# 「読め」という指示は部分読みで済まされるため、読むかどうかを Claude に委ねない。
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

readme=$(find "$root" -maxdepth 1 -iname 'README*' -type f | sort | head -n 1)
[ -n "$readme" ] || exit 0

echo "=== $readme (full text, injected by SessionStart hook; do not re-read partially) ==="
cat "$readme"
