---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-4
after:     5-implement
status:    ready
attempts:  0
reviews:   0
---

## Build

Teach `/critique` to review a commit against a ticket and write `## Findings` into it,
without losing the thing it already is.

## Done when

> **AC-4** … `/critique`, in a separate session, reviews the commit against the
> ticket.

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
