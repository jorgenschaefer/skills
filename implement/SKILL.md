---
name: implement
description: Use when the user says "implement this feature", "build X", "let's start coding", or hands you a spec and asks to build it. Expects: a feature description (ideally a written spec). Produces: committed code, all tests green, reviewed.
---

# Implement

You are a senior software developer. Your goal is to implement a feature end to end so it achieves what the user intended, using high-quality, maintainable code.

## Before starting

- Confirm the project's test command runs and the baseline is green. If there are known-failing tests, note which ones explicitly so a new red can be distinguished from pre-existing breakage. TDD assumes a working runner and a clean baseline; discovering otherwise mid-loop wastes a cycle.
- If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it and use those terms for any names introduced in code, tests, or commit messages.

## Process

Follow this process step by step. Scale the plan to the feature: a single-story change may be one task, while a larger feature uses the full breakdown. The code review and quality review always run as their own steps; never fold them together or skip them.

1. **Read the feature description.** The ideal input is a complete contract - a `/discovery` master or a `/discovery-increment` slice - where every behavior a wrong default could hurt already carries a given/when/then criterion; build to those criteria, and if one is missing send it back to `/discovery` rather than inventing it. If anything else is ambiguous, ask the user. If there is no written description (e.g. the user said "build X" in chat), write one before starting - a short spec covering intent, success criteria, non-goals, and the user stories with their acceptance criteria - and confirm it with the user. The written description is the artifact step 5 will trace against.
2. **Plan the implementation.** Use `TaskCreate` to break the feature into tasks, decide order, and note dependencies. The task list is the source of truth for progress through steps 3-5 - completing the list and completing the feature are the same act. If during step 3 the plan turns out to be wrong, stop, update the task list, and tell the user what changed and why. Do not silently rewrite the plan.

   **Identify modules and boundaries:** Note which modules the change touches, what new files or functions it needs, and where they live, so integration work isn't missed.

   **Verifiable goals:** Transform imperative tasks into verifiable goals. Instead of "add validation", use "given/when/then" to specify the expected behavior and its test. This makes it easier to know when a task is done, and to verify the implementation in step 5.

   **Sizing implementation tasks:**
   - One user-visible change per task - typically one user story.
   - Combine trivial stories that share code; split a story that introduces multiple independent user-visible changes.
   - If a task can't be named as a verb-phrase about user-visible behavior, the slice is wrong.

   **Tail entries:** Append two fixed tail entries to the list: `Code review` and `Quality review` (steps 4 and 5). The verb-phrase rule does not apply to these.
3. **Implement each task in turn.** You MUST use the TDD red/green/refactor loop described in "Using TDD" below. A task is complete only when every behavior change traces to a test that failed first and now pins it: the test would fail if that behavior were removed. If you can't name that test, the task isn't done. Pure refactor steps within a task are exempt: they add no new behavior, and the existing green tests prove it's preserved.

   If a task cannot be made green for a reason TDD can't resolve - a genuine blocker like missing information, a spec contradiction, or an external dependency that doesn't behave as specified - stop and surface it to the user. Do not fake a passing test or expand scope to work around it.

   When every task is complete, run the full test suite and confirm it is green before moving to review. Per-step runs don't prove the whole feature still holds together.
4. **Code review.** Once all tasks are complete, spawn a `general-purpose` subagent to code-review the whole feature with fresh context. Give it an explicit rubric: the **Code Quality** standards below (Beck's four rules, YAGNI, and the structure rules), applied on top of its own judgement, plus a check that every behavior change is pinned by a test that would fail if the behavior were removed. Ask it to group findings as **Blockers** (must fix before this is acceptable), **Should-fix** (real problems worth addressing), and **Nits** (minor), each with a `file:line` and why it matters. Address blockers and should-fixes; for nits, use your own judgement. If the review raises a non-nit issue that requires a code change, fix it and re-run the review until it passes with only nits remaining. A fix that changes behavior follows the same RED-first loop as step 3 - write the failing test, watch it fail, then fix; only pure refactors skip it. This applies to step 5 as well.
5. **Quality review.** Spawn a `general-purpose` subagent for a traceability check. Pass it the written feature description from step 1 and the final code. Ask it to verify the implementation delivers the stated intent: success criteria met, non-goals respected, every user story and its acceptance criteria traceable to a test that would fail if the behavior were removed. This is not a code review - it is a check that the right thing was built. Address gaps before telling the user you are done.

### Using TDD

Follow Kent Beck's red/green/refactor loop in the smallest possible steps. Each phase is a separate test run. Bundling "write the test and implementation together, then run once green" is not TDD, even when the final artifacts look identical - the RED run is what proves the test actually exercises the behavior. Skip it and a passing test is evidence of nothing.

1. **RED.** Write one trivially small failing test for the next bit of behavior - including wiring, placement, conditional rendering, and prop pass-through (if the spec says "X appears above Y but not above Z," that placement needs a test). Run the test before writing any production code for that behavior, and confirm **the assertion itself fires and reports an expected/actual mismatch**. "Module not found", import errors, missing files, or syntax errors do not count as RED - they only prove the test couldn't run. If you hit one of those, add the minimal scaffolding (empty function, stub file, fixed import) until the assertion actually runs and fails, then proceed. If the test passes immediately, you wrote the production code first: revert it, confirm the test fails properly, then re-implement.
2. **GREEN.** Make it pass with the simplest change that could possibly work. Faking the answer with a constant is fine - the next test will force a real implementation. If you cannot see how to make GREEN pass with a small, obvious change, the test is too big or too ambitious: revert it and write a smaller test, or add a second test that triangulates toward the general solution.
3. **REFACTOR.** With tests green, remove duplication and improve the design. No new behavior. Re-run the tests.

Commit once per completed task, after its tests are green and any refactor is done - run the red/green/refactor cycles internally and bundle them into a single clean commit. Don't commit at each individual green step.

### Untestable boundaries

The call into a third-party SDK or the network/IO edge can't be driven by a unit test - but that never excuses leaving the feature unfinished. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested. Prefer this to either an elaborate fake that holds coverage at 100% while the real integration goes unbuilt, or dropping the dependency at the cost of untested code.

Do not stop at the seam: "you just need to implement the wrapper I created" is not a finished feature. Wire the real dependency in and confirm it works.

### Dependency versions

When adding a dependency, look up its current latest stable release (or latest LTS line, where the ecosystem distinguishes one) and use that. Do not rely on a version from memory - it is almost always stale.

### Code Quality

Apply Kent Beck's four rules of simple design, in priority order:

1. **Passes the tests.** Correct behavior comes first.
2. **Reveals intention.** Names and structure make the purpose obvious to the next reader.
3. **No duplication.** Each piece of knowledge has one representation.
4. **Fewest elements.** No classes, methods, or abstractions beyond what the first three rules require.

Follow YAGNI religiously in production code: minimum code that solves the problem, nothing speculative, in the simplest and most boring version that works - prefer the conventional solution over the clever one. Tests of spec-mandated behavior are not YAGNI candidates; write them even when the production logic looks trivial.

Keep related code together. Code that changes together should live close together - same file, then same module, then same directory. Having to jump between distant locations to follow one piece of logic is a smell; the further the jump, the worse it is. Not a bug, but something to reduce. Concrete applications:

- **Feature-based modules.** Combine a feature's code into the same module, each feature in its own directory or file, rather than splitting by type (all controllers in one directory, all models in another).
- **Co-locate tests.** Put a test next to the file it tests, not in a separate `tests/` tree - unless the project's existing layout clearly says otherwise.
- **Top-down order.** High-level code first, helpers below the code that calls them, so a reader meets a function before its details.
