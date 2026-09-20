# Intent: the same craft, written down twice

## Problem

The craft of turning a request into something buildable - find the problem
under the solution the user arrived with, weigh candidates that differ in kind
against what already exists, write it down so the builder needn't ask - is
written down twice in this repo: once as `/discovery`'s phases 1 and 2, bound
to a codebase, and once as `/idea` and `/to-solution`, bound to none. Every
sharpening of that craft lands in one copy and reaches the other only if it is
carried across by hand and generalised on the way. They have drifted, and
consolidating them is blocked on a judgement nobody has made: `/discovery`
carries material the other lane never got - user stories, journeys, the mockup
walk, the domain-model turn - and it is unknown both whether that material is
necessary even for code, and whether it could be present for code work without
making a session about a process, a document or a skill worse. What would be
true instead: a rule about how work gets worked out would be stated once and
hold wherever that work happens, and every remaining difference between
handling a code change and a non-code change would be one somebody chose, for a
reason they could name.

The instance is `9b4243f` (2026-09-20): three moves were lifted out of
`/discovery` phase 2, generalised off the codebase they assumed, and written
into `/to-solution`. The port ran one way only, by hand, and it is the second
lane's first week - the two entry points have existed since `6f57b21`, one
commit earlier. The recurrence rate is every improvement to either skill, which
in this repo's history is most weeks.

## Proposed outcome

- A change to how a request is worked into something buildable is made in one
  place, and takes effect for both code and non-code work.
- Starting a piece of work does not require first classifying what kind of work
  it is in order to pick the entry point.
- Every piece of `/discovery`'s code-specific material has a recorded verdict:
  kept because code needs it, or dropped because it does not.
- A session about a skill, a process or a document is not carrying code-shaped
  questions it has no answer for.

## Affected

Jorgen, as the only maintainer of these skills and their heaviest user.
Downstream, the agents that run them: a rule fixed in one copy and not the
other is a behaviour difference nobody intended.

## Constraints

- **The non-code lane must not get worse for non-code work.** A candidate that
  makes a session about a process or a document survey a codebase, write user
  stories, or produce a mockup is disqualified, however well it serves code.
- **The unattended build must keep its input.** Whatever the code path emits
  must still decompose into tickets `loop.sh` can build with nobody present -
  the spec anchors `/spec-to-tickets` reads (`spec_hash`, criterion ids, the
  tiers) either survive or are replaced by something that does the same job. A
  candidate that leaves `loop.sh` without a consumable spec is disqualified.
- **Firing has to be reliable where it is load-bearing.** Where behaviour must
  happen every time, it cannot rest on a description matching - the ground on
  which `PLAN_MERGE_LANES.md` already rules out one auto-discoverable skill. A
  candidate that makes a must-happen step probabilistic is disqualified.

## Whatever they arrived with

`PLAN_MERGE_LANES.md`: one front door for everything, `/spec-to-tickets`
becoming a step added only when a big build is about to start, `/discovery`
retired. Four steps - teach `/to-solution` the `D-n` default scheme and domain
modelling and rename its colliding `## Criteria`; make `/spec-to-tickets` read
a solution spec; split `/implement`; delete `/discovery`. It rules out three
alternatives and names its own weakest point (journeys). In this conversation a
second mechanism was raised: carrying the code-specific material as
discoverable skills that attach only where the work is code.

Two things in that plan are parked as separate problems, not folded in here:
splitting `/implement` so the build protocol fires without a ticket, and the
plan's opening argument that small changes pay for unattendedness they never
use - which this conversation did not bear out as the driver.

## Open questions

- Is `/discovery`'s user-story and journey work necessary for code at all, or
  is it ceremony that survived because nothing forced the judgement?
- Can the material that is necessary be attached to a generic lane without a
  non-code session ever meeting it?
- `/spec-to-tickets` reads journeys today. If it needs them to place ticket
  seams, the answer to the first question is forced.
