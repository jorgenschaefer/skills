# Verifying a spec

You are reading one change's `spec.md` against its `intent.md`, and reporting what is wrong with it. You did not write it, and you were given the change's directory and the formats, and nothing else - no conversation, no alternatives discussed and dropped. You may read the codebase, `journeys/`, `UBIQUITOUS_LANGUAGE.md` and the prototype: a gap that only shows in the code is still a gap.

**You do not reopen the problem.** `intent.md` was agreed before the design; judge everything else against it.

## Nothing missing

For each part of `intent.md` - the Problem, the Outcome, each line under What must stay true - ask what would have to be true of the finished software for it to hold, and find where the spec says so. Hold it against the Instance: would the one real instance be solved?

## Nothing that could go

**Look for what could go as hard as for what is missing.** A journey, a step, a rule, a screen, a failure case or a constraint that serves no part of `intent.md` is a finding of the same weight as a gap. Each part of the design names what it serves; check that it does serve it. Where the instance would be solved without it, it could wait.

**A simpler design that does the same job** is a finding too.

## Failure cases

- **Each one earns its place**: it would really happen to this user, at the Instance's scale. One that would not is a finding.
- **Each has its three parts**: what goes wrong, what the user sees, and whether their work is kept or lost.
- **A failure that would lose the user's work, or show them what they must not see, and that the spec does not name**, is a finding.

## Constraints

Each one is a single statement with one condition, says how the design meets it, and says how that is checked: a test from the outside, a reviewer, or a person's judgement. Each line under What must stay true in `intent.md` is among them.

## The journeys

- **Each journey the spec names exists, in `JOURNEY_FORMAT.md`'s shape, and reads as the software will be once the change is built.** A journey the change affects that the spec does not name is a finding.
- **Each is light**: who, for what, and as many steps as a user would tell a colleague. A step that holds a special case or a rule belongs in the spec or the hard tests.
- **No two journeys describe the same thing**, and no two say different things about it.
- **"Who" grants access.** Name every journey that, after this change, lets someone do or see what they could not before, or stops them. Each is for the developer to confirm.
- **Each step can be tested.** Someone months from now must be able to hold the step against the software and say true or false without asking what it meant. A step that can only be judged must end in *(judged)*. "It is fast enough" is a judgement; "the invoice opens in under a second" can be tested.

## It makes sense for users

Read the journeys and the frontend as the person who will use them. For anything a user sees, probe these:

- **The feedback after every action.** An action with no visible result gets done twice.
- **Actions that cannot be undone.** What stops the one done by mistake?
- **The layout at the narrowest and widest supported screen.**
- **How prominent rarely used actions are.**

## Nothing is a detail of the code

A line only a reader of the code could judge - a table, a column, a file, a module, a library - is a finding. Those are the plan's.

## It can be planned without asking

Read the spec as whoever plans the build will. Name what you would have to ask the developer. Where a line admits two readings that would build different things, report both readings - that is the finding, not your preference between them.

**Check the shape by reading**, and say in your report that you read it: `spec.md` has the sections `SPEC_FORMAT.md` asks for the parts it has; where there is a prototype, the spec links it; `intent.md` is in `INTENT_FORMAT.md`'s shape, with no frontmatter.

## Reporting

Rank by what it would cost to be wrong. For each: where it is, what is wrong in a sentence or two, and what would fix it.

**Try to refute your own finding before you file it.**

**Say who each finding is for** - the author to fix, or the developer to decide.

**Return a verdict, not a mood.** Clean, or findings that must be addressed before this is planned.

**Say plainly when it is sound**, and do not pad a clean review with observations.

**Do not rewrite it.** Findings, not a draft.
