# ADR 0002: Entry Artifact Naming — Shared or Distinct Filenames

**Status:** Accepted
**Date:** 2026-04-28
**Context:** [Feature-First Docs Design Doc](../design/feature-first-docs.md)

## Context

The skills workflow has two entry points: `discovery` produces a Feature Brief and `refactor-project` produces a Refactoring Proposal. In the feature-first structure, both land in `docs/features/<slug>/`. The question is: should they use the same filename (e.g., both `discovery.md`) or distinct filenames (`discovery.md` vs. `refactoring.md`)?

The Feature Brief and Refactoring Proposal are structurally different documents. The Feature Brief captures a problem, users, constraints, and success criteria. The Refactoring Proposal captures friction points, proposed refactorings, and suggested order. Merging them under one name would obscure which entry point was used and would require either a hybrid template or a check on document contents.

## Decision

Distinct filenames: `discovery.md` for Feature Briefs (from `discovery`), `refactoring.md` for Refactoring Proposals (from `refactor-project`). Skills that need to read the entry artifact check for `discovery.md` first, then `refactoring.md`.

## Alternatives considered

**Single filename `discovery.md` for both.** Skills downstream of the entry artifact (design, planning) would always find `discovery.md` without conditional logic. Rejected because it erases the document type: a Refactoring Proposal has a distinct structure (friction points, proposed refactorings) that does not fit the Feature Brief template. Forcing both into `discovery.md` makes the filename misleading and requires readers to infer which entry point was used from document content rather than filename.

**Single filename `entry.md` for both.** A neutral name avoids the semantic mismatch. Rejected because "entry" is meaningless to a reader who opens the folder; `discovery.md` and `refactoring.md` tell the reader what they're about to read. Clarity outweighs the convenience of a single name.

## Consequences

- Downstream skills (design, planning, discovery-review) must check for `discovery.md` first, then `refactoring.md`. This adds one conditional lookup but is easy to specify in skill instructions.
- A feature folder cannot have both `discovery.md` and `refactoring.md` from the same initial entry — entry points are mutually exclusive in practice. If a user runs both, the folder will contain both files; this is not prevented but is also not a supported workflow.
- The document type is immediately visible from the filename, which is the right tradeoff for a documentation system.
