# ADR 0001: Sequential phased workflow with mandatory artifact handoffs

**Status:** Accepted
**Date:** 2026-04-30
**Context:** Retrospective — extracted from codebase

> **Decision:** We implement the workflow as a strict sequential chain of phases, each requiring the prior phase's artifact before starting. This enforces human-in-the-loop checkpoints and ensures each phase starts in a clean context, free of accumulated assumptions from prior phases.

## Context

This ADR was extracted from the existing codebase. No prior design document exists for this decision.

The workflow is divided into four discrete phases — discovery, design, planning, implementation — each implemented as a dedicated skill with a defined input artifact and a defined output artifact. CLAUDE.md specifies the sequence explicitly. Each skill's SKILL.md names the artifact it reads (e.g., `design` reads `discovery.md` or `refactoring.md`; `planning` reads `design.md`) and fails fast when the required input is missing. No skill accepts an artifact from a non-adjacent phase, and none produces multiple phases' output in one invocation.

## Decision

We implement the workflow as a strict sequential chain of phases. Each phase must complete and produce its artifact before the next phase begins. We do this for two reasons: first, to enable human-in-the-loop (HITL) checkpoints — after each phase a human can review the output and request revisions before work proceeds; second, to allow the context to be cleared between phases so each phase starts without accumulated assumptions from prior phases.

## Alternatives considered

**Continuous pipeline (phases run back-to-back without checkpoints).** Removes HITL review opportunities and causes context to accumulate across phases, defeating both goals. Rejected.

**Flexible phase ordering (phases can be skipped or reordered).** Artifact handoffs between phases become undefined; each skill is designed around specific inputs it can trust. Rejected.

## Consequences

**Easier:** Humans can review and iterate on each artifact before work proceeds. Each phase skill starts in a focused context, free of earlier phases' reasoning.

**Harder:** A feature cannot be expedited by skipping phases even when the team believes they are unnecessary — the next skill will ask for the missing input artifact.

**Committed to:** Each phase skill accepts only its defined input artifact; produces its defined output artifact; runs in its own invocation and conversation. New phase skills must follow this contract.

**Forecloses:** Merging multiple phases into a single skill invocation. Automating the full pipeline without human checkpoints between phases.
