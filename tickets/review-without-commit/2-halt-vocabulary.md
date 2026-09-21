---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-3
after:     1-head-check
status:    review
attempts:  1
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

## Record

`tests/run.sh` - 257 passed, 0 failed of its own cases, every child suite green, with
`tests/build-contract.sh` at 20 passed, 0 failed.

AC-3, the skill: **the unbuilt halt is named as the runner's** in
`tests/build-contract.sh`. The existing `exhausted`/`drift` case only asked that the
session is never *told* to raise the kind, which a skill that has never heard of it
passes, so the case now asks for both - named, and not instructed. RED before the edit;
dropping `unbuilt` from the sentence fails it again, and turning the sentence into an
instruction fails all three kinds.

AC-3, the idea doc: **the idea's halt list has unbuilt as the runner's**, same file,
reading the bullets between the runner's-kinds sentence and the next heading. RED before
the edit. Its edge is that boundary: renaming the bullet fails it, and moving the same
bullet one line up - into the kinds a session writes - fails it too.

The doc's other enumeration of halt kinds, in the four-touchpoints count, got `unbuilt`
as well; it lists the conditional stops and would otherwise now contradict the Halts
section a few hundred lines below it.
