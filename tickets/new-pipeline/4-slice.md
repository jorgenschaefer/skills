---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-3
after:     3-verify
status:    done
attempts:  1
reviews:   1
---

## Build

`/slice`, replacing `/spec-to-tickets`: discovered from plan mode, works the slicing
out in context, writes `tickets/<topic>/` after approval.

## Done when

> **AC-3** `/slice` works out the slicing inside plan mode, and writes
> `tickets/<topic>/` only after the slicing is approved. Each ticket copies the
> criteria it covers verbatim.

## Context

The description is measured, not guessed — 31 headless runs, recorded under *What the
experiment showed* in `NEW_PIPELINE_IDEA.md`. Start from the v2 wording; it separates
code-change planning from research, meetings and rollouts, and fires without the word
"plan". Do not rewrite it in this pipeline's vocabulary: that is what made v1 miss
every "I want to refactor X".

This ticket directory is itself a worked example, written by hand.

Verbatim copying replaces the spec hash: a ticket carrying its own criteria cannot be
redefined from a distance.

## Not here

Detecting drift is the runner's, ticket 7. *Responding* to it is this skill's, and
this boundary originally said otherwise - see `## Findings`.

## Record

`tests/run.sh` (255 + 18 + 22 + 27, green). The new suite is `tests/ticket-format.sh`,
the third on `format-lib.sh`, which is why the library existed before it was needed.

**AC-3's last clause is the one that could be tested, and is** — after the review
found it was not. `criterion_text` pulls each criterion from the solution, `flatten`
normalises the bullet and the blockquote to the same words, and a ticket whose
`Done when` is not the solution's sentence fails. Twelve `… conforms` cases, one per
ticket, and five fixtures holding the checker itself.

**Claim and quotation must agree both ways** — `AC-n is claimed but not quoted` and
`AC-n is quoted but not claimed`. A criterion claimed and not quoted is one the builder
never sees; quoted and not claimed is work no coverage check knows about.

**Backward coverage over the directory** — `new-pipeline covers every criterion of
SOLUTION_NEW_PIPELINE.md`. Plus the frontmatter keys, the section list, and that
`status` is one the runner knows.

**The suite found a real defect in the hand-slicing.** Ticket 6 quoted `AC-4` with an
ellipsis, because `AC-4` described two parties — `/implement` building and `/critique`
reviewing — and the slicing split it across two tickets. Rather than teach the checker
to accept elided quotations, the solution was split: `AC-4` keeps the building half,
`AC-15` carries the review. That is the rule the skill now states — a criterion covered
by two slices is two criteria — arrived at by the check refusing to bend.

Appending `AC-15` also showed that append-only and grouping-by-topic conflict: placed
beside `AC-4` it broke contiguity, so it went last. Ids are ordered; topics are not.

**Untested, because it is instruction to a model.** The plan-mode sequence — work it
out, `/verify` it, present, write only after approval — which is the whole of AC-3's
first two clauses. Also what makes a slice vertical, and the re-slicing rules. The
description is the measured one from the discovery trial, and measuring it again under
competition from the other skills in this repo is ticket 9's business.

## Findings

One review round, ten findings. Nine taken.

**The check this ticket exists for was not enforcing what it claimed.** It compared by
prefix, so a ticket quoting six words of a criterion passed, and dropping a criterion's
last sentence — the most natural way a hand-slicing goes wrong — was accepted. Now
equality.

Behind it, a second bug made the first invisible: the criterion was extracted with an
unterminated `sed` range, so the *last* criterion in a solution ran to end of file and
`want` became five kilobytes of document. Any prefix matched. The extraction is awk
now, bounded by the next criterion, a heading, or a blank line — which a range cannot
express, because the last criterion has no terminator and its own bullet looks like one.

**The suite shipped without the fixtures both siblings have**, which is exactly why
those two bugs reached the commit. Five now: a faithful ticket, a quotation that stops
early, the last criterion, a quotation with words added, a changed word. Written before
the fixes, and two of them failed.

**The single-file branch repeated a bug fixed the ticket before** — the solution
resolved against this repo rather than beside the artifact — and its comment named
`/verify` as its caller, which cannot be true: the slicing `/verify` reads is text and
has no files. Resolution fixed, comment corrected to the runner's pre-flight, and
`/verify`'s own list now names this suite for written tickets.

**An empty topic directory made `ls` list the caller's working directory**, so a result
depended on where the suite was run from. It reports an empty directory now.

**The claim-against-quotation check looked at the whole file**, so a blockquoted
criterion in `## Context` satisfied it. Scoped to `## Done when`.

**The skill contradicted itself** about what re-checks the written files, said nothing
about a request arriving with no solution behind it — which the measured description
deliberately fires on — and restated the paraphrase rationale a fourth time. All three
fixed; the rationale now lives in `SLICE_FORMAT.md` alone.

**The boundary in `## Not here` was wrong, and has been corrected rather than obeyed.**
It assigned re-slicing to ticket 7 with the runner. Detecting drift is the runner's;
*responding* to it is the skill that slices, and the design says so. Amending the ticket
to match what was built is the move a reviewer should be suspicious of, so it is
recorded here rather than quietly done.

**Recorded, not fixed.** `AC-15` is not a pure split of `AC-4`: it adds that `/critique`
writes its findings into the ticket, which `AC-4` never said. It is right, and backed by
the design, but it is scope added by a slicer editing a solution — and `/verify` was
re-run on the amended solution only mechanically, not as a reading.
