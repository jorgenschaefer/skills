---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-13
after:     10-coding-standard
status:    done
attempts:  1
reviews:   1
---

## Build

The design-time half: a skill that surfaces while a change is being planned and knows
about domain language, module separation and ADRs.

## Done when

> **AC-13** A software-design skill carries domain language, module boundaries and what
> deserves an ADR, surfaces while a change is being planned, and writes a ratified ADR
> at plan exit while the argument for it is still in context.

## Context

This is where the dropped spec sections come back — not as required paperwork on every
run, but as knowledge applied when a decision is actually being made. `## Domain`,
ubiquitous language and `## ADRs` were produced every run and read almost never; the
bet here is that the same knowledge, surfaced at the moment of choice, is worth more
and costs less.

It must fire on a new concept or a crossed boundary, not on a three-line edit — one
notch narrower than `/slice`, and harder. The discovery trial in
`NEW_PIPELINE_IDEA.md` is the method: write the description in the shapes a request
arrives in, then measure.

An ADR is never written unilaterally. Plan approval is the ratification; this skill
writes it at plan exit, because by (e) the argument that produced it is gone.

`ubiquitous-language-init` bootstraps and drift-audits the glossary this skill reads.
Decide here whether it survives; it is the open question in `INTENT_PROCESS_COST.md`.

## Not here

Reinstating any required section in the solution format. The knowledge moves; the
paperwork does not come back.

## Record

`tests/run.sh` (256 + 18 + 22 + 32 + 9, green). Three cases added to
`tests/standard-split.sh`, which already held the split itself.

**AC-13's three clauses.** The domain half became `software-design` by `git mv`, so the
split cases keep holding — `the split loses no section` still reads the same fixture and
now finds each heading in `coding-standard` or in the new skill. `the design skill
carries ## The glossary` and `## What deserves an ADR` pin the two things this ticket
added. `the design skill says when an ADR is written` pins the moment: plan exit.

Those three are thin, and say what they are — the material is prose a model acts on.
What they buy is that a later edit cannot quietly remove the sections AC-13 names.

**The ADR format is copied byte-identically** from `to-solution/ADR_FORMAT.md`, which
the repo's shared-format invariant requires and which also keeps the rule this skill
most depends on: an ADR is never written autonomously — the decision and a
recommendation go to the person, and the record exists once they say yes. Its prose
still names `/to-solution` and `/spec-to-tickets` as the skills that propose and read
ADRs. Editing every copy at once is what one commit does, so deferring that is a
choice and not a constraint: the copies live in `to-solution` and `handover`, and
changing what they tell those skills to do is not this ticket's business. The cost
shipped is real — `software-design` carries a format document that names the skills
being retired and never names `software-design`.

**The open question is answered.** `ubiquitous-language-init` stays:
`UBIQUITOUS_LANGUAGE.md` is the source of truth `software-design` reads for the
domain's names, which makes the bootstrapper its counterpart rather than a duplicate.
`INTENT_PROCESS_COST.md` records it.

**Untested, and this is the one that matters.** Whether the description fires while a
change is being planned and stays quiet on a three-line edit. It is one notch narrower
than `/slice`'s, which took two drafts and 31 runs to get right, and it now competes
with `/slice` for the same phrase — both say something close to "planning a change to
this codebase". That is ticket 9's trial, and it is the likeliest thing in this run to
come back needing another draft.

## Findings

One review round, five findings. All five taken.

**The same mistake as the last ticket, made worse by breaking the guard against it.**
The rename left `spec-to-tickets`, `to-solution` and `README.md` pointing at a
directory that no longer exists — and the reference walk I added in ticket 10 to catch
exactly that was disarmed in the same commit: replacing the `coding-conventions` arm
with `software-design` meant the retired name stopped being matched, and the
directory-exists guard became unreachable dead code. A guard that only knows the names
that still exist cannot catch a name that stopped existing. It now matches every
backticked skill name, and mutation-testing confirms it fails on a reference to the
retired one.

**AC-13's third clause had no wire.** "Writes a ratified ADR at plan exit" lived only
in a skill that the plan-exit skill never mentions, so it rested entirely on discovery
firing. `/slice` step 4 now names it: write the tickets, and with them any ADR the
change earned, because plan approval is the yes that lets one be written and the
argument is gone by acceptance.

**`## The glossary` was sixty percent restatement** of a bullet in the material that
moved. The bullet is a pointer now and the section carries the facts.

**Two descriptions.** `software-design` led with a declarative topic sentence while
`/slice` leads with "Use when", which is how a router picks one of two overlapping
skills. It now leads with the trigger and carries a negative clause — not a three-line
edit, not code being typed — which is what `/slice`'s description took 31 runs to earn.
The overlap is narrowed, not resolved; ticket 9 measures it.

**The README bullet** still said the skill "becomes the design skill when the pipeline
lands", which it had.
