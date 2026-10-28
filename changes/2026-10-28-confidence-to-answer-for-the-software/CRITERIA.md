# Criteria: the developer answers for the software as a whole

## Problem
A developer who knew the code could stand behind the software they shipped.
They were confident it worked, and they answered for it to users, customers
and their employer. A developer who does not read the code still answers for
it, but they see the software only through the evidence each change shows
them. Change after change on good evidence does not add up to knowing what
the software as a whole does. They also cannot tell where their confidence in
it is thin.

Instead, the developer is confident enough in the software as a whole to
answer for it to others, and where that confidence is thin, it reaches them
without their having to notice or ask.

The instance: in the weight tracker, the developer approved each fix to the
"gaining weight" rule, one at a time. Nobody saw the fixes add up to a pile
of special cases instead of one approach. In the end the developer could no
longer say what the rule was meant to do, so they could not answer for it.

## Acceptance criteria
### Behaviour
- **AC-1** Premise 1 in `MANIFESTO.md` reads: "**Humans do not read the code.** They decide what the software does, accept it on evidence they can see, and answer for it to the people who rely on it."
- **AC-2** The first line under "For every goal" in `MANIFESTO.md` reads: "The developer answers for the software as a whole, not for one change at a time. So they decide each change seeing **the whole it changes**: the rule or workflow as it will stand afterwards. Where that whole stops hanging together, such as a rule gathering special cases, an agent puts it to them as a decision, without being asked: **is this still what you want?** (1)"
- **AC-3** Nothing else in `MANIFESTO.md` changes.
- **AC-4** The backlog items `method-layer` and `critical-user-journeys` no longer say they wait on `confidence-to-answer-for-the-software`. Where they gave the manifesto's gap as a reason, they point to the new line instead.
- **AC-5** The backlog item `approved-criteria-outlive-the-change` tells the weight tracker story as the Problem above does: each fix was approved, and nobody saw them add up.
- **AC-6** The backlog item `method-layer` notes that no skill yet shows the developer the whole a change touches, or raises a whole that stops hanging together.
- **AC-7** The backlog item `method-layer` carries two notes from `confidence-to-answer-for-the-software`: that `/accept-criteria`'s "Show them what the change decided that they answer for" could be cut under its rule, though it serves this goal; and that a record of who decided what was left out on purpose, as blame rather than confidence.

### What production must show
None.

### Security policy
None.

### Information model
None.

## Agreed design
This change states the goal in the manifesto and does not yet make the
Problem true. Acceptance holds it to the new line being in place and the
backlog items that follow carrying it. Those items make the Problem true:

- the whole a change touches, and a whole that stops hanging together:
  `method-layer`, through the skills it reworks;
- earlier approved behaviour a later change quietly alters:
  `approved-criteria-outlive-the-change`;
- parts of the software no recent change touched: `critical-user-journeys`;
- steps that serve this goal lost in the rework: `method-layer`.

## Technical decisions
- **Concepts** none
- **Wire formats** none
- **Hard to reverse** none

## Out of scope
- Changing any skill so that it shows the whole a change touches or raises a whole that stops hanging together. That belongs to `method-layer` and the items that build on it.

## Ruled out
- **A lasting picture of what the software does and what proves each part** - mostly what `critical-user-journeys` and `approved-criteria-outlive-the-change` already plan.
- **Acceptance showing what a change did to earlier approved behaviour** - needs `approved-criteria-outlive-the-change` first, and is planned there.
- **An audit the developer runs before answering for the software** - a picture at one point in time that goes stale, and it waits for the developer to ask.
- **Showing the developer where and why their confidence is thin, or which gaps exist** - puts the noticing on the developer, who should not have to look or ask.
