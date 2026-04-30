# ADR 0002: Clean-context requirement for review skills

**Status:** Accepted
**Date:** 2026-04-30
**Context:** Retrospective — extracted from codebase

## Context

This ADR was extracted from the existing codebase. No prior design document exists for this decision.

Each of the four review skills (discovery-review, design-review, planning-review, implementation-review) includes an explicit clean-context requirement in its frontmatter description and in its setup instructions. For example, design-review's description ends: "Always use a clean context, separate from the conversation that produced the design." The instructions add: "If you're unsure, treat your judgment as potentially contaminated: note it in 'What was NOT checked'." The same language appears across all four review skills. CLAUDE.md reinforces it in the workflow description.

## Decision

Review skills must always be invoked in a fresh conversation with no prior context from the producing phase. We do this because an LLM that participated in producing an artifact is primed to agree with it: if the same context contains both the implementation step and the review step, the model is more likely to validate than to challenge. A reviewer starting from a clean context genuinely approaches the artifact with fresh eyes.

## Alternatives considered

**Integrated review step appended to each phase skill.** The producing agent reviews its own output at the end of the same conversation. Rejected: prior context makes the review a formality rather than an independent check; the same blind spots affect both production and review.

## Consequences

**Easier:** Reviews catch problems the author missed. The reviewer's judgment is not contaminated by the reasoning that produced the artifact.

**Harder:** Reviews require a deliberate separate invocation, not a follow-up message in the same conversation. Users must remember to start a new context.

**Committed to:** Review skills are standalone skills, never integrated into the tail of a producing skill. New review skills must include the clean-context requirement in both their description and their setup instructions.

**Forecloses:** Running any review skill in the same conversation as the producing skill and trusting the result.
