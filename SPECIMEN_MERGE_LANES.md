# Specimen: one door, the ceremony in the decomposer

The winning candidate, shown as the seams would actually read. Cheap paper:
it exists so the shape can be reacted to. It lives in `mockups/` beside the
spec, which is the directory `./accept.sh` deletes - a spec directory holds
exactly one `.md`, and the specimen is not it.

## The flow

```
  /idea ──┬──→ intent.md
          └──→ a reasoned no
             │
             ↓
  /to-solution ──┬──→ solution spec ──┬──→ built with you present
                 │                    └──→ /spec-to-tickets ──→ tickets ──→ loop.sh
                 └──→ a block

  One entry. Two skills, because `/idea` is a place to stop: noting an idea
  and being done with it is a whole use of the lane, not an abandoned run.
  The anchors an unattended run needs are added by the step that only runs
  when one is about to start.
```

## Seam 1 - `to-solution/SOLUTION_FORMAT.md` gains the anchors

```markdown
## What decided it
<What the candidates were ranked against, in the order agreed before
anything was scored.>

## Domain
<The actors, the work objects they act on, the actions and the events that
matter. Per aggregate: what changes together, and the invariant its root
holds. Where the corpus is a codebase that is a boundary in the code; where
it is a process or a document it is which steps have to move together.>

## Success criteria
- <How anyone tells this worked, once it is built. Observable from outside
  the thing, and written so it could be driven: given/when/then, or EARS
  (`WHILE <state> the system shall …`) where the behaviour is a standing
  invariant rather than an event.>

## Defaults
- **D-1** <what the builder should do absent evidence, stated as an
  instruction rather than a preference.>
  _Overturnable on: <what in the corpus would say otherwise.>_

## ADRs
- <Each ADR this design is built under or establishes, by number and path.
  Permanent-tier: never written without its own yes. `ADR_FORMAT.md` is the
  shape.>
```

`## Criteria` is gone - it meant the *ranked decision criteria*, and one step
downstream `criteria` means the ids tickets claim. Two readings of one word,
in a file a decomposer now reads, produces a wrong ticket set exactly once
and is expensive to find.

No `## Journeys`, no `## User Stories`, no `US-n.m` — *as `/to-solution`
writes it*. A document does not have them and a code change does not need
them until somebody is about to build it unattended, which is when Seam 2
adds them to this same file.

## Seam 2 - `/spec-to-tickets` hardens before it splits

It edits the spec it was handed and hashes the file it leaves - which is
what it already does when it marks `(binding)` before hashing, extended
from one mark to the whole set.

```markdown
## Harden the spec before you split it

You are handed a solution spec written for a reader, and you are about to
hand tickets to a run with nobody in it. What the reader did not need and
the run does, you add to that same file - with the user present to correct
you - and then you hash what you leave.

- **Number what tickets will cite.** Each part's _Done when_ becomes the
  testable criteria `US-n.m`, with `n` the part; constraints become `C-n`.
  The feature-level `## Success criteria` stay as they are and stay
  unnumbered - `/check-against-spec` sweeps for the ones no ticket claims,
  and collapsing the two levels would leave it nothing to sweep.
- **Derive the journeys, and show them.** `/check-against-spec` drives them
  as its script at the end of the run; nothing else produces them. They come
  out of `## Design` and `## Parts` rather than out of you - a journey you
  invented is an acceptance script for a feature nobody designed. Show them
  back before you decompose: the trigger, what each step changes, and where
  the last one puts the user down.
- **Map the dependencies.** `## Parts` already carries `Depends on:`.
- **Mark the binding defaults**, then hash.

You still do not decide what the system does. You decide what *done* is
precise enough to test, where the seams fall, and what the acceptance walks.
```

## Seam 3 - `/to-solution` reads a codebase as a corpus

Added to *Before you design*, where the skill already says to read the
corpus and find the standards:

```markdown
Where the corpus is a codebase, that reading is the code itself, plus
`UBIQUITOUS_LANGUAGE.md` and the project's ADRs for the language it already
holds, and `ARCHITECTURE.md` as a lead rather than as truth - it is only as
current as the last `/repo-overview` run, and the code settles anything the
two disagree on. `coding-conventions` is the standard.
```

One paragraph. Not a mode, not a branch - the skill already takes its
standards from the domain, and this says what the domain is when it is code.

## Seam 4 - `/idea` becomes the door

```yaml
---
name: idea
description: Use when a change is being worked out with the user - a
  feature, a bug, a refactor, or a passing idea that needs developing into
  something buildable. Finds the problem underneath what was asked for and
  writes it down as an intent. The one way in.
---
```

`disable-model-invocation` is dropped, so it fires without being typed -
which is what `/discovery` did and what "no classifying at the door" needs.
`/to-solution`, `/spec-to-tickets` and `/find-solution` stay user-invoked
and are reached by name, each pointed at by the step before it.

Firing `/idea` does not commit anyone to `/to-solution`. It ends at an
intent and points onward; stopping there is an ending, and the skill says
so rather than treating it as a handoff the user failed to take.

## Seam 5 - `/to-solution` gains a third ending

`/find-solution` dies into this one line, plus the two moves it held alone:

```markdown
**Or recommend without recording.** Where the decision will not be
re-argued, the recommendation goes in the conversation and no spec is
written. Never write one unasked.

**Reversibility breaks near-ties.** At an honest tie, the one that is cheap
to undo wins.

The four kinds are a floor, not the exercise. A field that turns out to be
exactly that list stopped at the checklist instead of starting from it.
```

## What this specimen does not show

`/discovery` and `/find-solution` deleted, `SPEC_FORMAT.md` absorbed, the
pointers at both cleared out of five `TICKET_FORMAT.md` copies, `loop.sh`,
`handover`, `implement` and `/spec-to-tickets`, and the README rewritten
around one door - consequences of the five seams above rather than designs
in their own right.
