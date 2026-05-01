---
name: implementation-review
description: Use this skill to review a code change produced by the Implementation phase before it gets merged. Checks workflow compliance (ticket adherence, acceptance criteria, design alignment, scope) and applies the nine code-quality dimensions, combining both into a single verdict. Trigger whenever the user says "review this PR", "code review for ticket X", "is this implementation ready to merge", or hands you a diff and asks for feedback. Always use a clean context, separate from the conversation that produced the code, since the value of the review depends on fresh eyes that don't share the implementer's blind spots.
---

# Implementation Review

This skill reviews a **code change** produced by the Implementation phase — the diff, tests, and related changes that satisfy a ticket. It builds on the shared review base; read `review-base.md` first for the reviewer stance, output format, and severity definitions.

The unique job of this review is to verify that the code does what the ticket says it does, that it does so correctly and well, and that it doesn't introduce problems the ticket didn't ask for. It works in four phases.

## Phase 1: Gather artifacts

Before reviewing, confirm you have:

1. The **diff or changed files** in full — the actual code under review.
2. The **ticket** the implementation is for — acceptance criteria, scope, in-scope/out-of-scope.
3. The **Design Doc** the ticket is part of — architecture decisions, proposed approach, referenced ADRs.
4. **CI status** — whether the test suite and linting passed. If CI is failing, record it immediately as a blocker in Phase 4 and note it in the summary — a review cannot approve code that doesn't pass CI. Proceed with Phase 2 and 3 to document other findings, but the verdict is Block regardless of other findings.

If the ticket or Design Doc is missing, note it. The code quality review (Phase 2) can proceed without them, but the workflow compliance review (Phase 3) will be partial. Don't silently skip Phase 3 checks — mark them as "could not verify: no ticket provided."

Also confirm you're in a clean context — you did not participate in creating this code. If you're unsure, note it in "What was NOT checked."

## Phase 2: Code quality

Read `code-quality-dimensions.md` and apply all quality dimensions to the diff gathered in Phase 1.

Record your findings using Blocker/Should-fix/Nit severity. These form the Code Quality section of the combined output in Phase 4.

## Phase 3: Workflow compliance

This phase checks whether the implementation faithfully satisfies the ticket and respects the design. Code quality is already handled in Phase 2; this phase checks traceability and process concerns only.

### Acceptance criteria coverage

The single most important check. Walk through every acceptance criterion in the ticket and verify each one is met by the diff.

- **Is each criterion satisfied?** Find the code (and tests) that satisfies it. If you can't find them, that's a blocker.
- **Satisfied by real runtime behavior, or only by test scaffolding?** Test doubles, stubs, and fakes that let the test pass without any real implementation are not evidence. The behavior must be proven in production code, not just in the test harness.
- **Addressed in production code with no test?** A smell — the behavior is unproven.
- **Scope creep?** Code in the diff that doesn't trace to any acceptance criterion is scope creep. Sometimes there are good reasons (a tightly-coupled refactor was necessary); surface them either way.

### Design alignment

- Does the implementation follow the approach proposed in the Design Doc?
- Does it respect ADR decisions? Silent deviations from architectural decisions recorded in ADRs are a should-fix — the decision may be wrong, but that conversation should happen explicitly, not in a diff.
- Note any places where the implementation made a different choice than the design, even if the choice seems reasonable.

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

## Phase 4: Combined verdict

Merge findings from Phases 2 and 3 into a single structured output using the format from `review-base.md`. Include an explicit **Acceptance Criteria Coverage** table listing each criterion with its status (verified / not verified / partially verified) and the file/test that proves it.

Apply the smell tests before finalizing:

- **The "Tuesday morning" test.** Production breaks because of this PR. Can the on-call engineer figure out what happened from logs and metrics alone?
- **The "six months later" test.** Someone reads this code without context. Will they understand it? Will they trust it?
- **The "different reviewer" test.** Name the two areas of this code where a different reviewer would most likely raise a concern you haven't raised yet. Check those two areas before finishing.

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
- Silent deviation from a Design Doc decision or ADR without explanation

Note: code quality findings (architecture, adapter boundaries, test quality, correctness, security, observability, performance, simplicity, consistency, documentation) come from `code-quality-dimensions.md` applied in Phase 2.

## Verdict guidance

- **Block** if: an acceptance criterion is unmet, tests are missing or don't actually test the behavior, there's a security issue (missing auth, injection vulnerability, secret exposure), or there's a high-likelihood correctness bug.
- **Request changes** if: multiple should-fix items (test gaps, code quality issues, observability gaps, performance smells, scope creep, design deviation).
- **Approve with comments** if: the implementation is solid with only nit-level concerns.
- **Approve** if: rare. Hold the bar.
