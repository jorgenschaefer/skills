---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7
advances:
after:     01-fast-check
status:    ready
attempts:  0
---

## Build
The manifesto says that the developer answers for the software as a whole,
and the backlog items that waited on this say so too.

## Done when
> **AC-1** Premise 1 in `MANIFESTO.md` reads: "**Humans do not read the code.** They decide what the software does, accept it on evidence they can see, and answer for it to the people who rely on it."

> **AC-2** The first line under "For every goal" in `MANIFESTO.md` reads: "The developer answers for the software as a whole, not for one change at a time. So they decide each change seeing **the whole it changes**: the rule or workflow as it will stand afterwards. Where that whole stops hanging together, such as a rule gathering special cases, an agent puts it to them as a decision, without being asked: **is this still what you want?** (1)"

> **AC-3** Nothing else in `MANIFESTO.md` changes.

> **AC-4** The backlog items `method-layer` and `critical-user-journeys` no longer say they wait on `confidence-to-answer-for-the-software`. Where they gave the manifesto's gap as a reason, they point to the new line instead.

> **AC-5** The backlog item `approved-criteria-outlive-the-change` tells the weight tracker story as the Problem above does: each fix was approved, and nobody saw them add up.

> **AC-6** The backlog item `method-layer` notes that no skill yet shows the developer the whole a change touches, or raises a whole that stops hanging together.

> **AC-7** The backlog item `method-layer` carries two notes from `confidence-to-answer-for-the-software`: that `/accept-criteria`'s "Show them what the change decided that they answer for" could be cut under its rule, though it serves this goal; and that a record of who decided what was left out on purpose, as blame rather than confidence.

## Technical decisions
> **Concepts** none

> **Wire formats** none

> **Hard to reverse** none

## Context
"The Problem above" in AC-5 is this change's Problem: in the weight tracker,
the developer approved each fix to the "gaining weight" rule, one at a time.
Nobody saw the fixes add up to a pile of special cases instead of one
approach. In the end the developer could no longer say what the rule was
meant to do, so they could not answer for it.

The backlog items are in `changes/backlog/`. The two notes of AC-7 are in
`changes/backlog/confidence-to-answer-for-the-software.md`, under "Outside
the statement". The agreed design leaves to the backlog items what makes the
developer's confidence true: the whole a change touches, a whole that stops
hanging together and steps lost in the rework to `method-layer`; approved
behaviour a later change quietly alters to
`approved-criteria-outlive-the-change`; parts no recent change touched to
`critical-user-journeys`.

What production must show, Security policy and Information model say
"None.". The change has no tests to write: its ACs are text, checked by
reading.

## Not here
- Changing any skill so that it shows the whole a change touches or raises a whole that stops hanging together. That belongs to `method-layer` and the items that build on it.
- Deleting `changes/backlog/confidence-to-answer-for-the-software.md`: `/accept-criteria` does that once the change is accepted.

## Left standing
