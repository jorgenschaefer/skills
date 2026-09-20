# Solution spec format

The shape of the spec `/to-solution` writes from an intent: the problem carried forward, the field that was weighed, the one that won, and the parts whoever builds it works through.

It carries no numbered anchors and no per-criterion IDs. This spec is handed to a person or to a planning agent, not to an unattended loop.

Omit sections that do not apply.

```markdown
# Solution: <the deliverable, in a few words>

## Why
<The problem, carried from the intent. The problem, not the solution. Where your cold re-derivation disagreed with the intent, record the reading that survived and say that the two differed.>

## Solution
- **Chosen** - <the approach in a sentence or two, and what it extends or introduces.>
- **Rejected** - <each candidate that lost, one line, with the criterion or constraint it lost to. Include what the user arrived with wherever that is not what was chosen, and say where they overruled the recommendation.>

## Criteria
<What the candidates were ranked against, in the order agreed before anything was scored.>

## Standards
<Which standing standards the design was held to, and the shape each imposed. Write this section even when the search found nothing. Then any contradiction between two of them left unresolved, naming both.>

## Design
<The thing itself, in whatever form the domain uses. Where a specimen was built - a mockup, a draft, a worked example - link it rather than describing it.>

## Parts
<Each piece the deliverable is made of, in an order that can be worked through:>
- **<name>** - <what it is.> Depends on: <other parts, or nothing.> Done when: <what is observably true.>

## Scope
- **Now** - <what this slice delivers.>
- **Later** - <deliberately deferred, and what would have to be true to start it.>
- **Never** - <out of scope for good.>

## Success criteria
- <How anyone tells this worked, once it is built. Observable from outside the thing.>

## Constraints
- <What any answer had to hold to, carried from the intent plus whatever the design added. Each says how it will be verified, in the future tense.>

## Open concerns
<What neither you nor the user could settle, each named as a guess: what was assumed, what would settle it, and what changes if it goes the other way. Everything here has a decision attached and was agreed.>
```
