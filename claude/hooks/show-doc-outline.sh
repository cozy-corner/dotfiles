#!/bin/bash
# PreToolUse(Edit|Write|MultiEdit): 既存の Markdown を初めて編集するとき、見出し構成を見せてから通す。
# 「既存の節の型に合わせる」はルールに書いても、書く瞬間に他の節を見ないため守られない。
input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
[[ $file == *.md && -f $file ]] || exit 0

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

Read a sibling section of the same level and match its sub-headings, item order, and format. Do not invent a new layout. Then retry the edit.
EOF
exit 2
