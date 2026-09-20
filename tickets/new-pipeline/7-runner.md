---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-6, AC-7
after:     6-critique-ticket
status:    done
attempts:  1
reviews:   1
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

`run.sh`, and `tests/runner.sh` — 29 cases after the review, 17 at first, invoked by `tests/run.sh`
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

## Findings

One review round, fifteen findings, three of them blockers. Twelve taken.

**The runner deleted the brief the rework needed.** `/implement` says the ticket's
`## Findings` is what a second pass builds from. The runner cleared that section at the
end of every round, including the round that wrote it — so a rework session saw a ticket
identical to the one it had already built, with no reason for its return, and spent the
budget until the ceiling halted it. The clear now happens only before a review. The
copy at the end turned out to be unreachable, which a mutation proved: no case could be
made to fail by removing it, because the pre-review clear had already done the work.
Deleted rather than kept.

**It reported success whenever it could not select a ticket.** A stale `doing` from a
killed runner, a halted ticket, a dependency naming a ticket that does not exist — all
of them ended the loop, printed "every ticket is done" and exited 0. Against this
repository's own directory it said exactly that while eight tickets waited. It now walks
the directory at the end and names what is unfinished and why. `loop.sh` had four
functions for this and the Record had not noticed they were gone.

**`drift` was never written into a ticket**, though AC-7 names it as one of the two the
runner writes. It went to stderr and exited. Now the first offending ticket carries the
halt, with what to do about it.

**Five cases claimed coverage they did not have**, each proven by mutation: the review
ceiling could be disabled entirely and the suite stayed green, because the attempt
ceiling halted the same ticket with the same word; dependency order was pinned only by
the filenames agreeing with it; neither counter's value was asserted. There are cases
for each of those now, including one where the numbering says the opposite of `after:`.

**Two smaller defects with real consequences.** `set_field` rewrote any line in the file
matching the key, so a ticket documenting the ticket format — which this repository is
full of — had its body rewritten. And a `README.md` in the ticket directory made every
pass fail as drift.

**Not fixed, recorded.** The limit predicate matches the CLI's human-readable wording
where `loop.sh` read the structured rate-limit event; if the wording changes, every
limit becomes a failure that spends the budget. The waiting itself and the give-up cap
are still untested. `unrecoverable` — not logged in, expired token, empty balance — is
gone, so those now burn every attempt and halt as `exhausted`, which is a lie about the
work. The runner still trusts `status: review` without checking a commit happened, and
trusts a halted ticket's `## Halt` without checking the kind is one a session may raise.
The Record's "not carried from `loop.sh`" named three things; the true list is about ten.
