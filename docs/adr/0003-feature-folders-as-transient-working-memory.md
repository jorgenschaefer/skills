# ADR 0003: Feature folders as transient working memory; ADRs and UBIQUITOUS_LANGUAGE.md as permanent artifacts

**Status:** Accepted
**Date:** 2026-04-30
**Context:** Retrospective — extracted from codebase

## Context

This ADR was extracted from the existing codebase. No prior design document exists for this decision.

README.md contains an explicit instruction to delete feature folders after a feature is fully implemented and its final review is approved: "The feature folder is working memory for the workflow; git history preserves it if you ever need to look back." Two artifact types are explicitly permanent: ADRs at `docs/adr/` (never deleted, referenced by future design phases) and `UBIQUITOUS_LANGUAGE.md` at the repo root (never deleted, maintained as a living glossary). All other workflow artifacts — Feature Briefs, Design Docs, Ticket Backlogs, review files — live inside the feature folder and are deleted with it.

## Decision

Feature folders are transient working memory: once a feature is shipped and its final review approved, the entire `docs/features/<slug>/` directory is deleted. Git history is the fallback if the content is ever needed again. Only two artifact types survive indefinitely: ADRs (which record the reasons behind architectural decisions) and `UBIQUITOUS_LANGUAGE.md` (which records canonical terms the team has agreed on). The rationale: once the feature is in the code, the code is the truth. Phase artifacts that were useful during development will only accumulate outdated information and generate noise for future agents and engineers.

## Alternatives considered

**Keeping all feature documents permanently.** Rejected: feature docs outdate quickly once the code exists; stale documents mislead future agents and developers who encounter them without knowing they are no longer current.

## Consequences

**Easier:** `docs/features/` stays clean over time — it reflects only in-progress work, not a graveyard of completed features. Future agents can treat any document in `docs/features/` as active and current.

**Harder:** Reconstructing the thinking behind a shipped feature requires digging into git history. There is no single document to point someone to after the fact.

**Committed to:** `docs/adr/` and `UBIQUITOUS_LANGUAGE.md` are permanent and must remain accurate as the codebase evolves. Feature folders are deleted on completion, not archived. No mechanism exists for "archiving" feature documents — delete is the only end state.

**Forecloses:** Using feature folder content as a reliable reference in future conversations after the feature ships. Treating phase artifacts (other than ADRs) as durable documentation.
