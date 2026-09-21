---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-1, AC-2, AC-4, AC-5, AC-6
after:
status:    ready
attempts:  1
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

