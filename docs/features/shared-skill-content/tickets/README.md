# Backlog: Shared Skill Content

**Design Doc:** [design.md](../design.md)
**Created:** 2026-04-30

## Tickets in suggested order

1. [#001 - Propagation mechanism — review-base.md tracer bullet](001-propagation-mechanism.md) — Creates `shared/`, `scripts/propagate.sh`, `scripts/pre-commit.sh`, and establishes the full mechanism using `review-base.md`
2. [#002 - Migrate architecture-principles.md](002-architecture-principles.md) — Extracts architecture principles into a Shared Content File and updates 7 SKILL.md files
3. [#003 - Migrate code-style.md](003-code-style.md) — Extracts code style principles into a Shared Content File and updates 2 SKILL.md files
4. [#004 - Update CLAUDE.md with propagation workflow](004-claude-md-update.md) — Documents the new mechanism for contributors

## Dependency graph

    001 ──> 002 ──> 004
     └────> 003 ──┘

    (002 and 003 are independent of each other; both depend on 001; 004 depends on all three)

## Notes on ordering

**Tracer bullet:** Ticket #001 is the tracer bullet. It creates every layer of the mechanism — the `shared/` directory, the Propagation Script, the pre-commit hook — and proves them working end-to-end with `review-base.md`. After #001, the repo has a complete, working propagation system; it just handles one Shared Content File. Each subsequent ticket adds a file to that working system.

**#002 before #003:** `architecture-principles.md` is the larger migration (7 skills, more complex SKILL.md changes including `design-review`). Doing it first surfaces any complications with the migration fidelity audit early. #002 and #003 can also run in parallel if two implementers are available — they touch different shared files and mostly different skills, with only minor conflicts possible in `propagate.sh` (easily resolved).

**#004 last:** CLAUDE.md documents a finished mechanism. Writing it before #001–#003 are complete would document a partially-working system.

## Design coverage

| Design Doc section | Ticket(s) |
|---|---|
| File structure — `shared/` directory | #001, #002, #003 |
| Shared file: `review-base.md` | #001 |
| Shared file: `architecture-principles.md` | #002 |
| Shared file: `code-style.md` | #003 |
| Propagation script (`scripts/propagate.sh`) | #001 (created), #002 and #003 (extended) |
| Pre-commit hook (`scripts/pre-commit.sh`) | #001 (created), #002 and #003 (extended) |
| SKILL.md changes (7 skills) | #002 (5 skills), #002 and #003 (2 overlapping: `implementation`, `code-review`) |
| CLAUDE.md update | #004 |

## Out of scope

- **Content of new guideline points** — the design explicitly excludes adding new principles as part of this feature; the shared files are populated from existing inline blocks only
- **Installing `.git/hooks/pre-commit`** — each developer installs manually using the instructions added in ticket #004; not scripted
- **Standalone validation script** (check propagated files without committing) — explicitly out of scope in the design doc
