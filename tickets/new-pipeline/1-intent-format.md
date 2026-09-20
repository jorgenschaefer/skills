---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-1
after:
status:    done
attempts:  1
reviews:   1
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

`tests/intent-format.sh`, 15 cases, invoked by `tests/run.sh` so one command runs
everything (252 + 15, green).

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

## Findings

One review round. Four were taken, three named as accepted.

**Blocking, fixed.** The Record claimed the new suite ran with the existing one, and
nothing made that so: `tests/run.sh` did not invoke it, and `README.md` still called
itself the one entry point. A suite nobody runs goes stale, and the Record asserted a
property the tree did not have. `run.sh` now runs it and folds its result; the README
says so.

**Fixed.** `### Ask for the ratification` had swallowed two paragraphs about endings
that were not about ratification, and contradicted them — it called itself the last
act while an ending below it wrote no file at all. Moved below them, and the no-file
ending now says there is nothing to ratify.

**Fixed.** The format-document assertions grepped the whole file, so deleting a section
from the template and mentioning it in the prose would have stayed green. They now
extract the fenced block first. The conformance loop was vacuous on an empty glob —
deleting both worked examples reported success — and now fails when it checked nothing.

**Accepted, not fixed.** Four of the fifteen cases exercise the checker in the test
file rather than anything shipped. They stay: without them, a broken checker would
report two conforming intents. `/verify` owns the real adversary, per `## Not here`.

**Accepted.** The relaxation of "a problem with no instance is a preference" is a policy
change to `/idea` that AC-1 does not cover and no test constrains. It was forced by
`INTENT_WRONG_PROBLEM.md`, which is ratified on exactly that ground — without it the
repository contradicts itself.

**Known inconsistency, left for ticket 2.** `to-solution/SKILL.md` says "The intent's
proposed outcome becomes the spec's success criteria", naming a section this ticket
deleted. `/to-solution` is replaced in ticket 2 and deleted in ticket 12; editing it
here would be work done twice.
