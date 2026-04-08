#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
rate5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Shorten to last 2 path components
short_cwd=$(echo "$cwd" | awk -F/ '{if(NF>2) print $(NF-1)"/"$NF; else print $0}')

line="$short_cwd"
[ -n "$model" ] && line="$line | $model"
[ -n "$remaining" ] && line="$line | ctx:$(printf '%.0f' "$remaining")%"
[ -n "$rate5h" ] && line="$line | 5h:$(printf '%.0f' "$rate5h")%"

printf "%s" "$line"
