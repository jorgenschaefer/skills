# 004: Update CLAUDE.md with propagation workflow

**Status:** Done
**Design Doc:** [design.md](../design.md)
**Depends on:** #001, #002, #003
**Estimate:** S

## Goal

Document the shared content workflow in `CLAUDE.md` so that future contributors know how to edit Shared Content Files, run Propagation, and install the pre-commit hook.

## Context

`CLAUDE.md` is the primary orientation document for agents working in this repo. The new Propagation mechanism and Shared Content Files are invisible without documentation — a contributor editing a skill principle directly in a skill directory will accidentally overwrite it on the next `propagate.sh` run. This ticket ensures the mechanism is self-explaining.

See [design.md §CLAUDE.md update](../design.md) for the exact additions specified.

## Scope

### In scope
- Extend the "Adding or modifying skills" section of `CLAUDE.md` with three bullets (verbatim from the design doc):
  - Shared content files live in `shared/`; run `scripts/propagate.sh` after editing, then stage all changed files
  - Pre-commit hook installation: `cp scripts/pre-commit.sh .git/hooks/pre-commit`; recovery instructions if the hook fails
  - Adding a new skill that uses shared content: extend `propagate.sh` and add a framing sentence to the skill's SKILL.md

### Out of scope
- Changes to any other section of `CLAUDE.md`
- Any new documentation files

## Acceptance criteria

- [ ] `CLAUDE.md` "Adding or modifying skills" section contains all three bullet points specified in the design doc
- [ ] The pre-commit hook installation command is present and matches `cp scripts/pre-commit.sh .git/hooks/pre-commit`
- [ ] The recovery instruction for a failed hook is present
- [ ] The guidance for adding a new skill that uses shared content is present

## Definition of done

- All acceptance criteria met
- Code reviewed
- Hook installation command manually verified on a fresh checkout (`cp scripts/pre-commit.sh .git/hooks/pre-commit` runs without error and the hook fires on the next commit attempt)
