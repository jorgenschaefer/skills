# 001: Add clarification round to design/SKILL.md

**Status:** In Review
**Design Doc:** [docs/features/phase-handoff/design.md](../design.md)
**Depends on:** none
**Estimate:** S

## Goal

The design phase asks targeted questions before producing output, capturing product-technical boundary decisions and presenting ADR choices to the user rather than assuming.

## Context

The design skill currently has no instruction to surface unspecified values or present significant decisions to the user before designing. A new "clarification round" step is inserted after the codebase survey and before the options phase. See the Design Doc, "Proposed design" section, for the full rationale and the exact instruction text.

## Scope

### In scope
- Insert the clarification round step into `design/SKILL.md` immediately after the "Survey the existing code" paragraph and before "Generate options before committing"
- The step covers both triggers: product-technical boundary decisions and pending ADRs
- The step specifies the no-response fallback (proceed with flagged defaults, do not block)
- The step reverses the default from "assume" to "ask"

### Out of scope
- Changes to `discovery/SKILL.md`, the discovery or design reviewer criteria, or any other skill file
- Automated tests (skill instructions are verified through manual use)

## Acceptance criteria

- [ ] `design/SKILL.md` contains a "Before designing: clarification round" step placed after the codebase survey instruction
- [ ] The step lists both triggers: product-technical boundary decisions AND pending ADRs
- [ ] The step instructs the agent to default toward asking rather than assuming
- [ ] The step specifies that all questions are collected into a single structured message, grouped by type (product decisions first, ADR confirmations second)
- [ ] The step specifies the no-response fallback: proceed with explicitly flagged defaults, do not block
- [ ] The step specifies to skip only when no gaps exist and no ADRs are planned
- [ ] Manual verification: running `/design` on a feature with unspecified UI values produces a clarification question before any design output (see [end-to-end scenario in the Design Doc](../design.md#end-to-end-scenario))
- [ ] Manual verification: running `/design` on a feature that warrants an ADR produces a user confirmation request before the ADR is written (see same scenario)

## Implementation notes

The exact instruction text is provided verbatim in the Design Doc under "What the instruction looks like" — use it as the base and adjust prose for natural fit within the surrounding SKILL.md text.

The skill file lives at `design/SKILL.md` in this repo. Do not edit the installed copy at `~/.claude/skills/design/SKILL.md`.

## Definition of done

- Acceptance criteria met
- Change reviewed
- Manually tested against at least one real feature invocation
