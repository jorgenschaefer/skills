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
- Related items: `standard-follows-the-manifesto`, "Cut files by concept"
  (what shape new code is held to).

## Finding where to work

This came from an item about pointing at code before the developer stops
understanding it. Under `MANIFESTO.md` the developer never understands the
code, so that signal is gone. The checks below are for the Maintainability
goal instead, where the checkers "judge whether a new agent would find what
it needs and make its next change correctly". The origin was the weight
tracker: its "gaining weight" rule only got attention once nobody could
judge an agent's fixes to it any more.

These are directions, not decisions:

- **Checks that warn early.** From cheap to expensive:
  1. coverage scatter: how many files and modules a behaviour's deciding
     code spans, from the test suite alone (the same measure as rule 2's
     check in `standard-follows-the-manifesto`, "Cut files by concept");
  2. history: churn, the share of bug fixes, and special cases piling up
     with each fix;
  3. the change test: a fresh agent makes a plausible change in the
     domain's terms on a throwaway branch, and the diff's spread is
     measured;
  4. the round trip: a fresh agent explains the behaviour from the code,
     and its explanation has to predict the existing tests' verdicts.

  Run 1 and 2 on every behaviour, and 3 and 4 only on the top few.
- **The trend matters more than the level.** Some rules really are
  complicated. A behaviour getting worse since the last check is the
  warning, so each check is compared with the previous one.
- **The behaviours to rank** are the approved criteria, once
  `approved-criteria-outlive-the-change` keeps them. The code does not list
  them, and a list derived from routes or test groups would make the ranking
  bad too.

## What was hard to change, collected across sessions

The manifesto does not speak to what was hard to change; it is the
pipeline's own. Each build reports it in its Left standing, "each with a
suggestion: a refactoring for a structural problem, a check for an invisible
reason" (`implement/SKILL.md:73`). `/accept-criteria` proposes each as a
follow-up: "What was hard to change is never fixed now, but proposed as a
follow-up, and its reason is what skipping it would cost"
(`accept-criteria/SKILL.md:89`). `/backlog` folds a finding into an item
that overlaps, so friction in one place gathers on one item. This phase
reads those items as a signal, beside the checks above, rather than only
refactoring where it can name a future change (`restructure/SKILL.md`,
"Find what changes together").

## The project's process, too

The user also wants a retro for the codebase the pipeline runs in: how to
improve the process there, as opposed to the pipeline itself (that one is
`retro-for-the-manifesto`). It belongs in this phase. `implement/SKILL.md:70`
gives two answers to what was hard to change: "a refactoring for a structural
problem, a check for an invisible reason". Refactoring is the first; the
project retro is the second - the project's checks, its `run` skill, its
structural rules, its glossary. Both read the same input, the friction
collected across runs (above), at the same periodic stop.

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

## Cases in a rule that are only accumulated cruft

Merged from `rule-cruft` on 2026-10-29: finding the cruft is what
`PIPELINE.md` has REFACTOR for.

The rule a module implements grows complicated over time as fixes pile up.
In the weight tracker, the logic for when a weight series shows as "gaining
weight" became so convoluted that the developer no longer understood it.
Some of its cases may be needed; others may be leftovers from earlier fixes
that nothing requires any more. Nothing tells the two apart.

A clear prose description of what the code does makes such cases visible,
and should prompt asking at each one whether it is really needed. Removing
one changes behaviour, so each removal is a product decision for the user.
Parked from an `/idea` session about making code follow the structure of a
readable description of what it does, which preserves behaviour. That work
could surface candidates without acting on them.

`restructure/SKILL.md:34` already proposes cutting whole features that cost
more than they give, but not cases inside a rule.

Depends on `standard-follows-the-manifesto`, whose "Cut files by concept" is
one of the parts it combines, and on
`approved-criteria-outlive-the-change` for the list of behaviours.

## A change of access model (2026-10-27)

One refactoring this phase should notice: the auth layer collects special
cases until a more general model would be simpler, for example from roles
alone (RBAC) to roles plus conditions on the record and the request (ABAC).
Nothing is broken when that is due, so only this phase finds it. The change
is an ordinary refactoring as long as the access matrix stays the same
(`SECURITY_POLICY.md`). Where the matrix has to change, how the
security goal is checked changes, and the developer decides.
