---
name: design
description: Evidence-first design workflow for non-trivial code changes — new features, refactors, multi-file edits, integrations with external APIs, or fixes whose root cause is not yet confirmed. Read the relevant code and docs FIRST, then produce a short written plan with file:line citations, then STOP and wait for user approval. Trigger whenever the user asks to design, implement, add, build, refactor, rewrite, or "figure out how to" do something, unless the task is a trivial single-file edit. Also trigger for bug fixes where the root cause is not yet confirmed. This skill exists to prevent speculation-driven design, fabricated APIs / URLs / error messages, over-engineering, and scope creep.
---

# Design: Evidence-First Planning

Before designing or implementing, gather evidence from the actual code and docs, produce a short written plan, and wait for user approval. No implementation until approved.

## Why this exists

Past sessions repeatedly failed when design was produced from speculation instead of reading actual code. Concrete failure modes that this skill exists to prevent:

- **Fabrication**: invented a "runtime mismatch" problem and made up URL formats for an external API, instead of reading the official docs. Result: multiple rounds of corrections before landing the right approach.
- **Over-engineered scope**: proposed top-level edits (e.g., to the app entry point) when the change was local to a single view file. Result: a whole PR had to be re-done from scratch.
- **Skipped research**: designed a custom pre-push hook without checking the industry-standard answer (run the audit in CI). Result: the user pushed back repeatedly before the design converged.
- **Symptom-not-cause**: diagnosed a UI sizing problem as a scrolling problem without inspecting the component. Result: two rounds of unrelated changes before the actual issue was addressed.

Each of these could have been avoided by a short evidence-gathering step before committing to a design.

## Workflow

### Step 1 — Gather evidence

Do NOT write anything about the problem or the solution before this step is done. Specifically:

- **Local code**: use Grep / Glob / Read to locate the files that currently implement the behavior in question. Track specific file:line references you will cite in the plan.
- **Existing patterns in the codebase**: search for how the codebase already solves analogous problems. If there is a convention, follow it — do not invent a new one. If a util, component, migration pattern, or helper already does 80% of what you need, reuse it.
- **External APIs / URL formats / config schemas**: verify from the official docs (WebFetch) or from existing code in the repo that already uses them. Never guess parameter names, response shapes, or URL templates.
- **Industry standards**: if the problem has a well-known standard answer ("where should a security audit run?", "how should auth tokens be stored?", "what's the idiomatic X in Y?"), check it before proposing anything custom.
- **Root cause for bug fixes**: reproduce or trace the actual behavior. Do not patch the first plausible cause that comes to mind.

If you cannot find evidence for a claim you would like to make, run a quick check (Read, Grep, WebFetch) or mark the claim explicitly as an unknown in the plan. Do not assert without grounding.

### Step 2 — Write the plan

Keep it short. Target under 300 words. Use this structure:

```
## 課題の要約 (Problem summary — plain language, no code)
<1-3 sentences. What is the user-visible problem or goal, and why it is not obvious.
Read as if to someone who has not opened the code.>

## 現状 (Current behavior — evidence that supports the proposal)
- <behavior> — <file>:<line>
- <behavior> — <file>:<line>

## 提案する変更 (Proposed change)
- <minimal change, scoped to smallest reasonable surface area>

## 却下した選択肢 (Alternatives considered)
- <alternative> — <why rejected>

## リスク / 未確認事項 (Risks / unknowns)
- <risk, or "I was unable to verify X — need to check before implementing">
```

Rules for the plan:

- **Start with the problem, not the code.** The Problem summary comes first and is readable without any code context. It sets up WHY the plan exists before the reader sees file:line details. Skipping this step leaves the reader drowning in evidence with no narrative.
- **Depth matches complexity.** For a simple change, the Current behavior section is a few lines. For a complex investigation (e.g., a subtle bug), it can be longer — but every line there must directly support the proposal. Do not give a guided tour of unrelated internals. If a reader asks "why is this bullet here?", you should be able to say "because it justifies X in the proposal".
- **Every claim about current behavior cites a file:line.** This is what turns the plan from speculation into evidence.
- **The proposed change is the smallest thing that solves the problem.** If the plan touches more than 2–3 files, explicitly justify why.
- **The "alternatives" section exists so the user can see what you rejected and why.** If you only considered one option, say so honestly rather than padding with fake alternatives.
- **Unknowns are explicit.** "I was unable to verify X" is fine. "X probably works like Y" is NOT fine — either run the check, or mark it as an unknown.

### Step 3 — Wait for approval

After presenting the plan, stop. Do not start implementing. The user will approve, request changes, or reject the direction entirely.

While waiting, do not preemptively edit files "to save time". Reverting speculative edits costs more than waiting for approval.

## When NOT to use this workflow

This skill adds overhead. For small tasks, the overhead costs more than the design step saves. Skip it when:

- Single-line typo or identifier rename.
- The user has given a precise spec (exact files, exact edits).
- Emergency fix where the cause is obvious and the change is local and unambiguous.
- Pure read / exploration questions ("how does X work?") — just read and answer.

In these cases, proceed directly without writing a formal plan.

## Anti-patterns this skill is designed to prevent

- **Fabrication**: inventing API behaviors, URL formats, error messages, or "known issues" without a source. If you don't know, say so.
- **Scope creep**: silently adding hooks, settings.json changes, parallelization, or refactors that were not asked for. If you notice something adjacent that needs fixing, list it under "Risks / unknowns" — do not expand scope without approval.
- **Over-engineering**: preferring a new abstraction over the simplest change that solves the problem. The first draft should be boring. If the task is "add a button", the plan is "add a button", not "introduce a generic component framework".
- **Top-level-by-default**: reaching for the app entry point / root file when the problem actually lives in a leaf component. A feature that is local to a single view should be designed and implemented in that view, not propagated up the tree.
