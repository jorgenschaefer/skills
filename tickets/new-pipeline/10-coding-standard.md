---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-12
after:
status:    review
attempts:  1
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

## Record

`tests/standard-split.sh`, 6 cases, invoked by `tests/run.sh` (255 + 18 + 22 + 32 + 6,
green).

**AC-12, and the case that actually guards it.** `the split loses no section` reads the
headings of `coding-conventions/SKILL.md` as it stood at `c6bfc1d` and requires each to
be in exactly one half; `the split duplicates no section` is the same walk in the other
direction. Splitting a document is safe only if nothing falls between the halves, and
that is mechanical.

**`the standard carries no design guidance`** — the five design headings by name.
Naming them rather than inferring them is deliberate: which side a section belongs on
was a decision, and a decision that quietly reverts is what the case exists to catch.

**`the standard is not scoped to tickets`** — the description may not name a ticket,
because being read only under one is the precise failure this split exists to prevent.
Thin, and it pins the one thing AC-12 says about the trigger.

**Untested.** Whether the description actually fires when code is being written. That
is discovery, it is measurable the way `/slice`'s was, and it is not measured here —
the trial belongs with ticket 9, under competition from the other skills.

**What moved.** `## Domain layering` and its four subsections — domain naming, the
seams, domain objects, conceptual granularity — are the shape of a change, decided
while planning. Everything else is what the code should look like once written.

**What `coding-conventions` is now.** The design half, kept under its own name with a
narrowed description until ticket 11 turns it into the software-design skill. It was
not left holding both halves, because a standard that still contains what it was split
out of is not split.

**References.** `/critique` and `/upgrade-dependencies` now name `coding-standard`;
`/critique` reads the design half as well when a change moves a seam or names a new
concept. `implement/`, `check-against-spec/` and `to-solution/` still say
`coding-conventions` and now mean something narrower by it. They are deleted in ticket
12, and editing them here is work done twice.
