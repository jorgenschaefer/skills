# Solution format

```markdown
# Solution: <the approach, in a few words>

## Intent
<The intent this answers - `01-INTENT.md`, beside this file - and the conditions it takes on.

Where a solution answers more than one intent, name each, and qualify every tag below with which one: `cost:C-1`, `problem:C-1`.

Where the change was small enough that no intent document was written, this section *is* the intent: the numbered conditions and the constraints, derived and confirmed before any approach existed. Everything downstream addresses them here instead of in a file of their own - acceptance judges against these sections.>

## Approach
<The chosen answer in prose. What it does, how it hangs together, why this shape.

Where a specimen was built for it, link it; it sits beside this file.

One approach; what did not survive is in `Ruled out`.>

## Behaviour
<What the finished thing does, numbered, each tagged with the conditions it serves:

- **AC-1** <Observable behaviour, stated so a test could name it.> *(C-1, C-3)*
- **AC-2** <...> *(C-2)*

The numbers are append-only, for the same reason the intent's are: tickets copy them, and a renumbering repoints a tag that was written against the old number.>

## Edge cases
<What happens at the boundaries - the empty case, the concurrent case, the case where the thing it depends on is missing. Omit when there are none, which is rare.>

## Non-goals
<What this deliberately does not do, so a reviewer does not file its absence as a defect.>

## Accepted tradeoffs
<What this approach costs, named and owned.

Each one says what is being given up and what is being bought with it.>

## Ruled out
<At least one alternative that was genuinely considered, and why it lost.

A solution with nothing ruled out was not chosen, it was the first thing thought of.>

## Open concerns
<What is still unsettled, and what would settle it. Omit when there is nothing.>
```

## What this format is not

**It is not a design document.** No domain model, no glossary, no architecture decision records, no tiered commitments. Where such knowledge belongs is with whoever is deciding the shape of the change, at the moment they are deciding it.

**It is not a plan.** It says what the finished thing does, not what order to build it in. The slicing reads this and decides that.
