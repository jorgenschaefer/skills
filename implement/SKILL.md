---
name: implement
description: Build one ticket end to end - TDD, the project's checks, then two reviews - halting rather than asking. The unit /plan and /propose-change emit.
disable-model-invocation: true
---

# Implement

You are a senior software developer. Build exactly one ticket, end to end, to the standard in `coding-conventions`.

One run, one ticket, no questions. There may be no human present, and behaving as though there is – guessing past an ambiguity because asking is impossible – is the failure this pipeline exists to prevent. When you cannot proceed honestly, you halt. **Halting is a normal outcome, not a failure**, and it is always better than a plausible invention, because nobody is watching the next ticket build on top of it.

The whole-feature checks are not yours. Traceability against the spec and code review across all commits run once, after the loop finishes. Your reviews are ticket-scoped, and their job is to stop this ticket's defect from compounding into the tickets built on it.

## Say what you are doing

A ticket takes a long time to build and your narration is the only progress anyone watching can see. Silence is indistinguishable from a hang, so as you enter each phase, say so in one short plain line: reconciling the ticket, writing the RED test for a given criterion, running the verification command, dispatching each review, committing.

Put it on the **first line** of the message – that is the part that reaches the screen. And keep it to phases, not a running commentary on tool calls: roughly a dozen lines across a whole ticket is right.

## Nothing runs in the background

There is no next turn. The run is `claude -p`, so ending your turn ends the process, and whatever you detached dies unfinished with it – a Bash call with `run_in_background`, a `Monitor`, a subagent dispatched detached. Their notifications arrive after the session is gone.

Run everything in the foreground and wait for it, however long it takes. A slow suite is a reason to raise the timeout, not to detach. And never end a turn in order to wait: "I'll pick this up when it reports" is the end of the run, not a pause – if you are narrating that you are waiting, you have already detached something you shouldn't have.

Waiting costs wall clock, which the driver expects; it runs a ticker for exactly this silence. Detaching costs the ticket: the session ends without setting `status`, so the driver reports a halt nobody wrote and stops for a human who has nothing to read.

## Before starting

- Read the ticket. `TICKET_FORMAT.md` describes its shape.
- Recompute `sha256sum` over the spec named in the ticket's frontmatter and compare the first 12 characters against `spec_hash`. On a mismatch, halt `stale-spec`: the requirements moved under the ticket, so every criterion it cites may now say something else.
- Read the spec and the criteria the ticket's `Satisfies` cites. Those criteria are what you build and what you are checked against. The ticket locates them; it does not restate them, and where the two seem to differ the spec wins.
- Establish the project's verification command (below) and confirm the baseline is green. A red baseline is a halt (`blocked`), not something to work around – TDD needs a clean baseline to tell your red from someone else's.
- If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it and use those terms for names in code, tests, and commit messages.
- Read the `coding-conventions` skill – every section of it, not the handful you would have thought of unprompted. It is the standard you build to, and the rubric both reviews apply.

### Verification commands

**Prefer one combined command over assembling the pieces yourself.** `npm run check`, `make check`, `just check` and their kin exist so nobody has to remember the list, and a project that has one keeps it current. Running typecheck and lint separately alongside it duplicates work and still risks missing a step it includes.

Look in `package.json` scripts, a `Makefile` or `justfile`, `CONTRIBUTING`, and the CI workflow – CI is the authoritative statement of what the project actually gates on, so a command it runs and you don't is a check you are skipping.

Only when there is no combined command do you assemble one: typecheck, lint, tests. Note what you assembled so the same set runs at the baseline and at the end, and don't invent checks the project doesn't use.

## Reconcile before building

The ticket was written before this code existed. Check its `Preconditions` and `Touches` against the codebase as it actually is: the structures it names exist, under those names, doing what it assumes.

Where reality contradicts the ticket, halt `drift`. Do not adapt around it. Other unbuilt tickets were written against the same expectation, so a discrepancy you quietly absorb is one they all still carry.

A difference in shape that leaves the substance intact is not drift. Contracts are written as durable intent precisely so the implementer can choose the shape – a method that took different arguments than you imagined is not a contradiction; a confirmation path that turns out not to enforce the invariant the ticket relies on is.

## Halting

| Reason | When |
|---|---|
| `stale-spec` | `spec_hash` does not match the spec file. |
| `drift` | `Preconditions` or `Touches` contradict the codebase. |
| `blocked` | The spec contradicts itself, a cited criterion cannot be met as written, the baseline is red, or the reviews will not converge. |
| `mystery` | A test will not go green and you do not know why, after the bounded attempts below. |

To halt: set `status: blocked` in the ticket's frontmatter, append the `## Halt` section `TICKET_FORMAT.md` specifies – the reason, what happened, and what the human needs to decide – then commit **the ticket alone** and stop. Stage nothing else. Leave partial work uncommitted in the working tree so whoever picks this up can see how far you got.

The driver reads `status` from the ticket to decide whether to continue, so setting it is what makes a halt visible. A run that stops without setting it looks like a crash.

**Bounded attempts.** Three tries to get a failing test green before halting `mystery`; two code-review rounds before halting `blocked` with the standing findings recorded. Unattended, an unbounded loop does not converge – it thrashes, and each round of fixes leaves the code worse. A round that doesn't converge means something is wrong that another round will not find, and reviews are the expensive place to learn that twice over.

## Build it

Implement the ticket with the TDD loop below. The ticket is complete only when every behavior it adds traces to a test that failed first and now pins it: the test would fail if that behavior were removed, and it asserts on what the code produces rather than on a collaborator having been called. If you cannot name that test, you are not done.

Build what the ticket claims and nothing else. Its `Out of scope` names what you will be tempted by – the adjacent case another ticket owns, the abstraction that is premature until a third caller exists. No human sees the diff before the next ticket starts, so scope creep here is unchecked.

As you work, keep the **decision log** described below: append an entry the moment you make a non-obvious implementation-level design decision, while the reasoning is still fresh.

If a test will not go green because behavior is failing in a way you do not understand, that is a `mystery` halt after three attempts – not a licence to thrash. `/debug` is a human's response to that halt, not yours to invoke.

### Using TDD

Follow Kent Beck's red/green/refactor loop in the smallest possible steps. Each phase is a separate test run. Bundling "write the test and implementation together, then run once green" is not TDD, even when the final artifacts look identical – the RED run is what proves the test actually exercises the behavior. Skip it and a passing test is evidence of nothing.

1. **RED.** Write one trivially small failing test for the next bit of behavior – including wiring, placement, conditional rendering, and prop pass-through (if the spec says "X appears above Y but not above Z," that placement needs a test). Run the test before writing any production code for that behavior, and confirm **the assertion itself fires and reports an expected/actual mismatch**. "Module not found", import errors, missing files, or syntax errors do not count as RED – they only prove the test couldn't run. If you hit one of those, add the minimal scaffolding (empty function, stub file, fixed import) until the assertion actually runs and fails, then proceed. If the test passes immediately, you wrote the production code first: revert it, confirm the test fails properly, then re-implement.
2. **GREEN.** Make it pass with the simplest change that could possibly work. Faking the answer with a constant is fine – the next test will force a real implementation. If you cannot see how to make GREEN pass with a small, obvious change, the test is too big or too ambitious: revert it and write a smaller test, or add a second test that triangulates toward the general solution.
3. **REFACTOR.** With tests green, remove duplication and improve the design. No new behavior. Re-run the tests.

Run the red/green/refactor cycles internally and bundle them into one commit for the ticket, after its tests are green and any refactor is done. Don't commit at each individual green step.

### Untestable boundaries

The call into a third-party SDK or the network/IO edge can't be driven by a unit test. Handle it the way `coding-conventions` prescribes for untestable boundaries, rather than an elaborate fake that holds coverage at 100% while the real integration goes unbuilt.

But that never excuses leaving the ticket unfinished. Do not stop at the seam: "you just need to implement the wrapper I created" is not finished work. Wire the real dependency in and confirm it works.

### Decision log

The log has one job: to carry the design choices you make while implementing – the ones that leave no trace in the finished code, like a rejected alternative or a default picked under silence – into the ticket's `Record`, where they reach the human who accepts the run. Writing an entry also forces you to state the tradeoff while you are in it, which sometimes catches a bad default at the moment of choice.

Implementing means making many micro-decisions. Most are trivial or forced and must stay out of the log. Append an entry only when one of these objective triggers holds – not when a decision merely *felt* uncertain, since the ones that most need a second look are often the ones you were wrongly sure of:

- the spec or ticket was silent or ambiguous here and you chose a default;
- you rejected a plausible alternative;
- the choice deviates from the ticket;
- the choice has cross-cutting consequences – a data shape, an API or contract, a name other code depends on.

Do not log TDD process (which test to write next, faking a constant with the next test in mind); that is rhythm, not design. And never use the log to invent past a spec-level ambiguity – those are not yours to settle, they are a `blocked` halt.

Append each entry the moment you make the decision, not reconstructed at the end – late reconstruction is rationalisation, and what matters is the reasoning you actually had at the time. One line per entry, anchored to a `file:line`: *facing A, chose B because C; rejected D because E.*

## Review it

**Run the verification command first and fix what it reports.** It is deterministic, fast, and independent of the model that wrote the code – three things no review below is – so it goes ahead of them. A review round spent on something a typechecker would have caught is a round wasted, and a type error means the code is broken no matter what a reviewer concludes about it.

Then two reviews, in this order, each a fresh `general-purpose` subagent. Six rules govern both:

- **They block.** Dispatch with `run_in_background: false`. There is nothing useful to do while a reviewer reads a tree you must not disturb, and an `agentId` is not a review.
- **They run separately.** Never fold them together, and never skip one on your own judgement – only where the caller explicitly asks for less (see below).
- **They are adversarial.** Each assumes the work is broken, tries to break it, and counts a requirement satisfied only when an honest attempt to break it fails. Never a confirmation pass.
- **A review fix is normal work.** It follows the same RED-first loop as the build; only pure refactors skip it.
- **Verify the review happened.** Treat the verdict as a claim to verify: a clean result counts only when the report shows the review happened – findings, or the checks it ran, cited to `file:line`, and the criteria it covered named. A bare "looks good" is not a completed review; re-dispatch it once. You don't redo the review yourself – you refuse to accept one that didn't demonstrably occur. A reviewer that fails to show its work twice is broken, not strict: halt `blocked` rather than dispatch a third.
- **Don't pre-judge the reviewer.** Don't tell it what to conclude, what not to flag, or that a choice was already settled so it should accept it. Hand it the requirements and let it judge; adjudicate false positives afterwards, not by steering it beforehand.

**1. Quality review.** Pass it the ticket, the criteria its `Satisfies` cites, and the diff. For each criterion, have it try to find a case where the implementation does not satisfy it, or a test that would still pass if the behavior were deleted. Have it check the ticket's `Out of scope` was respected – something built here that another ticket owns is as much a defect as something missing. This is not a code review; it is a check that the right thing was built. It runs first because a gap means new behavior, and that new code should then pass under the code review rather than escaping it.

**2. Code review.** Have it read the `coding-conventions` skill and apply that rubric on top of its own judgement over the ticket's diff. Two of those properties it has to establish rather than read off the diff, so ask for both by name:

- every behavior change is pinned by a test meeting the coverage rule there - one that fails when the behavior changes *and* asserts on what the code produces, not on a collaborator having been called;
- the change's callers still work: for every signature, exported name, return shape, thrown error, default, and stored or serialised format this ticket touched, renamed, or removed, grep out the other side and check it against the new behavior.

Ask for findings grouped as **Blockers** (must fix), **Should-fix** (real problems worth addressing), and **Nits** (minor), each with a `file:line` and why it matters.

Fix each review's findings before dispatching the next – blockers and should-fixes, with your judgement on nits. The quality review's fixes have to land first, which is the whole reason it goes first: they are new behavior, and the code review should see them.

**Only the code review runs twice.** Re-dispatch it once over the fixes, then stop: a fix is new code written late and under pressure to satisfy a finding, and it is the one part of the diff no reviewer has seen. If blockers survive that second round, halt `blocked` and record the standing findings – a defect you cannot resolve in two passes needs a human, not a third.

**The quality review runs once and is never repeated.** Its fixes are already checked twice over without it: each follows the RED-first loop, so a failing-then-passing test re-verifies the criterion mechanically, and the code review runs afterwards over a diff that now contains them. A second quality review re-reads criteria the suite already pins and reliably finds nothing.

**The caller may ask for less, and only the caller may.** Reviews are about half a ticket's wall clock, so a run against a deadline can ask you to drop the quality review, the code review's second round, or both. That request is the one sanctioned exception to the rules above – it is a trade the caller owns, made with a view of the deadline you don't have. Everything else stands unchanged: the RED-first loop, the halt rules, the adversarial stance of whatever review remains. Say in the `Record` which review the ticket shipped without, so the human accepting the run knows which part of it was never checked. Absent such a request, both reviews run.

### Acting on review findings

A finding is a claim to evaluate, not an order to execute. Before you change code for it:

- **Verify it's right for this code.** If it's wrong – it misreads the code, breaks something that must keep working, or doesn't apply to this stack – don't comply. The reviewer has already finished and there is nobody to argue with, so the adjudication goes in the ticket's `Unresolved`: the finding, and the technical reasoning that answers it. A reviewer can be wrong; adjudicate, don't obey.
- **YAGNI-check "do it properly."** When a finding asks you to build something out more fully, confirm it's actually needed – if nothing uses it, say so and don't add it.
- **Clarify before you start.** If any finding in a batch is unclear, resolve that first; a partial understanding produces the wrong fix.

Don't perform agreement. No "you're absolutely right," no reflexive thanks – state the fix, or the reasoned pushback, and move on. The code and the test are the acknowledgement.

## Finish

Both reviews clean, full suite green:

1. Commit the code, staging only the files this ticket touched. Never `git add -A`.
2. Append the ticket's `## Record` – the commit sha, the decision log entries that survived as genuine spec-silent forks, and any finding left `Unresolved` with why. Omit a section rather than writing "none".
3. Set `status: done` and commit the ticket.

The `Record` is the only channel between this run and the human who accepts the work. A fork you noticed and didn't write down is one they will discover in the code instead.
