---
name: discovery-increment
description: Use when a /discovery output is too large to implement in one cycle and you need the next vertical-slice INCREMENT file ready for /implement. Triggers on "/discovery-increment", "split this EPIC", "next slice", "next increment", or after /discovery flags its output as too large.
---

# Discovery Increment

Given a path to a complete `/discovery` master spec too large to implement in one chunk (the "source spec" - any filename is fine), project the next vertical-slice `INCREMENT-NN.md` next to it - a self-contained doc in the same shape, scoped to a slice that delivers real value on its own.

The master is already complete: its criteria are hardened to given/when/then, its baseline decisions bound to real code. So this skill projects, it does not re-derive - it adds only what slicing itself creates: which stories are in the slice, which earlier slices it depends on, and how its references resolve against code those slices actually built. Everything you need is in the source spec, its sibling INCREMENT files, and the codebase - no user interaction beyond getting the path, save the stop conditions below.

## Before starting

- The input is a path to the source spec. If the user didn't supply one, ask where the spec lives before doing anything else.
- Confirm the file is a complete `/discovery` master, not a draft: User Stories present, and every behavior a wrong default could hurt already carrying a given/when/then criterion. If criteria are missing or decisions are left open, it isn't finished - stop and send the user back to `/discovery` rather than inventing the gaps here.
- Skim the codebase for current shape - names, file paths, existing structures the new slice will reference.
- Identify any `INCREMENT-NN.md` siblings in the same directory. From each, extract only the User Stories it claimed - they tell you what's taken, nothing more. The master, not the siblings, is the source of truth for stories, criteria, and decisions; don't trust sibling prose about code shape, which may have drifted from what was actually built.

## What is a vertical slice

- **Vertical, not horizontal.** The slice traverses the full stack for at least one use case. After it ships, some real user's workflow works end-to-end. Never "db layer / backend layer / API layer / frontend layer" - those are useful only when the last layer lands.
- **Substantive enough to justify its own cycle.** Each slice incurs implementation, code review, and traceability-check overhead. A slice should justify those costs by what's learned, decided, or validated from it. If a candidate piece has no design decisions to make and lands naturally in the same area as the next meaningful slice, bundle it into that slice rather than carving it off alone.
- **As large as a single `/implement` cycle can carry.** The point of splitting is to make a large spec implementable in separate passes - not to atomize it into the smallest testable units. Individual testability is never a reason to split. Group closely-related stories into one slice; only separate them when the combined slice would overflow a single cycle or span unrelated areas of the product. A spec should yield a handful of meaningful slices, not dozens of tiny ones.

## Process

1. **Determine claimed stories.** From sibling `INCREMENT-NN.md` files, story-level only.
2. **Check refusal cases.** Stop and tell the user, do not emit a file, if:
   - The master is already small enough to act as one INCREMENT - `/implement` consumes it directly.
   - All stories in the master are already claimed by existing INCREMENT siblings.
   - The unclaimed stories can't be carved into a vertical, substantive slice (e.g., everything left is interlocked).
3. **Choose the next slice.** From the unclaimed stories, take the largest coherent vertical chunk that still fits one `/implement` cycle, cutting along the dependencies the master mapped and grouping closely-related stories rather than emitting each alone. A slice may cover several related stories, one story, or part of one story when that story alone is too large for a single slice.
4. **Reproduce the slice's criteria and decisions from the master, verbatim.** The master is complete; project it, don't re-derive it. Don't reword a criterion or re-make a decision - copy them across for the stories you selected.
5. **Anchor and state preconditions.** Baseline anchors carry over from the master unchanged. For references that point at feature-internal code an earlier slice built, resolve them against what that slice actually built - read the current codebase, not prior INCREMENT prose. Record which earlier slices this one depends on as Preconditions. If a built earlier slice turns out to contradict a master decision - the master was wrong, not merely unbound - stop and send the user back to `/discovery`; never silently patch a master decision here.
6. **Write the slice file.** Name it `INCREMENT-NN.md` with the next zero-padded sequence number after the highest existing INCREMENT sibling. Place it next to the input. The slice file stands alone - it does not link or refer to the source spec, so `/implement` can consume it directly.

## Output shape

The output is a complete document in the shared spec format (see `SPEC_FORMAT.md`), scoped to this slice:

- **Why.** Inherited from the master.
- **Success criteria.** Scoped to what this slice achieves.
- **Non-goals.** Relevant inherited non-goals, plus the master stories explicitly deferred to future slices. Calling these out keeps an implementer from pulling deferred work back in.
- **Preconditions.** What earlier slices must have built for this one to stand. This is the one section the master doesn't supply - it's a property of the slice ordering you chose.
- **Domain (Ubiquitous language).** Only terms this slice actually touches.
- **Roles.** Only roles this slice actually touches.
- **User Stories.** Only stories in this slice, their acceptance criteria copied from the master verbatim. When a story spans multiple slices, include only the partial scope for this one.
