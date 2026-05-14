# Good Code

Principles for writing and reviewing code. Read this before writing or reviewing code.

Code is read far more often than it is written. Every principle here optimizes for the reader, not the author.

## Clarity

### Clear Over Clever

Write the simplest, most boring code that works. Bugs are ten times harder to find than code is to write — cleverness makes bugs invisible; obviousness makes them stand out.

**Return early.** Eliminate nesting by returning (or throwing) for the failure cases first, leaving the happy path unindented.

**Avoid boolean parameters.** A call like `renderButton(true)` forces the reader to look up the signature. Use named alternatives: an enum, a separate function, or a named options object. A boolean parameter almost always signals the function does two things.

**Name complex conditions.** A condition with more than two terms, or any negation on a compound expression, should be extracted into a named variable or predicate function. `if (!isExpired && hasPermission && !isSuspended)` is harder to read than `if (canAccess(user, resource))`.

Concrete signals to push back on:
- Dense expressions or non-obvious idioms that hurt readability without earning their complexity
- Deeply nested conditionals where a flatter structure would be clearer
- Optimization that trades readability for speed — a worthwhile trade only when backed by measurement. Without a measured bottleneck, the readable version is correct.

### Naming

Use descriptive, unabbreviated names. A reader should never have to mentally expand `usr` to `user` or `e` to `error`. When the name tells you exactly what it holds and why it exists, the surrounding code becomes self-documenting.

Short names are only justified when the scope is tiny and the meaning is unambiguous — a loop index, a mathematical symbol matching a well-known formula.

**No magic literals.** A number like `86400`, a status string like `"PROC"`, or an HTTP code like `403` embedded without a name forces the reader to know what it means. Extract named constants for any literal whose meaning is not immediately obvious.

**Honest names.** A function called `validateUser` that also creates the user is misnamed. Names must not lie about what they do.

**Ubiquitous language.** Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Code that introduces synonyms for glossary terms fragments the model between documentation and code.

### Explicit Over Implicit

Prefer explicit code over implicit behavior. No hidden coupling, no magic method dispatch, no action-at-a-distance. If something is true — a value is nullable, a step is required, a conversion is lossy — say so in the code.

Concrete signals to push back on:
- Behavior that depends on import order, class definition order, or lifecycle hooks not visible at the call site
- Return types inferred from complex chains where the wrong type is silently accepted
- Optional parameters with non-obvious defaults that change behavior in surprising ways

### Comments

Code should be readable without comments. When code seems unclear, the first response is to write better code: clearer names, a named extraction, a simpler structure.

A comment is warranted only when the code truly cannot speak for itself: a hidden constraint, a subtle invariant, a workaround for a specific bug, behavior that would surprise a reader. Missing comments on self-explanatory code are not a problem.

## Structure

### Command-Query Separation

A function either returns a value (query) or changes state (command) — never both.

- **Query**: returns a value, no side effects. Safe to call multiple times; callers can reason about it in isolation.
- **Command**: changes state, returns nothing (or only a status). Callers know calling it has an effect.

A function must not both return a meaningful value *and* mutate state or produce a side effect. Intentional exceptions (e.g., `stack.pop()`) should be clearly named to signal the exception rather than left ambiguous.

### Temporal Coupling

When functions must be called in a specific order and the interface does not enforce it, callers can violate the order silently.

```
parser.init()   // must be called first
parser.parse()  // silently broken if init() was skipped
```

Initialization methods that must precede use methods, multi-step workflows where each step assumes the previous completed, and any "setup before use" pattern where the constraint lives only in documentation are all design problems.

Fixes: merge into one call, use a builder or factory that returns a ready-to-use object, or make step 1 return a typed value that step 2 requires as a parameter — so the compiler or runtime enforces the order.

### Simple Design

Avoid unnecessary complexity: abstractions added speculatively (YAGNI), logic that could be a simple function but became a class hierarchy. Requirements change in ways you cannot predict; code written for imagined future requirements is waste, and often makes the code that *did* arrive harder to change.

Kent Beck's four rules, in priority order:

1. **Passes all tests.** Correct behavior is the baseline. A simpler design that is wrong is not simpler.
2. **Reveals intention.** Names, structure, and shape make the purpose clear without comments explaining the what.
3. **No duplication (DRY).** Every piece of knowledge has a single representation. **Prefer duplication over the wrong abstraction** (Sandi Metz): two honest parallel implementations are better than one leaky shared interface. Extract only when callers become *simpler*, not when the implementation becomes shorter.
4. **Fewest elements.** No speculative classes, methods, parameters, or abstractions. Remove anything that does not serve the first three rules.

The order matters: don't sacrifice correctness for elegance, don't sacrifice clarity for DRY, don't sacrifice either for brevity.

### File Layout

The primary export comes first; helpers follow below the functions that call them, propagating through every level. A reader opening the file sees the entry point first and drills into detail as they scroll — never encountering a helper before its context.

### Housekeeping

Remove dead weight before committing: commented-out code, debug prints, unused imports, leftover `TODO` comments about the current change.

Code must match the surrounding codebase in naming conventions, error handling style, and structural patterns. Departures without a reason accumulate friction for every reader that follows.

## Architecture

Read [architecture-principles.md](architecture-principles.md) in full. All principles there apply without exception.

## Tests

### Test Quality

Tests are evidence that the code does what it claims — not just that it runs.

- **Public interface only.** Tests should call the same interface external callers use. Tests that reach into internals break when the implementation changes even if behavior is unchanged. That is the wrong breakage.
- **Behavior-based, not implementation-based.** A test that asserts "method X was called with argument Y" is testing implementation. A test that asserts "the user received a confirmation email" is testing behavior. The former breaks on refactoring; the latter does not.
- **Right level.** Unit tests verify isolated logic; integration tests verify two or more components working together; end-to-end tests verify a user-visible flow. A unit test passing doesn't prove the integration works.
- **Edge cases and boundary values.** Empty inputs, maximum values, concurrent access, error paths, timeouts. The obvious ones should always be present.
- **Negative tests.** Code has rules about what it rejects. Those rejection paths need tests.
- **Would catch a regression?** Mentally remove the new code and check whether the tests fail. A test that passes before *and* after the bug is reintroduced is not a test.
- **Mocking at system boundaries only.** Mock external APIs, databases, time, the filesystem, and randomness. Never mock your own code — your own classes, modules, and internal collaborators. If mocking your own code seems necessary, the interface is wrong.
- **Tests are independent.** Each test must run alone, in any order, and in parallel without affecting others. Shared mutable state, database rows from a previous test, or filesystem artifacts left by another test are problems.
- **No timing-dependent tests.** `sleep(100)` to wait for an async operation is flaky by design. Use explicit synchronization, event-driven signaling, or fake clocks.
- **Test code is clear.** Tests are documentation of behavior. Unclear names, opaque arrange/act/assert structure, magic numbers all reduce test value over time.

## Quality

### Correctness

- **Error paths.** What happens when the network call fails, the row isn't there, the input is malformed, the API returns 500? Every external call has a failure mode.
- **Fail-fast for programmer errors, graceful for expected failures.** An illegal argument or broken invariant should fail immediately and loudly. A network timeout or missing row is an expected failure and must be handled explicitly — not swallowed, not propagated as a raw exception.
- **Errors carry context.** An error that reaches a log or a caller should include what was being attempted, what failed, and the relevant identifiers. Wrap errors with context rather than re-throwing bare.
- **No silent swallows.** Never swallow errors in an empty catch block, and never return `null`/`undefined`/`None` to signal an error when the caller asked for a value.
- **Concurrency.** Shared state must be protected against race conditions, double-submits, cache stampedes, and deadlocks.
- **State machines.** Stateful entities must not have illegal states reachable, and transitions must be atomic where needed.
- **External dependency robustness.** Every blocking external call must have a timeout. Use retries with backoff and circuit breakers where appropriate.
- **Time and randomness.** Hardcoded `now()` or `random()` inside business logic is a correctness bug and a testing pain. Inject them.
- **Resources are explicitly released.** Every resource that must be closed — file handles, database connections, transactions, HTTP client sessions — must be released in a `finally` block, a `using`/`with` statement, or an RAII guard. Relying on garbage collection is a correctness bug for connections. Every code path that acquires a resource must release it.

### Security

- **Input validation.** Anywhere data crosses a trust boundary, validation is required.
- **Injection prevention.** Never concatenate user input into SQL queries, shell commands, or templates. Use parameterized queries and shell-safe APIs.
- **Secrets handling.** No secrets in code, no secrets in log output, no secrets in error messages surfaced to users.
- **Authorization.** Endpoints that mutate state must check who is allowed to do what.
- **PII in logs.** Passwords, tokens, personal data must never appear in log output.
- **Cryptography.** Use well-established high-level libraries (bcrypt, libsodium, native TLS). Manual composition of raw low-level cryptographic primitives is almost certainly wrong.

### Observability

- **Right things logged.** Errors, important state transitions, external service interactions. Not too verbose, not too sparse.
- **Log messages are useful.** "Failed to charge customer 12345 — gateway timeout after 30s" is useful. "Error" with no context is not.
- **Metrics.** Significant behaviors (state transitions, external calls, error paths) should be instrumented.
- **Tuesday morning test.** Production breaks. Can an on-call engineer figure out what happened from logs and metrics alone, without reading the code?

### Performance

- **N+1 queries.** Never query inside a loop that scales with result set size.
- **Unbounded operations.** In-memory loops on arbitrarily large data must use pagination or limits.
- **Missing indexes.** New queries on unindexed columns in WHERE or JOIN conditions will not scale.
- **Caching.** Two failure modes: *missing where needed* (repeated identical DB/API calls in one request), *added speculatively* without evidence of a bottleneck.
- **Slow operations bounded.** Timeouts on external calls, pagination on list endpoints, limits on retry counts.
