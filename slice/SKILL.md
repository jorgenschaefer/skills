---
name: slice
description: Cut a settled solution into the tickets that build it - vertical slices, each independently buildable and testable, worked out in plan mode and written once the slicing is approved. Typed, because a stage reached only by description is a stage that stops being reached.
disable-model-invocation: true
---

# Slice

Turn a settled solution into the tickets that build it. `SLICE_FORMAT.md` settles the shape of a ticket; this file is what you do.

**Where there is no solution yet, there is nothing to slice.** A request to plan a change that has not been designed is `/solve`'s, and handing it tickets derived from your own guess is the failure the whole chain exists to prevent. Say so and stop.

## Why this one is typed

Its description was measured twice: about three firings in four in a project holding
only this skill, and none at all in five runs in a project holding the twelve this
pipeline ships. What beat it was not a rival skill but the model deciding no skill was
needed. So the pipeline does not rely on being found here - `/solve` names this stage
when it finishes, and a person can type it. Entering plan mode without it still gives an
ordinary plan, which is the floor and is fine.

## The order matters, because plan mode cannot write

1. **Work the slicing out in context** - the tickets, their order, what each covers.
2. **Check it** - `/verify`, on the proposed slicing, before anyone is shown anything. This is the one review that arrives as text rather than a file: hand the subagent the slicing and the solution's path.
3. **Present it and get approval.** What is approved is the slicing, not the files.
4. **Write `tickets/<topic>/` to match**, once plan mode has exited - and with them any ADR the change earned. `software-design` says which decisions those are; plan approval is the yes that lets one be written, and the argument for it is in front of you now and gone by acceptance.

The written files are a transcription of what was approved, and nothing checks them at the moment of writing - the runner's pre-flight is what catches a transcription that drifted, one pass later. So transcribe, do not improve. An idea you have while writing the files is an idea that skipped the approval.

## What a slice is

**Vertical.** Buildable and testable on its own, end to end. "The database part" is not a slice; it cannot be verified without the thing above it, and it leaves the tree in a state no criterion describes.

**One seam.** If two parts of the change can be built and verified independently, they are two tickets - even when one person would do both in an afternoon.

**Ordered by need, not by size.** `after:` is what carries the order. Put a ticket after another only when it genuinely cannot be built first; a false dependency serialises a run for no reason.

**A criterion covered by two slices is two criteria.** When you find yourself quoting half a criterion into one ticket and half into another, stop: the solution is describing two pieces of work in one sentence. Say so and get it split there, where the coverage check can see it.

## Copy, never summarise

A ticket quotes its criteria exactly as the solution writes them - `SLICE_FORMAT.md` says why. Exactly means exactly: a quotation that stops a sentence early has dropped a requirement, and it is the most natural way this goes wrong.

## Re-slicing

Drift, or a verdict routing a lost criterion back, lands here against a directory that already has committed tickets.

- **Committed tickets are immutable.** Their words are what the code was built against, and rewriting them makes the `Record` a lie.
- **Numbering is append-only.** A re-slice adds tickets; it does not renumber the directory.
- **It goes back through plan mode and its approval**, because writing tickets is what that approval authorises. Repair `after:` against the committed tickets as part of the plan.

## Throughout

**Hand off when the tickets are written.** `./run.sh tickets/<topic>` drives them with
nobody watching; a small change is just as well built by working through them yourself.
Either way the tickets are the unit, and nothing merges until the verdict.

**Every criterion lands in some ticket, and every ticket claims some criterion.** Both directions, before you present - nothing checks the proposal but you and `/verify`, because there are no files yet to check.

**Say what you are not slicing.** A solution with parts you are deliberately leaving for later is a plan; say which, so the coverage gap is a decision rather than an oversight.
