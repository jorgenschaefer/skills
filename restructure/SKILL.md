---
name: restructure
description: Restructure a whole codebase so it is easier to change - its structural rules made checks, code that changes together moved together, grab-bag modules split up, hidden coupling made explicit, misleading names and comments fixed, dead and needlessly complex code gone, the docs agents read held to the code, and features that cost more than they give proposed for removal. Run it every one to two weeks.
disable-model-invocation: true
---

# Restructure

You are making the codebase easier to change. For any likely change, the code that has to change with it should be close by and easy to find, and understanding a feature should mean reading a small, contiguous part of the code. Line count is not the measure: deletion matters only because it leaves less to read.

This skill's `CODING_STANDARDS.md` is what the result has to look like. Read it whole first, along with `UBIQUITOUS_LANGUAGE.md` where the repo has one.

Where the codebase is larger than you can hold at once, have parallel `Explore` subagents each inventory one area - its concepts, entry points, enums, string keys, UI flows - and do the cross-matching yourself: coupling and duplication live between areas, where no single subagent sees them. A pass that stopped where the context ran out looks exactly like one that found nothing.

Every run reads the whole codebase. The areas the history changed since the last run are read first; none is skipped.

## Checks first

Before moving anything, make the structure something the checks hold.

- **The check command.** Where `CLAUDE.md` declares no single command on a `Check:` line, write one - build, type check, lint, tests and the structural checks - and declare it. Where the pre-commit hook or CI runs something else, make them run it.
- **Every structural rule `CLAUDE.md` states becomes a check** the command runs, with the places that break it today in a list the check reads, which only shrinks. This changes no behaviour, so apply it.
- **A rule the code follows only by habit** - a layout, a boundary nobody wrote down - goes to the user as a proposal, with the check that would hold it.

## Find what changes together

Judge it from the code: what a change to one piece would force in another - a shared concept, a shared data shape, a name or key that has to match. `git log --name-only` adds a second view, ignoring commits that touch more than about 20 files, and lockfiles and generated files: files that change together in several commits but live far apart are coupled even where the imports do not show it.

## Look for proposals first

Before restructuring anything, look for what the user would never have asked you to change:

- **Near-duplicate concepts.** Two screens, commands, settings or flows that do almost the same thing for the user. One concept, in the UI and in the code.
- **Features that cost more than they give.** A feature spread across many places, whose special cases turn up in code that has nothing to do with it, whose code is large next to what it gives the user, or whose code stays hard to follow however it is restructured.

Leave the code a proposal would remove alone, and say so under that proposal.

## Restructure

Before each change, name the concrete future change that will touch fewer places or need less code read afterwards. Where you cannot name one, leave the code alone.

1. **Delete** what can go without changing behavior: unreachable code, parameters, options, fields and branches, and code that runs to no effect - a redundant check, a flag that is always on, an option nobody sets differently, an unused dependency, stylesheet or asset. Prove each one dead or inert before it goes, against the paths the standard names as only looking dead.
2. **Colocate.** Move code that changes together into the same file, module or directory, grouped by feature. A helper with one caller that lives elsewhere moves next to that caller, or into it. After a move, grep the whole repo - build and CI config, scripts, docs, string paths - for the old location.
3. **Split.** A file or module whose parts change for different reasons - `utils`, `helpers`, `types`, `constants`, a god file - is dissolved into the features that use each part.
4. **Make hidden coupling explicit.** Code that must change in step with nothing linking it - a parallel enum, a string key matched in another file, a switch that must track a registry. Derive one from the other, or put them side by side.
5. **Unify** code that changes for the same reason, so the change happens in one place.
6. **Collapse layers** that spare their caller nothing.
7. **Generalize.** Where special cases pile up on a shared mechanism, change the mechanism so they can go - only where that leaves less code to read than the special cases did.
8. **Simplify** code you had to read twice to follow - deep nesting, long functions, clever constructs - until it reads the way the standard says code should.
9. **Rename** what a search for its concept would not find, or what names something else - a module, a function, a field, a directory - to the glossary's term. A name in stored data or on the wire is a proposal.
10. **Correct comments** that are false, or that tell history - a ticket, a slice, what the code used to do.

## Act or propose

**Apply a change yourself only when you can prove it preserves behavior.** Reading the code and concluding it is equivalent is not proof.

- **A restructuring** is proved by tests that pin the code it touches and pass before and after. Where coverage is missing, write the test that pins the current behavior first, and break the code to watch it fail - a pinning test passes from the start, so that is the only proof it pins anything.
- **A deletion** is proved by showing the code dead or inert. The tests that must pass are the ones on the code that remains.

**Everything you cannot prove preserves behavior goes to the user as a proposal** - feature cuts, merged concepts, and restructurings you could not pin. For each one: what the user loses, which parts of the code stop being entangled with it, and which future changes get easier. Order them by what they free against what they cost the user.

## Docs last

Once the code has moved, hold what agents read before they work against it.

- **`CLAUDE.md`:** every statement about the code - a layout, a layer, a file, a rule - is checked against the code, and whichever is wrong is fixed. A fix to the document is a commit of its own; a fix to the code is a restructuring like the others.
- **`ARCHITECTURE.md`**, where `/repo-overview` wrote it: never edited by hand. Where the structure changed, run `/repo-overview` again.
- **`UBIQUITOUS_LANGUAGE.md`**, where the repo has one: run `/ubiquitous-language` for its drift.

## Finish

One commit per restructuring, so each can be read and reverted on its own. Move a file in a commit of its own with its content unchanged, so `git log --follow` and the next run's history still see through it. Then report what you changed, and the proposals.

Count, for each step above - the checks, each kind of restructuring, the docs - how many things you found and how many you fixed. Put the counts in the report and in the message of the run's last commit, and compare them with the counts the previous run's last commit left.
