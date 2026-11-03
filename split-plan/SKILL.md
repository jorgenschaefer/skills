---
name: split-plan
description: Split a change's plan.md into parts in plan/, each a run of the plan's steps small enough for one agent to build within one context, built one after the other - or leave it whole where it fits or the developer asked for one part. Run by run.sh before the first build, with nobody watching.
disable-model-invocation: true
---

# Split a plan

Take a change's `plan.md`, judge whether one agent can build it within one context, and where it cannot, split it into parts that are built one after the other, each in a fresh context.

This skill's `PLAN_FORMAT.md` settles the shape of `plan.md` and of each part.

## What this takes

`changes/YYYY-MM-DD-<slug>/plan.md`, committed on the change's branch. Nobody is watching: ask nothing.

**An open question is not a halt.** The plan was checked and its hard decisions answered before the run. A question left open is a defect that check missed: write it under `plan.md`'s `## Left standing`, take the smallest reading, and go on.

## Does it fit?

**Where `plan.md` says to build it as one part, it is built as it is.** Write nothing and say so.

Otherwise, read the code the plan will touch, and estimate its footprint: the lines it changes and the files it touches, counting a moved block twice and a deletion like any other change. This stands in for what one agent builds well within one context.

**Under 1000 lines and 15 files, it fits.** Write nothing and say so. The runner builds `plan.md` itself.

Otherwise, split it.

## What a part is

**A run of the plan's steps**, in the plan's order, copied word for word with their numbers. A part such as "add the schema" builds nothing a user sees, and that is fine: nothing is walked inside the run.

**Sized by its footprint.**

- **At 2000 lines or 25 files, split** between two steps.
- **Between 1000 and 2000 lines, or 15 and 25 files,** split where the steps divide into two that read different files.
- **Under 500 lines and 10 files,** merge the part into a neighbour that reads the same files, as long as the two together stay under 1000 lines and 15 files.

**Split where the context divides, not where the work does.** Two parts that read the same files are one, within the bounds above. So is a part whose result a later part deletes or rewrites.

**Everything is placed.** Every step of `plan.md` is in exactly one part, except a step only for deployment, below.

**Preparatory steps come first.** Where the plan has no such step, add it at the front of `plan.md`'s steps, then place it like any other:

- **No fast check:** where `CLAUDE.md` has neither a `Fast check:` line nor a `Check:` line, the first part writes the fast check and declares it on a `Fast check:` line.
- **A fast check over 30 seconds:** time it. Where it takes longer, the first part makes the slowest tests fast where it can, moves the rest to the slow check, and reports how long the fast check took before and after.
- **Code a search would miss:** where a step adds to something that lives under a name or in a place a search would not find, or that the code does two ways, a step before it moves, renames or unifies it.

## Writing a part

`plan/NN.md` in the change's directory, numbered `01`, `02`, … in the order they are built. In `PLAN_FORMAT.md`'s shape:

- **Hard decisions:** each one its steps touch, copied word for word from `plan.md`.
- **Hard tests:** each one its steps write or change, copied word for word.
- **From the parts before:** what the earlier parts build that this one builds on. Decide that yourself.
- **Steps:** its run of the plan's steps, copied word for word.

A copy stops nowhere early: a quotation cut short has dropped part of what was agreed. And nothing added to a part asks for more than `plan.md` does.

## What a build cannot do

**A step only a person can do before the build** - a secret, a credential, an account, access to grant - halts the run. Write `plan.md`'s `## Halt` with the kind `blocked`, the step, and a shell command that shows it is done and prints no secret. Set its `status: halted`, commit it, and stop. A build must never write a secret, or fake the step.

**A step that can only happen at deployment** - DNS, a related service, data in production - goes into `plan.md`'s `## Left standing` as a line beginning "At deployment, a person", and into no part.

## Check, then commit

1. **Check the parts.** Spawn a subagent with a fresh context and give it `VERIFY.md` and `PLAN_FORMAT.md` from this directory, the path to the change's directory, and how long the fast check took. Nothing else - a reviewer that has your reasoning will read your intentions into the words.
2. **Fix what it finds** with the least text that settles it. Where a fix changed which steps a part holds, or what it takes from the parts before, check again the same way with the whole directory, naming what changed. **Two rounds at most.**
3. **Commit `plan/`**, with `plan.md` where it changed.

## Splitting again

The runner, or acceptance, can send a change back here once parts are built.

- **Edit the parts the change touches, in place:** no `## Halt`, no `## Left standing`, `status: ready`, `attempts: 0`. A built part whose steps changed is rebuilt this way.
- **Delete a part with nothing left to build; add parts for new work.** Parts are built in number order, so renumber the parts not yet built where new work has to come before them.
- **Set `plan.md` back to `status: ready`** and remove `### End review` and what is under it from its `## Left standing`, so the rebuilt parts are reviewed again.
- **Check and commit as above.**
