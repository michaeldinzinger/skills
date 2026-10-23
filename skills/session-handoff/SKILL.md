---
name: session-handoff
description: Write a throwaway HANDOFF.md for the next agent session, or consume and delete one. Use when the user asks for a handoff or to wrap up a session, or when a HANDOFF.md exists in the repo at session start.
---

# Session handoff

`HANDOFF.md` at the repo root is a **baton**: one session hands it over, the next one takes it, folds what lasts into the permanent docs, and deletes it. It holds only what a fresh session can't learn quickly from the repo, the status page or memory: what was in flight, what is unverified, what to do first.

## Write

1. **Pointer.** Make sure `CLAUDE.md` (or `AGENTS.md`) has this line, once, near the top: `If HANDOFF.md exists, read it first and follow its "Remove" step (session-handoff skill).` It is the only permanent trace; it stays when the file goes.
2. **Gather.** `git status`, `git log` since the session began, branches and remotes, running or interrupted jobs, files written outside git (data, results), and the user's last open questions.
3. **Write `HANDOFF.md`** within about 40 lines:

   ```markdown
   # Handoff — YYYY-MM-DD

   Written by the previous session; delete it once taken over (see Remove).

   ## Where things stand
   Two or three sentences, with branch, last commit and a link to the status page.

   ## In flight
   - Jobs, half-finished work, uncommitted or unpushed changes; where their outputs land.

   ## Waiting on the user
   - Decisions and actions only they can take (keys, approvals, choices), with deadlines.

   ## Do first
   1. The next action, with the exact command; done when <checkable criterion>.

   ## Watch out
   - Traps found this session that no doc records yet.

   ## Remove
   Fold anything still true and lasting into the status page, CLAUDE.md or memory;
   then `git rm HANDOFF.md` and commit "Take over handoff".
   ```

   Point to the status page, CLAUDE.md and the notes for everything they already say; the handoff carries the delta.
4. **Commit** it on the working branch under the repo's commit rules. If the next session runs on another machine, tell the user it must be pushed first.

Done when: a fresh session that reads only `CLAUDE.md` and `HANDOFF.md` knows its first command.

## Take over

1. Read `HANDOFF.md` before anything else, then check it against reality (`git log`, job outputs, files). The repo wins where they differ.
2. Fold every item that is still true and lasting into its permanent home: decisions and results into the status page (`rp-status` skill), rules and traps into `CLAUDE.md`, user facts into memory. Drop what is done or stale.
3. `git rm HANDOFF.md`, commit "Take over handoff". The pointer line in `CLAUDE.md` stays.
4. Tell the user in one or two lines what you took over and what you'll do first.
