# Plan: confirm the journeys before anything is drawn on them

Source: the `IDEAS.md` entry *The mockup is built on a journey the user has
never seen written down* (`IDEAS.md:154`). Analysed 2026-08-30; the entry's
premise needed correcting and the solution needed narrowing, both below.

## The problem

`/discovery` phase 3 writes the journeys (`discovery/SKILL.md:154`) and then
immediately builds on them: the option sketches, the walk, and the stories and
criteria derived from them. The user's first sight of the journeys as written
is `### Write it` (`:224`), which presents the finished spec inline - after all
three.

**The entry's premise is wrong on one point and the ticket must not repeat it.**
The journeys are not "never seen written down"; `### Write it` shows them. The
defect is ordering: they are seen only after the artifacts that depend on them
exist.

**What the walk can and cannot confirm.** `SPEC_FORMAT.md:59-63` gives a journey
four fields - `_Trigger:_`, `_Steps:_`, `_Domain effect:_`, `_Screens:_`. The
walk is an HTML mockup of screens in order: it confirms `_Screens:_` and,
implicitly, the order of `_Steps:_`. It cannot show `_Trigger:_` ("the actor and
the occasion") or `_Domain effect:_` ("which actors act on which work objects,
and what domain events that raises"). `SPEC_FORMAT.md:74` already names this
class - `## Design` asks for an inline `_Why: ..._` for "what the mockup shows
but cannot say".

**Why a wrong journey is expensive.** It is load-bearing in four places
downstream, and none of them can catch it:

- stories decompose from it - "a story belonging to no journey is a story
  nobody asked for" (`SPEC_FORMAT.md:65`);
- `### Harden it` requires "every journey's steps are covered by stories"
  (`discovery/SKILL.md:215`), so a wrong step *becomes* a required story;
- a ratified journey is quoted verbatim into a permanent workflow test, and
  `implement-ticket/SKILL.md:31` has the driver halt a ticket that edits one;
- `check-against-spec/SKILL.md:19` - "**The spec's `## Journeys` are the
  script.**" The acceptance drives the journey, so a wrong one is confirmed by
  the last gate rather than caught by it.

**The asymmetry.** `### Model the domain` (`discovery/SKILL.md:126`) shows the
model back "in a turn of its own ... before phase 3 hardens anything on top of
it", with a foreground list, closing "This is the cheapest correction in the
pipeline". The journey composes that confirmed model into paths and gets no
such turn.

So: the journey's non-visual fields - trigger, per-step domain effect, and where
the last step puts the user down - are confirmed by no instrument before the
feature is decomposed on them.

## The solution, and the ones the code ruled out

A show-back turn of its own at the end of `### Journeys`, **foregrounded on what
a walk cannot ask**, with the screens explicitly left to the walk.

Three cheaper solutions were tested and killed by the skill's own rules rather
than by taste - recorded so they are not re-proposed:

- **Fold it into the existing options turn** (zero new turns; the sketches
  already require stating the path). Killed by `### How to ask`
  (`discovery/SKILL.md:266`): a veto confirmation "gets its own turn, never
  mixed with a question", and the options turn ends at "which shape?". This is
  what makes "a turn of its own" the architecture's requirement rather than a
  preference.
- **Annotate the mockup with each step's domain effect.** Killed by
  `### Model the domain`: a show-back is "in the user's language - whether
  something is an entity or a value object is your problem, not theirs".
- **Let `### Write it`'s cold read catch it.** It asks what a reader would have
  to guess and where the document fights itself. A journey that is coherent but
  not what the user meant is neither.

Foregrounding rather than showing the journey whole is the one deliberate
narrowing of the parked entry. Shown whole, the turn re-asks in prose what the
walk asks better in pixels, and this repo has the failure mode on record: the
receipt replaced a closing brief that "grew with the spec until nobody read it
to the end, which is how the one item that needed a veto got skimmed past".

## The change

One file, one section. **`discovery/SKILL.md`, `### Journeys` (`:152-154`)** -
append a paragraph after the existing one. Draft, to be refined in the build:

> **Then show the journeys back, in a turn of its own** - before anything is
> sketched or drawn on them. The walk that follows will ask about the screens
> better than any prose can, so foreground what it cannot ask you about later:
>
> - it does not start there - that is not the occasion, or not the actor;
> - that step does not do that to the record;
> - those two are one step, or one of them is two;
> - you have left me somewhere I would not stop.
>
> Every ticket in the run decomposes from these, the acceptance drives them as
> its script, and a ratified one binds every feature after this. The screens
> are the walk's question, not this turn's.

Nothing else changes. `### Show, don't tell` keeps its two turns, and the
journey's four fields keep their definitions in `SPEC_FORMAT.md`.

## Scope

- **Spec lane only.** `discovery/SKILL.md:50` - "Phase 3 belongs to the spec
  lane alone". The small lane is untouched by construction.
- **The ratification seam is deliberately left alone.** A ratified journey will
  now be touched three times: this show-back, the second yes at
  `### Records that outlive the feature`, and the receipt. They ask different
  questions - is this path right, does it bind every feature after this one,
  last chance to take it back - and ratification is explicitly rare. Decided
  with the user 2026-08-30; reopening it is a change to the permanent tier and
  wants its own discovery.
- **No change to `SPEC_FORMAT.md`**, its `## Journeys` block, or any
  `TICKET_FORMAT.md` copy. Nothing here changes what a journey *is*.
- **No change to `check-against-spec`.** It reads journeys as its script and is
  unaffected by how they were agreed.

## Verification

`./tests/run.sh` stays green - baseline 239 passed, 0 failed as of `5c5bf83`.
Nothing in the suite reads a line of any `SKILL.md`, so the suite cannot
regress on this change and cannot pin it either.

No wording assertion is written. `TICKET_FORMAT.md:120` prescribes asserting on
a file's text for a criterion over prose, and this is a stated exception to it
on the same ground ticket 02 took: the user ruled that prose changes get no
tests, recorded in that ticket's `Record` at `9d94c62`. Reversing that ruling is
the user's, not a builder's. The criteria are verified by reading `### Journeys`
against each one.

The cost of the exception, stated plainly: nothing stops a later edit from
consolidating `### Journeys` and dropping this paragraph, with the suite green.

## Sequencing

1. Write the ticket - small lane, criteria in full, a leading `## Why`, no
   `spec`/`spec_hash`, in the shape `TICKET_FORMAT.md` gives. The `## Why`
   states the ordering defect, not the entry's "never seen written down".
2. `/implement` builds it.
3. **Retire `IDEAS.md:154` in a commit of its own**, matching `eb556c9` and
   `5c5bf83`. The lot is not pruned automatically - the entry that ticket 02
   answered survived its own fix by three commits - so this step is part of the
   work rather than a consequence of it.
