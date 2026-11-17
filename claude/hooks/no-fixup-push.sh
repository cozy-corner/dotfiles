#!/bin/bash
# PreToolUse(Bash): 未 push の範囲に fixup! / squash! / amend! のコミットがあるまま git push するのを止める。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

grep -Eq '(^|[;&|[:space:]])git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?push([[:space:]]|$)' <<<"$cmd" || exit 0

found=$(git -C "${cwd:-.}" log HEAD --not --remotes --format='%h %s' 2>/dev/null | grep -E '^[0-9a-f]+ (fixup|squash|amend)! ')
[ -n "$found" ] || exit 0

echo "Unpushed fixup!/squash!/amend! commits found. Fold them into their targets before pushing:" >&2
echo "$found" >&2
exit 2
