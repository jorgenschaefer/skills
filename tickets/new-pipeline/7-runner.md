---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-6, AC-7
after:     6-critique-ticket
status:    ready
attempts:  0
reviews:   0
---

## Build

The runner: a script that drives a ticket directory to completion with nobody
watching. Successor to `loop.sh`, which goes.

## Done when

> **AC-6** The runner drives `tickets/<topic>/` to completion unattended: it claims
> tickets, enforces the attempt and review ceilings from counters kept in the ticket
> files, refuses to start on the main branch, runs the bidirectional drift pre-flight,
> and waits out usage limits before resuming.

> **AC-7** Every unattended stop is a named halt written into the ticket — `blocked`,
> `undecided`, `mystery` from a session; `exhausted`, `drift` from the runner — and is
> addressed to a person.

## Context

It is a script and not a skill for one reason worth keeping in mind while building it:
a session cannot enforce a budget it is spending, and cannot wait out a limit that has
already stopped it. Everything here is something that must hold when the session is
dead.

The loop per ticket: claim `ready → doing`, run `/implement`, which commits and sets
`review`; run `/critique`; clean sets `done`, findings count a round and set `doing`
again. A session that exits without reaching `review` or `halted` gets its claim
reset.

The drift pre-flight runs before each pass, in both directions, and the report must
say which fired — a ticket criterion missing from the solution is an upstream edit; a
solution criterion in no ticket is slicing that lost something, which is also the only
mechanical check that the written tickets match what was approved.

## Not here

Re-slicing after a drift halt goes back through plan mode and `/slice`. The runner
detects and stops; it does not repair.
