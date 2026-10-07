---
name: delete-merged-branches
description: Delete local git branches and their worktrees whose work is already merged on the remote. Use whenever the user asks to clean up branches — マージ済みブランチを削除, リモートでマージ済みのブランチを消して, ブランチ掃除, ワークツリー掃除, 不要ブランチ削除, [gone] のブランチを消して, `git branch --merged` の後始末 — even if they do not say "squash" or "worktree". A plain `git branch --merged` misses squash-merged branches, so run this skill first.
---

# Delete Merged Branches

## 1. Scope: local branches

"マージ済みブランチを削除" and "リモートでマージ済みのブランチを削除" both mean **local** branches (and their worktrees) whose work is already merged on the remote. "リモートで" says where the merge happened, not where to delete.

Never delete `main`, `develop`, release branches, or environment-slot branches (e.g. `team-staging/*`) without an explicit ask.

## 2. Classify each branch

```bash
~/.claude/skills/delete-merged-branches/scripts/classify.sh [base-ref]   # default: origin's HEAD branch
```

Read-only; one row per local branch (`verdict`, PR, whether the local tip equals the PR head, patch-unique/total commits vs base, worktree path, dirty).

`git branch --merged` only sees ancestry and **misses squash-merged branches**, so the script combines several signals:

| Verdict | Meaning | Delete? |
| --- | --- | --- |
| `MERGED` | tip is in base, or the PR is merged (into any branch) and local tip == PR head | yes |
| `AHEAD_OF_MERGED_PR` | PR merged, but the local branch has commits pushed after it | **no** — those commits would be lost; show them |
| `CLOSED_CONTENT_IN_BASE` / `CONTENT_IN_BASE_NO_PR` | no PR merge, but identical patches are in base | ambiguous — ask |
| `OPEN_PR`, `CLOSED_UNMERGED`, `UNMERGED` | work not in base | no, unless the user explicitly says so |

`git cherry` is positive evidence only: a squash merge of several commits becomes one patch, so `unique > 0` does not prove a branch is unmerged. Trust the PR state for that.

## 3. Show the plan, then delete

List the candidates with last author and date (`git log -1 --format='%cs %h %an' <b>`) before deleting.

Record each deleted branch's tip SHA and report it afterwards. Restore with `git branch <b> <sha>`.

- `git branch -d` works for ancestry-merged branches; squash-merged ones need `-D` (acceptable once the verdict is `MERGED`).
- A branch checked out in a worktree is refused. Remove the worktree first, **without `--force`** — it refuses when files are modified/untracked, and that is the check you want. For worktrees managed by `git gtr` (see the `branch-workflow` skill) use `git gtr rm <branch> --yes`; otherwise `git worktree remove <path>`. If there are changes, show them; force only after the user agrees, and copy untracked files to the scratchpad first.
- `git worktree prune` clears `prunable` entries.


## Pitfalls

- zsh: `$f:refs` parses `:r` as a modifier, and in bash `$state→` swallows the multibyte character into the variable name. Always write `"${var}"`.
- Run git from inside the repo, not from the scratchpad, or every command fails with "not a git repository".
- Keep scratch lists (candidates, SHAs) in the scratchpad, not the repo.
