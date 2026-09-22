# Rules

- For code symbol resolution (finding where a symbol is defined, referenced, or implemented), prefer the LSP tool (goToDefinition / findReferences / goToImplementation) over Grep — it uses type information, so it is more precise and won't confuse same-named symbols. Fall back to Grep for plain-text search or when no language server is configured.
- For plain-text/content search in a repo, first run `tgrep status <repo-root>` to check for an index. Exit 0 means an index exists — use `tgrep` for the search. A nonzero exit (no index found) means use `rg` (ripgrep) instead.

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
- When addressing multiple review findings or items in one request, make one commit per item. Do not bundle unrelated changes into a single commit.
- Commit messages: use Conventional Commits format for the subject line — `type(scope): summary` (e.g. `feat(pi): ...`, `fix(install): ...`, `docs: ...`, `refactor(pgcli): ...`). Subject line only, concise, summarizing *what* changed. Do not add a body by default — do not narrate *how* it was implemented or re-list changes file-by-file; the diff already shows that. If the repo has an ADR/PR-description convention for large rationale, use that instead of the commit body. Only add a short one-line body when there's genuinely commit-scoped context not captured elsewhere.

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
- Before claiming you cannot verify, launch, or test something, name the mechanism that would do it — tmux (`new-session -d` / `send-keys` / `capture-pane`) for interactive programs, TUIs, and VM-backed sessions; a non-interactive/`--print` flag; a scripted harness. Your own shell being non-interactive does not limit what it can start. Claim a limit only after a mechanism has been tried and failed.
- Never say a named tool, skill, or agent was used unless that exact invocation is in the transcript. If asked to use one — or before spawning an Agent for a role a real Skill/agent already covers — first check the available Skill/agent list for that exact name and invoke it (Skill tool for skills, that exact agent type for agents). If you use something else instead (e.g. a general-purpose Agent role-playing a reviewer), say so literally and surface the substitution — never reuse the real name as the Agent's label, and do not describe the substitute by the requested name. Attribute work to the literal tool call, never to the role it played.

## Scripts Location
- Scripts meant to be reused later go in the repo (e.g., scripts/), so they are versioned. One-off/throwaway scripts (e.g. ad-hoc log analysis) follow the harness's own default (its scratchpad directory), not the repo.

## Hunk (diff review)
- Whenever the user wants you to read their Hunk review comments, or to review/annotate a changeset in Hunk, follow the bundled skill at `hunk skill path`.
