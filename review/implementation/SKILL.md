---
name: review-implementation
description: Use this skill to review a code change (PR, branch, or set of commits) produced by the Implementation phase before it gets merged. Trigger this whenever the user says things like "review this PR", "code review for ticket X", "is this implementation ready to merge", or hands you a diff and asks for feedback. The output is a structured review file with findings categorized by severity. Always use a clean context, separate from the conversation that produced the code, since the value of the review depends on fresh eyes that don't share the implementer's blind spots.
---

# Implementation Review

This skill reviews a **code change** produced by the Implementation phase — the actual diff, tests, and any related changes that satisfy a ticket. It builds on the shared review base; read `../SKILL.md` first for the reviewer stance, output format, and severity definitions.

The unique job of this review is to verify that the code does what the ticket says it does, that it does so well, and that it doesn't introduce problems the ticket didn't ask for.

## Setup

Before reviewing, confirm:

1. You can read the diff or the changed files in full.
2. You have access to the **ticket** the implementation is for, and to the **Design Doc** the ticket is part of. Code review without the ticket is reduced to style nitpicking.
3. You can run the tests locally if needed, or you can verify CI passed.
4. You're in a clean context — you did not participate in creating this artifact. If you're unsure, treat your judgment as potentially contaminated: note it in "What was NOT checked" and flag any area where prior context might be biasing you.

## What to check

### Acceptance criteria coverage

The single most important check. Walk through every acceptance criterion in the ticket and verify each one is met by the diff.

- **Is each acceptance criterion satisfied?** For each, find the code (and tests) that satisfies it. If you can't, that's a blocker.
- **Is each acceptance criterion satisfied by actual runtime behavior, or is it only "satisfied" by test scaffolding (stubs, fakes, or test doubles) that would pass without any real implementation?**
- **Are any acceptance criteria addressed only in production code, with no test?** Also a smell — the behavior is unproven.
- **Has scope crept beyond the ticket?** Code in the diff that doesn't trace to the ticket's acceptance criteria is scope creep. Sometimes there are good reasons (a tightly-coupled refactor was needed); call them out either way.

### Test quality

Tests are not just "did the implementer write some tests" — tests are evidence that the code does what it claims.

- **Do the tests actually test the behavior?** Read each new test. Does it assert something meaningful about the behavior, or does it test that the code runs without crashing? Tests that only check "no exception thrown" or that mock the system under test into oblivion are weak.
- **Are tests at the right level?** A unit test passing doesn't prove the integration works. An end-to-end test passing doesn't prove a unit's edge cases are handled. Look for the right mix.
- **Are edge cases covered?** Empty inputs, boundary values, concurrent access, error paths, retries, timeouts. The ticket may have called some out; the implementer should also cover the obvious ones.
- **Are negative tests present?** Code typically has rules about what it rejects as well as what it accepts. The rejection paths need tests too.
- **Would the tests catch a regression?** A common failure mode: tests that pass before *and* after the buggy change is reintroduced. Mentally try to break the code and see whether the tests would notice.
- **Is test code itself clear?** Tests are documentation of behavior. Bad test names, unclear arrange/act/assert structure, magic numbers — these reduce test value over time.

### Code quality

- **Does it match the codebase's conventions?** Naming, structure, error handling style, logging style. Code that looks like it was airdropped from another codebase is a finding.
- **Do identifiers use the ubiquitous language?** Check `UBIQUITOUS_LANGUAGE.md`. Class names, function names, and variable names that introduce synonyms for glossary terms are a should-fix — they fragment the model between documentation and code.
- **Is the code clear?** Could a future maintainer who lacks context understand it? Long functions, nested conditionals, dense expressions — push back when they hurt readability without earning their complexity. Clever tricks and non-obvious idioms are findings: bugs are far harder to find than code is to write, so the bar for "dumb but obvious" is high.
- **Are abstractions at the right level?** Premature abstraction (an interface used once, prepared for hypothetical future use) is as bad as missing abstraction (the same logic copy-pasted three times). Both are findings. When evaluating an abstraction, ask whether it is *deep*: a deep module has a simple interface that hides significant complexity; a shallow module's interface is nearly as complex as its implementation and leaks rather than encapsulates. Common shallow-module smells: pass-through methods that add no logic, and abstractions too small to justify their existence. Shallow modules spread complexity onto callers rather than containing it — flag them as a should-fix.
- **Are adapter boundaries respected?** Business logic should receive and return domain objects only — no HTTP/framework types, no validation-schema types (e.g., Zod inferred types), no ORM entities or DB row types. The inbound adapter (route handler, controller) owns validation and input mapping; the outbound adapter (repository) owns DB translation. If business logic imports from a validation library or an ORM, that is a should-fix. Equally, verify that the three type categories are kept separate: validation schemas belong in the inbound layer, domain types belong in the business logic, and database types belong in the outbound layer. Even in simple CRUD code that lives in one function, the three concerns should be visibly distinct and not interleaved.
- **Is the code dead-weight free?** Commented-out code, debug prints, unused imports, leftover TODOs about this ticket — these should be cleaned up.
- **Is duplication justified?** Sometimes duplication is fine (different domains that happen to look similar). Sometimes it's a refactor waiting to happen. Use judgment.
- **Is naming honest?** A function called `validateUser` that also creates the user is misnamed. Names that lie are a finding.

### Correctness

- **Are error paths handled, not just the happy path?** What happens when the network call fails, the row isn't there, the input is malformed?
- **Is concurrency handled if relevant?** Race conditions, double-submits, cache stampedes, deadlocks. If the change touches shared state, has the implementer thought about concurrent access?
- **Is the state machine correct?** If the change involves stateful entities, walk through the transitions. Are illegal states reachable? Are transitions atomic where they need to be?
- **Are external dependencies handled robustly?** Timeouts, retries with backoff, circuit breakers if the codebase uses them. A naive blocking call to an external service is often a finding.
- **Are time and randomness handled?** Hardcoded `now()` and `random()` calls inside business logic are testing pain and often correctness bugs.

### Security

- **Is user input validated?** Anywhere data crosses a trust boundary, validation is needed.
- **Are SQL/command/template injections prevented?** Look for string concatenation into queries, shell commands, or templates.
- **Are secrets handled correctly?** No secrets in code, no secrets in logs, no secrets in error messages.
- **Are authorization checks present?** Endpoints that mutate state should check who's allowed to do what. Missing auth checks are a classic blocker-level finding.
- **Is sensitive data redacted in logs?** PII, tokens, passwords — these should never make it into log output.
- **Is the cryptography boring?** Custom crypto is almost never the right answer. If the code composes low-level cryptographic primitives directly (raw digest functions, manual padding, custom key derivation) rather than using a well-established high-level library (bcrypt, libsodium, native TLS), push back hard. Using a library correctly is not hand-rolling.

### Observability

- **Are the right things logged?** Errors, important state transitions, external service interactions. Not too verbose, not too sparse.
- **Are metrics emitted where appropriate?** If the design or ticket specified metrics, verify they're actually wired up. If they weren't specified, check whether the change introduces significant behaviors (state transitions, external calls, error paths) that should be instrumented — flag any that aren't.
- **Are log messages useful?** "Error" with no context is unhelpful. "Failed to charge customer 12345 — gateway timeout after 30s" is useful.
- **Will an on-call engineer be able to debug this when it breaks?** Imagine a production incident. Does the code emit enough signal to diagnose it?

### Performance

- **Are there obvious inefficiencies?** N+1 queries, unbounded loops, in-memory operations on large data, missing indexes for new queries.
- **Is optimization justified?** An optimization that obscures intent without a measured bottleneck is a finding. Ask what benchmark motivated the change; if there isn't one, flag it — the readable version should be preferred unless performance is demonstrably critical.
- **Is caching used appropriately?** Both "missing where needed" and "added speculatively" are findings. For "missing where needed": look for repeated DB or API calls with identical inputs within a single request, or unconditional loads of large data sets on hot paths. Those are the patterns that warrant caching.
- **Are slow operations bounded?** Timeouts on external calls, pagination on list endpoints, limits on retry counts.

### Migrations and operational concerns

- **If a migration was added, is it correct?** Does it have a tested rollback path? Is it safe to run on a production-sized table? Does it lock tables unnecessarily?
- **Are feature flags wired correctly?** Default value matches the rollout plan. The flag is checked in the right places.
- **Are config and secrets management updated?** New environment variables documented? Secrets rotation considered?

### Documentation

- **Are public APIs documented?** Function/method docs at module boundaries.
- **Is the README / runbook updated if the ticket required it?**
- **Are non-obvious decisions explained?** When the code does something unusual, a short comment explaining why is worth more than the same comment explaining what.

### Regression risk

- **What does this change touch that has existing behavior?** Check the modified callers and surrounding code paths. The implementer may have changed something subtly that other code relies on.
- **Did existing tests change?** Updated tests can be legitimate (signature changed) or suspicious (test was loosened to make the new code pass). Review test changes carefully.
- **Did the test suite pass?** If you can run it, do. If you can't, verify CI is green.

### Smell tests

- **The "Tuesday morning" test.** It's Tuesday morning. Production breaks because of this PR. Can the on-call engineer figure out what happened from logs and metrics alone?
- **The "six months later" test.** Six months from now, someone reads this code without context. Will they understand it? Will they trust it?
- **The "different reviewer" test.** Name the two areas of this code where a different reviewer would most likely raise a concern you haven't raised. Then check those two areas before finishing.

## Common findings

- Tests that pass without proving the behavior works
- Missing edge cases (empty input, boundary values, error paths)
- Authorization checks missing or in the wrong place
- N+1 queries introduced silently
- Logging too sparse to debug a production issue
- Scope creep: changes outside the ticket's scope
- Magic numbers, hardcoded values that should be config
- Inconsistent error handling style
- Business logic receiving raw HTTP types, Zod inferred types, or ORM entities instead of domain objects
- Validation-schema types, domain types, or DB types crossing layer boundaries
- Tests updated to match new behavior in ways that might mask bugs
- Migration without a tested rollback path
- Feature flag added but never removed in code (and no follow-up ticket)

## Verdict guidance for this phase

- **Block** if: an acceptance criterion is unmet, tests are missing or don't actually test the behavior, there's a security issue (missing auth, injection vulnerability, secret exposure), or there's a high-likelihood correctness bug.
- **Request changes** if: multiple should-fix items (test gaps, code quality issues, observability gaps, performance smells, scope creep).
- **Approve with comments** if: the implementation is solid with only nit-level concerns.
- **Approve** if: rare. Hold the bar.

## Output

Save the review at `docs/features/<slug>/reviews/implementation-<ticket-NNN>-<YYYY-MM-DD>.md` using the format from the shared review base. Reference specific files, functions, and line ranges. Include the acceptance-criteria coverage as an explicit list with each item marked verified or not. If the verdict is Approve or Approve with comments, suggest merging and creating any follow-up tickets noted in the PR description.
