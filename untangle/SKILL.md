---
name: untangle
description: Turn an explanation of a part of the code that the developer understands, from /explain-code, into a module shape they approve, and write the CRITERIA.md that reworks the code behind it without changing what it does.
disable-model-invocation: true
---

# Untangle

The developer understands an explanation of a part of the code, and the code does not read like it. Agree with them a module shape whose parts are the explanation's concepts, then write the `CRITERIA.md` that reworks the code into that shape without changing what it does, for `/criteria-to-tickets` to slice.

This skill's `CRITERIA_FORMAT.md` settles the shape of the file it writes.

## Start from the explanation

**Take the explanation from the conversation**: the one `/explain-code` ended with, which the developer said they understand, with the files the code is in and any case they called surprising.

**Where there is none**, tell them to type `/explain-code <their question>` and then `/untangle` again, and stop. Do not write an explanation yourself: the one that works comes from `/explain-code`'s writer, rewriter and checker.

## Propose the shape

Read the files the explanation names and search for every use of them. Then propose, in chat and in the explanation's terms:

- **For each concept** of the explanation, the module it becomes. A concept is a term with a titled section, and every one becomes a module. A term only one section uses sits inside the module of that section's concept. A term the summary uses, or several sections use, sits at the deepest level that holds all its users - wherever its section happens to stand in the text. Give each module its path, named with `UBIQUITOUS_LANGUAGE.md`'s term where the project has one, and what it offers: its functions or types and their parameters. A new directory for a concept the glossary has no term for is named by the developer; once they approve the shape, the name goes into the glossary where the project has one, in the shape its entries have.
- **One call from an existing test**, rewritten against the new modules, so the shape shows in use.
- **The callers outside those files that will move**, as `<file>:<line>`, each with the module it will call instead.
- **A sample change** put in the explanation's terms - "measure the pace over ten days instead of seven" - which the rework will make on a throwaway branch to show it lands in one place.
- **The four technical decisions** for the rework, held against the files and the callers that move, "none" included: a scope file that defines a route or a stored type puts that format in scope. Stored formats always include `EXPLANATION.md`, `test-map.md` and `checks.md` in the change's directory, deleted with it, and the backlog item below where there is one.

They correct it or approve it. Push back once on a correction you think is wrong; a decision reaffirmed after hearing the objection is theirs. Keep each shape they rejected, with why, for `## Ruled out`. Write nothing before they approve.

## Surprising cases

Where they called a case surprising, run `/backlog` to add one item to the project's backlog: deciding whether those cases of the rule are still needed, with each case in their words.

## Write the criteria

Make `changes/YYYY-MM-DD-<slug>/` with today's date and a slug of the question, and write into it:

- **`EXPLANATION.md`**: the explanation as last shown, and the files the code is in.
- **`CRITERIA.md`**: the template below, filled in.

````markdown
# Criteria: <the question, as a rework>

## Problem
The developer asked <their question, in their words>, and no longer knows what <the part of the code, in the explanation's words> does, and cannot learn it from the code. Even once they understand what it does, the code does not follow that understanding, so a change they can put in its terms does not point to a place in the code. Instead, a change put in the explanation's terms points to one place in the code, and the code can be understood without the explanation. What the code does stays the same.

<The instance the developer gave in the conversation - the case that went wrong, the change they could not judge - or: "The developer gave no instance.">

## Acceptance criteria
- **AC-1** <Concept> is the module `<path>`, offering <what it offers>.
<one such AC per concept, numbered on>
- **AC-n** The new tests against these modules were committed green against the old code, before any commit changed the code behind them.
- **AC-n** `test-map.md` in this directory lists every test that existed before this change in a file importing one of the scope files directly, each with either the new test that is its home or "no longer reachable" and the reason.
- **AC-n** From the first commit that changes the code behind the new modules onward, the only change any commit makes to a test file is deleting an old test `test-map.md` lists.
- **AC-n** `test-map.md` holds a fresh agent's verdict on every row: that the new home holds the old test's inputs, expected values and assertions, or that the "no longer reachable" reason is borne out by the code.
- **AC-n** Outside this directory, the glossary, `docs/adr/` and `CLAUDE.md`, the diff touches only the scope files, the new modules, the callers that move, test files, and the structural checks that hold the new modules.
- **AC-n** Outside the new modules, no code, tests included, imports from a scope file that is not itself one of the new modules, and the project's check command is green.
- **AC-n** `checks.md` in this directory holds a description a fresh agent wrote from the new modules alone, which names every concept `EXPLANATION.md` gives a section and contradicts none of its statements.
- **AC-n** `checks.md` holds the diff stat of the sample change - <the sample change> - made by a fresh agent on a throwaway branch, touching one module per concept it changes.

## Agreed design
The code is reworked into the shape below, whose parts are the concepts of `EXPLANATION.md`, in three steps, in this order:

1. The new modules, as an interface over the old code, and the callers that move - test files among them - switched to them.
2. New tests against that interface, named and grouped by the explanation's concepts, and `test-map.md` mapping every old test to its new home.
3. The code behind the interface replaced, with the new tests unchanged.

| Concept | Module | Offers |
| --- | --- | --- |
| <concept> | `<path>` | <what it offers> |

The scope files: <the files the explanation names>.

The callers that move: <file:line, each with where it will call instead>.

**Agreed; build to this, do not redesign.**

## Technical decisions
- **Stored formats** <as approved>
- **Wire formats** <as approved>
- **Trust boundaries** <as approved>
- **Dependencies** <as approved>

## Nudges
- Build the three steps of the agreed design in order, each finished before the next starts.
- A new test reaches the case its old test pinned through the new modules, even where the old test called an internal function directly.
- Where the approved shape cannot work, halt and say why rather than change it: the developer approved it, and only they can change it.

## Out of scope
- Whether the rule's cases are all still needed<, in the backlog item `<slug>`>.
- <Each case the developer called surprising.>
- Writing tests where coverage is thin: the existing tests are taken as pinning the behaviour.

## Ruled out
- **<A shape the developer rejected>** - <why>.
<Omit the section where they rejected none.>
````

Number the ACs from 1 in the order above.

## Hand on

Say that `/criteria-to-tickets changes/YYYY-MM-DD-<slug>` turns it into work, and leave going on to them.
