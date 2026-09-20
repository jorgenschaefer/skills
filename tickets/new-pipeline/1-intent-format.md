---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-1
after:
status:    ready
attempts:  0
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
