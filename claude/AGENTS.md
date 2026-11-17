# Rules

- For code symbol resolution (finding where a symbol is defined, referenced, or implemented), prefer the LSP tool (goToDefinition / findReferences / goToImplementation) over Grep — it uses type information, so it is more precise and won't confuse same-named symbols. Fall back to Grep for plain-text search or when no language server is configured.
- For plain-text/content search in a repo, first check that `<repo-root>/.tgrep` exists (`tgrep status` always exits 0, even with no index, so don't rely on its exit code). If it exists, use `tgrep` for the search; otherwise use `rg` (ripgrep) instead.

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

## Investigation
- Before reading any repo for an investigation — including a repo other than the one the session started in — run `git pull --ff-only` in that repo, then read the working tree as usual. Pass the same instruction to subagents.
- If the pull can't bring it to the default branch's latest (on another branch, dirty tree, ff fails), do not switch branches or stash. Run `git fetch` and read `origin/<default-branch>` (`git show origin/main:path`, `git grep <pat> origin/main`) instead; the working-tree tools (LSP, tgrep, rg) would return stale results. This is only for when the pull actually failed — never use `fetch` + `origin/main` as a shortcut in place of a pull that would have succeeded, even when the user says "read the latest main".
- End every investigation report with the commit it is based on, per repo: `<branch> @ <short-sha>`, or `origin/main @ <short-sha>` when read via the fallback above. If you cannot write the sha, you skipped the update — go back and do it.

## Handoff
- HANDOFF.md を書く・更新するのは、ユーザーが引き継ぎを頼んだときだけ。既存の HANDOFF.md が古くても、頼まれなければ触らない。
- 作業状態の引き継ぎメモは、リポジトリのルート直下に `HANDOFF.md` として1枚だけ置く。サブディレクトリには置かない — 次のセッションが探さずに最初に目にする位置に置くため。調査メモのような永続する知識とは別物なので、それらと同じ場所に並べない。
- 書くのは作業状態だけ: 何をしているか、どこで止まっているか、次に何をするか、成果物と合意ファイルの場所。成果物の本文は書かない — 本文は別ファイルに置き、HANDOFF.md には場所と状態（例: 「docs/event-storming.md、ユーザーの確認待ち」）だけを書く。
- 内容は常に上書きして1枚に保つ。上書きとは、前の記載を捨てて今の状態に書き直すこと。セッションごとにファイルを増やさない。
- `HANDOFF.md` は commit しない。揮発物なので git 管理の対象外。共有される `.gitignore` は編集せず、必要なら `.git/info/exclude` に追記する。
- ユーザーに確認を頼むときは、確認してほしい内容を会話に直接出す。HANDOFF.md や合意ファイルを開くよう案内しない。

## 合意の記録
- 合意ファイルの一番の目的は、会話で合意したことを後で蒸し返さないこと。会話にしかない合意はセッションや修正を重ねるうちに消え、蒸し返しの原因になる。文書を直すときは、合意が本文から消えていないかの照合にも使う。次のセッションへの引き継ぎ用ではない（それは HANDOFF.md）。
- 合意した要点は、文書の中身に限らず作業の進め方なども含めて、合意したその場で追記する。文書に紐づく合意はその文書の隣の `<文書名>.agreements.md`（例: `docs/event-storming.md` → `docs/event-storming.agreements.md`）、どの文書にも紐づかない合意はリポジトリのルート直下の `AGREEMENTS.md` に書く。HANDOFF.md には書かない — 合意はずっと必要で、上書きされる作業状態とは寿命が違うため。
- 追記・修正したら、何をどう書いたかを会話に出す — 取り違えにユーザーがその場で気づけるように。
- 合意ファイルは上書きしない。合意を変えるのは、ユーザーと合意し直したときだけ。
- 答える・提案する・作業を進める前に、ルート直下の `AGREEMENTS.md` と、扱う文書の `<文書名>.agreements.md` を照らす。文書を直したら、各要点が修正後の本文のどこにあるかを示してから報告する。
- 合意ファイルは commit しない。`~/.config/git/ignore` の `*.agreements.md` と `AGREEMENTS.md` で全リポジトリから除外している。

## Git Workflow
- When addressing multiple review findings or items in one request, make one commit per item. Do not bundle unrelated changes into a single commit.
- Commit messages: use Conventional Commits format for the subject line — `type(scope): summary` (e.g. `feat(pi): ...`, `fix(install): ...`, `docs: ...`, `refactor(pgcli): ...`). Subject line only, concise, summarizing *what* changed. Do not add a body by default — do not narrate *how* it was implemented or re-list changes file-by-file; the diff already shows that. If the repo has an ADR/PR-description convention for large rationale, use that instead of the commit body. Only add a short one-line body when there's genuinely commit-scoped context not captured elsewhere.

## Scope Discipline
- Do not add refactors, parallelization, hooks, or settings.json changes unrelated to the requested change.
- When the user asks a question, ANSWER FIRST before taking any action or making changes.
- Do not over-engineer solutions (e.g., pre-push hooks, env var schemes). Prefer the simplest correct solution and research industry standards before designing custom mechanisms.

## Code Comments
- Default to no comment. Add one only when a future reader, seeing just the code, would likely "fix" or remove something that is deliberately that way (a hidden constraint, a workaround for an external bug, a surprising ordering) — and the reader cannot learn it from the name, types, or a one-line read.
- Do not comment *why this change was made* (e.g. "exact match because a similarly named item exists"). The diff already shows it, and it goes stale. A *why* that is merely true is not enough; it must prevent a mistake.
- Test before writing one: "If I delete this comment, what breaks or gets mis-edited?" If nothing, don't write it. Keep any surviving comment terse.

## No Speculation
- Do not write design docs or make technical claims based on speculation. Read the actual code/docs first.
- Do not fabricate API behaviors, URL formats, or 'runtime mismatch'-style problems without verification.
- If unsure, run a quick check (Read, Grep, WebFetch) before asserting.
- When a README/docs exists for the tool at hand, look the answer up there first; reason it out yourself only for what the docs don't cover. Read the tool's own docs, not only the surrounding repo's. A change that works is not evidence that it is the recommended setup.

## Verification
- Do not claim a task is complete, fixed, or passing without running the relevant verification (tests, build, manual check). Evidence before assertions.
- Before claiming you cannot verify, launch, or test something, name the mechanism that would do it — tmux (`new-session -d` / `send-keys` / `capture-pane`) for interactive programs, TUIs, and VM-backed sessions; a non-interactive/`--print` flag; a scripted harness. Your own shell being non-interactive does not limit what it can start. Claim a limit only after a mechanism has been tried and failed.
- Never say a named tool, skill, or agent was used unless that exact invocation is in the transcript. If asked to use one — or before spawning an Agent for a role a real Skill/agent already covers — first check the available Skill/agent list for that exact name and invoke it (Skill tool for skills, that exact agent type for agents). If you use something else instead (e.g. a general-purpose Agent role-playing a reviewer), say so literally and surface the substitution — never reuse the real name as the Agent's label, and do not describe the substitute by the requested name. Attribute work to the literal tool call, never to the role it played.

## Scripts Location
- Scripts meant to be reused later go in the repo (e.g., scripts/), so they are versioned. One-off/throwaway scripts (e.g. ad-hoc log analysis) follow the harness's own default (its scratchpad directory), not the repo.

## Hunk (diff review)
- Whenever the user wants you to read their Hunk review comments, or to review/annotate a changeset in Hunk, follow the bundled skill at `hunk skill path`.
