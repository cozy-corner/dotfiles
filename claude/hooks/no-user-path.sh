#!/bin/bash
# PreToolUse(Edit|Write|MultiEdit): dotfiles 配下に書くテキストへ /Users/<name> / /home/<name> が入るのを止める。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
input=$(cat)

file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
case "$file" in
  "$HOME"/dotfiles/*) ;;
  *) exit 0 ;;
esac

text=$(jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits[]?.new_string)] | map(select(. != null)) | join("\n")' <<<"$input")

grep -Eq '/(Users|home)/[A-Za-z0-9._-]+' <<<"$text" || exit 0

echo "Do not write user-specific absolute paths (/Users/<name>, /home/<name>) into dotfiles. Use ~, \$HOME, or the tool's default path." >&2
exit 2
