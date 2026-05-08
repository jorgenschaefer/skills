---
name: implementation
description: Use this skill when the user wants to implement tickets using TDD (test-driven development). Trigger this whenever the user says things like "implement ticket #X", "let's build #123", "work on the next ticket", "TDD this feature", hands you a ticket file and asks you to build it, OR says "implement all tickets for <feature>", "run the full implementation loop", or invokes the skill with a feature slug but no specific ticket. The output is working code with tests, committed in small steps, satisfying every acceptance criterion in the ticket. Always use this skill for ticket-driven implementation work — it enforces the TDD red-green-refactor discipline and the boundaries of the ticket scope.
---

# Implementation

The goal of the Implementation phase is to take a single ticket and produce working, tested, reviewable code that satisfies its acceptance criteria. The output is code, tests, and a description of what was done — all within the scope the ticket defines.

## Orchestrator mode

If you are invoked with a feature slug but **no specific ticket**, act as an orchestrator — not an implementer. Do not write any code yourself. Instead, run this loop:

1. List `docs/features/<slug>/tickets/*.md`. Filter to files whose `**Status:**` field is `Backlog`, ordered by filename.
2. For each Backlog ticket:
   - Read its `**Depends on:**` field. If any listed dependency ticket does not have `Status: Done`, skip this ticket and report the blockage to the user. Do not stop the loop — continue to the next ticket.
   - **Spawn an implementer subagent** using the `Agent` tool with `subagent_type: "general-purpose"`. Use this prompt (fill in the placeholders):

     > Use the Skill tool to invoke the `implementation` skill with args `<slug>`. The ticket to implement is at `<ticket-path>`. The Design Doc is at `docs/features/<slug>/design.md`. Proceed directly without asking the user which ticket to work on. When done, clearly list all commit hashes in your final summary under the heading **Commit hashes:**.

   - Wait for the subagent to finish. Extract the commit hashes from its result.
   - **Spawn a reviewer subagent** using the `Agent` tool with `subagent_type: "general-purpose"`. Use this prompt:

     > Invoke the `implementation-review` skill. The ticket is at `<ticket-path>`. The Design Doc is at `docs/features/<slug>/design.md`. The implementation commits are: `<hash1>`, `<hash2>`. Use `git show <hash>` to view each.

   - Wait for the reviewer subagent to finish. Read the review file it saved at `docs/features/<slug>/implementation-review-<NN>.md`. Check the verdict.
   - If the verdict is anything but **Approve**, **spawn a fix-up subagent** using the `Agent` tool with `subagent_type: "general-purpose"`. Use this prompt:

     > Address all findings from the review at `<review-path>` for ticket `<ticket-path>`. Read the review file, then read the relevant code. Fix each finding, run tests to confirm green. Commit any changes with descriptive messages. Report all new commit hashes when done.

   - Report the ticket outcome to the user: what was implemented, the review verdict, and what (if anything) was fixed.
3. When no Backlog tickets remain (or all remaining are blocked by unmet dependencies), report the feature complete and ready for final merge, or summarize which tickets are still blocked and why.

The orchestrator never touches code directly. Every implementation, review, and fix-up runs in its own isolated subagent with a clean context.

## Your role

You are the Implementer. You implement *one ticket at a time*. You do not redesign, you do not expand scope, you do not refactor unrelated code. If you find problems outside your ticket, you note them but do not fix them in this PR.

You write tests first. Always. This is not negotiable in this skill — if the user wants non-TDD implementation, that's a different skill.

## Inputs you need

Before starting, make sure you have:

1. **The ticket.** A specific ticket file with goal, scope, and acceptance criteria. If the user gestures at "the next ticket" without specifying, ask which one. Once identified, immediately update its **Status** to `In Progress` before doing anything else.
2. **The Design Doc.** The ticket should reference it. Read it for context before starting.
3. **The codebase.** Read the relevant existing code. Understand the patterns. Run the existing test suite — if it doesn't pass, stop and report to the user before adding any changes on top of a broken baseline.
4. **The repo's conventions.** Check `CLAUDE.md` / `AGENTS.md` for build/test/lint commands, code style, and any project-specific rules.
5. **The project's ubiquitous language.** Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Use canonical terms in identifiers — class names, function names, variable names, test descriptions.
6. **The reference files for this skill.** Read [tests.md](tests.md), [deep-modules.md](deep-modules.md), [mocking.md](mocking.md), and [refactoring.md](refactoring.md) before writing any code. They contain the patterns and guidelines this skill applies throughout the TDD loop.

If anything is missing or unclear, ask before writing code. Misunderstanding the ticket is the most expensive mistake at this stage.

## The TDD loop

This skill follows strict outside-in test-driven development.

**Tests verify behavior, not implementation.** Write tests through public interfaces — don't test private methods or internal collaborators. The right test survives a complete internal refactor. If renaming a private function breaks a test, that test was wrong. See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

**Anti-pattern: bulk-test-first.** Do not write all tests first, then all code. Tests written in bulk verify imagined behavior and are blind to what actually matters — you outrun your headlights and commit to test structure before understanding the implementation. Each test must respond to what you learned from the previous cycle. One test → one implementation → repeat.

```
WRONG (bulk-test-first):  RED: test1, test2, test3  →  GREEN: impl1, impl2, impl3
RIGHT (one-cycle-at-a-time):    RED→GREEN: test1→impl1    →  RED→GREEN: test2→impl2
```

1. **Read.** Before each loop iteration, read the ticket again and the relevant code. Pick the next acceptance criterion to satisfy.
2. **Red.** Write a test that captures that acceptance criterion. Run it. Confirm it fails *for the right reason* — the assertion you care about, not a syntax error or a missing import. A test that fails for the wrong reason is no test at all.
3. **Green.** Write the minimum code that makes the test pass. Don't anticipate future tests; don't add features the current test doesn't drive. Run the test. Confirm it passes. Run the *whole* test suite. Confirm nothing else broke.
4. **Refactor.** With tests green, look at what you wrote. Is there duplication? Is naming clear? Are abstractions at the right level? Improve the code without changing behavior. Run the tests after each refactor step to confirm green is preserved. One concrete lens: aim for *deep modules* — simple interfaces that hide significant complexity. If you find thin layers that just delegate without hiding anything (shallow modules), consider merging the layers into one module, or moving the logic down into a deeper implementation so callers interact with a simpler interface. The refactor step is the right moment to deepen abstractions; the test suite makes it safe. See [deep-modules.md](deep-modules.md) and [refactoring.md](refactoring.md).
5. **Commit.** Commit per logical behavior or acceptance criterion — typically one commit per acceptance criterion item, sometimes fewer if criteria are tightly coupled. Multiple small commits per ticket are normal and preferred over one large one. The commit message should describe what behavior was added, not what files changed. "Add validation for empty draft titles" beats "Update DraftService.ts." After committing, note the hash (`git log -1 --format=%H`) — you will pass it to the review agent.
6. **Repeat** until every acceptance criterion is met.

The discipline matters. The order matters. Skipping the red step ("I know the test will fail, I'll just write the code") is the most common way TDD breaks down — you end up writing tests that pass on the first run, which means they're not actually testing what you think they are.

## Picking the right test level

Not every test is a unit test. Match the test level to what you're verifying:

- **End-to-end / acceptance test.** Verifies a full user-visible flow. One per ticket is often enough — it proves the whole slice works. Slow but high-value.
- **Integration test.** Verifies that two or more components work together (e.g., service + database, controller + service).
- **Unit test.** Verifies a single function, class, or small module in isolation. Fast, fine-grained, the bulk of your tests.

Outside-in TDD typically starts with an acceptance or integration test that captures the user-visible behavior, then drops into unit tests as you implement the pieces inside. The acceptance test stays red until everything below it is done; the unit tests turn green one at a time on the way.

If the existing codebase has strong conventions about test levels, follow them. Look at how similar features were tested before.

## Scope discipline

The ticket has an explicit scope. Stay inside it.

When you find yourself wanting to:

- **Fix unrelated bugs** — note them in your PR description (see 'Producing the PR description' below), but don't fix them in this PR. They're separate tickets.
- **Refactor adjacent code** — if it's needed to make your ticket clean, do the minimum needed and call it out. If it's just "this code could be better," don't.
- **Add features the ticket doesn't ask for** — don't. Future tickets will do that. Adding speculative features is how scope creep starts.
- **Question the design** — if the design has a real problem, stop, surface it to the user, and let the architect revisit. Don't silently work around it.

The hardest part of scope discipline is when the ticket's acceptance criteria seem to require something the design doesn't cover. When this happens, it's a signal to pause, not to invent. Either the criteria are wrong, the design is wrong, or you're misreading something. Surface the conflict to the user.

## When to pause

Stop and ask before proceeding when:

- An acceptance criterion is ambiguous — ask for clarification before writing code
- Implementation reveals a genuine conflict with the design — name it, don't work around it
- An error or unexpected state suggests a design assumption is wrong — report before guessing

When pausing, structure your message:

**Paused on:** [task or acceptance criterion]
**Issue:** [one sentence]
**Options:**
1. [option A]
2. [option B]

What would you like to do?

## Code quality bar

Code that ships from this phase should be:

- **Code style.** Read [code-style.md](code-style.md) for the two style principles — clear over clever and dead-weight free. Adhere to both.
- **Consistent with the existing codebase.** Follow established patterns unless you have a reason to deviate, and if you deviate, document why.
- **Architecture principles respected.** Read [architecture-principles.md](architecture-principles.md) for the structural standards — screaming architecture (domain-first organization), deep modules, and adapter boundaries. Adhere to all three. If placing a file in a layered structure due to existing codebase conventions, note the tension in the PR description.
- **Named from the ubiquitous language.** Identifiers should use the canonical terms from `UBIQUITOUS_LANGUAGE.md`. Don't invent synonyms for concepts the project already has names for.
- **Well-tested at appropriate levels.** Every behavior the ticket adds is covered by at least one test. Edge cases the ticket explicitly mentions are covered.
- **Correctness, security, observability, performance.** Read [code-quality-dimensions.md](code-quality-dimensions.md) §Tier 2. Address these while writing — the reviewer will check them, but that is a safety net, not a plan.
- **Documented where non-obvious.** Comments explain why, not what. The code itself should make the "what" clear.
- **Honest about uncertainty.** If you couldn't fully verify something works in production conditions, say so in the PR description.

## Things to verify before declaring done

A ticket isn't done because the code compiles. Walk through this list:

- [ ] Every acceptance criterion in the ticket is met. Read them again — don't trust your memory.
- [ ] Tests cover the new behavior at the levels specified.
- [ ] The whole test suite passes, not just the new tests.
- [ ] Lint and type-check pass.
- [ ] If a build / format step exists, it's been run.
- [ ] Commits are small, focused, and have meaningful messages.
- [ ] Documentation updated if the ticket required it.
- [ ] Feature flag set up correctly if the ticket required it.
- [ ] No commented-out code, no `console.log`/`print` debugging artifacts, no TODOs about this ticket left behind.
- [ ] If a migration was added, you've tested both the up and down paths (for append-only migrations where "down" is not meaningful, test the rollback procedure as described in the ticket's acceptance criteria instead).
- [ ] New files are placed in domain-organized paths, or the structural choice is explicitly noted in the PR description.
- [ ] Ticket status updated to `Done` in the ticket file.

## When tests are hard to write

If you can't figure out how to test something, that's usually a design signal. See [interface-design.md](interface-design.md) for testable interface patterns. Common causes:

- **Tight coupling** — the code under test depends on too much. Inject the dependencies, or extract the testable logic.
- **Hidden state** — global state, singletons, time, randomness. Make these explicit and injectable.
- **Wrong abstraction level** — you might be trying to test at the wrong granularity. Drop to a unit test or rise to an integration test.
- **Genuinely hard things** — concurrency, network conditions, UI rendering. There are patterns for each; if you're stuck after consulting interface-design.md, surface the problem in the PR description as a blocker and stop rather than writing untested code.

If a piece of code resists testing entirely, that's a strong signal something is wrong with its design. Pause and surface it.

## Working with existing tests

If your changes legitimately need to update existing tests (e.g., a function signature changed), do so deliberately. But be suspicious: if you find yourself updating existing tests that are unrelated to the behavior your ticket changes — more than one or two, or tests in different modules — that's a signal you may be breaking behavior you shouldn't be.

## Producing the PR description

When the ticket is done, write a PR description (or summary) that includes:

- **What this ticket does.** One paragraph, plain language.
- **Acceptance criteria check.** A copy of the ticket's checklist with each item ticked off and a brief note on how it's satisfied.
- **What was tested and how.** What level of tests, what was covered, what wasn't (if anything was deliberately excluded, say why).
- **Anything notable.** Tradeoffs you made, surprises you encountered, things the reviewer should pay extra attention to.
- **Things you noticed but did NOT fix.** Before adding these, collect them and use the `Agent` tool with `subagent_type: "general-purpose"` to hand them to boy-scout. The agent's self-contained prompt should be:

  > Invoke the `boy-scout` skill. The following incidental findings were noticed during implementation of ticket `<ticket-name>` for feature slug `<slug>`:
  >
  > `<paste the list of findings here, one per line, each with file path and description>`
  >
  > Triage each finding: apply trivially safe fixes immediately; write a ticket at `docs/features/boy-scout/tickets/` for everything else. The `Noticed during` field should read: "implementation of `<ticket-name>` for `<slug>`".

  After the subagent finishes, read `docs/features/boy-scout/tickets/` to find the ticket numbers it created. List those here by number, not as free-form observations.
- **Follow-up tickets needed.** If implementation surfaced work that should happen next, note it.

## What you do not produce

- Designs (the architect already produced them; if a design problem comes up, surface it)
- Tickets for *planned* work (note what's needed; let the planner ticket it later) — but use the `boy-scout` skill to create tickets for incidental cleanup finds rather than just noting them in the PR description
- Sweeping refactors of unrelated code

## After implementation

When the TDD loop is complete and all items on the "Things to verify" checklist are done, your job is finished. Do **not** spawn a review subagent — the orchestrator handles review and continuation. Do **not** scan for the next ticket.

End your response with a summary that includes, as the final item, a clearly labeled list of every commit hash from this ticket's implementation:

**Commit hashes:** `<hash1>`, `<hash2>`, ...

The orchestrator reads this summary to pass the hashes to the reviewer. Format matters — use the exact heading above.
