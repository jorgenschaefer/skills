---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-2
after:     1-intent-format
status:    ready
attempts:  0
reviews:   0
---

## Build

`/solve`, replacing `/to-solution`: an intent in, a solution spec out, with the
tradeoff sections required rather than optional, and a prose entry path.

## Done when

> **AC-2** `/solve` produces `SOLUTION_<TOPIC>.md` with required `Accepted tradeoffs`
> and `Ruled out` sections, and acceptance criteria `AC-n` each tagged with the `C-n`
> they serve. Given prose instead of an intent file, it derives the conditions first,
> stops for confirmation, and only then forms an approach.

## Context

`SOLUTION_NEW_PIPELINE.md` is a worked example. Note it answers two intents, so its
tags are qualified (`cost:C-1`, `problem:C-1`) — the format has to allow that.

The ordering on the prose path is the whole point: conditions derived after an
approach exists describe the approach. `/solve` must also refuse the prose path and
hand back to `/idea` when the conditions cannot be stated observably.

## Not here

The lean format drops `## Domain`, ubiquitous language, `## ADRs`, the defaults tiers
and `## Journeys` from `to-solution/SOLUTION_FORMAT.md`. Dropping them is this
ticket's business; the software-design skill that picks up domain language and ADRs is
not, and is not in this run at all.
