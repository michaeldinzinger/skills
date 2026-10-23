---
name: rp-interview-me
description: Interview the user in a structured, thorough way to clarify every detail of a research project (RP) or a small-to-medium research coding study, before or during the work, and write the answers into a spec the agents can execute from autonomously. It first questions the underlying idea and brainstorms routes not yet taken, toward the most interesting, timely paper. Use when the user asks to be interviewed, to brainstorm or rethink a project's direction, to clarify or pin down specs, to "spec out" a study, at a project kickoff, at a pivot, or when an agent hits an open question that a guess would make costly.
---

# rp-interview-me: interview the user into a complete spec

Spec-driven work: agents work best when every decision is settled and written down in advance, so the build can then run on its own. Your job is to get the decisions out of the user's head and onto paper, completely, without wasting their attention. But first make sure they are the right decisions: question the idea at the root and dare to imagine other routes (phase R), so the spec describes the best paper within reach, not merely the current plan. The interview is done when an agent could carry out the study from the spec without asking a single question that changes the result.

## 0. Before the first question

1. **Read first, ask second.** Read the repo docs (README, CLAUDE.md, status page, decision record, existing spec), the code layout and git log. Never ask anything the files already answer; instead, state what you found and ask the user to confirm or correct it.
2. **Pick the mode:**
   - **Kickoff:** a new project; run phase R (question the roots) and then all phases (§2).
   - **Delta:** during the work, at a fork, a pivot or a failed assumption; run only the affected phases and their downstream dependants. Run phase R as well when the direction stalls, results disappoint, or the user asks where the paper is heading.
   - **Coding spec:** a well-defined study or tool to build; run phases 1, 6–9 and 12 in full and the rest briefly.
3. **Pick the depth with the user**, in one question: Quick (~15 questions, the decisions that block work), Standard (~40), Deep (everything; for a paper or a multi-week build). Recommend one.
4. **Open the spec file** (`docs/spec.md`, or the project's own spec home) with all sections set to `OPEN`, so progress is visible and an interrupted interview loses nothing.

## 1. How to ask (the strategy)

- **Rounds, not walls.** Ask 1–4 related questions per round with `AskUserQuestion`. Use 2–4 concrete options, with your recommendation first and marked "(Recommended)", and each option's consequence in its description. A free-text "Other" is always available. Use `preview` for comparing artifacts (table layouts, CLI signatures, figure sketches).
- **Funnel:** idea → goal → claim → design → details. The idea itself is questioned first (phase R); a well-specified study of the wrong idea is the costliest failure. Never ask a detail whose answer depends on an earlier, unanswered question. Follow the phase order (§2) unless the user jumps; then follow them and come back.
- **Propose, don't quiz.** Every question carries a default you'd choose and why. The user should be able to answer most rounds by accepting recommendations. A question with no sensible default is a sign the question is too broad: split it.
- **Make it concrete.** Ask for one example (an input record, a result sentence, a table row, a failure case) when an answer stays abstract. "What would the abstract's key sentence say if it worked?" pins a goal better than "what is the goal?".
- **Probe the edges.** For each decision, ask at least one of:
  - What would make this fail or be wrong?
  - What is explicitly out of scope?
  - What result would change your mind, or kill the project?
  - What happens at the extremes (empty, huge, missing, adversarial input)?
- **Check consistency.** After each phase, look for contradictions with earlier answers, with the budget or deadline, and with the code. Raise them as a question with the conflict quoted on both sides.
- **Separate decisions from guesses.** Every spec item carries a status:
  - `DECIDED` (the user said it; quote them);
  - `ASSUMED` (your default, accepted silently or by "go with your recs"; flag these for review);
  - `OPEN` (with an owner and a "needed by" date);
  - `DEFERRED` (with the trigger that reopens it).
- **Time is the user's call.** Never drop, shrink or rank a route by your own estimate of how long it takes; you estimate time poorly. If timing worries you, say so in one line ("Timing concern: …") and let the user weigh it.
- **Don't ask what is cheap to change later.** Rank questions by cost of a wrong guess × likelihood of a wrong guess. Below a threshold: make the call and record it as `ASSUMED`. Spend the user's attention on irreversible, expensive or result-changing choices: claims, data, evaluation protocol, budget, ethics.
- **Echo back.** At the end of each phase, give a 3–6 line summary ("Here's what I have; anything wrong?") and write it into the spec before moving on.
- **Respect attention.** Show progress ("Phase 4 of 12, ~8 questions left at this depth"). Offer to stop at any phase boundary; resume from the spec's `OPEN` items.
- **Verbatim answers.** Record the user's own words for decisions (short quotes), not your paraphrase.

## 2. What to ask (the phases)

Each phase lists the questions that must be answered. Skip any that the files already settle.

R. **Question the roots, and brainstorm.** Before specifying a study, question the idea under it. This phase is a conversation between two researchers, not a form. Open questions are welcome here, and you bring your own proposals and argue for them. The aim is the best and most reasonable roadmap toward a paper that is **interesting, insightful, timely and exciting**, not the safest continuation of what exists.
   - **Restate the idea** in two sentences, then list its hidden assumptions (about the problem, the data, the method, the audience, what counts as a result). Challenge each one: is it true, and what would the paper look like if it were false?
   - **Why this, why now?** What changed (models, data, costs, regulation, a community's open problem) that makes the question answerable or urgent today? If nothing did, say so.
   - **Imagine routes not yet taken.** Propose 3–5 genuinely different routes, with the courage to include ones that reframe the question, flip the claim, borrow a method from another field, use different data, aim at a different community, or discard work already done. For each, give: the paper's title and headline sentence, what makes it exciting, what it would teach the reader, the biggest risk, and the first experiment that would tell whether it holds. Include at least one bold route you are unsure about, and the current plan as one route among them.
   - **Steelman and attack.** For the leading two routes: the strongest case for it, and the review that would reject it.
   - **Converge.** Rank the routes by interesting / insightful / timely / exciting (and feasible at the project's means: data, compute, money), recommend one or a combination, and let the user choose. Record the chosen route and, for each rejected one, the reason, so it can be reopened when that reason changes.
   - Don't kill a route on your estimate of its duration (§1); name a timing concern and let the user decide.

1. **Goal and claim:**
   - the one-sentence contribution;
   - the headline result as it would appear in the abstract (with a placeholder number);
   - who cares, and why now;
   - what counts as success, partial success and failure.
2. **Research questions and hypotheses:**
   - the RQs, in order and with dependencies between them;
   - a falsifiable hypothesis per RQ;
   - the expected effect size, and the smallest effect worth reporting;
   - the kill or pivot criteria, with dates.
3. **Novelty and related work:**
   - the closest 3–5 papers or systems;
   - the delta against each;
   - what a hostile reviewer would say, and the answer to it;
   - must-cite works;
   - the terms and framing to use or to avoid.
4. **Venue, timeline, audience:**
   - the target venue and fallback, with page limit, format and anonymity rules;
   - hard deadlines (AoE?) and internal milestones;
   - a go/no-go date;
   - the co-authors and their roles;
   - the reviewer community's expectations (baselines, statistics, artifacts).
5. **Data:**
   - the sources, versions or snapshots, and licences/terms of use;
   - sampling, size, train/dev/test splits and leakage guards;
   - the labelling (who or what labels, agreement, gold set);
   - known biases;
   - what is test-only and must never be trained on;
   - storage location and retention.
6. **Method and baselines:**
   - the systems and models to compare, with versions pinned;
   - the strongest fair baseline, plus the "dumb" baseline (rules, random, oracle bound);
   - the hyperparameter policy and tuning budget per system, equal across systems;
   - the ablations.
7. **Evaluation:**
   - the primary metric (one) and secondary metrics;
   - how numbers are aggregated (micro or macro, per-source averaging);
   - seeds, repeats, confidence intervals and significance tests;
   - the calibration or cost metrics;
   - error analysis (which slices, how many examples);
   - what goes in each table and figure, sketched.
8. **Compute, cost, budget:**
   - the hardware (laptop, cluster, GPUs) and who runs what;
   - API spend limits per run and per day, plus the ledger;
   - wall-clock time per experiment;
   - rate limits and politeness toward external services;
   - what is affordable to rerun.
9. **Engineering spec (coding projects):**
   - the components and their interfaces (CLI commands, function signatures, file formats with example records);
   - inputs and outputs per step, with paths;
   - configuration and defaults;
   - resumability and caching;
   - logging and manifests;
   - the dependencies, and which are forbidden;
   - the code areas that must not be touched;
   - the test strategy (unit tests and fixtures, no network in tests, smoke test);
   - the acceptance criteria per component, as checkable statements;
   - the non-goals.
10. **Reproducibility and artifacts:**
    - pinned versions, seeds and environment;
    - what gets released (code, data, models) under which licence;
    - anonymised artifact links for review;
    - the exact commands to regenerate every number.
11. **Ethics, legal, privacy:**
    - personal data, GDPR basis and DPO involvement;
    - copyright and TDM exceptions, robots/opt-outs, terms of service;
    - crawling or human-subject approvals;
    - secrets handling;
    - what must never be logged or committed.
12. **Working agreement with the agents:**
    - autonomy level: what agents decide alone, what needs a card, what needs explicit approval (pushes, merges, paid runs, outward-facing actions);
    - git rules (branches, commit format, never main);
    - the communication format and cadence;
    - where state lives (spec, status page, decision record, paper notes);
    - when to interrupt the user, and when to make a call and log it as an assumption.
13. **Risks and plan B:**
    - the top 5 risks, each with likelihood, impact, early signal and mitigation;
    - what gets cut first if time runs short;
    - the minimum publishable result.

Delta mode adds a phase 0: **what changed and why**, which assumptions broke, which `DECIDED` items it touches. If what broke is the idea itself, or the work has lost its direction, go through phase R before re-asking anything else. Then re-ask only those items and their dependants (follow the funnel downward).

## 3. Output

- `docs/spec.md` (or the project's spec home) holds one section per phase, each item with its status, the user's quote or your rationale, and the date. Keep it compact: rewrite items in place, never append a log.
- A **Routes considered** section right after the readiness line: the chosen route and its headline sentence, then each rejected route in one line with the reason and what would reopen it.
- At the top: a **readiness line**, e.g. "Ready to build: phases 1–9 DECIDED; 3 ASSUMED items flagged; 2 OPEN (owner, by date)". Then the list of `ASSUMED` items for the user's review, and the `OPEN` items with owners.
- If the project keeps a decision record (e.g. `docs/decisions.md`), log decisions there too and link from the spec; don't duplicate the text. Give decisions, actions, routes and experiments IDs with a code and a speaking kebab-case name (`D7-paper-scope-breadth`, `A6-abstract-submission`, `R2-route-cost-first-framing`, `E4-crawl-replay-ta-br`), not a bare code or a bare name; numbers run per kind and continue the project's record.
- Per buildable unit, an **agent brief stub**: goal, inputs, outputs, acceptance criteria, constraints, return contract. Agents then work from the spec without asking.
- Commit the spec when the interview (or a phase of it) ends.

## 4. Done when

- The roots were questioned (phase R): the underlying idea's assumptions were challenged, at least three different routes were weighed, and the spec records why the chosen one beats the rest.
- Every phase at the chosen depth is `DECIDED`, `ASSUMED` (and listed for review) or `OPEN` with an owner and date.
- There are no contradictions between items, or with the budget, deadline or code.
- The user has confirmed the readiness line.
- Test: for each component, could a fresh agent build and verify it from the spec alone? If not, the gap is the next question.

During the work, re-run in delta mode whenever an agent reports an assumption that changes a result, a number contradicts the spec, or the user changes direction.
