---
name: pr-description
description: >
  Generate a concise, well-structured PR description from a PR number, branch, or
  diff, and deliver it as copyable markdown. Use when the user asks for "a PR
  description", "PR summary", "write up this PR", or similar — for an existing
  PR (by number/URL) or for the current branch's pending changes. Always ends
  by rendering the final output inside a single fenced ```markdown code block
  in the chat reply so the user can copy it directly — this is the one hard
  requirement of this skill.
user-invocable: true
---

# PR Description Generator

Produces a PR description and hands it back as **raw, copyable markdown** —
always inside one fenced ```markdown code block in the chat reply, never only
prose, never only rendered/formatted text, never only a file the user has to
go open.

## Inputs

Figure out what you're describing, in this priority order:

1. **User gave a PR number/URL** (e.g. "PR #2356", a github.com PR link) →
   fetch it.
2. **User gave nothing specific, but there's an open PR for the current
   branch** → use that.
3. **No PR exists yet** → describe the pending diff on the current branch
   against its base (usually `main`).

If genuinely ambiguous (e.g. multiple candidate PRs, or no PR and no diff),
ask the user rather than guessing.

## Gathering context

Run these as needed (parallelize independent calls):

```bash
gh pr view <number> --json title,body,files,commits
gh pr diff <number>
# or, for an unopened/local branch:
git log <base>..HEAD --oneline
git diff <base>...HEAD
```

Look at the actual diff, not just commit messages — commit messages on this
kind of repo are often terse or reflect abandoned intermediate steps (e.g. a
"set replicas to 0" commit immediately reverted). The end-state diff is the
source of truth for what the PR *does*; commits/history are the source of
truth for *why*, if the "why" isn't otherwise obvious.

**If the user supplies extra explanation in their prompt** (root cause, design
rationale, background not visible in the diff/commits), treat that as
authoritative context to weave into the description — it's usually the most
important part of the "why," since diffs don't explain motivation.

## Writing the description

Keep it concise. Default structure (drop sections that don't apply — don't
pad):

```markdown
## Summary

One or two sentences: what this PR does and the net effect.

## Context

Why this change is needed — root cause, background, prior state — especially
anything not obvious from the diff itself. Skip this section entirely for
trivial/self-explanatory changes.

## Changes

- Bullet list of concrete changes, file-scoped where useful.

## Testing

How this was/will be validated. Omit if there's nothing meaningful to say.
```

Notes on tone:
- Explain the *why*, not a line-by-line narration of the diff.
- No filler like "This PR improves the codebase." State the concrete effect.
- If this repo is the GitOps repo (or any repo with a CLAUDE.md carrying
  house rules), apply its conventions — e.g. flag PVC storage changes,
  mention manual follow-up steps, note cluster/branch targeting — the same
  way you would in normal work here.

## Delivering the output

1. Render the final description as **raw markdown text** inside a single
   ```` ```markdown ```` fenced code block in your chat reply. This is
   non-negotiable — a description that isn't in a copyable code block is an
   incomplete answer for this skill.
2. Optionally also save it to a file in the scratchpad directory (useful if
   the user wants to paste it into `gh pr edit` or similar later), but the
   in-chat fenced block is the deliverable, not a substitute for it.
3. Do not add commentary above/below that restates the description — a short
   one-line lead-in ("Here's the PR description:") is enough.
