---
name: split-change-into-chunks
description: Split a change's CHANGE.md into chunks in the same shape, each small enough for one agent to build within one context - or leave it whole where it already fits. Run by run.sh before the first build, with nobody watching.
disable-model-invocation: true
---

# Split a change into chunks

Take a change's `CHANGE.md`, judge whether one agent can build it within one context, and where it cannot, split it into chunks that can each be built and tested on their own. A chunk says what to build and what it shares with other chunks, never how: the builder plans in the code.

This skill's `CHANGE_FORMAT.md` settles the shape of `CHANGE.md` and of each chunk.

## What this takes

`changes/YYYY-MM-DD-<slug>/CHANGE.md` and the journeys it names, committed on the change's branch. Nobody is watching: ask nothing. Where only the developer can answer something, halt, as below.

## Does it fit?

Read the code the change will touch, and estimate its footprint: the lines it changes and the files it touches, counting a moved block twice and a deletion like any other change.

**Under 1000 lines and 15 files, it fits.** Write nothing and say so. The runner builds `CHANGE.md` itself.

Otherwise, split it.

## What a chunk is

**Provable on its own.** Each chunk ends in journey steps its build can test and its reviewer can see. A chunk that only builds what a later chunk will use is not one.

**Sized by its footprint.**

- **At 2000 lines or 25 files, split** along a real seam, even where that seam runs through a journey.
- **Between 1000 and 2000 lines, or 15 and 25 files,** split along a real seam where the chunk has one.
- **Under 500 lines and 10 files,** merge the chunk into a neighbour that reads the same files, as long as the two together stay under 1000 lines and 15 files.

**Split where the context divides, not where the work does.** Two chunks that read the same files are one, within the bounds above. So is a chunk whose visible result a later chunk deletes or rewrites.

**Ordered by need, not by size.** `after:` carries the order. Put a chunk after another only when it cannot be built first; a false dependency serialises a run for no reason.

**Everything is placed.** Every journey `CHANGE.md` names is named by a chunk, every step of those journeys is built by one, and every line of the design and of "Not in this change" lands in the chunk a builder needs it in.

**Preparatory chunks come first**, name no journeys, and every chunk that needs one comes `after:` it:

- **No fast check:** where `CLAUDE.md` has neither a `Fast check:` line nor a `Check:` line, the first chunk writes the fast check and declares it on a `Fast check:` line.
- **A fast check over 30 seconds:** time it. Where it takes longer, the first chunk makes the slowest tests fast where it can, moves the rest to the slow check, and reports how long the fast check took before and after.
- **Code a search would miss:** where a chunk adds to something that lives under a name or in a place a search would not find, or that the code does two ways, a chunk moves, renames or unifies it first.

## Writing a chunk

`chunks/NN-<slug>.md` in the change's directory, numbered for identity, never reused, two digits. In `CHANGE_FORMAT.md`'s shape:

- **`journeys`:** the journeys whose steps it builds.
- **Problem:** `CHANGE.md`'s, copied word for word.
- **Design:** the parts of `CHANGE.md`'s design it builds, copied word for word, with the prototype link where they rest on it. Then which steps of each journey it builds and tests, and what it shares with other chunks: which chunk builds a thing several need, a name or format other chunks build on. Decide those yourself; they are not the developer's.
- **Not in this change:** the lines of `CHANGE.md`'s that a builder here would wander into, and the boundary against the neighbouring chunks, naming the chunk that builds each excluded thing.

A copy stops nowhere early: a quotation cut short has dropped part of what was approved. And nothing added to a chunk asks for more than `CHANGE.md` does.

## What only the developer can decide

Walk each chunk against the code as its builder would.

**A question the design leaves open, whose answer changes what the user sees**, or two parts of the design that pull against each other, is the developer's. Do not guess. Halt: write `CHANGE.md`'s `## Halt` with the kind `undecided` and the question, set its `status: halted`, and commit it.

**A step only a person can do before the build** - a secret, a credential, an account, access to grant - halts the same way, with the kind `blocked`, the step, and a shell command that shows it is done and prints no secret. A build must never write a secret, or fake the step.

**A step that can only happen at deployment** - DNS, a related service, data in production - goes into `CHANGE.md`'s `## Left standing` as a line beginning "At deployment, a person", and into the "Not in this change" of the chunk a builder would otherwise wander into.

## Check, then commit

1. **Check the chunks.** Spawn a subagent with a fresh context and give it `VERIFY.md` and `CHANGE_FORMAT.md` from this directory, the path to the change's directory, and how long the fast check took. Nothing else - a reviewer that has your reasoning will read your intentions into the words.
2. **Fix what it finds** with the least text that settles it. A finding only the developer can settle halts, as above. A chunk added, or whose `journeys`, `after:` or design changed to fix a silent finding, goes through the check again with the whole directory, naming what changed. A fix to a loud finding does not.
3. **Commit `chunks/`**, with `CHANGE.md` where its `## Left standing` changed.

## Splitting again

The runner, or acceptance, can send a change back here once chunks are built.

- **Edit the chunks the change touches, in place:** no `## Halt`, no `## Left standing`, `status: ready`, `attempts: 0`. A built chunk whose design changed is rebuilt this way.
- **Delete a chunk with nothing left to build; add chunks for new work.** Fix every `after:` that named a deleted chunk.
- **Delete `REVIEW.md`**, where there is one: it reviewed what is about to change.
- **Check and commit as above.**
