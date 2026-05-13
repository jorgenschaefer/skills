---
name: workflow-status
description: Use this skill when the user wants to know where a feature is in the workflow — what phase it's in, what artifacts exist, what the latest review verdict was, and what the next step is. Trigger when the user says things like "what's the status of feature X", "where are we with slug Y", "what phase is Z in", "what's been done for this feature", or picks up work in progress and wants to orient themselves. The feature slug is a required argument.
---

# Workflow Status

## Before starting

The feature slug is a required argument. If the user did not provide one, ask for it before proceeding.

## How to read the state

Check `docs/features/<slug>/` for the following artifacts in order. Report what exists and what's missing.

| Artifact | Path | Produced by |
|---|---|---|
| Feature Brief | `discovery.md` | discovery |
| Refactoring Proposal | `refactoring.md` | refactor-design |
| Refactoring Proposal review(s) | `refactor-design-review-NN.md` | refactor-design-review |
| Design Doc | `design.md` | design |
| Ticket Backlog | `tickets/` directory | planning |
| Brief review(s) | `discovery-review-NN.md` | discovery-review |
| Design review(s) | `design-review-NN.md` | design-review |
| Ticket review(s) | `tickets-review-NN.md` | planning-review |
| Implementation review(s) | `implementation-tdd-review-NN.md` | implementation-tdd-review |

## Determine the current phase

The feature is in the phase whose primary artifact exists but is not yet complete or has not yet advanced:

1. **Discovery** — `discovery.md` missing or `discovery-review-NN.md` has verdict "Block" or "Request changes"
1a. **Refactor Design** — alternative entry: `refactoring.md` exists but `refactor-design-review-NN.md` is missing or has verdict "Block" or "Request changes"
2. **Design** — `discovery.md` exists and its review approved; `design.md` missing or `design-review-NN.md` verdict not "Approve"
3. **Planning** — entry artifact (`design.md` or approved `refactoring.md`) exists; `tickets/` missing or `tickets-review-NN.md` verdict not "Approve"
4. **Implementation** — `tickets/` exists and approved; at least one ticket exists without a corresponding approved implementation review. To determine which tickets have approved reviews: read each `implementation-tdd-review-NN.md` file in the feature folder. Each review's **Artifact** header links to the ticket it covers. Check the verdict. A ticket is complete when its most recent review is Approve or Approve with comments.
5. **Complete** — all tickets have approved implementation reviews

Use judgment when reviews are missing (assume the phase is still in progress) or when verdicts are mixed.

**Partial implementation:** If some tickets have approved implementation reviews and others don't, report as "Implementation (in progress): N of M tickets complete" and list which tickets are done vs pending.

**Stuck in review:** If the latest review for a phase has a "Block" or "Request changes" verdict and no newer artifact or review exists, flag it as "Stuck in review — address findings before proceeding" rather than treating it as in progress.

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
- Refactoring Proposal review: <Approve / Request changes / Block / none>
- Design review: <Approve / Request changes / Block / none>
- Tickets review: <Approve / Request changes / Block / none>
- Implementation reviews: <N of M tickets reviewed>
```

Keep the output concise. If the user wants detail on a specific artifact or review, they can open the file.
