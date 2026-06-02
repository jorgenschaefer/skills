---
name: implement
description: Use when the user says "implement this feature", "build X", "let's start coding", or hands you a discovery summary / spec and asks to build it. Expects: a feature description (preferably the output of the discovery skill). Produces: committed code, all tests green, reviewed.
---

# Implement

Your goal is to implement a feature end to end so it achieves what the user intended, using high-quality, maintainable code.

## Before starting

- Confirm the project's test command runs and the baseline is green. If there are known-failing tests, note which ones explicitly so a new red can be distinguished from pre-existing breakage. TDD assumes a working runner and a clean baseline; discovering otherwise mid-loop wastes a cycle.
- If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it and use those terms for any names introduced in code, tests, or commit messages.

## Process

Follow this process step by step.

1. **Read the feature description.** If anything is ambiguous, ask the user. If there is no written description (e.g. the user said "build X" in chat), write one before starting - either run the `discovery` skill, or summarise the request in the shape of a discovery summary, and confirm it with the user. The written description is the artifact step 5 will trace against.
2. **Plan the implementation.** Use `TaskCreate` to break the feature into tasks, decide order, and note dependencies. The task list is the source of truth for progress through steps 3-5 - completing the list and completing the feature are the same act. If during step 3 the plan turns out to be wrong, stop, update the task list, and tell the user what changed and why. Do not silently rewrite the plan.

   **Sizing implementation tasks:**
   - One user-visible change per task - typically one user story.
   - Combine trivial stories that share code; split a story that introduces multiple independent user-visible changes.
   - If a task can't be named as a verb-phrase about user-visible behavior, the slice is wrong.

   **Tail entries:** Append two fixed tail entries to the list: `Code review` and `Quality review` (steps 4 and 5). The verb-phrase rule does not apply to these.
3. **Implement each task in turn.** You MUST use the TDD red/green/refactor loop described in "Using TDD" below. A task is complete only when every behavior change you made traces to a test that failed first. If you can't name that test for some piece of the change, the task isn't done - write the missing red tests, watch them fail, then re-verify the implementation still satisfies them. Pure refactor steps within a task are exempt: they add no new behavior, and the existing green tests prove it's preserved.
4. **Code review.** Spawn a `general-purpose` subagent to code-review the entire feature once all tasks are complete. Address blockers and should-fixes. For Nits, use your own judgement. If the code review raises a non-nit issue that requires a code change, fix it and re-run the code review until it passes with only nits remaining.
5. **Quality review.** Spawn a `general-purpose` subagent for a traceability check. Pass it the written feature description from step 1 and the final code. Ask it to verify the implementation delivers the stated intent: success criteria met, non-goals respected, every user story and its acceptance criteria traceable to a test that would fail if the behavior were removed. This is not a code review - it is a check that the right thing was built. Address gaps before telling the user you are done.

### Using TDD

Follow Kent Beck's red/green/refactor loop in the smallest possible steps. Each phase is a separate test run. Bundling "write the test and implementation together, then run once green" is not TDD, even when the final artifacts look identical - the RED run is what proves the test actually exercises the behavior. Skip it and a passing test is evidence of nothing.

1. **RED.** Write one trivially small failing test for the next bit of behavior - including wiring, placement, conditional rendering, and prop pass-through (if the spec says "X appears above Y but not above Z," that placement needs a test). Run the test before writing any production code for that behavior, and confirm **the assertion itself fires and reports an expected/actual mismatch**. "Module not found", import errors, missing files, or syntax errors do not count as RED - they only prove the test couldn't run. If you hit one of those, add the minimal scaffolding (empty function, stub file, fixed import) until the assertion actually runs and fails, then proceed. If the test passes immediately, you wrote the production code first: revert it, confirm the test fails properly, then re-implement.
2. **GREEN.** Make it pass with the simplest change that could possibly work. Faking the answer with a constant is fine - the next test will force a real implementation. If you cannot see how to make GREEN pass with a small, obvious change, the test is too big or too ambitious: revert it and write a smaller test, or add a second test that triangulates toward the general solution.
3. **REFACTOR.** With tests green, remove duplication and improve the design. No new behavior. Re-run the tests.

Commit after each successful green or refactor step.

### Untestable boundaries

The call into a third-party SDK or the network/IO edge can't be driven by a unit test - but that never excuses leaving the feature unfinished. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested. Prefer this to either an elaborate fake that holds coverage at 100% while the real integration goes unbuilt, or dropping the dependency at the cost of untested code.

Do not stop at the seam: "you just need to implement the wrapper I created" is not a finished feature. Wire the real dependency in and confirm it works.

### Dependency versions

When adding a dependency, look up its current latest stable release (or latest LTS line, where the ecosystem distinguishes one) and use that. Do not rely on a version from memory - it is almost always stale.

### Code Quality

These rules are for *you, the implementing agent, while writing*. The final code review at step 4 applies the same rules independently.

Good, maintainable code is optimized for readability. The intent should always be obvious.

Order definitions top-down: the high-level, abstract code first, with helpers below the code that calls them. A reader meets a function before its details, and the file grows more detailed as they read down.

Co-locate a test with the file it tests rather than in a separate `tests/` tree (things that change together stay together), unless the project's existing layout clearly says otherwise.

Code should be in the simplest, most boring version that works.

Follow YAGNI religiously - in production code. Tests of spec-mandated behavior are not YAGNI candidates; write them even when the production logic looks trivial.

Apply Kent Beck's four rules of simple design, in priority order:

1. **Passes the tests.** Correct behavior comes first.
2. **Reveals intention.** Names and structure make the purpose obvious to the next reader.
3. **No duplication.** Each piece of knowledge has one representation.
4. **Fewest elements.** No classes, methods, or abstractions beyond what the first three rules require.
