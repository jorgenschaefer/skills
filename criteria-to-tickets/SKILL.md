---
name: criteria-to-tickets
description: Turn an agreed CRITERIA.md into the tickets that build it - cut into slices each provable on its own, one ticket each, checked by an adversary and then approved. Typed, because a stage reached only by description is a stage that stops being reached.
disable-model-invocation: true
---

# Criteria to tickets

Take an agreed `CRITERIA.md`, cut it into slices that can each be built and verified on their own, and write a ticket for each - one slice included. A ticket says what to build and what it shares with other tickets, never how: the builder plans in the code.

This skill's `TICKET_FORMAT.md` settles the shape of a ticket. This file is what you do.

## What this takes

`changes/YYYY-MM-DD-<slug>/CRITERIA.md`, agreed with the user.

**Prose describing a problem is not that.** A request to slice a change nobody has worked out is `/find-criteria`'s, and handing it slices derived from your own guess is the failure the whole chain exists to prevent. Say so and stop.

## What a slice is

**Provable on its own.** Each slice ends in behaviour its build can test and its reviewer can see: an AC it closes, or the narrower part of one it advances. A slice that only builds what a later slice will use is not one.

**Sized by its footprint.** Among provable cuts, this is the main constraint. Estimate each slice's footprint from the code you open while slicing: the lines it changes and the files it touches, counting a moved block twice and a deletion like any other change. ACs do not count.

- **At 2000 lines or 25 files, split** along a real seam, even where that seam runs through an AC.
- **Between 1000 and 2000 lines, or 15 and 25 files,** split along a seam the slice has, or have a reason not to.
- **Under 500 lines and 10 files,** merge the slice into a neighbour that reads the same files, as long as the two together stay under 1000 lines and 15 files.

**Split where the context divides, not where the work does.** Two slices that read the same files are one, within the bounds above. So is a slice whose visible result a later slice deletes or rewrites. A separation wanted only for history - a mechanical move kept apart from a behaviour change - is two commits in one ticket.

**`Out of scope` is yours to place.** Each line belongs in the `## Not here` of whichever ticket a builder would otherwise wander into - that is how it reaches the person who needs it, since no builder opens `CRITERIA.md`.

**Ordered by need, not by size.** `after:` is what carries the order. Put a slice after another only when it genuinely cannot be built first; a false dependency serialises a run for no reason.

**Exactly one ticket closes each AC.** It is the slice after which the AC is true, and it writes the AC's test where the user acts. An AC too big for one slice is also advanced by others, each building a narrower part it can prove on its own; the closing ticket comes `after:` every one of them. The size of the work is never a reason to split an AC - that puts your seams into what the user approved. An AC that turns out to describe two behaviours is: put it to the user and get it split in `CRITERIA.md`.

**Every AC is closed by some ticket, and every ticket closes or advances some AC** - except a preparatory ticket, below. Every ticket quotes all four technical decisions, so a builder knows a table or a library it adds is a departure even where the change agreed none. A nudge goes into every ticket it bears on.

**Preparatory tickets come first.** Every ticket that needs one comes `after:` it.

- **No check command:** where `CLAUDE.md` has no `Check:` line in the form `CODING_STANDARDS.md` gives, the first ticket writes the single check command - including a structural check with no rules in it yet - and declares it there in that form. Every other ticket comes after it.
- **Code a search would miss:** where a slice adds to a concept that lives under a name or in a place a search for it would not find, or that the code does two ways, a ticket moves, renames or unifies it first.
- **A large file:** below.

**A slice that introduces a structure adds its check.** A new feature directory, a boundary between layers, where the clock is read: the ticket that introduces it also adds the check that holds it, to the check command.

**A feature directory that is a domain concept gets its name from the glossary.** Where a slice needs one whose term `UBIQUITOUS_LANGUAGE.md` does not have, that is a product question for the approval; the answer goes into the glossary before a ticket names the directory. A missing name is never a reason to leave the directory out.

**A large file is split in a ticket of its own, first.** `CODING_STANDARDS.md` has a large file split before code is added to it, and a build scoped to its criteria will not do that inside its ticket: in one run, three builds in a row each declined the same split as a separate refactor, and each added to the file. Where a slice adds to a file the standard calls large, write a ticket that only splits it and put every ticket that adds to the file `after:` it. A slice that only removes from the file needs no split. Where the large file is a test file, the split ticket shortens it first, as the standard says; if that is not enough, it splits the source and its tests together, and its `Done when` names both, one test file per source file.

**Small files are combined the same way.** Where slices add to source files the standard says to combine, write a ticket that only combines them and their tests, and put every ticket that adds to them `after:` it.

Where a slice introduces a concept the codebase has no name for, or moves a boundary between the ones it does, this skill's `CODING_STANDARDS.md` binds the names the ticket will write.

## What slicing turns up

Read the code each slice will touch before you cut: what exists already, what it is called, which files it adds to. Then walk each slice against that code as its builder would, looking for what only the user can decide: behaviour the user sees that the ACs leave open, ACs that conflict, a nudge the code contradicts, a technical decision the code shows to be short - a table it does not name, a caller it does not mention. The walk is thinking, not a document: its answers go into `CRITERIA.md` or `## Context`, and its steps go nowhere. It turns up two kinds of question.

**Product questions are the user's.** An AC that could mean two things, an edge case nobody owns, a behaviour nobody specified. So is a technical decision that falls short: it was approved, and widening it is the user's call. Answering one yourself is inventing a requirement. Put it to the user at the approval, and write the answer into `CRITERIA.md` before any ticket quotes it - as a new or amended AC, or for a technical decision as the amended decision, never as an AC. Where the answer changes the cut, stop and hand back to `/find-criteria`: the slicing in your hands was made against criteria that no longer say what they said.

**Implementation decisions between tickets are yours.** Which ticket builds what several need, a name or format other tickets build on. Decide them, write them into the tickets' `## Context`, and show them at the approval so the user can object. They are not written back into `CRITERIA.md`. Decisions inside one ticket are its builder's.

## Write, check, approve

1. **Write the tickets** to `tickets/NN-<slug>.md` in the change's directory.
2. **Check them.** Spawn a subagent with a fresh context and give it `VERIFY.md` from this directory, the paths to the ticket files, and the path to `CRITERIA.md`. Nothing else - a reviewer that has your reasoning will read your intentions into the words.
3. **Fix what it finds, then ask for approval.** Fix a finding with the least text that settles it: name the ticket that owns a thing, not how it is built. Every sentence added to `## Context` is one the next check reads - in one run, an import rule written into a ticket to back up where a shared rule lived was the next check's main finding.

   A ticket added, or whose `closes`, `advances`, `after:` or `## Context` changed to fix a silent finding, goes through the check again first: hand the subagent the whole directory again, naming those tickets, so it holds the rest against them. A check that saw tickets 01 to 20 said nothing about the 21 a rework added after it, and that one built a second copy of something another ticket built. A fix to a loud finding alone does not go back: the stop it fixes was already the check, and another round costs more than that stop would have. Name what changed when you hand it back, not what to look for - a reviewer told where to look finds something there.

   Show the slicing - each slice with its estimated footprint, and the reason for any between 1000 and 2000 lines or 15 and 25 files - the implementation decisions, and the product questions as one list. A no means editing the tickets and asking again.

## Copy, never summarise

A ticket quotes its ACs, technical decisions and nudges exactly as `CRITERIA.md` writes them - `TICKET_FORMAT.md` says why. Exactly means exactly: a quotation that stops a sentence early has dropped a requirement, and it is the most natural way this goes wrong.

The same holds of the `## Context` under them: it adds no requirement to the ACs quoted above it. A Context that does has widened work nobody approved.

## ADRs

Only for a decision you newly make while reading the code - one from `/find-criteria` already has its record. Where this skill's `ADR_FORMAT.md` says it earns one, put it to the user at the approval with a recommendation, and on a yes write it to `docs/adr/` in that file's shape.

## Re-slicing

Drift, or acceptance routing an unmet AC back, lands here against a directory that already has committed tickets.

- **Edit the tickets the change touches, in place:** the new quote and Context, no `## Halt`, no `## Left standing`, `status: ready`, `attempts: 0`. A built ticket whose AC changed is rebuilt this way, not annotated - its words are what the code was built against.
- **A technical decision that changed is re-quoted in every ticket**, since every ticket carries all four. A ticket not yet built takes the new quote with the rest of its edit. A built one takes it in place and stays `done` - unless its code no longer holds to the new decision, and then it is rebuilt like a ticket whose AC changed.
- **Delete a ticket with nothing left to build; add tickets for new work.** Fix every `after:` that named a deleted ticket - the runner halts on one that names nothing.
- **Delete `REVIEW.md`**, where there is one: it reviewed what is about to change, and the runner does not review again while it is there.
- **It goes through the same write, check, approve**, because the tickets are what is being changed.
- **Commit the re-slice before the runner starts again** - the runner refuses a dirty tree, and its own halts are uncommitted too.

## Hand off

Commit the change's directory - `CRITERIA.md`, specimens, tickets - and any ADRs before handing off; the runner refuses a dirty tree.

**One ticket:** `/implement` on it, telling it what the runner tells every build: its technical decisions were agreed, and where the code calls for more than one says, or departs from a nudge, it builds what the code calls for and records under `## Left standing` what was agreed, what it built and why. Then `/accept-criteria`.

**Several:** `./run.sh changes/<slug>/tickets` drives them with nobody watching, and ends by pointing to `/accept-criteria`.

Name the next step - it will not find its own way in - and leave going on to them to ask for.
