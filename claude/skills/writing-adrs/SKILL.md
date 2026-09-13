---
name: writing-adrs
description: Write an Architecture Decision Record (ADR) using the Nygard template to capture a technical decision and its rationale. Use this whenever the user asks to "write an ADR", "document this decision", "record why we chose X", or after a design discussion lands on a non-trivial architectural or technical choice worth preserving for future readers — even if they don't say "ADR" explicitly (e.g. "let's write down why we went with Postgres over Dynamo").
---

# Writing ADRs (Nygard template)

An ADR exists so that someone reading the code six months from now can answer
"why is it built this way?" without having to ask the person who built it.
Write for that reader: someone with the technical background but none of the
context from this conversation.

## Where the file goes

Look for an existing ADR directory first (commonly `docs/adr/`, `doc/adr/`,
or `docs/decisions/`). If one exists, follow its numbering and match its
style. If none exists, create `docs/adr/` and start at `0001`.

Filename: `NNNN-short-title.md`, zero-padded to four digits, incrementing
from the highest existing number. Title is a short kebab-case slug of the
decision, e.g. `0003-use-postgresql.md`.

## Structure

Use exactly these five sections. Don't add a separate "Considered Options"
or "Alternatives" section — that belongs to a heavier template (MADR). The
Nygard format keeps alternatives folded into the Context prose instead,
because most decisions don't need a standalone comparison table to be
understood; the reasoning in Context should already make clear why the
chosen path won out.

```markdown
# <Number>. <Title>

## Status
<Proposed | Accepted | Deprecated | Superseded by ADR-XXXX>

## Context
<What situation forced this decision? What constraints — technical,
organizational, timeline — were in play? If other options were on the
table, mention them briefly in prose here (what they were, why they didn't
fit) rather than as a separate comparison section. Two to four short
paragraphs is normally enough. Write this section in a neutral, descriptive
voice, as if the decision hadn't been made yet.>

## Decision
<State what was decided, in active voice: "We will use X." Keep this
section short — the reasoning lives in Context, not here.>

## Consequences
<What follows from this decision, both good and bad. Include costs,
new constraints introduced, follow-up work created, or risks accepted.
An ADR that only lists upsides is a red flag — real decisions have
trade-offs, and naming them is what makes the record trustworthy.>
```

## Before writing

- Check whether the decision has genuinely been made. If the user is still
  weighing options, that's a discussion, not an ADR yet — an ADR records a
  decision, not an open question. If unsure, ask.
- Pull real details from the conversation or codebase (actual constraints,
  actual alternatives considered, actual reasons) rather than inventing
  generic-sounding justifications. A vague ADR is worse than no ADR.
- Check the Status of superseded ADRs if this decision replaces one — update
  the old ADR's Status line to `Superseded by ADR-<new-number>` rather than
  leaving it looking current.
