# Change file format

`changes/YYYY-MM-DD-<slug>.md`. It holds what was agreed for one change, so it
can be built and checked. It is deleted when the change is done, so nothing in
it is read later as a rule. Git history keeps it.

```markdown
# <Title>

## Problem
<What is wrong, in the user's words, and one real instance.>

## Approach
<The approach chosen. Also considered: <the others, one line each>.>

## Design
<What was agreed about how it looks and behaves, if anything.>

## Decisions that matter
- docs/adr/NNNN-<slug>.md (new | replaced)

## Could wait
- <item> -> backlog
```

An empty section says "None." `decide` fills in `## Decisions that matter`.
