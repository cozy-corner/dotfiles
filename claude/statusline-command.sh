#!/usr/bin/env bash
# Claude Code statusline: 2-line display (session info + 5h usage bar)

set -euo pipefail

input=$(cat)

# Catppuccin Mocha
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
RED="\033[38;2;243;139;168m"
GRAY="\033[38;2;108;112;134m"
RESET="\033[0m"

color_for_pct() {
  local pct=$1
  if (( pct >= 80 )); then
    printf '%s' "$RED"
  elif (( pct >= 50 )); then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

progress_bar() {
  local pct=$1
  local filled=$(( pct / 10 ))
  (( filled > 10 )) && filled=10
  local empty=$(( 10 - filled ))
  local color
  color=$(color_for_pct "$pct")
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="▰"; done
  for ((i=0; i<empty; i++)); do bar+="▱"; done
  printf '%b%s%b' "$color" "$bar" "$RESET"
}

model=$(echo "$input" | jq -r '.model.display_name // ""')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
rate5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

ctx_int=0
if [ -n "$ctx_pct" ]; then
  printf -v ctx_int "%.0f" "$ctx_pct" 2>/dev/null || ctx_int="${ctx_pct%%.*}"
fi
ctx_color=$(color_for_pct "$ctx_int")

short_cwd=$(echo "$cwd" | awk -F/ '{if(NF>2) print $(NF-1)"/"$NF; else print $0}')

git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || true)
fi

sep="${GRAY} │ ${RESET}"

line1="🤖 ${model}${sep}${ctx_color}📊 ${ctx_int}%${RESET}${sep}✏️ +${lines_added}/-${lines_removed}"
[ -n "$git_branch" ] && line1+="${sep}🔀 ${git_branch}"
[ -n "$short_cwd" ] && line1+="${sep}📁 ${short_cwd}"

line2=""
if [ -n "$rate5h" ]; then
  printf -v rate_int "%.0f" "$rate5h" 2>/dev/null || rate_int="${rate5h%%.*}"
  rate_color=$(color_for_pct "$rate_int")
  rate_bar=$(progress_bar "$rate_int")
  line2="${rate_color}⏱ 5h${RESET}  ${rate_bar}  ${rate_color}${rate_int}%${RESET}"
fi

printf '%b\n' "$line1"
[ -n "$line2" ] && printf '%b' "$line2"

exit 0
