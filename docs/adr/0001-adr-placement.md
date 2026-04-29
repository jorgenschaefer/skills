# ADR 0001: ADR Placement — Global vs. Co-located

**Status:** Accepted
**Date:** 2026-04-28
**Context:** [Feature-First Docs Design Doc](../design/feature-first-docs.md)

## Context

The feature-first-docs reorganization moves all phase artifacts into `docs/features/<slug>/`. ADRs are currently specified to live at `docs/adr/<NNNN>-<slug>.md`. The question is whether ADRs should move inside the feature folder (`docs/features/<slug>/adr/`) or remain in a global `docs/adr/` directory.

ADRs are classified as "permanent artifacts" in the project's ubiquitous language: they carry forward to influence future work regardless of feature status. All other phase artifacts (Feature Brief, Design Doc, tickets, reviews) are "phase artifacts" — scaffolding useful while building, but reference-only once the feature is done.

## Decision

ADRs remain at `docs/adr/<NNNN>-<slug>.md`. They are not moved inside feature folders.

## Alternatives considered

**Co-located ADRs (`docs/features/<slug>/adr/`).** ADRs would live alongside the design doc and tickets that reference them, making the feature folder complete. This satisfies the "one `ls` reveals everything" goal literally. Rejected because ADRs' primary audience is not the current-feature developer — it's the future developer making a new decision and needing to know what was decided before. Co-location buries ADRs inside feature folders, requiring a search of all feature folders to find all past ADRs. The sequential global numbering convention also implies global scope: a reviewer reading "see ADR-0003" should be able to find it in one place, not wonder which feature folder it's in.

**Dual presence (canonical in feature folder, symlinked at `docs/adr/`).** Symlinks keep both locations current. Rejected for complexity: the skills system is Markdown files with no tooling; maintaining symlinks would require the skill to instruct the agent to create them, which is fragile and adds steps with no clear benefit over a plain global directory.

## Consequences

- The feature folder is not fully self-contained: it references ADRs at `docs/adr/` rather than containing them.
- Future engineers looking for all decisions affecting a feature must also check `docs/adr/` and filter by the feature slug (which appears in the ADR filename and body).
- ADR discovery across features is straightforward: `ls docs/adr/` or `grep` across that directory.
- ADR numbering remains globally sequential and unambiguous.
