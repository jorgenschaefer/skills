---
name: refactor-codebase
description: Make a codebase easier to change, every few changes - from the friction notes the builds, debug sessions and acceptances left in changes/friction/, the git history and the code, agree a plan with the developer, build its most important items without changing what the software does, and have them reviewed.
disable-model-invocation: true
---

# Refactor the codebase

Make the codebase easier to change for the next agent, which will remember nothing of this one. For any likely change, the code that has to change with it should be close by and easy to find, and understanding a feature should mean reading a small part of the code. Line count is not the measure: deletion matters only because it leaves less to read.

**What the software does stays the same.** The hard tests - the files with `.hard.` in their name - pass without being changed. A refactor that needs to change a journey or a hard test changes what the software does: it is a change, and goes through `/idea`.

This skill's `JOURNEY_FORMAT.md` settles the shape of a journey.

## Gather the signals

- **The friction notes**, every file in `changes/friction/`. The builds and the debug sessions wrote them where something was hard to change or hard to find, and acceptance wrote down the review findings about the code that nobody fixed. A place several notes name is the strongest signal there is.
- **The git history.** Which files change often, which change together, and which keep getting fixed. Use `git log --name-only`, ignoring commits that touch more than about 20 files, and lockfiles and generated files. Files that change together in several commits but live far apart are coupled, even where the imports do not show it.
- **The code.** What a change to one piece would force in another: a shared concept, a shared data shape, a name or key that has to match elsewhere. And names that are not the journeys' words for the same thing.

Where the codebase is larger than you can hold at once, have parallel `Explore` subagents each survey one area, and do the cross-matching yourself: coupling and duplication live between areas, where no single subagent sees them. A survey that stopped where the context ran out looks exactly like one that found nothing.

## Make the plan

Each item in the plan says:

- **what is hard**, with the evidence: the friction notes, the history, the code;
- **the future change that gets easier**, named concretely. Where you cannot name one, it is not an item;
- **what to do**, from the kinds below;
- **how big it is.**

Rank the items by how much easier they make the changes most likely to come, against their size.

What would change what the software does - two screens that do almost the same thing, a feature that costs more than it gives the user - is not an item. List it apart, in the user's words: what the user would lose, and which changes would get easier.

Show the plan to the developer, and agree which items to build now. An item too large for this session gets a plan of its own: make a branch named `YYYY-MM-DD-refactor-<slug>`, write `changes/YYYY-MM-DD-refactor-<slug>/spec.md` with the item, commit it with `git-commit-message`, and hand it to `/create-plan`.

## The kinds of refactoring

1. **Delete** what can go without changing what the software does: unreachable code, unused parameters, options, fields and branches, a flag that is always on, an unused dependency or asset. Prove each one dead first. Code can look dead and still be live: called by reflection or through a string, registered for dependency injection, named in config, a framework entry point, required by a signature it has to match, a field in a stored or wire format, or used from outside this repository.
2. **Colocate.** Move code that changes together into the same file, module or directory, grouped by feature. After a move, grep the whole repository - build and CI config, scripts, docs, string paths - for the old location.
3. **Split** a file whose parts change for different reasons - `utils`, `helpers`, `types`, a god file - into the features that use each part.
4. **Make hidden coupling explicit.** Code that must change in step with code nothing links it to - a parallel enum, a string key matched in another file. Derive one from the other, or put them side by side.
5. **Unify** code that changes for the same reason, so the change happens in one place.
6. **Collapse layers** that spare their caller nothing.
7. **Generalize** a shared mechanism where special cases pile up on it, only where that leaves less to read than the special cases did.
8. **Simplify** code you had to read twice to follow.
9. **Rename** to the journeys' words what a search for its concept would not find. A name in stored data or on the wire changes what the software does to whoever reads it: it is not yours to change.
10. **Correct comments** that are false, or that tell history.

## Build it

**Work on a branch.** Where you are on `main` or `master`, make one named `YYYY-MM-DD-refactor` first.

**Prove that each item keeps what the software does.** Reading the code and concluding it is the same is not proof. The proof is tests that cover the code the item touches and pass before and after: the hard tests, unchanged, and any other test. Where nothing covers it, first write a test that pins what it does today, and break the code to watch it fail - a pinning test passes from the start, so that is the only proof it pins anything. Soft tests are yours to change or delete once they are in the way.

**An item you cannot prove**, leave as it is, and say so in the report.

**Run the checks** - the `Fast check:` and `Slow check:` lines in `CLAUDE.md` - before each commit, and see them green.

**One commit per item**, so each can be read and reverted on its own, with `git-commit-message`. Move a file in a commit of its own with its content unchanged, so `git log --follow` and the next refactor's history see through it. Stage only the files the item touched; never `git add -A`.

## Review it

Spawn `review-code` with a fresh context. Give it the diff from where the branch started, the result of the checks, and as its spec, the plan items you built. Not how you built them. Tell it that what the software does must not change, and that a changed `.hard.` file is a blocker. Fix the blockers and the should-fix, and say what you left standing.

## Docs last

- **`CLAUDE.md`:** hold every statement it makes about the code - a layout, a file, a rule - against the code, and fix whichever is wrong.
- **`UBIQUITOUS_LANGUAGE.md`**, where the repository has one: run `/init-ubiquitous-language` for its drift.

## Finish

Delete the friction notes the items you built dealt with, and commit that. Notes for items you did not build stay, so the next refactor sees them again.

Report what you changed, one line per item; each item you could not prove, and why; the items left in the plan; and what you listed apart as changes to what the software does. Merging the branch is the developer's.
