# Rules

- When reading or searching files, always use dedicated tools (Grep, Glob, Read) instead of Bash commands (grep, find, cat). Legitimate shell usage such as cat in a pipeline is acceptable.
- When launching subagents (Agent tool), always include in the prompt an explicit instruction to use Grep/Glob/Read instead of Bash grep/find/cat. Subagents do not reliably follow CLAUDE.md rules unless restated in their prompt.

## Project Onboarding
- ALWAYS read the project README before starting work on a new task in a repo.

## Scope Discipline
- Do not add refactors, parallelization, hooks, or settings.json changes that were not explicitly requested.
- When the user asks a question, ANSWER FIRST before taking any action or making changes.
- Do not over-engineer solutions (e.g., pre-push hooks, env var schemes). Prefer the simplest correct solution and research industry standards before designing custom mechanisms.

## No Speculation
- Do not write design docs or make technical claims based on speculation. Read the actual code/docs first.
- Do not fabricate API behaviors, URL formats, or 'runtime mismatch'-style problems without verification.
- If unsure, say so or run a quick check (Read, Grep, WebFetch) before asserting.

## Scripts Location
- Place all working scripts inside the repo (e.g., scripts/) rather than /tmp, so they are versioned and reusable.

## Branch Workflow
- When creating a branch (for a PR or otherwise), use `git gtr new <branch> --yes` instead of `git checkout -b` / `git switch -c`. `git gtr` is the `git-worktree-runner` tool (https://github.com/coderabbitai/git-worktree-runner) — not a git alias — and creates each branch in its own worktree directory.
- Always start a branch from the up-to-date base ref. Run `git fetch origin` first, then pass `--from <ref>` to `git gtr new` (e.g. `git gtr new <branch> --from origin/main --yes`). The base is not always `main` — it can be `origin/develop`, a release tag, or another feature branch in a stack — but in every case the local copy of that ref may be stale, so fetch first and reference the remote-tracking ref explicitly.
- Move into the new worktree with `cd "$(git gtr go <branch>)"`. The exact path is configured per repo via `gtr.worktrees.dir`; always use `git gtr go` instead of guessing the path.
- After merge or abandonment, clean up with `git gtr rm <branch> --delete-branch --yes`.
- Always pass `--yes` so the tool runs non-interactively. Run `git gtr help` for the full subcommand reference.
