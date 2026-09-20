# Intent format

```markdown
# Intent: <the problem, in a few words>

## Problem
<What is wrong and what would be true instead, with no mechanism in it. Who feels it. What it costs them belongs below, where it can be checked.>

## Evidence
<What makes this real: the last time it happened, what it cost, how often it recurs. Facts a reader can check, each one pointing at something they could go and look at - a file, a commit, a number.

Where there is no instance yet, say so plainly and say what makes the problem structural instead. Do not dress an argument up as an observation.>

## Done when
<The conditions that must hold for the problem to be solved, numbered:

- **C-1** <Stated so that someone could later check it true or false without asking you what you meant.>
- **C-2** <...>

Not the mechanism. If a condition would fail a solution that solved the problem a different way, it is a solution in disguise.

The numbers are the intent's contract with everything downstream: criteria tag them, tickets inherit those tags, the verdict walks them back. They are append-only - never renumbered, never reused, struck through rather than deleted.>

## Constraints
<What disqualifies a candidate outright - a budget, a deadline, a property that must not break, what we are optimizing for. Each one says what it would kill.

Test each: would it *kill* a candidate, or only score it lower? The second kind is a criterion, and belongs to whoever chooses between survivors.>

## Not this
<Adjacent problems deliberately excluded, and the intent that owns them if one does. Omit when there are none.>

## Whatever they arrived with
<The solution the user brought, in their words. Omit only when they genuinely arrived with a problem.>

## Open questions
<What could not be settled here. A question you did not ask does not belong. Omit when there are none.>

## Ratified
<Who confirmed they recognize their problem in this, and when.

Say what the yes was worth. Ratified *on evidence* means they can point at the instance. Ratified *on the argument* means they cannot, and were convinced the failure is real and would have left no trace - a weaker yes, which is recorded as weaker and carries a falsification condition: what would have to keep not happening for this to have been wrong.

Until someone has said yes, this section says so. An unratified intent is a draft, and nothing downstream should be built against it.>

## Routed back
<Appended by the acceptance stage each time a verdict sends the work back, with the date and the reason. Starts as "Nothing yet." A list that grows long is the sign that the intent, and not the work, is what needs changing.>
```

## Two things the shape is for

**The conditions make the last stage possible.** Acceptance asks whether the problem was solved, and it can only ask that against something written down before the solution existed. An unnumbered paragraph cannot be cited, cannot be walked, and cannot be found to have failed.

**The ratification makes the conditions binding.** They are the standard every later stage is measured against, so they need an owner who is accountable for them, and that is not whoever typed them.
