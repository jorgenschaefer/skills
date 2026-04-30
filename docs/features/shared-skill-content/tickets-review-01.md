# Review: docs/features/shared-skill-content/tickets/

**Reviewer:** Claude Sonnet 4.6 (clean context)
**Date:** 2026-04-30
**Artifact:** [Ticket Backlog](tickets/) — 4 tickets + README.md
**Verdict:** Request changes

## Summary

The backlog is structurally sound. Ticket #001 is a genuine tracer bullet: it builds the entire propagation mechanism end-to-end using `review-base.md`, leaving a fully working system that subsequent tickets extend one shared file at a time. Dependencies are correct, ordering is sensible, and design coverage is complete. Two should-fix items need attention before implementation begins: ticket #003 is missing an integration test that #001 and #002 both include, and ticket #002's acceptance criteria do not give an implementer a checkable way to verify the `design-review` migration fidelity distinction that the design doc flags as a risk.

## Findings

### Blockers

None.

### Should-fix

1. **Ticket #003 missing integration test acceptance criterion**
   - **Where:** `tickets/003-code-style.md` — Acceptance criteria section
   - **Issue:** Tickets #001 and #002 both include an integration test as an explicit acceptance criterion (confirm the agent reads the referenced file in a test context). Ticket #003 has no equivalent. An implementer can complete all listed acceptance criteria and leave no evidence that `code-review` and `implementation` agents actually find and read `code-style.md` in a deployed context.
   - **Why it matters:** Acceptance criteria define done. If this test is not listed, it will not be checked, and the consistency of coverage testing across the three migration tickets will silently break down.
   - **Suggested fix:** Add an acceptance criterion matching the pattern in #001 and #002: "Integration test: invoke the `code-review` and `implementation` skills in a test context and confirm agents find and read `code-style.md`."

2. **Ticket #002 acceptance criteria do not surface the `design-review` fidelity constraint**
   - **Where:** `tickets/002-architecture-principles.md` — Acceptance criteria section
   - **Issue:** The design doc's Risks section explicitly flags the `design-review` migration as the most complex: its SKILL.md has detailed adapter-boundary and deep-module guidance as inline review checklist items, and some of that framing ("flag X as should-fix") belongs in `design-review/SKILL.md`, not in `shared/architecture-principles.md`. The implementation notes in #002 repeat this warning. But the acceptance criteria do not include a checkable criterion that enforces this distinction — a reviewer confirming the ticket is done has no basis in the criteria to verify it. The criterion that covers `design-review/SKILL.md` only requires "a framing sentence directing agents to read `architecture-principles.md`," which a superficial edit could satisfy while silently moving review-specific framing into the shared file.
   - **Why it matters:** The risk the design doc identified will not be caught at acceptance time. It could ship undetected and introduce incorrect content into the shared file that affects all seven skills.
   - **Suggested fix:** Add an acceptance criterion: "`design-review/SKILL.md` retains its review-specific checklist framing (e.g., 'flag X as should-fix' language) — this content is not moved to `shared/architecture-principles.md`; the shared file states principles neutrally."

### Nits

- **Parallel conflict risk not surfaced at ticket level.** The README notes that #002 and #003 can run in parallel and that `propagate.sh` conflicts should be minimal. Ticket #003's implementation notes mention this too. Ticket #002's implementation notes do not. Minor, since the README covers it, but an implementer reading only their ticket won't see it. Consider adding one sentence to #002's implementation notes mirroring the note in #003.
- **Ticket #004 definition of done does not verify the hook command.** The CLAUDE.md update documents the hook installation command for the first time (`cp scripts/pre-commit.sh .git/hooks/pre-commit`). The definition of done says only "All acceptance criteria met / Code reviewed" — it does not include manually verifying the installation command is correct (e.g., that it runs without error in a fresh checkout). Low risk, but easy to add.

## Design coverage table

| Design Doc section | Ticket(s) |
|---|---|
| File structure — `shared/` directory | #001, #002, #003 |
| Shared file: `review-base.md` | #001 |
| Shared file: `architecture-principles.md` | #002 |
| Shared file: `code-style.md` | #003 |
| `scripts/propagate.sh` — creation | #001 |
| `scripts/propagate.sh` — extensions | #002, #003 |
| `scripts/pre-commit.sh` — creation | #001 |
| `scripts/pre-commit.sh` — extensions | #002, #003 |
| SKILL.md changes: `design`, `planning`, `refactor-project` (inline → reference) | #002 |
| SKILL.md changes: `implementation`, `code-review` (architecture-principles) | #002 |
| SKILL.md changes: `implementation`, `code-review` (code-style) | #003 |
| SKILL.md changes: `design-review`, `planning-review` (new framing sentence) | #002 |
| CLAUDE.md update | #004 |
| Pre-commit hook — installation and recovery instructions | #004 |
| Design doc Risks — migration fidelity audit | #001 (review-base), #002 (architecture-principles) |

All design doc sections are covered. No tickets implement work outside the design.

## What was checked

- Tracer bullet test: confirmed #001 is a genuine end-to-end slice, not an infrastructure-only layer
- Independent deployability: each ticket leaves the repo in a working state (#001 = working propagation for one file; #002 and #003 = working propagation for additional files; #004 = documented mechanism)
- Independent testability: all tickets have observable acceptance criteria, with the exception noted above for #003
- Design coverage: walked every section of the design doc and located the implementing ticket(s)
- Scope creep check: no tickets introduce work not described in the design
- Dependency graph: #001 → {#002, #003} → #004; correct and non-sequential where possible
- Ubiquitous language: checked all ticket titles, goals, and criteria against UBIQUITOUS_LANGUAGE.md — "Shared Content File," "Propagation Script," "Propagation," "Ticket Backlog," "Ticket," "Feature slug," and "Shared content file" are all used consistently and correctly
- Status fields: all four tickets are Status: Backlog ✓
- README coverage table: present and accurate ✓
- Out-of-scope items: hook installation, standalone validation script, and new content additions are all explicitly excluded with correct references ✓
- Cross-cutting concerns: no observability, security, or migration concerns apply to this feature (local tooling, one-author repo)
- Smell tests: layer-by-layer test (pass), "ship after ticket N" test (pass — each ticket leaves a usable artifact), "two implementers" test (#002 and #003 have a minor SKILL.md conflict risk, flagged as nit), "rename test" (all titles are specific and accurate), "design smuggling" test (no undocumented implementation choices in tickets)
- Boy-scout triage: nothing unrelated to this backlog was noticed that warranted triage

## What was NOT checked

- I did not run `diff` across the existing review-base.md copies to independently verify whether divergence exists — this is a runtime check requiring the actual files, which is covered by ticket #001's acceptance criteria.
- I did not invoke the skills in a test context to verify agent behavior — functional testing is in scope for the tickets, not this review.
- I did not verify that the design doc's inline blocks in the seven SKILL.md files are faithfully represented in the planned shared files — migration fidelity is an implementation-time concern; the tickets correctly gate on it in their acceptance criteria and implementation notes.
