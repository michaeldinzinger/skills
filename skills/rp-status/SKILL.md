---
name: rp-status
description: Create or update a project's concise status page: current goal, research questions, results so far, open decision points and next steps. Use when the user asks for a status, overview, summary of where a project stands, or a handoff, or after a pivot or a batch of new results.
---

# Project status

The status page is one screen of truth a newcomer (the user next month, a supervisor, a fresh agent session) reads first. It is a **snapshot**, never a log: an update rewrites it in place so each fact appears once, in its current form.

## 1. Find its home

Use the location the project already names (a pointer in `CLAUDE.md`/`AGENTS.md`/README, an existing `docs/status.md` or `docs/overview.md`). With none, create `docs/status.md` and add a one-line pointer to it in `CLAUDE.md` (or `AGENTS.md`) and the README. When the project keeps an external source-of-truth doc (paper notes, a spec), the status page carries headline numbers and links to it for the detail.

## 2. Gather the evidence

Read before writing: the current status page, the source-of-truth doc, `git log` since the page's as-of date, the branches and remotes (`git branch -a -vv`; note unpushed work and other clones), result directories and their summary files, and the user's memory for the project. Every number on the page traces to one of these; a fact you cannot confirm becomes an open question on the page, never a guess.

Done when: you know the newest commit, the newest result, and which of them the current page lacks.

## 3. Write it

Keep to this skeleton, in this order, within about 120 lines:

```markdown
# <Project> — status

*As of YYYY-MM-DD · branch `<branch>` @ `<short sha>`* · detail: <link to source-of-truth doc>

## Goal
Two or three sentences: the main claim or product, and why it matters.

## Research questions
| RQ | Question | Answered by | State |
(one row per RQ; State = not started / running / first result / answered)

## Results
- **<ID> <claim in a few words>.** One or two sentences with the key number and its caveat. (`<path or link>`)

## Decisions open
1. **<Decision>** — options; recommendation and why; who decides; what it blocks.

## Next steps
1. <Action> — done when <checkable criterion>. (owner if not the agent)

## Background
At most three lines on where the project came from.
```

- Lead each section with its point: the result, the number, the date.
- Results: only what has been measured, newest understanding first; superseded results are rewritten or removed, not struck through.
- Decisions: only those still open; a decided one moves into Goal, Results or Next steps.
- Next steps: at most seven, ordered by what unblocks what.
- Plain words, sentences under 25 words, numbers with units.

## 4. Check

- The as-of date is today and the commit matches `git rev-parse --short HEAD`.
- Every number appears once on the page and matches its source.
- Nothing contradicts `CLAUDE.md`, the README or the source-of-truth doc; fix whichever is stale, or name the conflict as an open decision.
- The page fits the skeleton and length; the reader learns the goal, the state and the next decision within one screen.
