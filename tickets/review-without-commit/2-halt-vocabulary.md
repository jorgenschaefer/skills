---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-3
after:     1-head-check
status:    ready
attempts:  0
reviews:   0
---

## Build

Put `unbuilt` in the two places that teach the halt vocabulary, so a session is not
told it may raise a kind that belongs to the runner.

## Done when

> **AC-3** `unbuilt` joins `exhausted` and `drift` as the runner's halt kinds in
> the two places that teach the vocabulary: `implement/SKILL.md`, which tells a
> session which kinds are not its to raise, and `NEW_PIPELINE_IDEA.md`'s halt
> list.

## Context

`implement/SKILL.md` lists the three kinds a session raises and names `exhausted` and
`drift` as the runner's, with the reason for each. `NEW_PIPELINE_IDEA.md`'s
*Unattended execution* section carries the same split.

`tests/build-contract.sh` already asserts that the session is not told to raise
`exhausted` or `drift`, by looking for an instruction rather than a mention. The same
case shape covers a third kind.

`SOLUTION_NEW_PIPELINE.md` and `tickets/new-pipeline/7-runner.md` also list the runner's
kinds and will be wrong afterwards. Leave both: they are quoted from each other, and
editing one without the other halts the next run of that directory on `drift`. The
solution records this as an accepted tradeoff.

## Not here

The check itself, and the halt being written. Ticket 1.
