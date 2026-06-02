---
name: discovery-increment
description: Use when a /discovery output is too large to implement in one cycle and you need the next vertical-slice INCREMENT file ready for /implement. Triggers on "/discovery-increment", "split this EPIC", "next slice", "next increment", or after /discovery flags its output as too large.
---

# Discovery Increment

Given a path to a `/discovery`-shaped spec too large to implement as one chunk (the "source spec" - any filename is fine), produce the next vertical-slice `INCREMENT-NN.md` next to it - a self-contained doc in the same shape, scoped to a slice that delivers real value on its own. No user interaction beyond getting the path; everything else you need is in the source spec, its sibling INCREMENT files, and the codebase.

The common case is no split needed - a `/discovery` output that fits one `/implement` pass is already an INCREMENT in shape. Only invoke this skill when the source spec is large enough to need carving.

## Before starting

- The input is a path to the source spec. If the user didn't supply one, ask where the spec lives before doing anything else.
- Confirm the file at that path is recognizably a `/discovery`-shaped spec (at minimum: Why and User Stories sections). If not, stop and tell the user.
- Skim the codebase for current shape - names, file paths, existing structures the new slice will reference.
- Identify any `INCREMENT-NN.md` siblings in the same directory. From each, extract only the User Stories it claimed. Do not trust their prose about code shape - that may have drifted from what was actually built.

## What is a vertical slice

- **Vertical, not horizontal.** The slice traverses the full stack for at least one use case. After it ships, some real user's workflow works end-to-end. Never "db layer / backend layer / API layer / frontend layer" - those are useful only when the last layer lands.
- **Substantive enough to justify its own cycle.** Each slice incurs implementation, code review, and traceability-check overhead. A slice should justify those costs by what's learned, decided, or validated from it. If a candidate piece has no design decisions to make and lands naturally in the same area as the next meaningful slice, bundle it into that slice rather than carving it off alone.
- **As large as a single `/implement` cycle can carry.** The point of splitting is to make a large spec implementable in separate passes - not to atomize it into the smallest testable units. Individual testability is never a reason to split. Group closely-related stories into one slice; only separate them when the combined slice would overflow a single cycle or span unrelated areas of the product. A spec should yield a handful of meaningful slices, not dozens of tiny ones.

Ask yourself: "what would we learn from shipping this alone?" If the answer is "nothing significant", bundle.

## Process

1. **Determine claimed stories.** From sibling `INCREMENT-NN.md` files, story-level only.
2. **Check refusal cases.** Stop and tell the user, do not emit a file, if:
   - The source spec is already small enough to act as one INCREMENT.
   - All stories in the source spec are already claimed by existing INCREMENT siblings.
   - The unclaimed stories can't be carved into a vertical, substantive slice (e.g., everything left is interlocked).
3. **Choose the next slice.** From the unclaimed stories, take the largest coherent vertical chunk that still fits one `/implement` cycle, grouping closely-related stories together rather than emitting each alone. A slice may cover several related stories, one story, or part of one story when that story alone is too large for a single slice.
4. **Anchor to current code.** When the slice references existing structures - names, file paths, current shape - draw those references from the codebase, not from prior INCREMENT prose. Drift between earlier slices and what was actually built does not propagate forward.
5. **Write the slice file.** Name it `INCREMENT-NN.md` with the next zero-padded sequence number after the highest existing INCREMENT sibling. Place it next to the input. The slice file stands alone - it does not link or refer to EPIC.md, so `/implement` can consume it directly.

## Output shape

The output is a complete `/discovery`-shaped document (see `discovery/SKILL.md` for the full template), scoped to this slice:

- **Why.** Inherited from the source spec.
- **Success criteria.** Scoped to what this slice achieves.
- **Non-goals.** Relevant inherited non-goals, plus the stories from the source spec explicitly deferred to future slices. Calling these out keeps an implementer from accidentally pulling deferred work back in.
- **Domain (Ubiquitous language).** Only terms this slice actually touches.
- **Roles.** Only roles this slice actually touches.
- **User Stories.** Only stories in this slice, with their acceptance criteria. When a story spans multiple slices, include only the partial scope for this one.
- **Open questions.** Only those bearing on this slice's stories. Open questions unrelated to this slice stay in the source spec.
