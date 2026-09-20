---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-3
after:     3-verify
status:    ready
attempts:  0
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
