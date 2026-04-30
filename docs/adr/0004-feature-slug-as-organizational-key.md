# ADR 0004: Feature slug as the primary organizational key

**Status:** Accepted
**Date:** 2026-04-30
**Context:** Retrospective — extracted from codebase

> **Decision:** A short kebab-case feature slug is the required identifier for every feature, and all artifacts for a feature share one parent directory named by that slug. This makes it immediately clear what belongs together, what can be deleted together, and what the team is currently working on.

## Context

This ADR was extracted from the existing codebase. No prior design document exists for this decision.

Every workflow phase uses `docs/features/<slug>/` as the root directory for all artifacts it produces. Every phase skill and review skill requires the feature slug as a required argument at invocation time — if not provided, the skill asks for it before proceeding. CLAUDE.md specifies the slug pattern explicitly, and `UBIQUITOUS_LANGUAGE.md` defines "feature slug" as a canonical term: "A short kebab-case identifier that names a feature and appears in its folder path and artifact filenames."

## Decision

A short kebab-case feature slug is the required identifier for every feature tracked through the workflow. All artifacts for a feature share one parent directory named by that slug. We do this because grouping all artifacts under one human-readable key makes it immediately clear what belongs together, what can be deleted together, and what the team is currently working on — with minimal directory clutter.

## Alternatives considered

**Auto-incremented numeric IDs.** Would require a central registry to issue IDs and map them to descriptions; harder to read at a glance.

**Free-form directory naming.** No convention for what belongs together, making cleanup ambiguous and directory scanning harder.

## Consequences

**Easier:** Finding all artifacts for a feature is one directory lookup. Cleanup after completion is one `rm -rf`. Scanning `docs/features/` shows exactly what is in flight.

**Harder:** Slug collisions are possible if names aren't chosen carefully. Renaming a feature mid-workflow requires renaming the directory and updating any references to it.

**Committed to:** Every phase skill and review skill requires the feature slug as a required argument. All artifacts for a feature are written under `docs/features/<slug>/`. New skills must follow this convention.

**Forecloses:** Identifying features by any key other than the slug. Organizing workflow artifacts by phase rather than by feature.
