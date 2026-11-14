#!/bin/bash
# SessionStart: リポジトリの README と CONTRIBUTING を全文コンテキストに流し込む。
# 「読め」という指示は部分読みで済まされるため、読むかどうかを Claude に委ねない。
# AGENTS.md は Claude Code が直接読む(CLAUDE.md が無い場合)ので、ここでは注入しない。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

inject() {
  local file
  file=$(find "$@" -maxdepth 1 -type f 2>/dev/null | sort | head -n 1)
  [ -n "$file" ] || return 0
  echo "=== $file (full text, injected by SessionStart hook; do not re-read partially) ==="
  cat "$file"
  echo
}

inject "$root" -iname 'README*'
inject "$root" "$root/.github" "$root/docs" -iname 'CONTRIBUTING*'
