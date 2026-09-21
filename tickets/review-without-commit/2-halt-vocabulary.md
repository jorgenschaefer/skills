---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-3
after:     1-head-check
status:    review
attempts:  3
reviews:   2
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
`tests/build-contract.sh` at 27 passed, 0 failed.

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

**Third pass, answering the findings.** The prose-shaped half of the same regression was
open: `says_to` filtered out any sentence containing `cannot`, and an instruction to raise
`unbuilt` contains it by nature. `cannot` is gone from the disclaimer list - the other
four deny, it does not. The finding's construction was reproduced green first, then RED
against the fixed filter; its edge is the kind, and the same sentence written for
`exhausted` and for `drift` fails their cases too. Removing the whole `told` branch again
fails the bullet-shaped construction, so both halves are held.

The stop-count loop could take its own cases with it: renaming `### Halts` left the
extraction empty, the loop body never ran, and the suite reported 20 passed / 0 failed
with the pinning gone. The kinds are now asserted non-empty before the loop -
**the idea's halt kinds are there to count against**. Reproduced green, then RED on the
renamed heading; its edge is the bullet shape, since the extraction reads a
backticked kind on a list bullet and nothing else. An empty count sentence no longer blames the Halts section either: the six
kinds now report that the count sentence was not found, watched by rewording
`conditional and named` and comparing against the old message.

`exhausted drift unbuilt` was written out in both document loops; it is the oracle, so it
is one `runner_kinds` above them. No behaviour change - 27 passed, 0 failed either way.

## Findings

**Blocker — `tests/build-contract.sh:91-101` still passes on a skill that tells the
session to raise `unbuilt`.** The bullet-shaped regression is closed; the prose-shaped
one is not. `told` comes from `says_to`, whose disclaimer filter drops any sentence
containing `cannot` - and an instruction to raise this kind naturally contains it,
because the kind is *about* a commit that could not be made.

Constructed: in `implement/SKILL.md`, leave the not-yours sentence exactly as it is and
add one line above it, in the same Halts section:

    If the build cannot be committed, raise `unbuilt`.

The skill now says both things: `unbuilt` is not yours, and raise `unbuilt`. Nothing
sees it. `mine` misses it because it is not a `- ` bullet, `theirs` is untouched, and
`says_to` swallows the instruction on `cannot`. `tests/build-contract.sh` reports 26
passed, 0 failed.

This is not a contrived phrasing. `implement/SKILL.md` already uses `cannot` five times,
including in the sentence that introduces the yours-list ("A session that cannot proceed
writes the halt"), so the sentence a future edit writes is likely to be exactly this
shape. The same hole is open on `exhausted` and `drift` through the same filter.

`cannot` is the odd one in that filter: the others - `never`, `not yours`, `the runner
owns`, `do not` - deny, and `cannot` is just a common word. Dropping it from the
`grep -viE` on line 41 keeps the suite at 26 passed, 0 failed and turns the construction
above red. Scoping `told` to the section outside the not-yours sentence would do it too;
either way the case should hold the property its name claims.

**Should-fix — `tests/build-contract.sh:121` is a case that can disappear without
failing.** The stop-count loop iterates over kinds extracted from the doc, so when the
extraction finds nothing the loop body never runs, no `ok` and no `bad` is written, and
the suite reports green with the pinning gone. The two loops above it are literal and
cannot do this; only the derived one can.

Constructed: rename `### Halts` to `### Halt kinds` in `NEW_PIPELINE_IDEA.md` - an
ordinary edit to a design doc, and not a violation of anything this suite is for.
`sed -n '/^### Halts/,/^### /p'` matches nothing, `idea_halts` is empty, and
`tests/build-contract.sh` reports **20 passed, 0 failed**. Six cases vanished and the
only trace is a number nobody is comparing against a previous run. The agreement the
Record says is "now pinned rather than done by hand" is unpinned from that moment on.

The derived loops elsewhere in `tests/` (`consumers.sh:53`, `standard-split.sh:110`) sit
inside an outer loop that reports per line either way, so an empty extraction there still
produces a verdict. This one is the whole case. It wants the extraction asserted
non-empty before the loop.

**Nit — `tests/build-contract.sh:118` reports the wrong cause when the count sentence is
renamed.** `counted` is found by grepping the whole file for `conditional and named`. If
that wording changes, `counted` is empty and all six kinds fail with "in the Halts
section of NEW_PIPELINE_IDEA.md, not in the count" - which sends the reader to a count
sentence that does in fact list every kind. The sibling case one block up names its own
cause precisely; this one should say that the count sentence was not found.

**Nit — `tests/build-contract.sh:91` and `:109` state the runner's kinds twice.** Both
loops are `for kind in exhausted drift unbuilt`, and both change for the same reason: a
fourth runner kind means editing both. Editing only one leaves the other document
unpinned, silently and in green. The list is the oracle and belongs in one variable above
the two loops. (The third loop already derives its list, so this is two copies, not
three.)

