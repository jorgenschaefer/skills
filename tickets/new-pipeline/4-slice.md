---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-3
after:     3-verify
status:    review
attempts:  1
reviews:   0
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

Re-slicing rules (committed tickets immutable, append-only numbering, second
approval) are real but belong with the runner that detects drift, ticket 7.

## Record

`tests/run.sh` (255 + 18 + 22 + 27, green). The new suite is `tests/ticket-format.sh`,
the third on `format-lib.sh`, which is why the library existed before it was needed.

**AC-3's last clause is the one that could be tested, and is.** `criterion_text` pulls
each criterion from the solution, `flatten` normalises the bullet and the blockquote to
the same words, and a ticket whose `Done when` is not the solution's sentence fails.
Twelve `… conforms` cases, one per ticket.

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
