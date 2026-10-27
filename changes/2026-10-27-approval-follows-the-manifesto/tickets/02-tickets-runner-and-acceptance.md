---
criteria:  CRITERIA.md
closes:    AC-8, AC-9, AC-10, AC-11, AC-13, AC-14
advances:
after:     01-approval-before-the-build
status:    ready
attempts:  0
---

## Build
Everything downstream of `CRITERIA.md` follows its new shape: the ticket format and `/criteria-to-tickets`, the runner and its tests, `/implement`, `/accept-criteria`, `/critique`'s mention of nudges, and the README.

## Done when
> **AC-8** `/accept-criteria` asks the developer to decide on: anything that goes beyond a technical decision or that a group's "None." rules out; a departure from the agreed design; an ADR worked around or a `CLAUDE.md` rule broken; and a weakened check, described by what it no longer protects.

> **AC-9** `/accept-criteria` does not show departures from nudges, new or crossed boundaries where no check was loosened, precedents, or tables, columns and fields as such. It still shows the operational shape, blast radius and revert, new dependencies, and assumptions about facts outside the repository.

> **AC-10** A ticket quotes the three technical decisions and no nudges, and `run.sh` still stops on a ticket whose technical decision is not in `CRITERIA.md` word for word.

> **AC-11** A change sliced in the old shape - four technical decisions and nudges - still runs through `run.sh` with no drift halt caused by that shape.

> **AC-13** The README describes what the developer approves as the four AC groups and the three technical decisions, and says nothing about nudges.

> **AC-14** `./test.sh` is green.

## Technical decisions
> **Stored formats** `CRITERIA.md` changes shape: four AC groups under `## Acceptance criteria`, three technical decisions, no `## Nudges`. A ticket quotes three technical decisions and has no `## Nudges`. Nothing is migrated: a change already in flight keeps its old shape and still runs (AC-11).

> **Wire formats** `run.sh`'s arguments and exit codes are unchanged. Its drift halt for a nudge not quoted word for word goes away.

> **Trust boundaries** none.

> **Dependencies** none.

## Nudges

## Context
Ticket 01 changes `CRITERIA_FORMAT.md`: four AC groups as `###` headings under `## Acceptance criteria`, three technical decisions (Concepts, Wire formats, Hard to reverse), no `## Nudges`. This ticket brings the rest in line. The agreed design in `CRITERIA.md` lists what `/accept-criteria` asks the developer to decide and what it only shows.

Places that name nudges or the four technical decisions today: `criteria-to-tickets/SKILL.md`, `TICKET_FORMAT.md` and `VERIFY.md`; `implement/SKILL.md:18,64`; `accept-criteria/SKILL.md:33-52,89`; `critique/SKILL.md:22`; `run/prompts.sh:23,75,80,82`; `run/drift.sh`'s nudge check; the fixtures in `tests/run/harness.sh` and the nudge tests in `tests/run/drift.sh`; README.md throughout, wherever it describes what is approved, the technical decisions, nudges or what acceptance shows.

`run/drift.sh` compares technical decisions by their words, not their names, which is what lets a change in the old shape keep running (AC-11).

## Not here
- `/find-criteria`, `CRITERIA_FORMAT.md` and `/untangle`: ticket 01.
- How a builder or acceptance reads a file in the old shape, beyond `run.sh` running it: no change is in flight here, and an old `## Nudges` read as guidance does no harm.
- The labels `accept-criteria/signals.sh` and `explain-diff/facts.sh` give files ("stored formats", "wire formats"): they only name kinds of files to read.
- `explain-diff`.
- Departures that later tickets build on (`departures-built-on-by-later-tickets`).

## Left standing

