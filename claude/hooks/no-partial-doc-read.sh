#!/bin/bash
# PreToolUse(Bash|Read): README 等を一部だけ読んで全体を読んだつもりになるのを止める。
# auto mode のシステムプロンプトが head / sed -n での読み取りを勧めるため、AGENTS.md の規則だけでは負ける。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
input=$(cat)
doc='(README|CONTRIBUTING|AGENTS|CLAUDE)[^[:space:]/;&|]*'
msg='Partial read of a project doc is blocked. Read the whole file with the Read tool, without offset/limit.'

case $(jq -r '.tool_name' <<<"$input") in
Read)
  jq -e '.tool_input | (.offset != null or .limit != null)' <<<"$input" >/dev/null || exit 0
  basename "$(jq -r '.tool_input.file_path // empty' <<<"$input")" | grep -Eiq "^$doc\$" || exit 0
  ;;
Bash)
  cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
  # head README.md / sed -n '1,20p' sub/README.md
  direct="(^|[;&|(])[[:space:]]*(head|tail|sed[[:space:]]+-n)([[:space:]][^;&|]*)?[[:space:]/:]$doc"
  # cat README.md | head / git show origin/main:README.md | head
  piped="(^|[;&(])[[:space:]]*(cat|git[[:space:]]+show)([[:space:]][^;&|]*)?[[:space:]/:]$doc[^;&|]*\|[[:space:]]*(head|tail|sed[[:space:]]+-n)"
  grep -Eiq -e "$direct" -e "$piped" <<<"$cmd" || exit 0
  ;;
*) exit 0 ;;
esac

echo "$msg" >&2
exit 2
