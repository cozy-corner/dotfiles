# Rules

- When reading or searching files, always use dedicated tools (Grep, Glob, Read) instead of Bash commands (grep, find, cat). Legitimate shell usage such as cat in a pipeline is acceptable.
- For code symbol resolution (finding where a symbol is defined, referenced, or implemented), prefer the LSP tool (goToDefinition / findReferences / goToImplementation) over Grep — it uses type information, so it is more precise and won't confuse same-named symbols. Fall back to Grep for plain-text search or when no language server is configured.
- When launching subagents (Agent tool), always include in the prompt an explicit instruction to use Grep/Glob/Read instead of Bash grep/find/cat. Subagents do not reliably follow CLAUDE.md rules unless restated in their prompt.

## Project Onboarding
- Run `git pull` at the start of every conversation to ensure the working tree is up to date.
- ALWAYS read the project README before starting work on a new task in a repo.

## Git Workflow
- ALWAYS use a git worktree for feature/bugfix work — never `git checkout -b` in the main checkout. Create it with `git gtr new <branch>` (the worktree runner; folder is named after the branch, fetches by default). This is a standing rule; do not ask each time.
- The base branch is task-dependent — usually `origin/main`, but work may stack on another branch. Pass `--from <ref>` to set the base; if it isn't obvious, ask.
- When addressing multiple review findings or items in one request, make one commit per item. Do not bundle unrelated changes into a single commit.

## Scope Discipline
- Do not add refactors, parallelization, hooks, or settings.json changes that were not explicitly requested.
- When the user asks a question, ANSWER FIRST before taking any action or making changes.
- Do not over-engineer solutions (e.g., pre-push hooks, env var schemes). Prefer the simplest correct solution and research industry standards before designing custom mechanisms.

## Code Comments
- Prefer comments that explain the non-obvious *why* (rationale, gotcha, constraint) over ones that restate *what* the code does. If the name, types, or a one-line read already make it clear, skip the comment. Keep comments terse.

## No Speculation
- Do not write design docs or make technical claims based on speculation. Read the actual code/docs first.
- Do not fabricate API behaviors, URL formats, or 'runtime mismatch'-style problems without verification.
- If unsure, say so or run a quick check (Read, Grep, WebFetch) before asserting.

## Verification
- Do not claim a task is complete, fixed, or passing without running the relevant verification (tests, build, manual check). Evidence before assertions.

## Scripts Location
- Place all working scripts inside the repo (e.g., scripts/) rather than /tmp, so they are versioned and reusable.
