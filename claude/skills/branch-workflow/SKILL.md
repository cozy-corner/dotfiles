---
name: branch-workflow
description: Git branch and worktree policy using `git gtr` (git-worktree-runner). Invoke BEFORE editing any file that will land in a PR — the moment a task crosses from exploration/Q&A into "I'm about to make changes". Also invoke when creating, switching to, or cleaning up a branch or worktree, when about to run `git checkout -b` / `git switch -c` / `git worktree add`, or when about to edit files while on `main`. Some repos override this with their own rule to work directly on main — check the repo's AGENTS.md/CLAUDE.md first.
---

# Branch Workflow

- Create the branch as soon as the task scope is decided — before opening any file for editing.
- Do NOT edit on `main` and migrate the changes to a branch later via stash. That defeats the point of worktrees: main stays dirty, stash slots conflict across parallel tasks, and there is no isolation.
- The trigger to branch is the moment a task crosses from exploration/Q&A into "I'm about to edit files that will land in a PR".
- When creating a branch (for a PR or otherwise), use `git gtr new <branch> --yes` instead of `git checkout -b` / `git switch -c`. `git gtr` is the `git-worktree-runner` tool (https://github.com/coderabbitai/git-worktree-runner) — not a git alias — and creates each branch in its own worktree directory.
- Always start a branch from the up-to-date base ref. Run `git fetch origin` first, then pass `--from <ref>` to `git gtr new` (e.g. `git gtr new <branch> --from origin/main --yes`). The base is not always `main` — it can be `origin/develop`, a release tag, or another feature branch in a stack — but in every case the local copy of that ref may be stale, so fetch first and reference the remote-tracking ref explicitly.
- Move into the new worktree with `cd "$(git gtr go <branch>)"`. The exact path is configured per repo via `gtr.worktrees.dir`; always use `git gtr go` instead of guessing the path.
- After merge or abandonment, clean up with `git gtr rm <branch> --delete-branch --yes`.
- Always pass `--yes` so the tool runs non-interactively. Run `git gtr help` for the full subcommand reference.

## Repos that opt out

A repo's own `AGENTS.md` / `CLAUDE.md` takes precedence over this skill. Known opt-outs where work happens directly on `main` with no branch or worktree: `dotfiles`, `loverese`.
