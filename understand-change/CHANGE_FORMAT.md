# Change file format

`changes/YYYY-MM-DD-<slug>.md`. It holds what was agreed for one change, so it
can be built and checked. It is deleted when the change is done, so nothing in
it is read later as a rule. Git history keeps it.

```markdown
# <Title>

## Problem
<What is wrong, in the user's words, and one real instance.>

## Approach
<The general direction chosen. Also considered: <the others, one line each>.>

## Design
<What is costly to change: how the user moves through the task, the design
system, the data. Links to the mock-ups in changes/.>

## Decisions that matter
- <the decision> - held by <the code | a test of what | structure: what | docs/adr/NNNN-<slug>.md>

## Could wait
- <item> -> backlog
```

`understand-change` writes Problem, Approach and Could wait. `design-change`
adds Design and Decisions that matter: every decision it told or asked, each
with what holds it after the change file is gone. An empty section says
"None."
