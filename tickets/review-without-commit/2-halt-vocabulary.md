---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-3
after:     1-head-check
status:    review
attempts:  4
reviews:   3
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

**Fourth pass, answering the findings.** The idea doc's case asked whether a kind appears
among the runner's bullets and nothing more, so the half of the split the skill's case had
already been rewritten around was open here: the doc could say `unbuilt` is the runner's
and hand it to a session in the same section. It now reads both lists - `idea_theirs` from
the runner's sentence to the next heading, `idea_mine` from *The kinds a session writes*
down to that sentence - and a kind in both is a `bad` naming which. The finding's
construction was reproduced green at 28 passed first, then RED against the scoped case;
the same duplicate bullet written for `exhausted` and for `drift` fails their cases too.
Its edge is that boundary: moving the runner's `unbuilt` bullet verbatim up into the
session's list fails it, and renaming the bullet still fails this case and the stop count's.

The non-empty guard is `expect_counted` from `tests/format-lib.sh`, which this file already
sources and which exists for this rule; the hand-rolled version restated its comment. Same
verdict on the renamed heading - 20 passed, 1 failed - under the helper's case name.

## Findings

One review round: one should-fix, one nit. `tests/run.sh` is 257 passed / 0 failed with
`tests/build-contract.sh` at 27. Every `Record` claim was checked by mutation and every
one held - dropping `unbuilt` from the not-yours sentence, adding it as a bullet to the
yours-list with that sentence intact, and adding "If the build cannot be committed, raise
`unbuilt`." above it each fail the skill case; renaming the idea's bullet fails two cases;
dropping `unbuilt` from the count sentence fails one; rewording `conditional and named`
fails all six with the cause named; and renaming `### Halts` now fails on the empty
extraction at 20 passed / 1 failed rather than at 20 passed / 0 failed.

**Should-fix — `tests/build-contract.sh:116-120` asks whether the idea doc mentions a
kind as the runner's, not which side of its split the kind is on.** The previous round
established that the side is the criterion and the skill's case was rewritten around it -
`mine` and `theirs`, with a bullet on the wrong side failing. The other of the two places
AC-3 names kept the old shape: `grep -q "^- \`$kind\`"` inside the runner's bullets, and
nothing looks at the list above them.

Constructed: in `NEW_PIPELINE_IDEA.md`, leave the runner's `unbuilt` bullet exactly as it
is and add one to *The kinds a session writes*, above `mystery`:

    - `unbuilt` — the build produced no commit.

The doc now says both things, and the doc is where the next skill is written from.
`tests/build-contract.sh` reports **28 passed, 0 failed** - a case more than before,
because `idea_halts` extracts `unbuilt` twice and the stop-count loop runs seven times.
The one number a reader might compare against a previous run moves in the reassuring
direction. The identical edit to `implement/SKILL.md` fails, which is the whole of the
asymmetry: the same regression is caught in one document and rewarded in the other.

The fix is the shape the skill case already has - the kinds a session writes are a
sed range away, and a kind found in both lists is a `bad`.

**Nit — `tests/build-contract.sh:133-135` hand-rolls the guard `tests/format-lib.sh:53`
already provides.** `expect_counted` exists for exactly this - its comment is "An empty
glob is zero cases and zero failures, which reads as success", which is the sentence the
new guard's own comment restates - and this file already sources `format-lib.sh`. Two
representations of one rule: the next suite that grows a derived loop greps
`expect_counted`, finds the three format suites, and does not find this. It wants
`expect_counted "$(printf '%s\n' "$idea_halts" | grep -c .)" "halt kinds"`, or - if the
more specific case name is worth keeping - a note saying why the helper did not fit.

