#!/bin/bash
# SessionStart: このセッションの合意ファイル ~/.claude/agreements/<session_id>.md の場所と中身を流し込む。
# session_id は再開(resume)しても変わらないので、再開時も同じファイルが見える。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
sid=$(jq -r '.session_id // empty')
[ -n "$sid" ] || exit 0

dir="$HOME/.claude/agreements"
mkdir -p "$dir" || exit 0
file="$dir/$sid.md"

echo "=== このセッションの合意ファイル: $file (injected by SessionStart hook) ==="
if [ -s "$file" ]; then
  cat "$file"
else
  echo "(まだ合意はない。合意したらこのファイルに追記する)"
fi
echo
