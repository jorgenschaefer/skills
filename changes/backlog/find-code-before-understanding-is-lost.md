---
effort: M
utility: L
---

# Find behaviours before the developer stops understanding them

"I don't understand this anymore" is a very late signal for refactoring.
In the weight tracker, the "gaining weight" rule only got attention once
the developer had lost track of it and could no longer judge an agent's
fixes. `explain-code` now explains a behaviour once it is
lost. The user plans to set
aside regular time for refactoring, such as one day a week or one sprint in
four, and wants an agent to point out the code to look at before it gets
that far.

Discussed on 2026-10-19, alongside what became `explain-code`.
These are directions, not decisions:

- **Checks of this kind work as early warnings.** From cheap to
  expensive:
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
  with evidence, and the one the developer picks goes to `/explain-code`.

## What was hard to change, collected across sessions

The manifesto does not speak to what was hard to change; it is the
pipeline's own. Each build reports it in its Left standing, "each with a
suggestion: a refactoring for a structural problem, a check for an invisible
reason" (`implement/SKILL.md:70`). `/accept-criteria` proposes each as a
follow-up: "What was hard to change is never fixed now, but proposed as a
follow-up, and its reason is what skipping it would cost"
(`accept-criteria/SKILL.md:87`). `/backlog` folds a finding into an item
that overlaps, so friction in one place gathers on one item. What this item
adds: `restructure` reading those items as a signal, beside the checks
above, rather than only refactoring where it can name a future change
(`restructure/SKILL.md`, "Find what changes together").

Open:

- **Listing the behaviours.** The code doesn't list them. Screens and
  routes, the groups of tests, and `UBIQUITOUS_LANGUAGE.md` where it exists
  are candidates. A badly made list makes the ranking bad too.
