---
name: check-against-spec
description: Drive a finished feature against the spec it was built from, the way its user would, and file a ticket for each gap. Runs after the ticket loop drains.
disable-model-invocation: true
---

# Check Against Spec

This is the acceptance. Not that the code is good - `/critique` owns that - but that the feature the spec describes is the feature that now exists, established the way anyone outside the code would establish it: by using it.

It is also the check with no human backstop. Per-ticket reviews only prove each ticket met the criteria it claimed; nothing before you proves the feature holds together, that a criterion nobody claimed didn't quietly go unbuilt, or that the sum of twelve correct tickets is the thing the user asked for.

## Drive it, don't read it

Every review before this one read code and judged it, yours included if you let it. Reading is how a feature comes to be twelve correct tickets that do not add up: each piece matches its description, and nobody ever started the thing.

So start it the way this project starts it - the dev command, the entry point, the test harness that boots it - and use it. Where the harness offers a `run` skill, it already knows this project's shape; otherwise the README's own instructions are the best account of how a person starts it.

**The spec's `## Journeys` are the script.** Each one gives a trigger, its steps in order, and where the last step puts the user down. Walk them in that order, as one sitting rather than as a checklist, and the criteria the stories claim get driven on the way past - in the sequence a user would meet them, which is the sequence that finds what twelve correct tickets do not add up to.

A server is a background process, and the rule against those is about ending a turn while something you started is still running. Start it, drive it, and kill it inside this turn - and kill it before you finish, or the next step's check command finds the port taken. Drive from a scratch directory outside the repository and leave the tree as you found it: acceptance that leaves the working tree dirty makes the run unacceptable, since `accept.sh` refuses a dirty tree.

Where nothing will start - no dev command, no fixtures, no way to reach the feature at all - that is one fact about the project rather than a verdict on each criterion. File it as a maintenance ticket, say in the report that the whole run was checked on evidence rather than driven, and use the fallback below throughout. A project the pipeline cannot start is a project it cannot accept, and the second run should not discover that again.

Adversarial throughout: assume the feature is unbuilt and try to prove it. A criterion counts as met only when an honest attempt to show it unmet fails - never because you read the code and it looked right, and never because a test with a promising name is green.

Two ways a criterion fails, and the second is the one that hides:

- **Nothing implements it.** Driving it finds this in seconds; reading the code can take an afternoon and still miss it.
- **Something implements it and no test pins it.** The behavior works today and nothing stops the next change from removing it. For every criterion you drove successfully, find the test that would fail if the behavior were deleted, and read the `Record` of the ticket that claimed it for the test it named. A behaviour one ticket pinned and a later ticket quietly unpinned surfaces here and nowhere earlier, since every build before you could see only its own diff - and where the later ticket loosened the test rather than escaping it, `Every test that left` below is what catches it. If you cannot name the test, the criterion is unmet even though the feature works in front of you.

  Name it; do not break the code to prove it. Editing source here would leave the tree dirty and unacceptable, and the criterion you cannot name a test for is already going to a remediation ticket, whose build breaks the behaviour under TDD where doing so is safe.

### Where nobody can drive it

Some criteria have no seat to sit in: a retry policy that needs the network to fail, an invariant that holds across states nobody can reach by hand, a performance budget, a migration that ran once.

The test is not whether driving is awkward. It is whether **no input a user could supply reaches this**, or whether it needs a failure you cannot cause. Setup, seeding, a slow boot, an unfamiliar client - those are the work, not an exemption. Where the test holds, fall back to code and test evidence: name the test that exercises it, or the code path and what makes it hold.

Both modes are required, and **which criterion got which is part of the report**. A criterion marked met with no account of how is one nobody checked. And count the fallbacks: past a handful, on a feature a user is supposed to be able to use, the finding is not about any one criterion - it is that this feature cannot be driven, and that is worth a ticket of its own.

## What to check

The argument is where the run's paper lives - the spec file, or the directory holding it and the `tickets/` beside it. Read the spec and the full diff of the run - every commit from the branch point.

**Spend the session on what nothing else could reach.** Two things may already be pinned, and where they are, they are pinned better than a reading would pin them: a journey with a test under `tests/workflows/` is walked at every ticket by the project's own check command, and a criterion whose ticket `Record` names the test that pins it was checked by execution in that build. Check that those are true rather than assuming them - a project may have ratified nothing, and a `Record` may name no test for a criterion its ticket claimed.

Where a journey is covered that way, confirm its test still passes and move on; drive the journeys that are not. Everything below is yours either way, because no earlier step can reach any of it: a per-ticket review is structurally blind to what no ticket claimed.

- **Every success criterion.** The spec's own account of the feature working as a whole, which no ticket claims and no criterion decomposes into. This is the one thing only an end-to-end drive can answer.
- **Every criterion (`US-N.M`).** Met, and pinned by a test that would fail without it.
- **Every constraint (`C-N`).** Verified the way the spec said it would be. A constraint with no check is a wish, and this is the last place that gets noticed.
- **Every non-goal.** Respected. Something the spec ruled out that got built anyway is a defect, not a bonus.
- **Every binding default (`D-n`).** Held to, by all of the tickets rather than most of them. A default marked binding is one several tickets were built on; one ticket quietly going its own way is invisible from inside every ticket including that one.
- **Every duplication-survey verdict.** The spec recorded, module by module, what this feature would reuse, extend, absorb, replace or deliberately sit beside. A `replace` or `absorb` the run did not carry out leaves the thing it was supposed to remove - file it.
- **Everything built that traces to nothing.** Behavior in the diff that no criterion asked for is either scope creep, something off the spec's `Later` list built early, or a fork the spec left silent. All three are findings: the first two to remove, the last for the human who reads the closing report to ratify.
- **Every test that left.** A test deleted, renamed away, or weakened over the run's diff - an assertion loosened, a case dropped, two suites consolidated into one that covers less. Coverage that existed before the run and does not exist after it is a gap even though it traces to no criterion here: the criterion it pinned belonged to a spec deleted when its own feature was accepted, so nothing you can read points at it. Consolidation is where this hides, because the diff reads as tidying.

That list is the orphan sweep, and it is the half of this check nothing else can do. A criterion nobody built, a constraint nobody verified, a non-goal somebody built anyway - each is invisible from inside every ticket in the run, because the ticket that would have noticed is the ticket that does not exist.

**Read the done tickets' `Record` sections as leads.** Each build wrote down what it decided where the spec was silent, which review findings it argued down, and what it noticed and deliberately did not fix. Those are places worth looking, and the third of them - what a build noticed and left open - is read by nothing else in the pipeline. They are not verdicts you inherit: the agent that wrote one is gone and cannot defend it, so verify each for yourself, adversarially, like anything else.

**The bar a gap has to clear.** Three things hold of every one, and a candidate that fails any is not a gap:

- **A constructed trigger** - the input or state that shows the criterion unmet, or the deletion the test failed to notice. Not an account of how it might be unmet.
- **A destination** - a numbered criterion, a constraint, a non-goal, a workflow test, or one of `coding-conventions`' `## Security` or `## Changing what already runs` properties, which bind whether or not the spec names them. Anything else is a new requirement, and it goes to `IDEAS.md` rather than into a ticket. Coverage that left during the run is the exception above: file it.
- **No reopening** - a gap that overturns a prior ticket's `Unresolved` adjudication on the same code may not be filed. Say in the report that you disagree and leave it there, for a human to rule on rather than the loop to rebuild.

Delegate breadth where the spec is large - a subagent per story, each hunting for the way its criteria fail. Dispatch them with `run_in_background: false`, batched into one message so they still run at once; detached, they hand you an `agentId` and the run ends before their reports arrive. You own the verdict. Treat it as a claim to verify: a clean result counts only when the report shows the review happened - what it checked and where.

## Output

**File a ticket for each gap.** Write it beside the tickets this run was built from – the caller names the directory, and `tickets/` beside the spec is only the default – as `NN-slug.md` in the shape `TICKET_FORMAT.md` specifies, numbered after the highest existing ticket, `status: todo`, `depends_on: []`. A gap filed where the loop doesn't read is a gap nothing builds, and the run finishes looking clean. `Satisfies` cites the criterion that failed. The gap is objective - a criterion is met or it isn't - so it goes back through the same loop that built everything else, with the same TDD and review discipline, rather than being patched by hand at the end.

Where closing the gap would reach a ratified workflow test, write the ticket's `## Workflow tests` section as you file it. The driver halts a build that touches one without it, and a remediation ticket is the case that most often needs it.

Name the ticket for the behavior that is missing, not for the failure: "Let a reviewer see the rejection reason", not "fix US-3.2 gap".

Where the gap is missing tooling rather than missing code, file it as a **maintenance ticket** - the format's third kind, which claims no criteria and whose contract is that nothing observable changed.

Where the gap is a missing *test* over working behavior, file it as a **remediation ticket** - the format's second kind, which names the defect because there is no new behavior to name. Say in it that the behavior already works: the implementer still writes the test RED first, which here means deliberately breaking the behavior to watch the test fail, then restoring it. A test written green against code that already works proves nothing.

**Report what you found**, whether or not you filed tickets. Per criterion: whether you drove it or fell back to evidence, what you did, and what came back. A silent pass and a pass with nothing to show look identical to whoever reads it next, and only one of them means anything - and the difference between "drove it, got the rejection with its reason" and "found a test called `test_rejection_reason`" is the whole of this step.

Then close with the verdict line, alone on the last line and in exactly this shape:

```
VERDICT: 3 gaps filed, 2 gaps reported, 0 standing disagreements, 5 criteria checked on evidence
```

Four counts, always all four, in that order, with those words whatever the numbers are - `1 gaps filed` rather than `1 gap filed`, and `0 gaps reported` rather than a field left out. It is read by machine, and English pluralisation is the kind of detail that turns a parse into a guess.

- **Gaps filed** - the tickets you wrote this pass, of all three kinds.
- **Gaps reported** - what you found and did not file because it has no destination under the bar: a test whose weakness traces to no criterion, a candidate that turned out to be a new requirement. Named here so a human weighs it rather than a loop building it.
- **Standing disagreements** - gaps that clear the bar's first two tests and that you refused to file because filing them would reopen a prior ticket's adjudication. A pass with none of the first count and one of this one is not a clean run, and this line is the only place that distinction survives: your tickets are what the caller sees, and this is the finding there is no ticket for.
- **Criteria checked on evidence** - how many you could not drive and fell back on. This is the fallback count the section above asks you to keep, and it is the one number nobody can recover from the tickets: a criterion checked by reading is a criterion nobody drove, and a report that does not say so reads exactly like one where every criterion was.

Only your tickets are otherwise read mechanically, so anything you decided not to file reaches the caller through this line or not at all. A caller that has to read the prose to learn what the acceptance established spends a whole second agent on it, and gets an answer that disagrees with yours about as often as people disagree about prose.

If you filed tickets, the loop runs again and `/check-against-spec` runs again after it. Expect that; a run that needs a second pass is working as designed, not failing - the count that decides anything is the one on the pass that files nothing.
