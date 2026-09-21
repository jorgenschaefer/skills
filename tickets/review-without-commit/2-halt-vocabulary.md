---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-3
after:     1-head-check
status:    review
attempts:  2
reviews:   1
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
`tests/build-contract.sh` at 26 passed, 0 failed.

AC-3, the skill: **the unbuilt halt is named as the runner's** in
`tests/build-contract.sh`. The existing `exhausted`/`drift` case only asked that the
session is never *told* to raise the kind, which a skill that has never heard of it
passes, so the case now asks for both - named, and not instructed. RED before the edit;
dropping `unbuilt` from the sentence fails it again, and turning the sentence into an
instruction fails all three kinds.

Second pass: that case looked for the mention anywhere in the file, so it stayed green
when the kind was moved across the boundary the criterion is about. The lookup is now
scoped to the two sides of the Halts section - the kind has to be in the not-yours
sentence, and must not be among the bullets a session raises from. The finding's
constructed regression was reproduced green first, then RED against the scoped case.
Its edge is that boundary: adding the `unbuilt` bullet to the yours-list while leaving
the not-yours sentence intact - the harder half of the regression - fails it, and
turning the sentence into an instruction still fails all three kinds.

AC-3, the idea doc: **the idea's halt list has unbuilt as the runner's**, same file,
reading the bullets between the runner's-kinds sentence and the next heading. RED before
the edit. Its edge is that boundary: renaming the bullet fails it, and moving the same
bullet one line up - into the kinds a session writes - fails it too.

The doc's other enumeration of halt kinds, in the four-touchpoints count, got `unbuilt`
as well; it lists the conditional stops and would otherwise now contradict the Halts
section a few hundred lines below it. That agreement is now pinned rather than done by
hand: **the stop count names the $kind halt** takes the kinds from the Halts bullets and
asks for each in the count sentence, so the list that has to be edited is derived from
the one the case above forces. RED against the doc with `unbuilt` dropped from the count.
Its edges are the two extractions: a kind added to the Halts section and not the count
fails it, and moving a kind out of the count sentence into the one after it fails it too.

The comment above the kinds a session raises said there were two it could not, which was
the misconception the ticket exists to remove; it now introduces its own loop only, and
the third reason sits with the other two in the runner's-kinds comment.

## Findings

**Blocker — `tests/build-contract.sh:83-92` passes on a skill that hands `unbuilt` back
to the session.** The case is named *the $kind halt is named as the runner's*, and its
comment says the kinds "have to be named as its, not merely left out" - but the
assertion is only *mentioned anywhere in the file* plus *not instructed*, with no
reference to which of the skill's two lists the mention sits in. Moving the kind across
the boundary the criterion is about leaves it green.

Constructed: in `implement/SKILL.md`, drop `unbuilt` from the not-yours sentence and add
a bullet to the *kinds are yours to raise* list reading

    - **`unbuilt`** - a build that cannot be committed. Raise it when the commit cannot be made.

The skill now tells a session to
raise the runner's halt - the exact regression AC-3 exists to prevent - and
`tests/build-contract.sh` reports 20 passed, 0 failed. The `says_to` disclaimer filter
swallows the instruction because the sentence happens to contain "cannot".

The idea-doc case written in the same commit does pin this: it extracts the bullets
between the runner's-kinds sentence and the next heading, so the same move fails it. The
skill case wants the same treatment - scope the lookup to the not-yours sentence (or to
the text after the yours-list) rather than to the whole file - and the ticket's Record
should claim the edge it then actually holds.

**Should-fix — `tests/build-contract.sh:71-73` now miscounts the loop below it.** The
comment reads "The kinds a session can know about, and the two it cannot", and gives two
reasons; the loop it introduces covers three kinds, and the third reason is in the new
comment at line 80. A reader arriving at this block is told by the surviving comment that
there are two runner kinds, which is the misconception this ticket was written to remove
- and it sits in the suite whose job is to catch exactly that prose drift.

**Nit — `NEW_PIPELINE_IDEA.md:70` is now an enumeration nothing pins.** The Record names
the reason it was edited: it would otherwise contradict the Halts section. That
agreement between the two lists is the invariant, and no case holds it. The next change
to the halt kinds updates the Halts bullets (the new case forces that) and leaves line 70
stale, reproducing the contradiction this commit removed by hand.
