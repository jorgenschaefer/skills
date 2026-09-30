---
name: criteria-to-tickets
description: Turn an agreed CRITERIA.md into the tickets that build it - cut into vertical slices, one planned ticket each, checked by an adversary and then approved. Typed, because a stage reached only by description is a stage that stops being reached.
disable-model-invocation: true
---

# Criteria to tickets

Take an agreed `CRITERIA.md`, cut it into slices that can each be built and verified on their own, and write a planned ticket for each - one slice included.

This skill's `TICKET_FORMAT.md` settles the shape of a ticket, its `PLANNING.md` the shape of a plan. This file is what you do.

## What this takes

`changes/YYYY-MM-DD-<slug>/CRITERIA.md`, agreed with the user.

**Prose describing a problem is not that.** A request to slice a change nobody has worked out is `/find-criteria`'s, and handing it slices derived from your own guess is the failure the whole chain exists to prevent. Say so and stop.

## What a slice is

**Vertical.** Buildable and testable on its own, end to end. "The database part" is not a slice; it cannot be verified without the thing above it, and it leaves the tree in a state no criterion describes. When small and vertical conflict, vertical wins.

**A size one session can build.** Among vertical cuts, this is the main constraint: every turn of a build re-reads its whole context, so a long session costs more with every turn. A slice that would clearly run long - many plan steps, many files - is split along a real seam, even where that seam runs through an AC.

**And no smaller than it has to be.** Every ticket pays its setup again: a fresh session reads the ticket, the standards and the files it touches, and its reviewer starts the app, logs in and makes its test data. In one run seven slices each applied one shared dialog in one more place, and each cost a fifth to a third of a five-hour usage window, mostly on that setup. Slices that repeat one pattern over the same files and context go into fewer tickets, as long as each still fits one session.

**`Out of scope` is yours to place.** Each line belongs in the `## Not here` of whichever ticket a builder would otherwise wander into - that is how it reaches the person who needs it, since no builder opens `CRITERIA.md`.

**Ordered by need, not by size.** `after:` is what carries the order. Put a slice after another only when it genuinely cannot be built first; a false dependency serialises a run for no reason.

**Exactly one ticket closes each AC.** It is the slice after which the AC is true, and it writes the AC's test where the user acts. An AC too big for one slice is also advanced by others, each building a narrower part it can prove on its own; the closing ticket comes `after:` every one of them. The size of the work is never a reason to split an AC - that puts your seams into what the user approved. An AC that turns out to describe two behaviours is: put it to the user and get it split in `CRITERIA.md`.

**Every AC is closed by some ticket, and every ticket closes or advances some AC** - except one that only splits a large file. A nudge goes into every ticket it bears on.

**A large file is split in a ticket of its own, first.** `CODING_STANDARDS.md` has a large file split before code is added to it, and a build scoped to its criteria will not do that inside its ticket: in one run, three builds in a row each declined the same split as a separate refactor, and each added to the file. Where the plans add to a file the standard calls large, write a ticket that only splits it - it closes and advances nothing, its `Done when` names the files it splits into, with the behaviour unchanged and the checks green - and put every ticket that adds to the file `after:` it.

Where a slice introduces a concept the codebase has no name for, or moves a boundary between the ones it does, this skill's `CODING_STANDARDS.md` binds the names the ticket will write.

## What planning turns up

`PLANNING.md` has you read the code and walk each plan as its builder. That turns up two kinds of question.

**Product questions are the user's.** An AC that could mean two things, an edge case nobody owns, a behaviour nobody specified. Answering one yourself is inventing a requirement. Put it to the user at the approval, and write the answer into `CRITERIA.md` as a new or amended AC before any ticket quotes it. Where the answer changes the cut, stop and hand back to `/find-criteria`: the slicing in your hands was made against criteria that no longer say what they said.

**Implementation decisions are yours.** Which file, which order, what to reuse. Decide them, and show them at the approval so the user can object. They are not written back into `CRITERIA.md`.

## Write, check, approve

1. **Write the tickets** to `tickets/NN-<slug>.md` in the change's directory, following `PLANNING.md` for each plan.
2. **Check them.** Spawn a subagent with a fresh context and give it `VERIFY.md` from this directory, the paths to the ticket files, and the path to `CRITERIA.md`. Nothing else - a reviewer that has your reasoning will read your intentions into the words.
3. **Fix what it finds, then ask for approval.** Show the slicing, the implementation decisions, and the product questions as one list. A no means editing the tickets and asking again.

## Copy, never summarise

A ticket quotes its ACs and nudges exactly as `CRITERIA.md` writes them - `TICKET_FORMAT.md` says why. Exactly means exactly: a quotation that stops a sentence early has dropped a requirement, and it is the most natural way this goes wrong.

The same holds of the plan under them: it implements the ACs quoted above it and nothing else. A plan that adds a requirement has widened work nobody approved.

## ADRs

Only for a decision you newly make while reading the code - one from `/find-criteria` already has its record. Where `CODING_STANDARDS.md` says it earns one, put it to the user at the approval with a recommendation, and on a yes write it to `docs/adr/` in this skill's `ADR_FORMAT.md` shape.

## Re-slicing

Drift, or acceptance routing an unmet AC back, lands here against a directory that already has committed tickets.

- **Edit the tickets the change touches, in place:** the new quote and plan, no `## Halt`, no `## Left standing`, `status: ready`, `attempts: 0`. A built ticket whose AC changed is rebuilt this way, not annotated - its words are what the code was built against.
- **Delete a ticket with nothing left to build; add tickets for new work.** Fix every `after:` that named a deleted ticket - the runner halts on one that names nothing.
- **Delete `REVIEW.md`**, where there is one: it reviewed what is about to change, and the runner does not review again while it is there.
- **It goes through the same write, check, approve**, because the tickets are what is being changed.
- **Commit the re-slice before the runner starts again** - the runner refuses a dirty tree, and its own halts are uncommitted too.

## Hand off

Commit the change's directory - `CRITERIA.md`, specimens, tickets - and any ADRs before handing off; the runner refuses a dirty tree.

**One ticket:** `/implement` on it, then `/accept-criteria`.

**Several:** `./run.sh changes/<slug>/tickets` drives them with nobody watching, and ends by pointing to `/accept-criteria`.

Name the next step - it will not find its own way in - and leave going on to them to ask for.
