---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-15
after:     5-implement
status:    ready
attempts:  0
reviews:   0
---

## Build

Teach `/critique` to review a commit against a ticket and write `## Findings` into it,
without losing the thing it already is.

## Done when

> **AC-15** `/critique`, in a session of its own, reviews each commit against the ticket
> it was built from, and writes what it wants changed into that ticket.

## Context

`/critique` survives this rewrite deliberately: it is the review anyone can run by
hand on any branch or diff, and it must stay usable that way. Taking a ticket is an
additional mode, not a replacement for its existing one.

It reviews against the ticket, never against the solution or the problem. A reviewer
allowed to reopen "is this the right approach" makes the pipeline relitigate every
prior stage.

## Not here

Deciding what happens after findings — counting the round, resetting the status,
enforcing the ceiling — is the runner's, ticket 7.
