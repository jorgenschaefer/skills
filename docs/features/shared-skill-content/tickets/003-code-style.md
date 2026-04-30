# 003: Migrate code-style.md

**Status:** Done
**Design Doc:** [design.md](../design.md)
**Depends on:** #001
**Estimate:** S

## Goal

Create `shared/code-style.md` from existing inline blocks in `code-review` and `implementation`, extend the Propagation Script, and update those two SKILL.md files to reference the Shared Content File.

## Context

`code-review` and `implementation` both contain near-duplicate blocks describing code style principles (clear over clever, dead-weight-free — no commented-out code, debug prints, etc.). Planning, design, and review skills explicitly do not get this file — code-writing style guidance is only relevant to agents that write or review code.

See [design.md §Shared file contents](../design.md) for the content definition.

## Scope

### In scope
- Create `shared/code-style.md` — canonical content extracted from existing inline blocks in `code-review/SKILL.md` and `implementation/SKILL.md`
- Extend `scripts/propagate.sh` with the `copy_to code-style.md code-review implementation` call
- Extend `scripts/pre-commit.sh` with the corresponding `check` call
- Run `scripts/propagate.sh` to create the 2 propagated copies
- Update `code-review/SKILL.md` and `implementation/SKILL.md` — replace inline code-style blocks with reference instructions
- Verify both copies match `shared/code-style.md` with `diff`

### Out of scope
- `architecture-principles.md` (ticket #002)
- `review-base.md` (ticket #001)
- `CLAUDE.md` update (ticket #004)
- Adding `code-style.md` to any other skill — the design explicitly limits this to `code-review` and `implementation`

## Acceptance criteria

- [ ] `shared/code-style.md` exists and covers at minimum: clear over clever, dead-weight-free (no commented-out code, debug prints, or other dead weight)
- [ ] `scripts/propagate.sh` includes the `code-style.md` `copy_to` call; `scripts/pre-commit.sh` includes the corresponding `check`
- [ ] After running `propagate.sh`, `diff` exits 0 for both skill-directory copies vs. the source
- [ ] `code-review/SKILL.md` and `implementation/SKILL.md` no longer inline the code style principles — they reference `code-style.md` with a framing sentence
- [ ] No inline block in either SKILL.md duplicates content now in `shared/code-style.md`
- [ ] Integration test: invoke the `code-review` and `implementation` skills in a test context and confirm agents find and read `code-style.md`

## Implementation notes

- Ticket #002 may be in progress simultaneously (both depend on #001, neither depends on the other) — coordinate to avoid merge conflicts on `propagate.sh` and `pre-commit.sh`; the `copy_to` calls for different files are independent lines, so conflicts should be minimal.
- Migration fidelity: diff the two source inline blocks before extracting; note any divergences and capture the superset.

## Definition of done

- All acceptance criteria met
- Code reviewed
- Both propagated copies verified in sync with `diff`
