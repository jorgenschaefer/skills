# 001: Propagation mechanism — review-base.md tracer bullet

**Status:** Done
**Design Doc:** [design.md](../design.md)
**Depends on:** none
**Estimate:** S

## Goal

Establish the full propagation mechanism — shared source directory, propagation script, and pre-commit hook — by wiring up `review-base.md` as the first Shared Content File. The four review skill directories get propagated copies replacing their current manual copies.

## Context

The design calls for three Shared Content Files in a new `shared/` directory, copied into skill directories by `scripts/propagate.sh`. The pre-commit hook (`scripts/pre-commit.sh`) enforces that propagated copies are never out of sync with the source.

`review-base.md` is the simplest candidate to start with: four identical copies already exist in `design-review/`, `discovery-review/`, `implementation-review/`, and `planning-review/`. No SKILL.md changes are needed — those skills already reference `review-base.md` in prose and the reference stays unchanged. This ticket proves the mechanism end-to-end before touching inline SKILL.md content.

See [design.md §Propagation script](../design.md) and [design.md §Pre-commit hook](../design.md) for the exact script formats.

## Scope

### In scope
- Create `shared/` directory at repo root
- Create `shared/review-base.md` — content migrated verbatim from any one of the four identical existing copies; verify all four are identical before migrating
- Create `scripts/propagate.sh` — with only the `review-base.md` `copy_to` call (subsequent tickets extend it)
- Create `scripts/pre-commit.sh` — full hook implementation checking only `review-base.md` destinations (subsequent tickets extend it with new `check` calls)
- Run `scripts/propagate.sh` to overwrite the four existing copies with propagated copies
- Verify the four copies match the source with `diff`

### Out of scope
- `architecture-principles.md` migration (ticket #002)
- `code-style.md` migration (ticket #003)
- SKILL.md changes (tickets #002, #003)
- `CLAUDE.md` update (ticket #004)
- Installing the hook into `.git/hooks/` (documented in ticket #004's CLAUDE.md update; each developer installs manually)

## Acceptance criteria

- [ ] `shared/review-base.md` exists and its content is the canonical version of the review base (author has confirmed no divergence across the four source copies, or has resolved any differences)
- [ ] `scripts/propagate.sh` exists, is executable, and runs without error
- [ ] `scripts/pre-commit.sh` exists and is executable
- [ ] After running `propagate.sh`, `diff shared/review-base.md design-review/review-base.md` exits 0, and likewise for the other three review skills
- [ ] Editing `shared/review-base.md` then running `propagate.sh` propagates the change to all four destinations
- [ ] Running `pre-commit.sh` after editing `shared/review-base.md` without re-staging the propagated copies exits non-zero and prints the exact `git add` recovery command
- [ ] Integration test: invoke the `design-review` skill in a test context and confirm the agent reads `review-base.md` without error (the file is present and readable)

## Implementation notes

- The four existing copies may have small divergences — audit with `diff design-review/review-base.md discovery-review/review-base.md` etc. before picking the canonical version. Any differences are the content risk flagged in the design doc's Risks section.
- The design doc specifies the exact script formats — use them verbatim; don't invent an alternative.
- `propagate.sh` uses `set -euo pipefail`; test it on a clean checkout to ensure the `shared/` directory is found correctly.
- The pre-commit hook must not silently auto-stage changes (see design doc). It should fail with the `git add` command needed to recover.

## Definition of done

- All acceptance criteria met
- Code reviewed
- All propagated copies verified in sync with `diff`
