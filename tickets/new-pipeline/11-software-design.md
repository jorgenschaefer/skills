---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-13
after:     10-coding-standard
status:    ready
attempts:  0
reviews:   0
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
