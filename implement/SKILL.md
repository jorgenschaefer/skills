---
name: implement
description: Use for implementation work that changes behavior - building a feature, adding or altering functionality, or fixing a bug - whether or not the user names it ("implement X", "build X", "add X", "fix X", or a handed-over spec). Skip it for trivial or mechanical edits (a typo, rename, formatting, or config tweak) with no behavior to test. Expects or writes a short spec first.
---

# Implement

You are a senior software developer. Your goal is to implement a feature end to end so it achieves what the user intended, using high-quality, maintainable code.

## Before starting

- Confirm the project's test command runs and the baseline is green. If there are known-failing tests, note which ones explicitly so a new red can be distinguished from pre-existing breakage. TDD assumes a working runner and a clean baseline; discovering otherwise mid-loop wastes a cycle.
- If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it and use those terms for any names introduced in code, tests, or commit messages.
- Read the `coding-conventions` skill (`coding-conventions/SKILL.md`) - the quality standard you build to, and the rubric the code reviews (the per-task gate in step 3 and the code review in step 5) apply.

## Process

Follow this process step by step. Scale the plan to the feature: a single-story change may be one task, while a larger feature uses the full breakdown.

Five rules govern every review step – the task-scoped gate in step 3 and the two end reviews in steps 4 and 5:

- **Reviews run separately.** The quality review and code review always run as their own steps; never fold them together or skip them.
- **Reviews are adversarial.** Every review subagent takes a falsification stance: it assumes the work is broken, tries to break it, and counts a requirement satisfied only when an honest attempt to break it fails. Never a confirmation pass. Each step below names only what that review targets – this task's diff, the spec's criteria, the whole feature – and inherits the stance from here.
- **A review fix is normal work.** A fix arising from any review step follows the same RED-first loop as step 3 (write the failing test, watch it fail, then fix; only pure refactors skip it) and is logged like any implementation work.
- **Verify the review happened.** Treat every review subagent's verdict as a claim to verify, not proof: a clean or approved result counts only when the report shows the review actually happened – findings, or the checks it ran, cited to `file:line`, and the requirements it covered named. A bare 'looks good' with no such evidence is not a completed review; re-dispatch it. You don't redo the review yourself – you refuse to accept one that didn't demonstrably occur.
- **Don't pre-judge the reviewer.** When you construct a reviewer's prompt, don't pre-judge its findings – don't tell it what to conclude, what not to flag, or that a choice was already settled so it should accept it. Hand it the requirements and let it judge; adjudicate any false positive in the review loop, not by steering the reviewer before it starts.

1. **Read the feature description.** The ideal input is a complete contract – a `/discovery` master, a `/discovery-increment` slice, or a `/propose-change` plan – where every behavior a wrong default could hurt already carries a given/when/then criterion; build to those criteria, and if one is missing send it back to `/discovery` rather than inventing it. If anything else is ambiguous, ask the user. If there is no written description (e.g. the user said "build X" in chat), write one before starting – a short spec covering intent, success criteria, non-goals, and the user stories with their acceptance criteria – and confirm it with the user. The written description is the artifact step 4 will trace against.
2. **Plan the implementation.** Use `TaskCreate` to break the feature into tasks, decide order, and note dependencies. The task list is the source of truth for progress through steps 3-5 – completing the list and completing the feature are the same act. If during step 3 the plan turns out to be wrong, stop, update the task list, and tell the user what changed and why. Do not silently rewrite the plan.

   **Identify modules and boundaries:** Note which modules the change touches, what new files or functions it needs, and where they live, so integration work isn't missed.

   **Verifiable goals:** Transform imperative tasks into verifiable goals. Instead of "add validation", use "given/when/then" to specify the expected behavior and its test. This makes it easier to know when a task is done, and to verify the implementation in step 4.

   **Sizing implementation tasks:**
   - One user-visible change per task – typically one user story.
   - Combine trivial stories that share code; split a story that introduces multiple independent user-visible changes.
   - If a task can't be named as a verb-phrase about user-visible behavior, the slice is wrong.

   **Tail entries:** Append two fixed tail entries to the list: `Quality review` and `Code review` (steps 4 and 5). The verb-phrase rule does not apply to these.
3. **Implement each task in turn.** You MUST use the TDD red/green/refactor loop described in "Using TDD" below. A task is complete only when every behavior change traces to a test that failed first and now pins it: the test would fail if that behavior were removed. If you can't name that test, the task isn't done. Pure refactor steps within a task are exempt: they add no new behavior, and the existing green tests prove it's preserved.

   As you work, keep the **decision log** described below: append an entry the moment you make a non-obvious implementation-level design decision, while the reasoning is still fresh.

   If a task cannot be made green for a reason TDD can't resolve – a genuine blocker like missing information, a spec contradiction, or an external dependency that doesn't behave as specified – stop and surface it to the user. Do not fake a passing test or expand scope to work around it. If instead a task won't go green because behavior is failing in a way you don't understand – a defect or mystery, not a missing-information blocker – use `/debug` to find the root cause before thrashing on fixes.

   **Task-scoped review before the next task.** After a task's commit, and before starting the next, dispatch a fresh `general-purpose` subagent to review just that task's diff (from the commit before the task to its latest commit). Give it two jobs: spec compliance for *this task's* requirements – for each, try to find where it is unmet (nothing missing, nothing extra, the right thing built) – and code quality of the diff, judged against `coding-conventions/SKILL.md`, which it must read for the rubric. Keep it task-scoped: the whole-feature Quality and Code reviews still run once at the end; this gate only stops a task's defect from compounding into the tasks built on top of it. Group findings as Blockers / Should-fix / Nits; fix Blockers and Should-fixes RED-first as in this step and re-review until only Nits remain, then move on – judgement on Nits.

   When every task is complete, run the full test suite and confirm it is green before moving to review. Per-step runs don't prove the whole feature still holds together.
4. **Quality review.** Spawn a `general-purpose` subagent for a traceability check. Pass it the written feature description from step 1 and the final code. For each success criterion and each acceptance criterion the spec states – in a `/propose-change` plan these are its `Done when` list – have it try to find a case where the implementation does not satisfy it, or a test that would still pass if the behavior were deleted. It should also confirm any non-goals are respected. This is not a code review – it is a check that the right thing was built. Run it first of the two: a gap here means new behavior to implement, and that new code should then pass under the code review that follows rather than escaping it. Address gaps before continuing.

   **Collect the discretionary decisions.** The same pass yields a second output for free. Every behavior that traces to no acceptance criterion is either something extra that shouldn't be there (a gap, flagged above) or a fork the spec left silent and the implementation had to settle anyway. Ask the subagent to read the diff with fresh eyes and list every spec-silent fork it finds, *independent of the decision log*, then reconcile the two: the log is your self-report of the choices you noticed making; the subagent's list catches the forks you never recognized as decisions – the blind spot a self-kept log cannot cover on its own. Together they give the discretionary list you hand the user at step 5's close: the spec-silent forks you logged, plus those the subagent caught that you didn't. A log entry that instead records a *deviation* from something the spec did say is not a discretionary call – it is a compliance question the traceability check above already owns. Do not adjudicate these against the spec – by definition it is silent, so whether each default matches intent is the user's call, not the reviewer's.
5. **Code review.** Spawn a `general-purpose` subagent to code-review the whole feature with fresh context. Give it an explicit rubric: have it read `coding-conventions/SKILL.md` and apply those standards on top of its own judgement, plus a check that every behavior change is pinned by a test that would fail if the behavior were removed. Ask it to group findings as **Blockers** (must fix before this is acceptable), **Should-fix** (real problems worth addressing), and **Nits** (minor), each with a `file:line` and why it matters. Address blockers and should-fixes; for nits, use your own judgement. If the review raises a non-nit issue that requires a code change, fix it and re-run the review until it passes with only nits remaining. Because no review follows this one, if a fix here changes behavior, confirm it still satisfies the spec's acceptance criteria before telling the user you are done.

   **Hand-off: sign off the discretionary calls.** Close by presenting the discretionary list from step 4 to the user – each spec-silent fork with the choice you made and why, anchored to a `file:line`. This is the one thing neither review can settle for you: where the spec is silent, whether the default matches intent is the user's call, and a different answer means rework, so surface it now rather than after they discover it. If the list came out empty, say so rather than omitting it silently.

### Using TDD

Follow Kent Beck's red/green/refactor loop in the smallest possible steps. Each phase is a separate test run. Bundling "write the test and implementation together, then run once green" is not TDD, even when the final artifacts look identical – the RED run is what proves the test actually exercises the behavior. Skip it and a passing test is evidence of nothing.

1. **RED.** Write one trivially small failing test for the next bit of behavior – including wiring, placement, conditional rendering, and prop pass-through (if the spec says "X appears above Y but not above Z," that placement needs a test). Run the test before writing any production code for that behavior, and confirm **the assertion itself fires and reports an expected/actual mismatch**. "Module not found", import errors, missing files, or syntax errors do not count as RED – they only prove the test couldn't run. If you hit one of those, add the minimal scaffolding (empty function, stub file, fixed import) until the assertion actually runs and fails, then proceed. If the test passes immediately, you wrote the production code first: revert it, confirm the test fails properly, then re-implement.
2. **GREEN.** Make it pass with the simplest change that could possibly work. Faking the answer with a constant is fine – the next test will force a real implementation. If you cannot see how to make GREEN pass with a small, obvious change, the test is too big or too ambitious: revert it and write a smaller test, or add a second test that triangulates toward the general solution.
3. **REFACTOR.** With tests green, remove duplication and improve the design. No new behavior. Re-run the tests.

Commit once per completed task, after its tests are green and any refactor is done – run the red/green/refactor cycles internally and bundle them into a single clean commit. Don't commit at each individual green step.

### Decision log

The log has one job: to carry the design choices you make while implementing – the ones that leave no trace in the finished code, like a rejected alternative or a default picked under silence – into step 4's reconciliation, where they join the forks a fresh reviewer finds and go to the user for sign-off. Writing an entry also forces you to state the tradeoff while you are in it, which sometimes catches a bad default at the moment of choice. It is not audited or re-judged on its own; a self-report cannot be its own check.

Implementing a feature means making many micro-decisions. Most are trivial or forced and must stay out of the log. Append an entry only when one of these objective triggers holds – not when a decision merely *felt* uncertain, since the ones that most need a second look are often the ones you were wrongly sure of (those you will miss, which is exactly why step 4's fresh-eyes audit is the backstop and not this log):

- the spec or plan was silent or ambiguous here and you chose a default;
- you rejected a plausible alternative;
- the choice deviates from the plan or spec;
- the choice has cross-cutting consequences – a data shape, an API or contract, a name other code depends on.

Do not log TDD process (which test to write next, faking a constant with the next test in mind); that is rhythm, not design. And never use the log to invent past a spec-level ambiguity – those are not yours to settle: ask the user or send it back to `/discovery`, exactly as step 1 requires. The log is for implementation-level design choices that legitimately belong to you.

Append each entry the moment you make the decision, not reconstructed at the end – late reconstruction is rationalisation, and what matters is the reasoning you actually had at the time. One line per entry, anchored to a `file:line` or task: *facing A, chose B because C; rejected D because E.* Let relevance, not a length limit, bound the log – a good trigger filter keeps it short on its own.

### Untestable boundaries

The call into a third-party SDK or the network/IO edge can't be driven by a unit test. Handle it the way `coding-conventions` prescribes for untestable boundaries, rather than an elaborate fake that holds coverage at 100% while the real integration goes unbuilt.

But that never excuses leaving the feature unfinished. Do not stop at the seam: "you just need to implement the wrapper I created" is not a finished feature. Wire the real dependency in and confirm it works.

### Acting on review findings

A finding – from the per-task gate, the end reviews, or the user – is a claim to evaluate, not an order to execute. Before you change code for it:

- **Verify it's right for this code.** Confirm the finding actually holds here before fixing. If it's wrong – it misreads the code, breaks something that must keep working, or doesn't apply to this stack – push back with technical reasoning instead of complying. A reviewer, yours or human, can be wrong; adjudicate, don't obey.
- **YAGNI-check "do it properly."** When a finding asks you to build something out more fully, confirm it's actually needed – if nothing uses it, say so and don't add it.
- **Clarify before you start.** If any finding in a batch is unclear, resolve that first; a partial understanding produces the wrong fix. Don't fix half the batch and guess at the rest.

Don't perform agreement. No "you're absolutely right," no reflexive thanks – state the fix you're making, or the reasoned pushback, and move on. The code and the test are the acknowledgement.

### Code Quality

Build to the standards in the `coding-conventions` skill (`coding-conventions/SKILL.md`) - simple design, structure and locality, domain layering, clarity, test coverage, and security - on top of your own judgement. It is the single source of truth for what good code is here, and the rubric the per-task gate (step 3) and the code review (step 5) apply.
