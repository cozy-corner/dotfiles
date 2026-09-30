#!/usr/bin/env bash
# Cursor Agent statusline, same layout as claude/statusline-command.sh.
# The CLI payload has no 5h rate limit and no line-add/remove totals, so those
# slots are left empty. Shown: model, context %, autorun, vim, branch, directory.

set -euo pipefail

input=$(cat)

# Catppuccin Mocha
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
RED="\033[38;2;243;139;168m"
GRAY="\033[38;2;108;112;134m"
RESET="\033[0m"

# Nerd Font glyphs. Ghostty bundles "Symbols Nerd Font" as a fallback face,
# so these render without installing anything — but only inside Ghostty.
ICON_MODEL="󰚩"
ICON_BRANCH=""
ICON_DIR=""
# Battery levels, index 0 (empty) .. 9 (full)
BATTERY=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁿" "󰂀" "󰂁" "󰂂" "󰂃")

battery_for_pct() {
  local idx=$(( $1 / 10 ))
  (( idx > 9 )) && idx=9
  printf '%s' "${BATTERY[$idx]}"
}

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

row=$(printf '%s' "$input" | jq -r '
  def s: if . == null then "" else tostring end;
  [
    (.model.display_name // ""),
    (.context_window.used_percentage // "" | s),
    (.workspace.current_dir // .cwd // ""),
    (if .autorun == true then "1" else "" end),
    (.vim.mode // "")
  ] | join("\u001f")
')

# Unit separator, not tab: bash `read` collapses empty IFS-whitespace fields.
IFS=$'\037' read -r model ctx_pct cwd autorun vim_mode <<<"$row"

ctx_int=0
if [ -n "$ctx_pct" ]; then
  printf -v ctx_int "%.0f" "$ctx_pct" 2>/dev/null || ctx_int="${ctx_pct%%.*}"
fi
ctx_color=$(color_for_pct "$ctx_int")

if [ -n "$cwd" ] && [ -n "${HOME:-}" ] && [ "${cwd#"$HOME"}" != "$cwd" ]; then
  short_cwd="~${cwd#"$HOME"}"
else
  short_cwd=$(echo "$cwd" | awk -F/ '{if(NF>2) print $(NF-1)"/"$NF; else print $0}')
fi

git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null || true)
fi

sep="${GRAY} │ ${RESET}"
ctx_icon=$(battery_for_pct "$ctx_int")

line="${ICON_MODEL} ${model}${sep}${ctx_color}${ctx_icon} ${ctx_int}%${RESET}"
[ "$autorun" = "1" ] && line+="${sep}auto"
[ -n "$vim_mode" ] && line+="${sep}${vim_mode}"
[ -n "$git_branch" ] && line+="${sep}${ICON_BRANCH} ${git_branch}"
[ -n "$short_cwd" ] && line+="${sep}${ICON_DIR} ${short_cwd}"

printf '%b' "$line"

exit 0
