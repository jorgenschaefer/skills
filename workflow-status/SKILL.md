---
name: workflow-status
description: Use this skill when the user wants to know where a feature is in the workflow — what phase it's in, what artifacts exist, what the latest review verdict was, and what the next step is. Trigger when the user says things like "what's the status of feature X", "where are we with slug Y", "what phase is Z in", "what's been done for this feature", or picks up work in progress and wants to orient themselves. The feature slug is a required argument.
---

# Workflow Status

This skill reads the artifacts for a feature and reports its current state: what exists, what phase the work is in, what reviews have been completed and what they found, and what the logical next step is.

## Before starting

The feature slug is a required argument. If the user did not provide one, ask for it before proceeding.

## How to read the state

Check `docs/features/<slug>/` for the following artifacts in order. Report what exists and what's missing.

| Artifact | Path | Produced by |
|---|---|---|
| Feature Brief | `discovery.md` | discovery |
| Refactoring Proposal | `refactoring.md` | refactor-project |
| Design Doc | `design.md` | design |
| Ticket Backlog | `tickets/` directory | planning |
| Brief review(s) | `discovery-review-NN.md` | review/discovery |
| Design review(s) | `design-review-NN.md` | review/design |
| Ticket review(s) | `tickets-review-NN.md` | review/planning |
| Implementation review(s) | `implementation-review-NN.md` | review/implementation |

Also check `docs/adr/` for any ADRs whose filename contains the slug.

## Determine the current phase

The feature is in the phase whose primary artifact exists but is not yet complete or has not yet advanced:

1. **Discovery** — `discovery.md` missing or `discovery-review-NN.md` has verdict "Block" or "Request changes"
2. **Design** — `discovery.md` exists and approved; `design.md` missing or `design-review-NN.md` verdict not "Approve"
3. **Planning** — `design.md` exists and approved; `tickets/` missing or `tickets-review-NN.md` verdict not "Approve"
4. **Implementation** — `tickets/` exists and approved; at least one ticket exists without a corresponding approved implementation review
5. **Complete** — all tickets have approved implementation reviews

Use judgment when reviews are missing (assume the phase is still in progress) or when verdicts are mixed.

## Output

Report to the conversation (not a file) in this format:

```
## Status: <feature slug>

**Current phase:** <Discovery | Design | Planning | Implementation | Complete>
**Next step:** <one sentence — what skill to run or what action to take>

### Artifacts
- [x] Feature Brief (`discovery.md`) — <one phrase: date, or last review verdict>
- [ ] Design Doc — missing
- [x] Ticket Backlog — <N tickets>
...

### Latest review verdicts
- Discovery review: <Approve / Request changes / Block / none>
- Design review: <Approve / Request changes / Block / none>
- Tickets review: <Approve / Request changes / Block / none>
- Implementation reviews: <N of M tickets reviewed>

### ADRs
<list of ADR files for this slug, or "none found">
```

Keep the output concise. If the user wants detail on a specific artifact or review, they can open the file.
