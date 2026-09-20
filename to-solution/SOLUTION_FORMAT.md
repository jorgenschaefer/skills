# Solution spec format

The shape of the spec `/to-solution` writes from an intent. It holds one deliverable: the problem carried forward, the field that was weighed, the one that won, and enough detail that whoever builds it needs nothing from the conversation that produced it.

It carries no `US-N.M` criteria, no `C-N` anchors, no numbered defaults and no journeys. Those anchors exist so a spec can survive a build with nobody watching; this one is handed to a person, and is worse for carrying them. Where the work turns out to want that loop, `/discovery` produces the spec it takes - see `SKILL.md`'s close.

Omit sections that do not apply. Add subsections where the domain warrants.

```markdown
# Solution: <name>

## Why
<The problem, carried from the intent, in the originator's words. State the problem and not the solution. This is the paragraph everything below is answerable to. Where your cold re-derivation disagreed with the intent, that was raised with the user before anything was designed: record the reading that survived, and add one line saying the two differed and which won. A correction nobody was told about is invisible afterwards; one recorded as a correction is checkable.>

## Solution
- **Chosen** - <the approach in a sentence or two, and which existing concept it extends or what new one it introduces.>
- **Rejected** - <each candidate that lost, one line each, with the criterion or constraint it lost to. Include whatever the originator arrived with, wherever that is not what was chosen: an idea rejected for good reasons and recorded nowhere gets rediscovered and argued from scratch, and theirs is the one everything downstream drifts back toward. Where they overruled the recommendation, say so here - it marks the choice as settled rather than open.>

## Criteria
<The criteria the candidates were ranked against, in the agreed order, as agreed before anything was scored. Recording the order is what makes every "lost to" above checkable rather than assertable. Distinct from Constraints below: a criterion ranks the survivors, a constraint eliminated whoever it was going to eliminate before the scoring started.>

## Success criteria
- <How anyone tells this worked, once it is built. Observable from outside the thing. Not a list of what was built.>

## Non-goals
- <Explicitly out of scope - not now and not later.>

## Now and later
- **Now** - <the one slice that ships, in a sentence: what is true once this is done.>
- **Later** - <what this wants next, deliberately deferred, and what would have to be true to start it. Distinct from a non-goal: a non-goal is out of scope for good, this is scope held back.>

## Constraints
- <What any answer had to hold to: carried from the intent, plus whatever the design added. Each says how it will be verified, in the future tense. A constraint nobody can check is a wish. Omit the section when there are none.>

## Standards
<Which standing standards were applied - the skill, the guide, the convention - and the shape each imposed on the design. Write this section even when the search found nothing: "looked, found none" tells the next person how much the design was actually constrained, and is the one section here that is never omitted. Then any contradiction between two standards that was left unresolved, naming both and what each would have required - that half is omitted when there were none, which is the usual case.>

## Design
<The thing itself, in whatever form the domain uses: the structure, the wording, the steps, the interface. This is the section that makes the spec buildable, and the one the cold read is really testing. Everything above it is the reasoning that got here.>

## Open concerns
<Every place the design rests on a guess, with the guess named as one. Each says what was assumed, what would settle it, and what changes if it goes the other way.

Two lines separate this from a block. An unknown that would flip which candidate won had to be checked or block the run - one that changes something below the recommendation lands here instead. And the guess has to be defensible: where you would be picking at random, or where being wrong costs more than the run, that is a block too.

This is not an open-questions section - everything here has a decision attached, and the uncertainty is recorded alongside it rather than in place of it. Omit when there are none.>
```
