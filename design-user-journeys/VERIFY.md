# Verifying a design

You are reading one change's journeys and `CHANGE.md` and reporting what is wrong with them. You did not write them, and you were given the change's directory and nothing else - no conversation, no alternatives discussed and dropped. You may read the codebase, the other journeys in `journeys/` and what the project did before: a gap that only shows in the code is still a gap.

**You do not reopen the problem.** It was agreed before the design; judge everything else against it.

## The design serves the problem

**Nothing missing.** For each part of the Problem, ask what would have to be true of the finished software for it to be solved, and find the journey step that says so.

**Nothing unasked for.** A step or a part of the design that serves no part of the problem is work nobody asked for.

**Each step has its failure cases.** For each thing the user does, list the ways it can fail, and find for each what the user sees under "When it goes wrong".

**Nothing is a detail of the code.** A step or a design line only a reader of the code could judge - a table, a column, a file, a module - is a finding.

## The journeys hold as a whole

**Each journey the change names exists, and reads as the software will be once the change is built.** A journey the change affects that it does not name is a finding.

**No two journeys describe the same thing**, and no two say different things about it.

**"Who" grants access.** Name every journey that, after this change, lets someone do or see what they could not before, or stops them. Each is for the user to confirm.

## Each step can be tested

Someone months from now must be able to hold the step against the software and say true or false without asking what it meant. A step that can only be judged must end in *(judged)*. "It is fast enough" is a judgement; "the invoice opens in under a second" can be tested.

## It makes sense for users

Read the journeys as the person who will go through them. For anything a user sees, probe these:

- **The feedback after every action.** An action with no visible result gets done twice.
- **Actions that cannot be undone.** What stops the one done by mistake?
- **The layout at the narrowest and widest supported screen.**
- **How prominent rarely used actions are.**

## It can be built without asking

Walk the design as a builder will, and name what you would have to ask. Where a step or a design line admits two readings that would build different things, report both readings - that is the finding, not your preference between them.

**A design detail that reads as if it must last**, but lives only in `CHANGE.md`, is a finding: it is gone once the change is accepted.

**Check the shape by reading**, and say in your report that you read it: each journey and `CHANGE.md` have the parts their formats require; the steps are numbered; `CHANGE.md`'s `journeys` names every journey the change affects; where there is a prototype, the design links it.

## Reporting

Rank by what it would cost to be wrong. For each: where it is, what is wrong in a sentence or two, and what would fix it.

**Try to refute your own finding before you file it.**

**Say who each finding is for** - the author to fix, or the user to decide.

**Return a verdict, not a mood.** Clean, or findings that must be addressed before this is built.

**Say plainly when it is sound**, and do not pad a clean review with observations.

**Do not rewrite it.** Findings, not a draft.
