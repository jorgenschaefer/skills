---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-12, AC-15
advances:
after:     
status:    done
attempts:  0
---

## Build
What the developer approves before a build: `/find-criteria`, its verifier, the criteria format, and `/untangle`'s proposal and template, as the agreed design in `CRITERIA.md` describes.

## Done when
> **AC-1** For every behaviour in the criteria, `/find-criteria` asks what the user experiences when it fails, and the approved ACs state it.

> **AC-2** `/find-criteria` asks about what production must show and how fast, who may see and do what, and what the system keeps, for how long, and never keeps. Each ends as ACs or as "None.".

> **AC-3** Every `CRITERIA.md` that `/find-criteria` or `/untangle` writes has, under `## Acceptance criteria`, the groups Behaviour, What production must show, Security policy and Information model, each holding ACs or "None.".

> **AC-4** Its technical decisions are exactly Concepts, Wire formats and Hard to reverse, each answered or "none". Concepts names the things the system keeps and how they relate, in the glossary's words, and never tables, columns or files.

> **AC-5** `/find-criteria` never asks the developer to approve or object to details of the code - tables, columns, file or directory names, a repository's layout or layers, ideas for how to build it - and a `CRITERIA.md` has no `## Nudges`. The developer still picks the approach from the alternatives and approves the agreed design.

> **AC-6** A new concept's term is agreed with the developer under Concepts, and added to the glossary where the project has one.

> **AC-7** `/find-criteria`'s verifier reports a missing AC group, a behaviour without its failure cases, and an AC only a reader of the code could judge.

> **AC-12** `/untangle` proposes the three technical decisions and its template writes them, with no nudges. Its three nudges - the build order, reaching an old test's case through the new modules, and halting where the approved shape cannot work - are in its agreed design. Its ACs stand under Behaviour, unchanged, and the other three groups say "None.". `EXPLANATION.md`, `test-map.md` and `checks.md` are no longer named in a technical decision.

> **AC-15** At acceptance, two follow-ups are proposed to `/backlog`: `untangle`'s code-level ACs as an item of their own, and "Give every new domain rule one home" (`find-criteria/SKILL.md:39`) as a finding for `cut-files-by-concept`.

## Technical decisions
> **Stored formats** `CRITERIA.md` changes shape: four AC groups under `## Acceptance criteria`, three technical decisions, no `## Nudges`. A ticket quotes three technical decisions and has no `## Nudges`. Nothing is migrated: a change already in flight keeps its old shape and still runs (AC-11).

> **Wire formats** `run.sh`'s arguments and exit codes are unchanged. Its drift halt for a nudge not quoted word for word goes away.

> **Trust boundaries** none.

> **Dependencies** none.

## Nudges

## Context
The agreed design in `CRITERIA.md` gives the wording of the three technical decisions and the four group headings, in order, with `None.` for an empty group. Both copies of `CRITERIA_FORMAT.md` (`find-criteria/` and `untangle/`) must stay byte-identical: `./test.sh` checks it.

The criteria format's runner-facing shape - ACs as `- **AC-n**` list items, technical decisions as list items under `## Technical decisions` - stays, since `run/drift.sh` reads it. Ticket 02 changes the ticket format, the runner and acceptance to match, and the README.

AC-15 is met by naming both follow-ups under this ticket's `## Left standing` as suggestions for `/backlog`, which `/accept-criteria` proposes at acceptance: `untangle`'s code-level ACs as an item of their own, and "Give every new domain rule one home" (now `find-criteria/SKILL.md:39`) as a finding for `changes/backlog/cut-files-by-concept.md`.

## Not here
- The ticket format, `/criteria-to-tickets`, `/implement`, `/accept-criteria`, `/critique`, `run/` and README.md: ticket 02.
- `untangle`'s code-level ACs - module paths, `test-map.md`, imports, diff stats - and the "one home" rule, beyond proposing them as follow-ups (AC-15).
- What the developer is shown beyond what they decide.

## Left standing
- Follow-ups for `/backlog` (AC-15): `untangle`'s code-level ACs as an item of their own - module paths, `test-map.md`, imports, diff stats - and with them `untangle/SKILL.md:23`, which still has the developer name a new directory for a concept the glossary has no term for (review, should-fix). And "Give every new domain rule one home" (was `find-criteria/SKILL.md:39`) as a finding for `changes/backlog/cut-files-by-concept.md`.
- Fixes after the last review, which no reviewer saw: `find-criteria/VERIFY.md`'s failure-case check now asks for each way a thing can fail, not one AC (second-round nit); the two "None."/"none" sentences in `CRITERIA_FORMAT.md` now name what departs instead of using pronouns (second-round nit).
- No automated test proves AC-1 to AC-7 or AC-12: the skills are Markdown. Each was checked by reading, by both review rounds.
- Until ticket 02 is built, `/criteria-to-tickets` and `TICKET_FORMAT.md` still ask for all four technical decisions and nudges, so a `CRITERIA.md` in the new shape should not be sliced before then.
