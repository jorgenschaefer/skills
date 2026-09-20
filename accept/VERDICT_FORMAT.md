# Verdict format

`VERDICT_<TOPIC>.md`, beside the intent and the solution it judges, with the same topic they carry - `INTENT_NEW_PIPELINE.md` and `SOLUTION_NEW_PIPELINE.md` are judged by `VERDICT_NEW_PIPELINE.md`.

```markdown
# Verdict: <accepted | rejected | abandoned>

## Conditions
<One row per condition in the intent, by id, with what establishes it:

- **C-1** met - the test that pins it, or what you did and what happened
- **C-2** not met - what is missing
- **C-3** unverifiable - why it cannot be checked

`unverifiable` is not a pass. It routes back to the intent: the condition was never observable, which is a defect in the problem statement rather than in the work.>

## Tradeoffs paid
<What the solution said this would cost, against what it cost.

Its reader is whoever writes the next solution: `/solve` reads the verdicts already in the tree before it names its own tradeoffs, because a pattern of optimistic estimates is invisible inside any one of them and obvious across five.>

## Routing
<On a rejection, where the work goes back to and why:

- the problem was misframed - back to `/idea`
- the solution does not address it - back to `/solve`, the intent still holds
- a criterion nobody claimed went unbuilt - back to `/slice`
- the code does not match its ticket - back to `/implement`, and that is a hole in the review as well
- a condition cannot be checked at all - back to `/idea`: it was never observable

On an abandonment, why it was dropped. On an acceptance, omit.>

## What changed
<What the branch does now that it did not before, for whoever reads the pull request.>

## Look here
<Where a reviewer should spend their attention.>

## Still uncertain
<What nobody has established. An empty section is a claim; write it only if it is true.>
```

## Why this page and no other survives

The intent, the solution and the tickets are deleted when a run is accepted. This one is committed with the change, which makes it the only durable answer to *what was this for* - and the pull request description, because a reviewer needs the same three things a verdict already carries.

## What would show this stage is not worth running

`INTENT_WRONG_PROBLEM.md` was ratified on an argument rather than an instance, and carries the condition that would falsify it: verdicts that never once contradict what the per-ticket checks already established. The verdicts in the tree are where that is read off - which is the other reason this page survives, and why `## Conditions` records what established each one rather than only whether it held.

## It judges against the intent as written

Against the conditions, by id, not against a reconstruction of what the problem probably was. A verdict that re-derives the problem drifts toward whatever was built, and then it agrees with the work by construction.
