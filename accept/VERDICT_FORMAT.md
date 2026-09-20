# Verdict format

```markdown
# Verdict: <accepted | rejected | abandoned>

## Conditions
<One row per condition in the intent, by id, with what establishes it:

- **C-1** met - the test that pins it, or what you did and what happened
- **C-2** not met - what is missing
- **C-3** unverifiable - why it cannot be checked

`unverifiable` is not a pass. It routes back to the intent: the condition was never observable, which is a defect in the problem statement rather than in the work.>

## Tradeoffs paid
<What the solution said this would cost, against what it cost. Not needed for the verdict; it is here because this page survives the paper, and a pattern of optimistic estimates is only visible across several of them.>

## Routing
<On a rejection, where the work goes back to and why:

- the problem was misframed - back to `/idea`
- the solution does not address it - back to `/solve`, the intent still holds
- a criterion nobody claimed went unbuilt - back to `/slice`
- the code does not match its ticket - back to `/implement`, and that is a hole in the review as well

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

## It judges against the intent as written

Against the conditions, by id, not against a reconstruction of what the problem probably was. A verdict that re-derives the problem drifts toward whatever was built, and then it agrees with the work by construction.
