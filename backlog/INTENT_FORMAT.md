# intent.md format

A backlog item and a change's `intent.md` are one file at different stages. It says what is wrong and what would be true instead. It names no mechanism and holds no design.

## The stages

1. **A backlog item**: `changes/backlog/<slug>.md`, a note, as far as the developer got, with its evidence. It may hold no agreed problem yet, and none of the headings below.
2. **After `/idea`**: the same file holds what the developer and `/idea` agreed, under the headings below. `/idea` writes them into the item it started from, or hands a new idea to `/backlog`, which writes the item. Either way the file is committed on main, before any branch for the change exists.

## The shape

While the file is a backlog item, the backlog's frontmatter (`effort`, `utility`), the title and the item's own notes stay above the headings. Below them, one heading per part, in this order:

```markdown
## Problem

What is wrong, in the user's words.

## Outcome

What would be true instead. No mechanism: "there is no X" and "nothing
tracks Y" are a solution with "there is no" in front of it.

## Instance

The one real instance: the last time it happened, what went wrong, what it
cost. Something a reader could go and look at - a file, a commit, a number,
a day.

## What must stay true

Only what is part of the problem, such as "nobody new gets access to member
data", with no mechanism either. A limit on the solutions, such as "we
cannot run a second login system", is not here: it is a hard decision for
the design or the plan.

## What they arrived with

The solution the developer arrived with, in their words. Evidence about the
problem, not the brief.

## Parked

What was split off as a problem of its own, one line each.
```

Where a part is empty, the heading stays with "None."

The design and acceptance hold the change against Problem, Outcome and What must stay true.
