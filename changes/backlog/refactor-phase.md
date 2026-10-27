---
effort: XL
utility: L
---

# A refactor phase every few changes

The user wants to go through a "refactor" phase every few
idea → accept-criteria iterations, to improve the codebase over time where
it deteriorates, and to combine `explain-code` and `restructure` into
that step. What a refactor phase means still needs
thought.

## What is there today

- `restructure` sweeps the whole codebase "every one to two weeks": checks
  first, co-change from git history, proposals, then ten kinds of
  behaviour-preserving restructuring, each only for a future change it can
  name (`restructure/SKILL.md`).
- `explain-code` explains a part of the code once the developer can no
  longer follow it.
- Related items: `find-code-before-understanding-is-lost` (pointing at code
  before it is lost, as an extension of `restructure`, and collecting what
  was hard to change across sessions), `rule-cruft` (cases in a rule nothing
  needs any more), `cut-files-by-concept` (what shape new code is held to).

## The project's process, too

The user also wants a retro for the codebase the pipeline runs in: how to
improve the process there, as opposed to the pipeline itself (that one is
`retro-for-the-manifesto`). It belongs in this phase. `implement/SKILL.md:70`
gives two answers to what was hard to change: "a refactoring for a structural
problem, a check for an invisible reason". Refactoring is the first; the
project retro is the second - the project's checks, its `run` skill, its
structural rules, its glossary. Both read the same input, the friction
collected across runs (`find-code-before-understanding-is-lost`), at the
same periodic stop.

Today `retro` finds project-side failures but, living only in this
repository, cannot fix them: a fix "is fixed in the project, and changed
only when the user asks for it there; otherwise give the wording"
(`.claude/skills/retro/SKILL.md`, "Pipeline or project"). Its moments - a
person stepping in, defects caught late, searching, interference - and its
mechanism ladder (something that executes, then a check without a stake,
then an instruction) are what the project side would reuse.

## Where the two depart from MANIFESTO.md

- **explain-code smooths over differences.** The manifesto: "On request, an
  agent explains any part of the program in those words, and says where the
  code thinks of things differently." The rewriter never sees
  the code and "may cut, merge and drop detail"
  (`explain-code/SKILL.md:28`); the checker reports only contradictions, and
  "a missing detail is never a finding" (`:29`). Nothing reports where the
  code's concepts do not match the words used where the answer shows.
- **restructure judges its own result.** It applies what it can prove
  preserves behaviour (`restructure/SKILL.md:55`) and commits (`:70`); the
  green suite proves behaviour, but whether the code got easier to change is
  judged only by the session that changed it. The manifesto: "Nothing
  reliably judges its own work."

## Where they depart from the rest of the pipeline

- **restructure refactors where it can name a future change, without
  asking.** `accept-criteria/SKILL.md:87` has what was hard to change come
  to the user instead: "What was hard to change is never fixed now, but
  proposed as a follow-up, and its reason is what skipping it would cost",
  and "The user may skip it."

## Found while removing untangle (2026-10-27)

- The user: `untangle` "was one idea and attempt to achieve something
  restructure should do - using explain-code as the basis".
- **Restructurings nobody picks up.** Since 201edfe, `restructure` leaves a
  restructuring it cannot prove safe undone and names it in one line of its
  report (`restructure/SKILL.md:60`). Nothing picks it up later. The
  refactorings a build suggests for what was hard to change
  (`implement/SKILL.md:70`) reach the developer as follow-ups at acceptance
  (`accept-criteria/SKILL.md:87`). That is a decision about the code, put in
  front of them. The user: "someone (restructure) noticed a useful
  refactoring that it could not do. Maybe we extend restructure to the full
  refactor step, or we write a new refactor-stage skill that uses
  restructure".
- **Step 9 contradicts the standard.** "A name in stored data or on the
  wire is a proposal" (`restructure/SKILL.md:50`). But `CODING_STANDARDS.md`,
  under Ubiquitous Language, says such a name "is not renamed for this
  alone" and is mapped to the domain name at the boundary.
- **Where an agent following `restructure` was unsure**, in an acceptance
  walk on made-up findings:
  - A file moved "with its content unchanged" whose imports then break.
  - Whether a habit rule made into a check also gets a list of today's
    breaks and a line in `CLAUDE.md`.
  - What to count on a first run, with no previous counts.
  - Where the report goes.
  - "The user" meaning both the developer and the app's user.

Depends on `cut-files-by-concept`, `find-code-before-understanding-is-lost`
and `rule-cruft`, the parts it combines.

## A change of access model (2026-10-27)

One refactoring this phase should notice: the auth layer collects special
cases until a more general model would be simpler, for example from roles
alone (RBAC) to roles plus conditions on the record and the request (ABAC).
Nothing is broken when that is due, so only this phase finds it. The change
is an ordinary refactoring as long as the access matrix stays the same
(`security-in-the-standard`). Where the matrix has to change, how the
security goal is checked changes, and the developer decides.
