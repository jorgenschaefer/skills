# Review: the developer answers for the software as a whole

## For you

Needs your decision first:

- **Where the weight tracker story lives** (review, round 1; ticket 02). AC-5
  puts the story in `approved-criteria-outlive-the-change`. But the story is
  about fixes nobody saw add up, and the agreed design gives that part, "a
  whole that stops hanging together", to `method-layer`. The item that holds
  the story is about something else: a later change quietly altering
  approved behaviour. Moving the story would go against AC-5, so I left it.
  Decide whether it stays, moves to `method-layer`, or appears in both.

The rest of what is open, most important first:

- **The fast check is over 30 seconds on small machines** (ticket 01). It
  takes 22 seconds on 24 cores, 35 on 4 and 67 on 2, because the gain comes
  from running the suites side by side. Run alone, `tests/run/report.sh`
  takes about 30 seconds and `tests/run/drift.sh` about 26. Each case starts
  about 1,300 processes in the runner. Making the runner start fewer would
  fix this on every machine. That is a change of its own.
- **No pre-commit hook and no CI workflow** (ticket 01). The standard asks
  for both. Neither existed before this change. Adding them is a change of
  its own.
- **No automated test proves AC-1 to AC-7** (ticket 02). They are text. Both
  review rounds checked them by reading: AC-1 and AC-2 match word for word,
  and the diff of `MANIFESTO.md` is exactly those two lines.

## Findings fixed

Round 1 (critique of the whole change):

- **Should-fix: the backlog items did not say which part of the Problem they
  carry.** The agreed design splits it among three items, and `CRITERIA.md`
  goes once the change is accepted. Each item now cites the manifesto line
  and names its part: `method-layer` what the line asks of each change,
  `approved-criteria-outlive-the-change` approved behaviour a later change
  quietly alters, `critical-user-journeys` the parts no recent change
  touched. Each also says that its part reaches the developer without their
  having to ask, as the Problem asks.
- **Should-fix: one concept under two names.** The manifesto bolds "the
  whole it changes", and `method-layer` said "the whole a change touches",
  the wording of AC-6. A step that cites the manifesto by its wording would
  not find the phrase. `method-layer` now uses the manifesto's name. AC-6
  still holds, because it asks for the note and not for its exact words.
- **Nit: the `/accept-criteria` note contradicted the sentence above it.**
  The opening said a step that serves the goal cites the line, and the note
  said such a step could be cut. The note now says the step cites nothing
  yet, and should cite the line rather than be cut.
- **Nits: two comments in `test.sh`.** One said the longest suite decides
  the time, which is true only with a core for each suite. The other said
  each suite is named after a file of the library, which `loop-checks.sh`
  and `loop-sessions.sh` are not quite.

Round 2 (critique of the round-1 fixes) found three wording should-fixes. I
fixed all three in b5fd9bc: an "it" in `method-layer` that pointed at the
skill, a "though" that still pulled against the opening, and "the part of
that which" in `critical-user-journeys`.

## Findings not fixed

- **Round 1, should-fix, in part:** move the story to the item that owns it.
  This is the decision under "For you".
- **Round 2, nit:** in `approved-criteria-outlive-the-change`, nothing links
  the story to the part the item says it carries. That gap goes away or
  stays depending on the decision above.

## Fixes no reviewer saw

The round-2 fixes in b5fd9bc. Each answers one of round 2's three
should-fixes above. A round-2 nit about `critical-user-journeys` ("a journey
that breaks reaches the developer") is fixed in the same commit. The fast
check is green after them.

## Checks

I ran the fast check `./test.sh` after each round of fixes. It was green both
times, in about 22 seconds. The project has no slow check. No fix was written
test-first: every fix is to backlog text or a comment, which no test reads.

## Tradeoffs, blast radius and revert

My fixes change only backlog text and two comments in `test.sh`. No code
behaves differently. Reverting a6ac769 and b5fd9bc undoes them completely.
