# Criteria: the developer approves what the manifesto gives them

## Problem
Two problems, each agreed with `/idea` on 2026-10-27.

First: before a change is built, the developer approves its behaviour and its technical decisions. But four decisions the manifesto gives them are never put to them: what the user experiences when something fails, what production must show and how fast, what the system keeps and for how long and what it never keeps, and whether to make a change that discards information. An agent settles these alone, or they come up only after the build. Instead, each of these is put to the developer before the build, in words they can judge without reading the code. The developer decides it, or decides that it doesn't apply.

Instance: no failure. The manifesto rewrite (23c6504) gave the developer these decisions, and `find-criteria` was not updated with it. `find-criteria/CRITERIA_FORMAT.md:26-29` and `find-criteria/SKILL.md:33` ask none of them, and retention appears nowhere in the repo.

Second: before and after a build, the developer is asked to decide how the code is built. That means table and column names, feature directory names, a new repository's layout, ideas for how the build should go, and departures from these at acceptance. They can't usefully judge any of this, so they wave it through or ignore it. Asking them costs their attention and adds no check. In one build, a useful directory was not created because the glossary had no name for it. Meanwhile, what they can judge comes mixed in with all this rather than in its own terms. Whether the stored data maps to the domain - which things exist and how they relate - comes as column names. Who may see and do what comes mixed with new input and outgoing calls. Instead, the developer is asked to decide only what they can judge, in the glossary's words: the shape of the data as concepts, the security policy, and a weakened check as what it no longer protects.

Instance: the developer was asked to approve table and column names and waved them through because they fit the glossary. In drk-barmbek.de, which merged a Prisma and a Drizzle project, the table names are a mix, and nobody cares. What matters is that the schema maps to the domain, which is closer to an ER diagram. The developer ignores nudges, and did not care about the feature directory names they were asked for.

## Acceptance criteria
- **AC-1** For every behaviour in the criteria, `/find-criteria` asks what the user experiences when it fails, and the approved ACs state it.
- **AC-2** `/find-criteria` asks about what production must show and how fast, who may see and do what, and what the system keeps, for how long, and never keeps. Each ends as ACs or as "None.".
- **AC-3** Every `CRITERIA.md` that `/find-criteria` or `/untangle` writes has, under `## Acceptance criteria`, the groups Behaviour, What production must show, Security policy and Information model, each holding ACs or "None.".
- **AC-4** Its technical decisions are exactly Concepts, Wire formats and Hard to reverse, each answered or "none". Concepts names the things the system keeps and how they relate, in the glossary's words, and never tables, columns or files.
- **AC-5** `/find-criteria` never asks the developer to approve or object to details of the code - tables, columns, file or directory names, a repository's layout or layers, ideas for how to build it - and a `CRITERIA.md` has no `## Nudges`. The developer still picks the approach from the alternatives and approves the agreed design.
- **AC-6** A new concept's term is agreed with the developer under Concepts, and added to the glossary where the project has one.
- **AC-7** `/find-criteria`'s verifier reports a missing AC group, a behaviour without its failure cases, and an AC only a reader of the code could judge.
- **AC-8** `/accept-criteria` asks the developer to decide on: anything that goes beyond a technical decision or that a group's "None." rules out; a departure from the agreed design; an ADR worked around or a `CLAUDE.md` rule broken; and a weakened check, described by what it no longer protects.
- **AC-9** `/accept-criteria` does not show departures from nudges, new or crossed boundaries where no check was loosened, precedents, or tables, columns and fields as such. It still shows the operational shape, blast radius and revert, new dependencies, and assumptions about facts outside the repository.
- **AC-10** A ticket quotes the three technical decisions and no nudges, and `run.sh` still stops on a ticket whose technical decision is not in `CRITERIA.md` word for word.
- **AC-11** A change sliced in the old shape - four technical decisions and nudges - still runs through `run.sh` with no drift halt caused by that shape.
- **AC-12** `/untangle` proposes the three technical decisions and its template writes them, with no nudges. Its three nudges - the build order, reaching an old test's case through the new modules, and halting where the approved shape cannot work - are in its agreed design. Its ACs stand under Behaviour, unchanged, and the other three groups say "None.". `EXPLANATION.md`, `test-map.md` and `checks.md` are no longer named in a technical decision.
- **AC-13** The README describes what the developer approves as the four AC groups and the three technical decisions, and says nothing about nudges.
- **AC-14** `./test.sh` is green.
- **AC-15** At acceptance, two follow-ups are proposed to `/backlog`: `untangle`'s code-level ACs as an item of their own, and "Give every new domain rule one home" (`find-criteria/SKILL.md:39`) as a finding for `cut-files-by-concept`.

## Agreed design
The decisions the manifesto gives the developer become ACs, in four fixed groups that are always present, each a `###` heading under `## Acceptance criteria`, in this order: `### Behaviour` (failure cases included), `### What production must show`, `### Security policy`, `### Information model`. A group with nothing in it holds the plain line `None.`, which makes anything the build adds there a departure. Three technical decisions stay: Concepts, Wire formats, Hard to reverse. Nudges leave the pipeline: builders work out how to build from the code and `CODING_STANDARDS.md`. Acceptance asks the developer only about what they approved, and shows a weakened check by what it no longer protects.

The technical decisions in `CRITERIA_FORMAT.md`, as agreed:

- **Concepts** <The things the change adds to or changes in what the system keeps, and how they relate, in the glossary's words: "a swap request belongs to one shift and to two members". A new concept gets its term here, agreed with the developer. Not tables, columns or files - or "none".>
- **Wire formats** <The endpoints, payloads, events, flags, config keys, environment variables and exit codes something outside this change depends on, and what an old caller sees - or "none".>
- **Hard to reverse** <A change that discards information - data deleted, a field dropped, history merged - and a dependency the codebase will be built around, each with what it gives and what it costs - or "none".>

Acceptance's list of what changed from what was agreed: the developer decides on going beyond a technical decision or a group's "None.", a departure from the agreed design, an ADR worked around or a `CLAUDE.md` rule broken, and a weakened check (a structural check or its exception list loosened, a test for an approved AC weakened or deleted). It shows, without a decision, the operational shape, blast radius and revert, new dependencies, and assumptions about facts outside the repository. The opening paragraph of that section drops "what every later session will copy".

Touched: both `CRITERIA_FORMAT.md` copies, `find-criteria/SKILL.md` and `VERIFY.md`, `untangle/SKILL.md`'s template, `criteria-to-tickets/SKILL.md`, `TICKET_FORMAT.md` and `VERIFY.md`, `implement/SKILL.md`, `accept-criteria/SKILL.md`, `critique/SKILL.md:22` (its list of what the usability driver is not handed), `run/prompts.sh`, `run/drift.sh`, the runner's tests, README.md.

## Technical decisions
- **Stored formats** `CRITERIA.md` changes shape: four AC groups under `## Acceptance criteria`, three technical decisions, no `## Nudges`. A ticket quotes three technical decisions and has no `## Nudges`. Nothing is migrated: a change already in flight keeps its old shape and still runs (AC-11).
- **Wire formats** `run.sh`'s arguments and exit codes are unchanged. Its drift halt for a nudge not quoted word for word goes away.
- **Trust boundaries** none.
- **Dependencies** none.

## Out of scope
- `untangle`'s code-level ACs - module paths, `test-map.md`, imports, diff stats - and the "one home" rule, beyond proposing them as follow-ups (AC-15).
- How a builder or acceptance reads a file in the old shape, beyond `run.sh` running it: no change is in flight here, and an old `## Nudges` read as guidance does no harm.
- The labels `accept-criteria/signals.sh` and `explain-diff/facts.sh` give files ("stored formats", "wire formats"): they only name kinds of files to read.
- `explain-diff`.
- Departures that later tickets build on (`departures-built-on-by-later-tickets`).
- What the developer is shown beyond what they decide.

## Ruled out
- **A section per manifesto approval** (Concepts, Information model, Security policy, What production must show, Wire interface, Hard-to-reverse decisions) - effort L, six quotes in every ticket, and prose where an AC can be checked.
- **Keeping four technical decisions with new content** - some decisions would be ACs and some technical decisions, with no rule for which goes where.
- **Leaving `untangle` untouched** - `test.sh` keeps both `CRITERIA_FORMAT.md` copies byte-identical, so its template would contradict the format beside it.
- **Failure cases as a group of their own** - they belong to the behaviour that fails.
