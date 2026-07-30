# Rules

- When reading or searching files, always use dedicated tools (Grep, Glob, Read) instead of Bash commands (grep, find, cat). Legitimate shell usage such as cat in a pipeline is acceptable.
- For code symbol resolution (finding where a symbol is defined, referenced, or implemented), prefer the LSP tool (goToDefinition / findReferences / goToImplementation) over Grep — it uses type information, so it is more precise and won't confuse same-named symbols. Fall back to Grep for plain-text search or when no language server is configured.
- When launching subagents (Agent tool), always include in the prompt an explicit instruction to use Grep/Glob/Read instead of Bash grep/find/cat. Subagents do not reliably follow CLAUDE.md rules unless restated in their prompt.

## Subagents
- Delegating is not free: each subagent re-establishes context, re-explores, and reports back, and you then read its report. Delegate only when that overhead is clearly worth it.
- Do NOT delegate work you could finish yourself in a handful of tool calls.
- Judge by context volume, not call count: reading a few large files can cost more context than a subagent's report. Delegate when you only need the conclusion (locating code, answering "where/whether"); read directly when you need the contents to keep working with — you would have to read them yourself anyway.
- DO delegate genuinely independent, sizeable tracks: wide multi-file investigations, unrelated modules that can proceed in parallel.
- Prefer one subagent over several. Do not split one modest job across multiple agents. Never exceed 20 parallel agents unless explicitly asked.
- Brief the subagent fully the first time rather than launching, waiting, and re-briefing.
- Launch independent subagents in a single message with multiple tool uses so they run concurrently.

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
- Never say a named tool, skill, or agent was used unless that exact invocation is in the transcript. If asked to use one — or before spawning an Agent for a role a real Skill/agent already covers — first check the available Skill/agent list for that exact name and invoke it (Skill tool for skills, that exact agent type for agents). If you use something else instead (e.g. a general-purpose Agent role-playing a reviewer), say so literally and surface the substitution — never reuse the real name as the Agent's label, and do not describe the substitute by the requested name. Attribute work to the literal tool call, never to the role it played.

## Scripts Location
- Place all working scripts inside the repo (e.g., scripts/) rather than /tmp, so they are versioned and reusable.

## Hunk (diff review)
- Whenever the user wants you to read their Hunk review comments, or to review/annotate a changeset in Hunk, follow the bundled skill at `hunk skill path`.
