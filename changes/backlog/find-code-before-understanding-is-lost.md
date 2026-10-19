---
effort: M
utility: M
---

# Find behaviours before the developer stops understanding them

"I don't understand this anymore" is a very late signal for refactoring.
In the weight tracker, the "gaining weight" rule only got attention once
the developer had lost track of it and could no longer judge an agent's
fixes (see `code-reads-like-its-description.md`). The user plans to set
aside regular time for refactoring, such as one day a week or one sprint in
four, and wants an agent to point out the code to look at before it gets
that far.

Discussed in the same session as the readable-code item, on 2026-10-19.
These are directions, not decisions:

- **The readable-code skill's own checks work as early warnings.** From
  cheap to expensive:
  1. coverage scatter: how many files and modules a behaviour's deciding
     code spans, from the test suite alone;
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
- **An optional check on the developer.** The agent shows three cases for a
  behaviour the developer thinks they know, and they predict the verdicts.
  It is the most direct measure, but it costs their time, so it is their
  choice.
- **It extends `restructure` rather than being a new skill.** `restructure`
  already runs every one to two weeks over the whole codebase, reads the
  history, compares with its previous run and ends with proposals
  (`restructure/SKILL.md`). The addition is a ranked list of behaviours
  with evidence, and the one the developer picks goes to the readable-code
  skill.

Open:

- **Listing the behaviours.** The code doesn't list them. Screens and
  routes, the groups of tests, and `UBIQUITOUS_LANGUAGE.md` where it exists
  are candidates. A badly made list makes the ranking bad too.
- **It depends on the readable-code skill existing.** Until then the list
  points at problems with no tool to fix them.
