#!/bin/bash
# PreToolUse(Bash): git commit / git push で、追跡外の NG ワード一覧にある文字列が公開リポジトリへ入るのを止める。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
list="$HOME/.config/claude/ng-words.txt"
[ -r "$list" ] || exit 0

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
dir="${cwd:-.}"

git_sub='(^|[;&|[:space:]])git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?'
if grep -Eq "${git_sub}commit([[:space:]]|\$)" <<<"$cmd"; then
  if grep -Eq "${git_sub}commit[[:space:]]+(.*[[:space:]])?-[a-zA-Z]*a" <<<"$cmd"; then
    diff_args=(HEAD)
  else
    diff_args=(--cached)
  fi
  text=$(printf '%s\n%s' "$cmd" "$(git -C "$dir" diff "${diff_args[@]}" 2>/dev/null | grep '^+')")
elif grep -Eq "${git_sub}push([[:space:]]|\$)" <<<"$cmd"; then
  text=$(git -C "$dir" log HEAD --not --remotes -p --format='%B' 2>/dev/null | grep -v '^[-]')
else
  exit 0
fi

hits=$(grep -iFof <(grep -vE '^[[:space:]]*(#|$)' "$list") <<<"$text" | sort -u)
[ -n "$hits" ] || exit 0

[ "$(cd "$dir" 2>/dev/null && gh repo view --json isPrivate -q .isPrivate 2>/dev/null)" = "true" ] && exit 0

echo "NG word(s) found in content going into a non-private (or unverifiable) repo:" >&2
echo "$hits" >&2
exit 2
