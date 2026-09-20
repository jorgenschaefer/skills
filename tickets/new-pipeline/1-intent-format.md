---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-1
after:
status:    review
attempts:  1
reviews:   0
---

## Build

Reshape `/idea` and `INTENT_FORMAT.md` so an intent carries numbered conditions,
constraints, a ratification line and a routed-back log — the sections everything
downstream addresses.

## Done when

> **AC-1** `/idea` produces `INTENT_<TOPIC>.md`, whose `Done when` is numbered `C-n`
> conditions, each stated so it can later be checked true or false without asking the
> author what it meant. It ends by a person confirming they recognize their problem.

## Context

`INTENT_PROCESS_COST.md` and `INTENT_WRONG_PROBLEM.md` are two worked examples,
written by hand against the intended format. The `## Ratified` sections of both show
the two strengths of yes that need to be expressible: on evidence, and on argument
with a falsification condition.

The existing `idea/INTENT_FORMAT.md` has `## Proposed outcome` as unnumbered prose and
no ids. Numbering is the change that makes everything downstream possible.

## Not here

The adversary that checks observability is `/verify`, ticket 3. `/idea` asks the
person; it does not grade the conditions itself.

## Record

`tests/intent-format.sh`, 14 cases, run alongside the existing `tests/run.sh` (252,
still green).

**AC-1, the format half** — `format specifies ## Problem`, `## Evidence`,
`## Done when`, `## Constraints`, `## Ratified`, `## Routed back`;
`format numbers the conditions`; `format drops the unnumbered Proposed outcome`.

**AC-1, the conformance half** — `INTENT_PROCESS_COST.md conforms` and
`INTENT_WRONG_PROBLEM.md conforms`, checking required sections, contiguous `C-n`
numbering and a non-empty `## Ratified`.

**The checker itself** — `a well-formed intent passes`, `a gap in the numbering is
caught`, `an empty ratification is caught`, `unnumbered conditions are caught`.

Six of the fourteen failed before the change, all against the format document.

**The ratification half of AC-1** — "ends by a person confirming they recognize their
problem" — is instruction to a model and has no test. It is `### Ask for the
ratification` in `idea/SKILL.md`. Nothing here can prove a model will do it.

**Follow-on, not done here:** `idea/SKILL.md` still points at `/to-solution` as the
next stage. Correct today; ticket 2 replaces it.
