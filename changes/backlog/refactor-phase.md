---
effort: XL
utility: L
---

# A refactor phase every few changes

The user wants to go through a "refactor" phase every few
idea → accept-criteria iterations, to improve the codebase over time where
it deteriorates, and to combine `explain-code`, `restructure` and
`untangle` into that step. What a refactor phase means still needs
thought.

## What is there today

- `restructure` sweeps the whole codebase "every one to two weeks": checks
  first, co-change from git history, proposals, then ten kinds of
  behaviour-preserving restructuring, each only for a future change it can
  name (`restructure/SKILL.md`).
- `explain-code` explains a part of the code once the developer can no
  longer follow it; `untangle` turns that explanation into a `CRITERIA.md`
  that reworks the code into its concepts, sliced by `criteria-to-tickets`.
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

## Where the three depart from MANIFESTO.md

- **explain-code smooths over differences.** The manifesto: "On request, an
  agent explains any part of the program in those words, and says where the
  code thinks of things differently." The rewriter never sees
  the code and "may cut, merge and drop detail"
  (`explain-code/SKILL.md:28`); the checker reports only contradictions, and
  "a missing detail is never a finding" (`:29`). Nothing reports where the
  code's concepts do not match the words used where the answer shows, which
  is what `untangle` works from.
- **restructure judges its own result.** It applies what it can prove
  preserves behaviour (`restructure/SKILL.md:55`) and commits (`:70`); the
  green suite proves behaviour, but whether the code got easier to change is
  judged only by the session that changed it. The manifesto: "Nothing
  reliably judges its own work."
- **untangle shows the developer code.** Each module comes with "its
  functions or types and their parameters", plus "one call from an existing
  test, rewritten against the new modules" (`untangle/SKILL.md:23-24`). The
  concept-to-module mapping and the sample change in the explanation's terms
  (`:27`) are what the developer can judge.
- **untangle's CRITERIA.md is not checked** by a fresh adversary, unlike
  `find-criteria`'s; it is handed straight on (`:102`).
- **untangle's proofs do not stay.** `checks.md` and `test-map.md` are
  deleted with the change's directory; the manifesto wants a check that
  "executes and stays".

## Where they depart from the rest of the pipeline

- **restructure refactors where it can name a future change, without
  asking.** `accept-criteria/SKILL.md:87` has what was hard to change come
  to the user instead: "What was hard to change is never fixed now, but
  proposed as a follow-up, and its reason is what skipping it would cost",
  and "The user may skip it."
- **untangle's ACs test the decision** ("<Concept> is the module `<path>`")
  rather than the constraint - a change in the explanation's terms lands in
  one place. The rule "Test the constraint, not the decision it led to" left
  the manifesto and waits to go into the standard
  (`standard-follows-the-manifesto`).

Depends on `cut-files-by-concept`, `find-code-before-understanding-is-lost`
and `rule-cruft`, the parts it combines, and on
`approved-criteria-outlive-the-change`, which makes untangle's proofs stay.
