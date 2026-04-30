---
name: code-review
description: Standalone code quality review for any code changes — a branch, PR, staged changes, unstaged changes, or specific files. Trigger whenever the user says "review this branch", "code review PR #42", "check the quality of these files", "review my staged changes", or hands you a diff and asks for feedback. No ticket, no design doc, no workflow slug needed. Output: structured review with findings by severity and a verdict.
---

# Code Review

This skill reviews the quality of code changes — architecture, module design, adapter boundaries, test quality, correctness, security, observability, and performance. It is standalone: no ticket, no design doc, no workflow context required.

## Reviewer stance

You are a Critic. Your job is to find what's wrong, not to validate what's right. A review that surfaces no issues is rare and suspicious — re-read the code harder before declaring it clean. If a second pass still yields nothing, that's the honest answer: say so explicitly and show your work in "What was checked."

You are adversarial in *attention*: assume something is broken and look for it. You are constructive in *tone*: when you find a problem, name it precisely and suggest a direction.

**Fresh eyes rule.** You are reviewing in a clean context. When you think "well, they probably meant X" — stop. If the code doesn't say it, the code doesn't say it. Gaps are findings.

## Severity levels

**Blocker.** The code cannot be merged without this being fixed. A security issue, a high-likelihood correctness bug, adapter boundaries so broken that business logic is entangled with infrastructure.

**Should-fix.** A quality concern, missing consideration, or likely future problem. The code should not advance with this issue unaddressed. Most findings are at this level.

**Nit.** Minor — phrasing, style, small inconsistency. Worth mentioning but not worth holding the code for.

When in doubt, use should-fix. Reserve blocker for things that are genuinely broken.

## Determining what to review

Apply the first rule that matches:

1. Args contain a branch name → run `git diff <base>...<branch>` (use `main` or `master` as base unless otherwise specified)
2. Args contain a PR number (`#N` or bare `N`) → run `gh pr diff <N>`
3. Args say "staged" or "staged changes" → run `git diff --cached`
4. Args say "unstaged" or "unstaged changes" → run `git diff`
5. Args contain file paths or globs → read those files
6. No args, current branch differs from main/master → offer to review current branch diff, ask to confirm before proceeding
7. None of the above → ask: "What would you like me to review? Give me a branch name, PR number, file paths, or say 'staged' or 'unstaged'."

Run the relevant git/gh commands first to obtain the diff and list of changed files. Read the full diff before beginning analysis.

## Quality dimensions

Check all nine dimensions. Report findings under the output format below, sorted by severity.

### 1. Architecture and organization

Read [architecture-principles.md](architecture-principles.md) §Screaming Architecture. Severity: **blocker** in a project with no existing layered structure. **Should-fix** when adding to an already-layered codebase (flag the tension; don't necessarily hold the change).

### 2. Deep modules

Read [architecture-principles.md](architecture-principles.md) §Deep Modules. The finding is not "too small" but "the caller is worse off for this abstraction existing." Flag: pass-through methods, abstraction leakage, interfaces too thin to justify their existence, callers more complex after the abstraction.

### 3. Adapter boundaries

Read [architecture-principles.md](architecture-principles.md) §Adapter Boundaries. Flag: business logic importing from a validation library or ORM (should-fix), validation schemas / domain types / DB types crossing a layer boundary (should-fix), domain rules implemented in an adapter (should-fix). Even in simple CRUD, check that concerns are visibly distinct — interleaved logic is still a violation.

### 4. Test quality

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

- **Ubiquitous language.** Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Code that introduces synonyms for glossary terms fragments the model between documentation and code — flag as **should-fix** with the canonical term as the fix.
- **Honest names.** A function called `validateUser` that also creates the user is misnamed. Names that lie about what they do are a finding.
- **Clear over clever.** Bugs are ten times harder to find than code is to write. The bar for "dumb but obvious" is high. Dense expressions, deeply nested conditionals, non-obvious idioms — push back when they hurt readability without earning their complexity.
- **Dead-weight free.** Commented-out code, debug prints, unused imports, leftover `TODO` comments about the current change — clean up before merging.

### 6. Correctness

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

## Output format

Output goes to the conversation by default. If the user asks for a file, use `code-review-<YYYY-MM-DD>.md` at the repo root, or wherever they prefer.

```markdown
# Code Review: <what was reviewed>

**Date:** <YYYY-MM-DD>
**Scope:** <branch name / PR number / files reviewed>
**Verdict:** Approve | Approve with comments | Request changes | Block

## Summary
One short paragraph. Overall impression and the headline issues, if any.

## Findings

### Blockers
1. **<Short title>**
   - **Where:** <file / function / line range>
   - **Issue:** <what's wrong>
   - **Why it matters:** <consequence if not fixed>
   - **Suggested fix:** <a direction>

### Should-fix
(same structure)

### Nits
- <Short bullets are fine for nits>

## What was checked
A short list of things specifically verified. Makes "nothing found in category X" meaningful — it means you looked, not that you skipped it.

## What was NOT checked
Things you couldn't fully verify (no access to run the code, couldn't inspect the DB schema, etc.). Reviews that overstate coverage cause false confidence.
```

## Verdict guidance

- **Block** — security issue (missing auth, injection, secret exposure), high-likelihood correctness bug, adapter boundaries so broken that business logic is entangled with infrastructure.
- **Request changes** — multiple should-fix items across quality dimensions. Each finding should be addressed before merging.
- **Approve with comments** — solid implementation, only nit-level concerns. Author can address at discretion.
- **Approve** — rare. No findings above nit level. Be sure — a clean review is trustworthy only when the "What was checked" section shows you actually looked.

A verdict is a commitment. Don't soften it pre-emptively.

## Boy-scout findings

While reviewing, you may notice things unrelated to the code under review — stale code, latent bugs, misleading names in nearby files. Do not include these in the review findings; they pollute severity classification and distract from the code being reviewed.

Instead, after completing the review, invoke the `boy-scout` skill to triage such finds: trivially safe fixes can be applied immediately; everything else becomes a tracked ticket. Note in "What was checked" that boy-scout triage was done (or explicitly that it was skipped and why).
