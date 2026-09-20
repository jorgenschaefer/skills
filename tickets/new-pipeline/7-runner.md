---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-6, AC-7
after:     6-critique-ticket
status:    review
attempts:  1
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

## Record

`run.sh`, and `tests/runner.sh` — 17 cases, invoked by `tests/run.sh`
(256 + 18 + 22 + 32 + 10 + 16 + 17, green). Fourteen were red before the script existed;
the three that passed were the refusals, which pass vacuously against nothing.

Each case builds a throwaway repository — a solution with two criteria, a ticket for
each, a stub on `PATH` as `claude` — and runs the real script against it. The stub is
`tests/stub-session`: given a plan line it does to the ticket what that session would
have done, which is the only way to test a process whose whole job is what happens when
a session misbehaves.

**AC-6, clause by clause.**
- *Claims tickets* — `a ticket whose session died is picked up again`, which is the only
  externally visible proof that the claim went back: a ticket left at `doing` is never
  selected again.
- *Enforces the ceilings from counters in the files* — `the attempt ceiling halts the
  ticket as exhausted`, `the review ceiling halts the ticket as exhausted`, and `a dead
  session still spends an attempt`.
- *Refuses the main branch* — and `it launches nothing when it refuses`, because a
  refusal that has already started a session is not a refusal.
- *The bidirectional drift pre-flight* — one case per direction: a ticket whose
  criterion left the solution, and a criterion quoted by no ticket. Both stop the run
  before any session starts.
- *Waits out usage limits* — `a usage limit is waited out and the ticket still finishes`,
  with `waiting out a limit does not spend an attempt`, because the session never got to
  do any work.

**AC-7** — `a session halt stops the run`, and `a halt leaves the rest of the directory
alone`.

**Two bugs the tests found.** A stale `## Findings` from an earlier round made the next
review's clean verdict read as one more round of the same complaint, so a ticket could
be sent back for something already fixed until the ceiling halted it. The section is
now cleared before each review and again when the ticket is finished. And my own first
case asserted a crashed session leaves the ticket at `ready` after the run — wrong, the
runner is supposed to retry, and what needed asserting was that it does.

**Untested.** The real `claude` invocation: every case runs against a stub, so what is
proven is the runner's handling of each outcome, not that `/implement` and `/critique`
produce those outcomes. That is ticket 9's business.

**Not carried from `loop.sh`.** The build/review model split, deliberately — the design
dropped it in favour of a fresh context. Its state directory, its transcript logging,
and its handover step, which is `/accept`'s now.
