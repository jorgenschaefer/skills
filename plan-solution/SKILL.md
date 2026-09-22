---
name: plan-solution
description: Turn a settled solution into the plans that build it - cut into vertical slices, one plan each, written to tickets once the slicing is approved. Typed, because a stage reached only by description is a stage that stops being reached.
disable-model-invocation: true
---

# Plan a solution

Take a settled solution, cut it into the smallest number of slices that can each be built and verified on their own, and plan each one.

`TICKET_FORMAT.md` settles the shape of a ticket, `PLANNING.md` the shape of a plan. This file is what you do.

## What this takes

A solution: `02-SOLUTION.md`, or a description in the conversation of an approach someone has already settled on.

**Prose describing a problem is not that.** A request to plan a change nobody has designed is `/find-solution`'s, and handing it slices derived from your own guess is the failure the whole chain exists to prevent. Say so and stop.

## Why this one is typed

Its description was measured twice: about three firings in four in a project holding
only this skill, and none at all in five runs in a project holding the full set. What
beat it was not a rival skill but the model deciding no skill was needed. So the
pipeline does not rely on being found here - `/find-solution` names this stage when it
finishes, and a person can type it. Entering plan mode without it still gives an
ordinary plan, which is the floor and is fine.

## What a slice is

**Vertical.** Buildable and testable on its own, end to end. "The database part" is not a slice; it cannot be verified without the thing above it, and it leaves the tree in a state no criterion describes.

**One seam.** If two parts of the change can be built and verified independently, they are two slices - even when one person would do both in an afternoon.

**The solution's `## Non-goals` and `## Edge cases` are yours to place.** A non-goal
belongs in the `## Not here` of whichever slice a builder would otherwise wander out of
- that is how it reaches the person who needs it, since nobody downstream opens the
solution. An edge case belongs in the `## Done when` of the slice that owns it, or it is
work nobody claimed.

**Read the solution's `## Open concerns` before you cut.** Something unsettled either
lands in a slice as a thing to settle, or it is a reason not to cut yet. It is not a
thing to discover mid-build.

**Ordered by need, not by size.** `after:` is what carries the order. Put a slice after another only when it genuinely cannot be built first; a false dependency serialises a run for no reason.

**A criterion covered by two slices is two criteria.** When you find yourself quoting half a criterion into one slice and half into another, stop: the solution is describing two pieces of work in one sentence. Say so and get it split there, where the coverage check can see it.

**Every criterion lands in some slice, and every slice claims some criterion.** Both directions, before you present anything.

## Then the count decides the path

**One slice: plan it in plan mode, and write no ticket.**

Enter plan mode and produce the plan there. A single slice has no dependency to record, no second builder to brief and no runner to drive, so a ticket file for it is paper produced for nobody - the thing this pipeline exists to stop. The session stays in plan mode and the plan is approved the ordinary way.

**More than one slice: plan each in context, and write them out.**

Plan mode cannot be entered once per slice without stopping a person once per slice, so the planning happens here. Work through the slices in order, following `PLANNING.md` for each, and write each plan into its ticket at `tickets/NN-<slug>.md` inside the intent's directory - beside the `01-INTENT.md` and `02-SOLUTION.md` it descends from.

## What the rehearsal turns up

`PLANNING.md` has you walk each plan as its builder.

**What to build is the solution's.** A criterion that could mean two things, a behaviour nobody specified, an edge case the slice runs into and the solution is silent on. None of these can be settled here: answering one is inventing a requirement. Put it to the person at the approval, and then it splits. Where the answer is a sentence, amend `02-SOLUTION.md` and quote the amended words - the solution stays the one file everything downstream reads. Where the answer would change the cut, stop and hand back to `/find-solution`: the slicing in your hands was made against a solution that no longer says what it said.

**How to build it is yours.** Which file it lives in, the order of the steps, what to reuse - decide those and move on, and surface the ones that would be expensive to reverse.

## The order matters, because plan mode cannot write

1. **Work the slicing out in context** - the slices, their order, what each covers. Where a slice introduces a concept the codebase has no name for, or moves a boundary between the ones it does, `CODING_STANDARDS.md` binds the names the ticket will write.
2. **Check it.** Spawn a subagent with a fresh context and give it `VERIFY.md` from this directory, the slicing as text, and the solution's path. This is the one review that arrives before there is a file to read, so it is the only thing standing between a bad cut and a directory full of tickets.
3. **Present it and get approval** - the slicing, and the rehearsal's questions as one list. What is approved is the slicing, not the files.
4. **Write the tickets to match**, once plan mode has exited - and with them any ADR the change earned. `CODING_STANDARDS.md` says which decisions those are and `ADR_FORMAT.md` is the shape; plan approval is the yes that lets one be written, and the argument for it is in front of you now and gone by acceptance.

The written files are a transcription of what was approved, and nothing checks them at the moment of writing - the runner's pre-flight is what catches a transcription that drifted, one pass later. So transcribe, do not improve. An idea you have while writing the files is an idea that skipped the approval.

## Copy, never summarise

A ticket quotes its criteria exactly as the solution writes them - `TICKET_FORMAT.md` says why. Exactly means exactly: a quotation that stops a sentence early has dropped a requirement, and it is the most natural way this goes wrong.

The same holds of the plan you write under it: it implements the criteria quoted above it and nothing else. A plan that adds a requirement has widened work nobody approved, in a file that claims to be transcribing one.

## Re-slicing

Drift, or a verdict routing a lost criterion back, lands here against a directory that already has committed tickets.

- **Committed tickets are immutable.** Their words are what the code was built against, and rewriting them makes the `Record` a lie.
- **Numbering is append-only.** A re-slice adds tickets; it does not renumber the directory.
- **It goes back through plan mode and its approval**, because writing tickets is what that approval authorises. Repair `after:` against the committed tickets as part of the plan.

## Hand off

`./run.sh intents/<slug>/tickets` drives the directory with nobody watching; a small
change is just as well built by working through the tickets yourself. Either way the
ticket is the unit, and nothing merges until the intent has been walked.
