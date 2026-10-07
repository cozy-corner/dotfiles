#!/usr/bin/env bash
# Classify local branches by whether their work is already in the base branch.
# Usage: classify.sh [base-ref]   (default: origin's HEAD branch, else origin/main)
# Read-only. Prints one TSV row per branch:
#   branch  verdict  pr  head_match  unique/total  worktree  dirty
set -euo pipefail

base=${1:-$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)}
base_name=${base#origin/}
current=$(git branch --show-current)

git fetch -q --prune origin

printf 'branch\tverdict\tpr\thead_match\tunique/total\tworktree\tdirty\n'
git for-each-ref --format='%(refname:short)' refs/heads | while read -r b; do
  case "$b" in main|develop|"$base_name"|"$current") continue ;; esac
  sha=$(git rev-parse "$b")

  wt=$(git worktree list --porcelain | awk -v b="refs/heads/$b" '/^worktree /{p=$2} $0==("branch " b){print p}')
  dirty=-
  [ -n "$wt" ] && { [ -n "$(git -C "$wt" status --porcelain)" ] && dirty=yes || dirty=no; }

  # Patch-equivalence is positive evidence only: a squash merge of several commits
  # becomes one patch, so unique>0 does not prove the branch is unmerged.
  total=$(git cherry "$base" "$b" | wc -l | tr -d ' ')
  unique=$(git cherry "$base" "$b" | grep -c '^+' || true)

  # Prefer a MERGED PR; otherwise the first one listed.
  pr=$(gh pr list --head "$b" --state all --json number,state,baseRefName,headRefOid \
        -q 'sort_by(.state != "MERGED") | .[0] // empty | "\(.number)\t\(.state)\t\(.baseRefName)\t\(.headRefOid)"')
  num=- ; state=- ; pbase=- ; poid=-
  [ -n "$pr" ] && IFS=$'\t' read -r num state pbase poid <<<"$pr"
  head_match=-
  [ "$poid" != - ] && { [ "$poid" = "$sha" ] && head_match=yes || head_match=no; }

  if git merge-base --is-ancestor "$sha" "$base"; then verdict=MERGED
  elif [ "$state" = MERGED ]; then
    [ "$head_match" = yes ] && verdict=MERGED || verdict=AHEAD_OF_MERGED_PR
  elif [ "$state" = OPEN ]; then verdict=OPEN_PR
  elif [ "$state" = CLOSED ]; then
    [ "$unique" = 0 ] && verdict=CLOSED_CONTENT_IN_BASE || verdict=CLOSED_UNMERGED
  elif [ "$unique" = 0 ] && [ "$total" -gt 0 ]; then verdict=CONTENT_IN_BASE_NO_PR
  else verdict=UNMERGED
  fi

  printf '%s\t%s\t%s\t%s\t%s/%s\t%s\t%s\n' "$b" "$verdict" \
    "$([ "$num" = - ] && echo - || echo "#${num} ${state} → ${pbase}")" "$head_match" "$unique" "$total" "${wt:--}" "$dirty"
done
