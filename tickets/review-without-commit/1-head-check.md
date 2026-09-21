---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-1, AC-2, AC-4, AC-5, AC-6
after:
status:    review
attempts:  2
reviews:   0
---

## Build

Teach the runner to remember where `HEAD` was before it launched a build session, and
to stop believing a session that says it built something without moving it.

## Done when

> **AC-1** The runner records `HEAD` before each build session and, on `status:
> review`, requires it to have moved.

> **AC-2** A session that reported a build without committing is retried within
> the attempt budget, as a crashed one is. When the budget is spent, the runner
> halts the ticket as `unbuilt` — saying the session claimed a build and
> committed nothing, rather than that the budget ran out — and the run stops, as
> it does on every other halt.

> **AC-4** The runner suite exercises a session that sets `review` and commits
> nothing, and the stub can be told to behave that way.

> **AC-5** A rework pass, which commits again on an earlier commit, does not
> halt.

> **AC-6** The runner refuses to start in a repository with no commits, where
> `HEAD` cannot be read and the check would otherwise pass by accident.

## Context

`run.sh` launches the build session at the `session "$ticket" implement` call and then
reads `status` out of the ticket. `review` is accepted there with no further check.
Around it: a crashed session already resets the claim and spends an attempt, which is
the tolerance this failure is being given too, and `halt()` writes a `## Halt` section
and sets `status: halted`; every caller of it exits.

`tests/stub-session` is the instrument. It commits on `implement:review` today, which
is why no case in the 29 has ever exercised this. It needs an outcome that sets the
status and commits nothing.

The refusal for a repository with no commits goes beside the other pre-launch refusals.
`--is-inside-work-tree` succeeds there, and `git rev-parse --abbrev-ref HEAD` fails, so
the branch check passes by accident today.

## Not here

The halt kind's appearance in `implement/SKILL.md` and `NEW_PIPELINE_IDEA.md` is ticket
2. Write the halt; do not teach it.

## Record

`tests/run.sh` — 257 passed, 0 failed, which includes `tests/runner.sh` at 37.

**AC-1, AC-2** — `a session that committed nothing still spends an attempt`, `a build
that never commits halts once the budget is spent`, `the halt is named for what
happened, not for the budget`, `and says the session claimed a build and committed
nothing`. `head_before` is read just before the build session and compared once
`review` has been accepted, so a status the session wrote is checked against a commit
it cannot fake. An unmoved HEAD is given a crash's tolerance — the claim goes back and
the attempt is spent — and the halt fires on the attempt that spends the last of the
budget rather than letting the next pass report `exhausted`.

**AC-4** — the stub's new `implement claim-only`: it appends to the ticket and sets
`review`, and commits nothing. `implement review` was the only build outcome before,
which is why none of the suite's cases could reach this.

**AC-5** — `a rework that commits again is not read as a build that committed nothing`.
A rework's commit lands on the one the first pass left, so HEAD has moved twice rather
than not at all; the case runs findings, a second build and a clean review and asserts
no `## Halt`.

**AC-6** — `it refuses a repository with no commits`, `a repository with no commits
launches nothing`. `git rev-parse HEAD` beside the other pre-launch refusals, above the
branch check that passes there by accident.

**Each criterion was broken and watched to fail.** Deleting the refusal fails AC-6's two
cases; inverting the HEAD comparison fails the rework case and sixteen more; moving the
budget edge from `-ge` to `-gt` fails the two that name the halt — and, worth saying,
*not* the case asserting it halted at all, which the wrong halt satisfies. The kind and
its wording are what pin AC-2, not the status.

