# Code Quality Dimensions

These dimensions are organized in two tiers. **Tier 1** covers project-specific quality preferences — check these with the detailed guidance below. **Tier 2** covers general code quality dimensions — the elaborated ones have specific pitfalls worth naming; the brief ones are well-known and just need to be checked. Report all findings sorted by severity.

## Tier 1: Project-specific preferences

### 1. Architecture and organization

*Covers the general dimension: Design / Cohesion*

Read [architecture-principles.md](architecture-principles.md) §Screaming Architecture. Severity: **blocker** in a project with no existing layered structure. **Should-fix** when adding to an already-layered codebase (flag the tension; don't necessarily hold the change).

### 2. Deep modules

*Covers the general dimension: Coupling*

Read [architecture-principles.md](architecture-principles.md) §Deep Modules. The finding is not "too small" but "the caller is worse off for this abstraction existing." Flag: pass-through methods, abstraction leakage, interfaces too thin to justify their existence, callers more complex after the abstraction.

### 3. Adapter boundaries

*Covers the general dimension: Coupling*

Read [architecture-principles.md](architecture-principles.md) §Adapter Boundaries. Flag: business logic importing from a validation library or ORM (should-fix), validation schemas / domain types / DB types crossing a layer boundary (should-fix), domain rules implemented in an adapter (should-fix). Even in simple CRUD, check that concerns are visibly distinct — interleaved logic is still a violation.

### 4. Test quality

*Covers the general dimension: Testability*

Tests are evidence that the code does what it claims — not just that it runs.

- **Public interface only.** Tests should call the same interface external callers use. Tests that reach into internals, inspect private state, or call private methods break when the implementation changes even if behavior is unchanged. That is the wrong breakage.
- **Behavior-based, not implementation-based.** A test that asserts "method X was called with argument Y" is testing implementation. A test that asserts "the user received a confirmation email" is testing behavior. The former breaks on refactoring; the latter does not.
- **Right level.** Unit tests verify isolated logic; integration tests verify two or more components working together; end-to-end tests verify a user-visible flow. Look for the right mix. A unit test passing doesn't prove the integration works.
- **Edge cases and boundary values.** Empty inputs, maximum values, concurrent access, error paths, timeouts. The obvious ones should always be present.
- **Negative tests.** Code has rules about what it rejects. Those rejection paths need tests.
- **Would catch a regression?** Mentally try to remove the new code and see whether the tests would fail. A test that passes before *and* after the bug is reintroduced is not a test.
- **Mocking at system boundaries only.** Mock external APIs, databases, time, the filesystem, and randomness. Never mock your own code — your own classes, modules, and internal collaborators. If mocking your own code seems necessary, the interface is wrong. Red flags: mocking the system under test into oblivion, asserting on call counts or call order.
- **Test code is clear.** Tests are documentation of behavior. Unclear names, opaque arrange/act/assert structure, magic numbers — all reduce test value over time.

### 5. Code clarity

*Covers the general dimension: Readability*

- **Ubiquitous language.** Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Code that introduces synonyms for glossary terms fragments the model between documentation and code — flag as **should-fix** with the canonical term as the fix.
- **Honest names.** A function called `validateUser` that also creates the user is misnamed. Names that lie about what they do are a finding.
- **Code style.** Read [code-style.md](code-style.md) for the style principles: clear over clever and dead-weight free. Apply them when reviewing — flag dense or non-obvious code and dead weight as should-fix.

## Tier 2: General code quality dimensions

### 6. Correctness

*Covers the general dimensions: Correctness, Error handling*

- **Error paths.** What happens when the network call fails, the row isn't there, the input is malformed, the API returns 500? Every external call has a failure mode.
- **Concurrency.** Shared state: race conditions, double-submits, cache stampedes, deadlocks.
- **State machines.** Stateful entities: illegal states reachable? Transitions atomic where needed?
- **External dependency robustness.** Timeouts, retries with backoff, circuit breakers. A blocking external call with no timeout is a finding.
- **Time and randomness.** Hardcoded `now()` or `random()` inside business logic: correctness bug and testing pain. Inject them.

### 7. Security

- **Input validation.** Anywhere data crosses a trust boundary, validation is needed. Missing validation at external inputs is a blocker.
- **Injection prevention.** Look for string concatenation into SQL queries, shell commands, or templates. Parameterized queries and shell-safe APIs are the fix. Flag any interpolation into a query or command.
- **Secrets handling.** No secrets in code, no secrets in log output, no secrets in error messages surfaced to users.
- **Authorization.** Endpoints that mutate state must check who is allowed to do what. Missing authorization checks are a blocker.
- **PII in logs.** Passwords, tokens, personal data — these should never appear in log output.
- **Cryptography.** Custom crypto is almost never correct. Flag code that composes raw low-level cryptographic primitives (manual padding, raw digest functions, custom key derivation) instead of using a well-established high-level library (bcrypt, libsodium, native TLS). Using a library correctly is not hand-rolling.

### 8. Observability

- **Right things logged.** Errors, important state transitions, external service interactions. Not too verbose, not too sparse.
- **Log messages are useful.** "Failed to charge customer 12345 — gateway timeout after 30s" is useful. "Error" with no context is not.
- **Metrics.** If the design or ticket specified metrics, verify they are wired up. If not specified, check whether the change introduces significant behaviors (state transitions, external calls, error paths) that should be instrumented — flag any that are not.
- **Tuesday morning test.** Production breaks. Can an on-call engineer figure out what happened from logs and metrics alone, without reading the code?

### 9. Performance

- **N+1 queries.** A query inside a loop that scales with result set size. Always a should-fix.
- **Unbounded operations.** In-memory loops on arbitrarily large data without pagination or limits.
- **Missing indexes.** New queries on unindexed columns in WHERE or JOIN conditions.
- **Optimization without measurement.** Obscures intent without a measured bottleneck — prefer the readable version unless demonstrably critical.
- **Caching.** Two failure modes, both should-fix: *missing where needed* (repeated identical DB/API calls in one request), *added speculatively* without evidence of a bottleneck.
- **Slow operations bounded.** Timeouts on external calls, pagination on list endpoints, limits on retry counts.

### 10. Simplicity

Avoid unnecessary complexity. Flag: cyclomatic depth that obscures intent, abstractions added speculatively (YAGNI), logic that could be a simple function but is a class hierarchy, deeply nested conditionals that would flatten to a table. Prefer the readable version unless there is a measured reason not to.

### 11. Consistency

Does the change match the surrounding codebase? Flag: naming conventions that differ from the local idiom, error handling style inconsistent with adjacent code, structural patterns that break from established conventions without a reason. A codebase that surprises readers in small ways accumulates friction.

### 12. Documentation

Non-obvious decisions should be explained — a hidden constraint, a specific bug workaround, behavior that would surprise a reader. Flag: code doing something unusual with no explanation, public APIs with no contract stated where one is expected. Do not flag missing comments on self-explanatory code.
