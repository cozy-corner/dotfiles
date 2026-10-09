#!/bin/bash
# PreToolUse(Bash): 再帰 grep を止める。tgrep / rg の使い分けは AGENTS.md の規則に任せる。
cmd=$(jq -r '.tool_input.command // empty')

# パイプ後段 (| の直後) は対象外
grep -Eq "(^|[;&(])[[:space:]]*(e?grep|fgrep)[[:space:]]([^|;&]*[[:space:]])?(-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)([[:space:]]|\$)" <<<"$cmd" || exit 0

echo 'Recursive grep is blocked. Use `rg`, or `tgrep` if the repo has a <repo-root>/.tgrep index (see AGENTS.md); pass -uu to include gitignored/hidden files.' >&2
exit 2
