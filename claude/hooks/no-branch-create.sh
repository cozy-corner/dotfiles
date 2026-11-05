#!/bin/bash
# PreToolUse(Bash): git checkout -b / switch -c を止める。ブランチ作成は git gtr new に統一する。
cmd=$(jq -r '.tool_input.command // empty')

grep -Eq 'git[[:space:]]+(checkout[[:space:]]+-[bB]|switch[[:space:]]+(-c|-C|--create|--force-create))([[:space:]]|$)' <<<"$cmd" || exit 0

echo "Create branches with 'git gtr new', not 'git checkout -b' / 'git switch -c' (see the branch-workflow skill)." >&2
exit 2
