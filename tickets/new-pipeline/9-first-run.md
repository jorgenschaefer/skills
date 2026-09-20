---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-9, AC-10
after:     8-accept
status:    ready
attempts:  0
reviews:   0
---

## Build

Run the finished pipeline on one real change, end to end, and establish the two
properties that no single skill can be responsible for.

## Done when

> **AC-9** Each artifact section has a named consumer, stated in the design: the intent
> is read by `/solve` and `/accept`, the solution by `/slice` and the runner's
> pre-flight, the ticket by `/implement` and `/critique`, the verdict by a person at
> the merge. A section nothing reads is removed rather than kept.

> **AC-10** Three mandatory human decisions per change, fixed regardless of how large
> the change is: recognize the problem, approve the slicing, read the verdict and
> merge. Every other interruption is a named conditional — an `undecided` interrupt, a
> halt, raising a ceiling, abandoning, or a re-slice approval.

## Context

These are properties of the assembled pipeline, not features of any skill, so they can
only be established by using it. Count the stops; name the reader of every section
that was written. Anything unread gets deleted here rather than kept for later.

This is also the discovery experiment's missing half: the first run happens in a
repository where `/critique`, the coding standard and `/slice` all compete for the
same requests, which the 31-run trial did not test.

## Not here

Fixing what the run finds. File it; this ticket establishes the facts.
