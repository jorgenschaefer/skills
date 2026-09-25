# Intent format

```markdown
# Intent: <the problem, in a few words>

## Problem
<What is wrong and what would be true instead, with no mechanism in it. Who feels it. What it costs them belongs below, where it can be checked.>

## Evidence
<What makes this real: the last time it happened, what it cost, how often it recurs. Facts a reader can check, each one pointing at something they could go and look at - a file, a commit, a number. Where there is no instance, this section says so.>

## Done when
<The conditions that must hold for the problem to be solved, numbered:

- **C-1** <One condition, checkable true or false.>
- **C-2** <...>

The numbers are the intent's contract with everything downstream: acceptance walks them back, and a condition renumbered cannot be cited. They are never renumbered and never reused. A condition that no longer holds is deleted, and its number goes with it.>

## Constraints
<What disqualifies a candidate outright - a budget, a deadline, a property that must not break, what we are optimizing for. Each one says what it would kill. What only ranks the survivors is a criterion, and belongs to whoever chooses between them.>

## Not this
<Adjacent problems deliberately excluded, and the intent that owns them if one does. Omit when there are none.>

## User's solution
<The solution the user brought, in their words. Omit only when they genuinely arrived with a problem.>

## Open questions
<What could not be settled here. A question you did not ask does not belong. Omit when there are none.>
```
