# ADR 0006: Shared content via copy-propagation

**Status:** Accepted
**Date:** 2026-04-30
**Context:** [Design Doc — Shared Skill Content](../features/shared-skill-content/design.md)

## Context

Several skill files contain near-duplicate blocks of instructional content (architectural principles, code style, reviewer guidance). Updating a guideline requires editing 5–11 files, and the copies have already begun to diverge. A mechanism is needed to maintain one source of truth while keeping each installed skill directory self-contained.

skills.sh installs skills as individual directories. A shared directory at the repo root is not installed when a single skill is installed, so runtime cross-skill file references are not viable. Per-skill copies of the shared content must exist in the committed repo.

## Decision

Shared content lives in canonical source files under `shared/` at the repo root. A script (`scripts/propagate.sh`) copies each source file verbatim into every skill directory that needs it. The script is the configuration: destination lists are hardcoded in `copy_to` calls. Each affected `SKILL.md` is updated to read the local copy with a short per-skill framing sentence. Propagated copies are committed to the repo. A git pre-commit hook re-runs the script and fails if any propagated file is out of sync with its source.

## Alternatives considered

**Inline duplication (status quo).** No tooling required. Every update touches multiple files; divergence grows over time. Rejected — this is the problem being solved.

**Template expansion.** `SKILL.md` files contain markers (`<!-- include: ... -->`) that a script expands in-place. Keeps all content in a single file per skill. Rejected: `SKILL.md` becomes partly generated, making manual sections hazardous to edit; a marker parser is required; the complexity is not justified when separate reference files already work (the `implementation` skill reads five reference files without issue).

**Runtime cross-skill reference.** `SKILL.md` links to `../shared/code-quality.md`. Works in the source repo; breaks after `npx skills add` installs a single skill without the shared directory. Rejected — skills.sh constraint.

## Consequences

**Easier:** Adding or updating a shared guideline requires editing one file and running the propagation script. The propagation map in the script makes the sharing relationship explicit and auditable.

**Harder:** Adding a new skill that uses shared content requires two steps instead of one: add it to the script, then run it. This must be documented in `CLAUDE.md`.

**Committed to:** Every shared content change produces a git diff touching one source file plus N propagated copies. This is expected and correct; reviewers should expect to see it.

**Forecloses:** Generating SKILL.md from templates, or making skill directories pure build artifacts. The design treats SKILL.md as hand-written and the propagated reference files as managed copies — mixing the two (inline generated sections) contradicts this ADR.
