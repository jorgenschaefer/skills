---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-9, AC-10
after:     8-accept
status:    done
attempts:  1
reviews:   1
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

`tests/consumers.sh` (3 cases) and, after the review, `tests/handoffs.sh` (11),
invoked by `tests/run.sh` (257 + 18 + 22 + 32 + 10 + 16 + 29 + 24 + 3 + 11, green).

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
their costs. **Then fixed, which this ticket's `## Not here` forbids** — see below.

**Not done: a real end-to-end run.** Every stage has been exercised against stubs and
against this repository's own paper, and the two properties AC-9 and AC-10 name are
established. What has not happened is one real change driven through all five stages
with live sessions. Stage (c) is reachable again, so the reason for deferring it is no
longer the discovery result — it is simply that it has not been done, and it is the last
thing standing between this pipeline and ticket 12.

## Findings

One review round, ten findings. All ten taken.

**The boundary was crossed, and this Record said otherwise.** `## Not here` reserves
fixing for later; the finding was filed, the user chose an answer, and `5cc5694` made
`/slice` typed. That is authorised and it is still a boundary crossing, and until this
paragraph the ticket claimed the opposite while pointing at an `IDEAS.md` entry the fix
had deleted. Recorded rather than argued away.

**AC-9 failed on its own terms inside the map written to prove it.** `## Non-goals` was
mapped to `/critique` — a skill whose ticket mode says, in bold, never to open the
solution. So the section had no reader at all. Four more mappings were aspirational: the
named skill never read the section and nothing in it described the act. The honest
choices were to delete each section or to give it a reader, and the readers turned out
to exist once looked for: `/slice` places non-goals into the `## Not here` of the ticket
a builder would wander out of, places each edge case in the slice that owns it, and
settles or defers the open concerns before cutting; `/solve` reads the intent's
`## Not this` as a fence and says what its approach does with each open question. Those
are instructions now, not hopes.

**Five real readers were missing, all of them mechanical.** The runner's read of
`## Findings` decides whether every ticket goes back — the most load-bearing consumer in
the file, absent from it. Same for its read of `## Halt` in the stuck report, its drift
pre-flight over `## Done when`, `/verify` re-deriving the problem from `## Problem`, and
the format suites. A map of consumers that omits the scripts is a map of the prose.

**Two mutation escapes in the suite.** Readers after the first semicolon were never
existence-checked — six mappings name a second reader — and a bare "a person" with no
moment passed, which the map's own header forbids. Both closed and both proven.

**AC-10's count was wrong and a reader would have found it in ten minutes.** "Three
mandatory stops, nothing in between asks" — while `/solve` asks twice in every ordinary
run, to agree what decides between candidates and to choose one. It is four now, with
the reasoning written down, because a count is only worth stating if it survives being
checked. C-6 holds either way: four does not grow with the size of the change.

**The chain the fix pinned was missing its last link.** Nothing named `/accept`
anywhere in the repository — the typed stage that closes a run, reachable by nobody. The
runner names it now when it finishes, and `/implement` naming `/critique` is pinned too.

**Smaller.** The design document listed the discovered skills twice, 375 lines apart,
and the two lists disagreed about `/implement`. The intent's open question about
discovery still said the competition case "could still overturn it" after it had.

**On `cost:C-3`.** The reviewer agrees it survives unamended — it asks how work is
*started*, and `/slice` is not where work starts — but notes the repo said both things
at once. The intent now records the competition result and what is left exposed:
`/idea`, the door, still rests on discovery, measured on two prompts.
