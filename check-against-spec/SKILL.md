---
name: check-against-spec
description: Check a finished feature against the spec it was built from, and file a ticket for each gap. Runs after the ticket loop drains.
disable-model-invocation: true
---

# Check Against Spec

Check that the right thing was built. Not that the code is good - `/critique` owns that - but that the feature the spec describes is the feature that now exists.

This is the check with no human backstop. Per-ticket reviews only prove each ticket met the criteria it claimed; nothing before you proves the feature holds together, that a criterion nobody claimed didn't quietly go unbuilt, or that the sum of twelve correct tickets is the thing the user asked for.

## Stance

Adversarial, throughout. Assume the feature is unbuilt and try to prove it. A criterion counts as met only when an honest attempt to show it unmet fails - never because you read the code and it looked right.

Two ways a criterion fails, and the second is the one that hides:

- **Nothing implements it.** Easy to find, easy to fix.
- **Something implements it and no test pins it.** The behavior works today and nothing stops the next change from removing it. For every criterion, find the test that would fail if the behavior were deleted. If you cannot name it, the criterion is unmet even though the feature appears to work.

## What to check

The argument is where the run's paper lives - the spec file, or the directory holding it and the `tickets/` beside it. Read the spec and the full diff of the run - every commit from the branch point.

- **Every criterion (`US-N.M`).** Met, and pinned by a test that would fail without it.
- **Every constraint (`C-N`).** Verified the way the spec said it would be. A constraint with no check is a wish, and this is the last place that gets noticed.
- **Every non-goal.** Respected. Something the spec ruled out that got built anyway is a defect, not a bonus.
- **Everything built that traces to nothing.** Behavior in the diff that no criterion asked for is either scope creep or a fork the spec left silent. Both are findings: the first to remove, the second for the human who reads the closing report to ratify.
- **Every test that left.** A test deleted, renamed away, or weakened over the run's diff - an assertion loosened, a case dropped, two suites consolidated into one that covers less. Coverage that existed before the run and does not exist after it is a gap even though it traces to no criterion here: the criterion it pinned belonged to a spec deleted when its own feature was accepted, so nothing you can read points at it. Consolidation is where this hides, because the diff reads as tidying.

**Read the done tickets' `Record` sections as leads.** Each build wrote down what it decided where the spec was silent, which review findings it argued down, and what it noticed and deliberately did not fix. Those are places worth looking, and the third of them - what a build noticed and left open - is read by nothing else in the pipeline. They are not verdicts you inherit: the agent that wrote one is gone and cannot defend it, so verify each for yourself, adversarially, like anything else.

**The bar a gap has to clear.** Three things hold of every one, and a candidate that fails any is not a gap:

- **A constructed trigger** - the input or state that shows the criterion unmet, or the deletion the test failed to notice. Not an account of how it might be unmet.
- **A destination** - a numbered criterion, a constraint, a non-goal, a workflow test, or one of `coding-conventions`' `## Security` or `## Changing what already runs` properties, which bind whether or not the spec names them. Anything else is a new requirement, and it goes to `IDEAS.md` rather than into a ticket. Coverage that left during the run is the exception above: file it.
- **No reopening** - a gap that overturns a prior ticket's `Unresolved` adjudication on the same code may not be filed. Say in the report that you disagree and leave it there, for a human to rule on rather than the loop to rebuild.

Delegate breadth where the spec is large - a subagent per story, each hunting for the way its criteria fail. Dispatch them with `run_in_background: false`, batched into one message so they still run at once; detached, they hand you an `agentId` and the run ends before their reports arrive. You own the verdict. Treat it as a claim to verify: a clean result counts only when the report shows the review happened - what it checked and where.

## Check the tests mechanically, not by reading

The second failure mode - behavior that works with nothing pinning it - is the one you should not judge by eye. Deciding whether a test would notice a deletion means simulating that deletion, and a tool does it by execution instead of prediction. Every review before this one, including your own, is a model judging work a model produced. The per-ticket gate and this one are the exceptions, and this is the only one that sees the whole run at once.

**If the project already has a mutation testing tool configured**, run it over this run's diff - Stryker's `--since`, `mutmut`, PIT's incremental mode, `cargo-mutants`, Infection. Scope it to what changed: a whole-suite run is slow enough to be worth avoiding, and untouched code is not what you are checking.

Read surviving mutants as evidence, not as a score to chase:

- A survivor on behaviour the bar can name - a criterion, a constraint, a non-goal, a workflow test, or one of `coding-conventions`' `## Security` or `## Changing what already runs` properties - means that thing is unpinned. File a ticket; the gap is objective.
- A survivor anywhere else has no destination under the bar, so it is not a ticket. Report it for a human to weigh. Mutants are not a finite set - every codebase has an unbounded supply of them on code nobody promised anything about - and a gate without that limit is the relitigation the bar exists to stop.
- Never chase a score. Equivalent mutants cannot be killed by definition, and a loop trying to kill one writes absurd tests until something stops it.

**Where no such tool is configured**, fall back to the crude version: revert the non-test files in the run's diff, run the suite, confirm the new tests fail, then restore. It proves less - removing everything at once tends to produce import errors rather than assertion failures, which is exactly the evidence `/implement` refuses to accept as RED - but a suite that stays green with the feature deleted is damning however it was measured.

**Where the project has no tool**, file its setup as a maintenance ticket and use the fallback for this run. Adding a framework is a change to the project rather than a check on it, so it goes through the same build and the same reviews as any other change - once, and every run after this one has the gate at every ticket. This is the one gap you file that traces to no criterion: the bar's destination rule cannot see a check that does not exist yet, and leaving it unfiled is what has kept most projects on a fallback this skill itself calls "proves less". Say in your report that the real check was unavailable this time, so a clean result is never mistaken for a verified one.

Where the tooling was there, each ticket has already run the same gate over its own diff. Yours is the sweep across the whole run, which sees what one ticket's tests pinned and a later ticket's change quietly unpinned - visible from nowhere else.

## Output

**File a ticket for each gap.** Write it beside the tickets this run was built from – the caller names the directory, and `tickets/` beside the spec is only the default – as `NN-slug.md` in the shape `TICKET_FORMAT.md` specifies, numbered after the highest existing ticket, `status: todo`, `depends_on: []`. A gap filed where the loop doesn't read is a gap nothing builds, and the run finishes looking clean. `Satisfies` cites the criterion that failed. The gap is objective - a criterion is met or it isn't - so it goes back through the same loop that built everything else, with the same TDD and review discipline, rather than being patched by hand at the end.

Where closing the gap would reach a ratified workflow test, write the ticket's `## Workflow tests` section as you file it. The driver halts a build that touches one without it, and a remediation ticket is the case that most often needs it.

Name the ticket for the behavior that is missing, not for the failure: "Let a reviewer see the rejection reason", not "fix US-3.2 gap".

Where the gap is missing tooling rather than missing code, file it as a **maintenance ticket** - the format's third kind, which claims no criteria and whose contract is that nothing observable changed.

Where the gap is a missing *test* over working behavior, file it as a **remediation ticket** - the format's second kind, which names the defect because there is no new behavior to name. Say in it that the behavior already works: the implementer still writes the test RED first, which here means deliberately breaking the behavior to watch the test fail, then restoring it. A test written green against code that already works proves nothing.

**Report what you found**, whether or not you filed tickets. Name the criteria you checked and how, so a clean result is evidence rather than an assertion. A silent pass and a pass with nothing to show look identical to whoever reads it next, and only one of them means anything.

If you filed tickets, the loop runs again and `/check-against-spec` runs again after it. Expect that; a run that needs a second pass is working as designed, not failing.
