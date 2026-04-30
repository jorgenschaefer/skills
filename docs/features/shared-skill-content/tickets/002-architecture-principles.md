# 002: Migrate architecture-principles.md

**Status:** Done
**Design Doc:** [design.md](../design.md)
**Depends on:** #001
**Estimate:** M

## Goal

Create `shared/architecture-principles.md` from existing inline blocks, extend the Propagation Script to copy it to 7 skill directories, and update those skills' SKILL.md files to reference the shared file instead of inlining the content.

## Context

Seven skill files (`implementation`, `code-review`, `design`, `design-review`, `planning`, `planning-review`, `refactor-project`) contain near-duplicate blocks covering architecture principles (screaming architecture / domain-first organization, deep modules, adapter boundaries). This ticket consolidates them into one Shared Content File and removes the duplicate inline blocks.

See [design.md §Shared file contents](../design.md) and [design.md §SKILL.md changes](../design.md) for the reference instruction format.

## Scope

### In scope
- Create `shared/architecture-principles.md` — canonical content extracted from the existing inline blocks; cover screaming architecture (domain-first folder organization), deep modules (Ousterhout), and adapter boundaries (3-layer pattern with type separation)
- Extend `scripts/propagate.sh` with the `copy_to architecture-principles.md ...` call for all 7 destination skills
- Extend `scripts/pre-commit.sh` with the corresponding `check` call
- Run `scripts/propagate.sh` to create the 7 propagated copies
- Update SKILL.md in `implementation`, `code-review`, `design`, `planning`, `refactor-project` — replace inline architecture-principles blocks with a short reference instruction
- Update SKILL.md in `design-review` and `planning-review` — add framing sentence for `architecture-principles.md` (these did not have the content inline, but should now reference the file)
- Verify all 7 copies match `shared/architecture-principles.md` with `diff`

### Out of scope
- `code-style.md` migration (ticket #003)
- `review-base.md` (ticket #001)
- `CLAUDE.md` update (ticket #004)

## Acceptance criteria

- [ ] `shared/architecture-principles.md` exists and contains canonical versions of all three principles (screaming architecture, deep modules, adapter boundaries)
- [ ] `scripts/propagate.sh` includes the `architecture-principles.md` `copy_to` call; `scripts/pre-commit.sh` includes the corresponding `check` call
- [ ] After running `propagate.sh`, `diff` exits 0 for all 7 skill-directory copies vs. the source
- [ ] `implementation/SKILL.md`, `code-review/SKILL.md`, `design/SKILL.md`, `planning/SKILL.md`, `refactor-project/SKILL.md` no longer inline the architecture principles — they reference `architecture-principles.md` with a framing sentence matching the design doc example format
- [ ] `design-review/SKILL.md` and `planning-review/SKILL.md` include a framing sentence directing agents to read `architecture-principles.md`
- [ ] No inline block in any of the 7 SKILL.md files duplicates content now in `shared/architecture-principles.md`
- [ ] `design-review/SKILL.md` retains its review-specific checklist framing (e.g. "flag X as should-fix" language) — this content is not moved to `shared/architecture-principles.md`; the shared file states principles neutrally
- [ ] Integration test: invoke the `implementation` and `code-review` skills in a test context and confirm agents find and read `architecture-principles.md`

## Implementation notes

- **Migration fidelity audit:** Before writing `shared/architecture-principles.md`, diff the relevant inline blocks across all 7 source files to identify any divergences. The content extraction should be the superset of all current wording — don't silently discard phrasing that appeared in only one file.
- **`design-review` is the most complex:** This SKILL.md already has detailed adapter-boundary and deep-module guidance as inline review checklist items (not just a description). Some of this framing (e.g. "flag X as should-fix") belongs in `design-review/SKILL.md`, not in the shared file — the shared file should state the principles neutrally, while each skill adds its own framing. Read the risks section of the design doc carefully before editing `design-review/SKILL.md`.
- Ticket #003 may be in progress simultaneously (both depend on #001, neither depends on the other) — coordinate to avoid merge conflicts on `propagate.sh` and `pre-commit.sh`; the `copy_to` calls for different files are independent lines, so conflicts should be minimal.
- The reference instruction format is specified in design.md §SKILL.md changes — match it for consistency across skills.
- After editing SKILL.md files, manually review each one to confirm no orphaned inline blocks remain.

## Definition of done

- All acceptance criteria met
- Code reviewed
- Each updated SKILL.md manually reviewed to confirm inline blocks fully removed and reference instructions are correct
- All 7 propagated copies verified in sync with `diff`
