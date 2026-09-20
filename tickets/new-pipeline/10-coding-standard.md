---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-12
after:
status:    ready
attempts:  0
reviews:   0
---

## Build

Split the write-time half out of `coding-conventions`: the standard for code, fired by
the act of writing code.

## Done when

> **AC-12** The coding standard is its own skill, fires whenever code is written rather
> than only under a ticket, and contains no design guidance.

## Context

The trigger is the point. Folded into `/implement`, the standard would apply only to
ticket-driven work, which is not most of what happens in this repository. It has to
fire on an ad-hoc edit too.

What leaves with it: TDD, and everything about what good code looks like here. What
stays behind for ticket 11: domain language, module boundaries, when something
deserves an ADR.

Ticket 5 assumes this exists. If this ticket is dropped, `/implement` has no standard
to lean on and grows one, which is the failure this split exists to prevent.

## Not here

Changing what the standard says. This moves it and re-aims its trigger.
