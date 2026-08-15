---
name: trace
description: Use to check a finished feature against the spec it was built from - every criterion met, every constraint verified, every non-goal respected. Runs after the ticket loop drains, and files a ticket for each gap it finds. Triggers on "/trace".
---

# Trace

Check that the right thing was built. Not that the code is good - `/critique` owns that - but that the feature the spec describes is the feature that now exists.

This is the check with no human backstop. Per-ticket reviews only prove each ticket met the criteria it claimed; nothing before you proves the feature holds together, that a criterion nobody claimed didn't quietly go unbuilt, or that the sum of twelve correct tickets is the thing the user asked for.

## Stance

Adversarial, throughout. Assume the feature is unbuilt and try to prove it. A criterion counts as met only when an honest attempt to show it unmet fails - never because you read the code and it looked right.

Two ways a criterion fails, and the second is the one that hides:

- **Nothing implements it.** Easy to find, easy to fix.
- **Something implements it and no test pins it.** The behavior works today and nothing stops the next change from removing it. For every criterion, find the test that would fail if the behavior were deleted. If you cannot name it, the criterion is unmet even though the feature appears to work.

## What to check

Read the spec and the full diff of the run - every commit from the branch point.

- **Every criterion (`US-N.M`).** Met, and pinned by a test that would fail without it.
- **Every constraint (`C-N`).** Verified the way the spec said it would be. A constraint with no check is a wish, and this is the last place that gets noticed.
- **Every non-goal.** Respected. Something the spec ruled out that got built anyway is a defect, not a bonus.
- **Everything built that traces to nothing.** Behavior in the diff that no criterion asked for is either scope creep or a fork the spec left silent. Both are findings: the first to remove, the second for the human to ratify at handover.

Delegate breadth where the spec is large - a subagent per story, each hunting for the way its criteria fail - but you own the verdict, and a subagent's clean report counts only when it shows what it checked and where.

## Check the tests mechanically, not by reading

The second failure mode - behavior that works with nothing pinning it - is the one you should not judge by eye. Deciding whether a test would notice a deletion means simulating that deletion, and a tool does it by execution instead of prediction. Every review before this one, including your own, is a model judging work a model produced; this is the one check in the pipeline that isn't.

**If the project already has a mutation testing tool configured**, run it over this run's diff - Stryker's `--since`, `mutmut`, PIT's incremental mode, `cargo-mutants`, Infection. Scope it to what changed: a whole-suite run is slow enough to be worth avoiding, and untouched code is not what you are checking.

Read surviving mutants as evidence, not as a score to chase:

- A survivor on behavior a criterion names means that criterion is unpinned. File a ticket - the gap is objective.
- A survivor anywhere else goes to handover as a finding, for a human to weigh.
- Never chase a score. Equivalent mutants cannot be killed by definition, and a loop trying to kill one writes absurd tests until something stops it.

**Where no such tool is configured**, fall back to the crude version: revert the non-test files in the run's diff, run the suite, confirm the new tests fail, then restore. It proves less - removing everything at once tends to produce import errors rather than assertion failures, which is exactly the evidence `/implement` refuses to accept as RED - but a suite that stays green with the feature deleted is damning however it was measured.

**Don't install tooling to satisfy this.** Adding a mutation framework is a change to the project, not a check on it, and that is not a decision to make from inside a review. Say in your report that the check was unavailable, so a clean result is never mistaken for a verified one.

## Output

**File a ticket for each gap.** Write it to `tickets/NN-slug.md` in the shape `TICKET_FORMAT.md` specifies, numbered after the highest existing ticket, `status: todo`, `depends_on: []`. `Satisfies` cites the criterion that failed. The gap is objective - a criterion is met or it isn't - so it goes back through the same loop that built everything else, with the same TDD and review discipline, rather than being patched by hand at the end.

Name the ticket for the behavior that is missing, not for the failure: "Let a reviewer see the rejection reason", not "fix US-3.2 gap".

Where the gap is a missing *test* over working behavior, file it as a **remediation ticket** - the format's second kind, which names the defect because there is no new behavior to name. Say in it that the behavior already works: the implementer still writes the test RED first, which here means deliberately breaking the behavior to watch the test fail, then restoring it. A test written green against code that already works proves nothing.

**Report what you found**, whether or not you filed tickets. Name the criteria you checked and how, so a clean result is evidence rather than an assertion. A silent pass and a pass with nothing to show look identical to whoever reads it next, and only one of them means anything.

If you filed tickets, the loop runs again and `/trace` runs again after it. Expect that; a run that needs a second pass is working as designed, not failing.
