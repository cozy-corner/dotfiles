# Rules

- When reading or searching files, always use dedicated tools (Grep, Glob, Read) instead of Bash commands (grep, find, cat). Legitimate shell usage such as cat in a pipeline is acceptable.
- When launching subagents (Agent tool), always include in the prompt an explicit instruction to use Grep/Glob/Read instead of Bash grep/find/cat. Subagents do not reliably follow CLAUDE.md rules unless restated in their prompt.

## Testing Rules
- ALWAYS run integration tests before claiming a task is complete, even if local DB setup is required. Do not skip tests citing 'local DB issues' - fix the setup or ask.
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
