#!/bin/bash
# PreToolUse(Edit|Write|MultiEdit): 既存の Markdown を初めて編集するとき、見出し構成を見せてから通す。
# 「既存の節の型に合わせる」はルールに書いても、書く瞬間に他の節を見ないため守られない。
trap 'rc=$?; echo "$(date +%FT%T) ${0##*/} exit=$rc" >>"$HOME/.claude/hook-stats.log"' EXIT
input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
[[ $file == *.md && -f $file ]] || exit 0

# git で追跡していない文書（HANDOFF.md などのメモ）には守る慣習がない
git -C "$(dirname "$file")" ls-files --error-unmatch -- "$file" >/dev/null 2>&1 || exit 0

# コードフェンス内の # 行は見出しではない
outline=$(awk '/^(```|~~~)/{f=!f; next} !f && /^#{1,6} /{print NR": "$0}' "$file")
(( $(wc -l <<<"$outline") >= 3 )) || exit 0

# 同じセッションでは 1 ファイルにつき 1 回だけ止める
session=$(jq -r '.session_id // "none"' <<<"$input")
seen="${TMPDIR:-/tmp}/claude-doc-outline-$session"
grep -qxF "$file" "$seen" 2>/dev/null && exit 0
echo "$file" >>"$seen"

cat >&2 <<EOF
Before editing $file, check its existing structure. Outline:
$outline

Read a sibling section of the same level. If sibling sections share a clear convention (sub-headings, item order, format), match it. If the document has no such convention (e.g. working notes or a status log), edit it as you intended. Then retry the edit.
EOF
exit 2
