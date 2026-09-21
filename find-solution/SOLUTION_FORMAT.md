# Solution format

```markdown
# Solution: <the approach, in a few words>

## Intent
<The intent this answers - `01-INTENT.md`, beside this file - and the conditions it takes on.

Where a solution answers more than one intent, name each, and qualify every tag below with which one: `cost:C-1`, `problem:C-1`.

Where the change was small enough that no intent document was written, this section *is* the intent: the numbered conditions and the constraints, derived and confirmed before any approach existed. Everything downstream addresses them here instead of in a file of their own - acceptance judges against these sections.>

## Approach
<The chosen answer in prose. What it does, how it hangs together, why this shape.

One approach. The field of candidates is not here - what survived is here, and what did not is in `Ruled out`.>

## Behaviour
<What the finished thing does, numbered, each tagged with the conditions it serves:

- **AC-1** <Observable behaviour, stated so a test could name it.> *(C-1, C-3)*
- **AC-2** <...> *(C-2)*

Every criterion carries at least one tag, or it is work nobody asked for. Every condition in the intent is carried by at least one criterion, or it is a condition nothing will build. Both directions are checked.

The numbers are append-only, for the same reason the intent's are: tickets copy them, and a renumbering repoints a tag that was written against the old number.>

## Edge cases
<What happens at the boundaries - the empty case, the concurrent case, the case where the thing it depends on is missing. Omit when there are none, which is rare.>

## Non-goals
<What this deliberately does not do, so a reviewer does not file its absence as a defect.>

## Accepted tradeoffs
<What this approach costs, named and owned. Not hedges - "adds some complexity" is not a tradeoff, it is a shrug.

Each one says what is being given up and what is being bought with it. A cost the intent's constraints forbid is not a tradeoff; it disqualifies the approach.>

## Ruled out
<At least one alternative that was genuinely considered, and why it lost.

This is what makes the tradeoffs falsifiable: a cost only means something relative to something else. A solution with nothing ruled out was not chosen, it was the first thing thought of.>

## Open concerns
<What is still unsettled, and what would settle it. Omit when there is nothing.>
```

## What this format is not

**It is not a design document.** No domain model, no glossary, no architecture decision records, no tiered commitments. Those were required here once, produced on every run, and read almost never. Where that knowledge belongs is with whoever is deciding the shape of the change, at the moment they are deciding it.

**It is not a plan.** It says what the finished thing does, not what order to build it in. The slicing reads this and decides that.

## The two checks it exists to make possible

**Coverage, both ways.** Every criterion traces to a condition; every condition lands in a criterion. That is mechanical, and it is the reason for the tags.

**Cost, made visible.** `Accepted tradeoffs` and `Ruled out` are required because a review can find an unlisted drawback but cannot find a better solution. Naming what this costs, against something it was chosen over, is what gives the reviewer something to bite on.
