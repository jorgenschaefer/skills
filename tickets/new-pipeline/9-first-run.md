---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-9, AC-10
after:     8-accept
status:    review
attempts:  1
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

## Record

`tests/consumers.sh`, 3 cases, invoked by `tests/run.sh`
(257 + 18 + 22 + 32 + 10 + 16 + 29 + 24 + 3, green).

**AC-9 is now mechanical rather than asserted.** `tests/fixtures/consumers.txt` maps
every section of every artifact to who reads it and when — 31 sections across the four
formats. The suite checks both directions: a section with no reader fails, and a reader
waiting for a section that was removed fails. Both were proven by breaking them. A
reader must be a skill, a script, or "a person at a stated moment"; anything else is not
a consumer however plausible it reads.

Writing the map is what made it real. Two sections had readers I could not name without
inventing one, and both turned out to have a genuine reader once I looked: `Open
concerns` is read by `/accept` as what was known to be unsettled, and `Routed back` on
the short path is read by a person rather than by a stage.

**AC-10 is counted, in the design document where a reader can check it.** Three
mandatory stops for a change of any size — ratification, plan approval, verdict and
merge — with the nine conditional ones named. None grows with the size of the change,
which is what `cost:C-6` asks.

**The competition trial, which is what this ticket was really for.** `/slice`'s
description was measured in an empty project at about three firings in four. In a
project holding the twelve skills this pipeline ships, it fired **zero** times in five
runs across three natural planning prompts. It fires on "cut this solution into tickets",
which is the pipeline's own vocabulary and which nobody outside the pipeline would type.
Everything else behaved: `idea` on an idea and on a new concept, `critique` and
`coding-standard` on a review, `coding-standard` when conventions were named.

That falsifies what `cost:C-3` rests on. The floor holds — a miss gives an ordinary plan
and no tickets, so nothing half-happens — but a process whose middle stage nobody
reaches is not a process with one way in. Filed in `IDEAS.md` with the three answers and
their costs, per this ticket's `## Not here`: establish the facts, do not fix them here.

**Not done: a real end-to-end run.** Every stage has been exercised against stubs and
against this repository's own paper, and the two properties AC-9 and AC-10 name are
established. What has not happened is one real change driven through all five stages
with live sessions. The discovery result is the reason to do it in that order — there is
no point measuring a pipeline whose stage (c) is not reachable by the route the design
claims.
