---
id: 01
status: done
depends_on: []
---

# Show the journeys back before anything is drawn on them

## Why

`/discovery` phase 3 writes the journeys in `### Journeys` and then
builds on them immediately: the option sketches, the walk, and the stories and
criteria derived from them. The user's first sight of the journeys as written is
`### Write it`, which presents the finished spec - after all three. The
defect is that ordering, not an absence.

The walk cannot close it. `SPEC_FORMAT.md:59-63` gives a journey four fields -
`_Trigger:_`, `_Steps:_`, `_Domain effect:_`, `_Screens:_` - and the walk is an
HTML mockup of screens in order. It confirms `_Screens:_` and implies the order
of `_Steps:_`; it cannot show the trigger or the domain effect. `SPEC_FORMAT.md:74`
already names this class, asking `## Design` for an inline `_Why: ..._` covering
"what the mockup shows but cannot say".

A wrong journey is expensive because four things downstream stand on it and none
can catch it: stories decompose from it (`SPEC_FORMAT.md:65`), `### Harden it`
requires every journey step to be covered by a story, a ratified journey
is quoted verbatim into a permanent workflow test the driver protects
(`implement-ticket/SKILL.md:31`), and `check-against-spec/SKILL.md:19` makes the
journeys the acceptance's driving script - so the last gate confirms a wrong
journey rather than catching it.

The domain model already gets the turn this is missing in `### Model the domain`,
closing "every
ticket after it is built on what they agree to here". The journey composes that
confirmed model into paths and gets none.

## Satisfies

- **AC-1** - **Given** `/discovery` on the spec lane has identified the journeys
  and written them into `## Journeys`, **when** it leaves `### Journeys`,
  **then** `### Journeys` has instructed it to show them back in a turn of its
  own, placed before anything is sketched or drawn on them - so the turn falls
  ahead of both moves in `### Show, don't tell`, not between them.

- **AC-2** - **Given** that instruction, **when** an agent composes the turn,
  **then** it is told to foreground what a walk cannot ask about later - the
  trigger, what each step changes, and where the last step puts the user down -
  and told that the screens belong to the walk's question rather than this one.

- **AC-3** - **Given** that instruction, **when** an agent composes the turn,
  **then** it offers the user concrete vetoes to react against rather than a
  finished path to approve, in the shape `### Model the domain`'s show-back uses,
  and says what standing on these journeys commits the run to.

## Preconditions

- None. Nothing was built before this.

## Touches

- `discovery/SKILL.md`, `### Journeys` - the section gains a show-back
  instruction after its existing paragraph: a lead sentence, a veto list, and a
  closing line on what the run then stands on. Its first paragraph, which
  identifies the journeys and says what to write down, is unchanged.

## Provides

- Nothing. This is a single ticket with no run behind it.

## Out of scope

- **The small lane.** `## The shape` - "Phase 3 belongs to the spec lane
  alone". Untouched by construction, and not to be extended to it here.
- **The ratification seam.** A ratified journey will now be touched three times:
  this show-back, the second yes at `### Records that outlive the feature`, and
  the receipt. They ask different questions and ratification is explicitly rare.
  Ruled on by the user 2026-08-30; reopening it changes the permanent tier and
  wants its own discovery.
- **`SPEC_FORMAT.md`**, its `## Journeys` block, and every `TICKET_FORMAT.md`
  copy. Nothing here changes what a journey is, only when it is confirmed.
- **`check-against-spec/SKILL.md`.** It reads journeys as its script and does not
  care how they were agreed.
- **`### Show, don't tell`.** It keeps both its turns and its wording; this turn
  lands before it, not inside it.
- **Restating the user's-language rule** from `### Model the domain`. One
  representation per piece of knowledge; the bullets carry the register by
  example instead.

## Verification

No wording assertion is written for any criterion, and this is a stated
exception to `TICKET_FORMAT.md:120` rather than a gap.

`tests/run.sh` reads no line of any `SKILL.md`, so the suite can neither regress
on this change nor pin it. `TICKET_FORMAT.md:120` says a criterion over prose is
pinned by asserting on that file's text, and declining that rests on one thing
only: the user ruled that prose changes in this repo get no tests. That ruling is
recorded in the `Record` of the last such ticket, at `9d94c62`, where both
reviewers argued the opposite in both rounds and the ruling stood. Reversing it is
the user's and not a builder's.

The cost, stated rather than hidden: a later edit that consolidates
`### Journeys` can drop this paragraph with the suite green.

AC-1 through AC-3 are verified by reading `### Journeys` against each criterion.
The full suite must still pass unchanged - 239 passed, 0 failed at `5c5bf83`.

## Record

**Commit:** bb6d3d1

**Pinned by:**
- **AC-1** - nothing pins it. Verified by reading `### Journeys` against the
  criterion, and by confirming the new text sits above the `### Show, don't tell`
  heading and so ahead of both the sketches and the walk. Neither proof the build
  normally runs was executable: `tests/run.sh` reads no line of any `SKILL.md`,
  which both reviews confirmed independently by grep.
- **AC-2** - nothing pins it. Read the same section against the criterion; the
  three items it requires are named and the screens are assigned to the walk.
- **AC-3** - nothing pins it. Read the same section against the criterion and
  against `### Model the domain`'s show-back, whose shape it mirrors.

**Decisions:**
- **[medium]** The two rulings the user gave - foreground rather than show the
  journey whole, and leave the ratification seam alone - were written into the
  criteria and `## Out of scope` rather than into a `## Defaults` section.
  Facing where a binding ruling would actually be read, chose those because no
  copy of `TICKET_FORMAT.md` defines `## Defaults` for a spec-less ticket and
  nothing in `/implement` tells a builder to read one; rejected `## Defaults`
  because a ruling recorded where no instruction reads it can be missed. This is
  the parked entry *A small-lane ticket's defaults bind nobody in particular*,
  met head-on in the first ticket after it was parked.
- **[medium]** The closing sentence names two stakes - stories decompose from
  the journeys, and the finished feature is checked by driving them - and
  deliberately not the third, that a ratified journey binds every feature after
  this. Facing whether to name ratification as a stake, chose to leave it out
  because naming it invites "does saying yes here ratify it?", which is exactly
  the confusion the cross-reference the user declined would have had to answer.
  Rejected including it as the stronger stake, since it would have reopened a
  seam the ticket puts out of scope.
- **[low]** `### Model the domain`'s "in the user's language" rule is not
  restated in the new text. Chose to let the veto bullets carry the register by
  example, on `coding-conventions`' one-representation rule; rejected a clause
  repeating it, which would duplicate knowledge thirty lines away and drift.

**Unresolved:**
- **[low]** *The new text paraphrases "domain effect" rather than naming it.*
  Filed by the code review as a nit: `### Journeys`' untouched paragraph and
  `SPEC_FORMAT.md` both call the field "domain effect", and the show-back says
  "what each step changes" instead, so a reader has to infer they are the same
  thing. Adjudicated down: this turn is spent in the user's language, and
  "domain effect" is precisely the vocabulary `### Model the domain` says not to
  spend the user's turn on - "a turn spent on that vocabulary is a turn they
  cannot correct you in". The reviewer noted the sibling veto list paraphrases
  its terms the same way, and flagged it for awareness rather than insisting.

**Left open:**
- The `## Verification` exception has a live cost and both reviews confirmed the
  mechanism: `tests/run.sh` cannot see any `SKILL.md`, so a later edit that
  consolidates `### Journeys` can drop this paragraph with the suite green. The
  code review noted that this repo does have machinery for invariants over prose
  - the `TICKET_FORMAT.md` md5 parity check and the needle check beside it - so a
  presence check is declined by policy rather than impossible. That is the second
  ticket running to reach this; reversing the ruling is the user's.
- The ticket's `## Why` originally cited `discovery/SKILL.md` by line. The code
  review caught one slip; checking found three, all true claims behind wrong
  pointers, and all invalidated by this change's own eleven-line shift. Replaced
  with section names per `TICKET_FORMAT.md`'s rule against a `file:line` drift
  will invalidate. The two cross-file citations that remain were verified by both
  reviews and are not moved by this change.
- Both reviews ran on a peer model, per the rule as it stood when they were
  dispatched. That rule was parked for removal during this build, at `9a86a4a`.
