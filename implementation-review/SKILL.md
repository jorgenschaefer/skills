---
name: implementation-review
description: Use this skill to review a code change produced by the Implementation phase before it gets merged. Checks workflow compliance (ticket adherence, acceptance criteria, design alignment, scope) and applies the nine code-quality dimensions, combining both into a single verdict. Trigger whenever the user says "review this PR", "code review for ticket X", "is this implementation ready to merge", or hands you a diff and asks for feedback. Always use a clean context, separate from the conversation that produced the code, since the value of the review depends on fresh eyes that don't share the implementer's blind spots.
---

# Implementation Review

Reviews a code change produced by the Implementation phase. Read [review-base.md](review-base.md) first for reviewer stance, output format, and severity definitions. Works in four sections: Gather artifacts, Code quality, Workflow compliance, and Combined verdict.

## Gather artifacts

Before reviewing, confirm you have:

1. The **diff or changed files** in full.
2. The **ticket** — acceptance criteria, scope, in-scope/out-of-scope.
3. The **Design Doc** — architecture decisions and proposed approach.
4. **CI status** — if failing, record it as a blocker in Combined verdict immediately; proceed with Code quality and Workflow compliance to document other findings, but the verdict is Block regardless.

If ticket or Design Doc is missing, note it; mark any unchecked Workflow compliance items as "could not verify: no ticket provided." Confirm you're in a clean context; if unsure, note it in "What was NOT checked."

## Code quality

Read [code-quality-dimensions.md](code-quality-dimensions.md) and apply all quality dimensions to the diff gathered in Gather artifacts.

Record your findings using Blocker/Should-fix/Nit severity. These form the Code Quality section of the Combined verdict.

## Workflow compliance

Checks traceability and process concerns — whether the implementation faithfully satisfies the ticket and respects the design.

### Acceptance criteria coverage

Walk through every acceptance criterion in the ticket and verify each one is met by the diff — this is the most important check.

- **Is each criterion satisfied?** Find the code and tests that satisfy it; if you can't, that's a blocker.
- **Satisfied by real runtime behavior, or only by test scaffolding?** Test doubles that let the test pass without real production code are not evidence.
- **Addressed in production code with no test?** The behavior is unproven — a smell.
- **Scope creep?** Code that doesn't trace to any acceptance criterion is scope creep; surface it even if there were good reasons.

### Design alignment

- Does the implementation follow the approach proposed in the Design Doc?
- Does it respect constraints in `ARCHITECTURE.md`? Silent deviations are a should-fix — that conversation should happen explicitly, not in a diff.
- Note any places where the implementation chose differently from the design, even if the choice seems reasonable.

### Migrations and operational concerns

- **Migration correctness.** Does it have a tested rollback path? Is it safe to run on a production-sized table? Does it lock tables unnecessarily?
- **Feature flags.** Default value matches the rollout plan. The flag is checked in the right places.
- **Config and secrets management.** New environment variables documented? Secrets rotation considered?

### Documentation

- Are public APIs documented where the ticket required it?
- Is the README or runbook updated if the ticket required it?
- Are non-obvious decisions explained? When the code does something unusual, a short comment explaining *why* is worth more than one explaining *what*.

### Regression risk

- What existing behavior does this change touch? Check modified callers and surrounding code paths.
- Did existing tests change? Updated tests can be legitimate (signature changed) or suspicious (test was loosened to make the new code pass). Review test changes carefully.
- Did the test suite pass? If you can run it, do. If you can't, verify CI is green.

## Combined verdict

Merge findings from Code quality and Workflow compliance into a single structured output using the format from [review-base.md](review-base.md). Include an explicit **Acceptance Criteria Coverage** table listing each criterion with its status (verified / not verified / partially verified) and the file/test that proves it.

Apply the smell tests before finalizing:

- **The "Tuesday morning" test.** If production breaks because of this PR, can the on-call engineer diagnose it from logs and metrics alone?
- **The "six months later" test.** Will someone reading this code without context understand and trust it?
- **The "different reviewer" test.** Name the two areas where a different reviewer would most likely raise a concern you haven't raised; check those before finishing.

Determine the combined verdict:

- **Block** if: any acceptance criterion is unmet, there is a security issue, there is a high-likelihood correctness bug, or adapter boundaries are so broken that trust in the implementation is lost.
- **Request changes** if: multiple should-fix items across either code quality or workflow compliance.
- **Approve with comments** if: only nits remain across both dimensions.
- **Approve** if: rare. Hold the bar.

Save the combined review at `docs/features/<slug>/implementation-review-<NN>.md`. Reference specific files, functions, and line ranges in findings. If the verdict is Approve or Approve with comments, suggest merging and note any follow-up tickets from the PR description.

## Common findings

- Tests that pass without proving the behavior works
- Missing edge cases (empty input, boundary values, error paths)
- Authorization checks missing or in the wrong place
- N+1 queries introduced silently
- Logging too sparse to debug a production issue
- Scope creep: changes outside the ticket's scope
- Magic numbers, hardcoded values that should be config
- Inconsistent error handling style
- Business logic receiving HTTP types, Zod inferred types, or ORM entities instead of domain objects
- Validation-schema types, domain types, or DB types crossing layer boundaries
- Tests updated to match new behavior in ways that might mask bugs
- Migration without a tested rollback path
- Feature flag added but never removed (and no follow-up ticket)
- Silent deviation from a Design Doc decision or `ARCHITECTURE.md` constraint without explanation

Note: code quality findings (architecture, adapter boundaries, test quality, correctness, security, observability, performance, simplicity, consistency, documentation) come from [code-quality-dimensions.md](code-quality-dimensions.md) applied in the Code quality section.

