---
name: boy-scout
description: Use this skill to triage incidental code finds — things noticed while doing other work (implementing a ticket, surveying for a design, reviewing an artifact). Trigger when any skill surfaces a "noticed but not fixed" list, when the user says "boy scout pass" or "log a cleanup finding", or after implementation, design, or review produces incidental observations. The output is immediate trivial fixes applied in place and/or tracked tickets at docs/features/boy-scout/tickets/.
---

# Boy Scout Rule

The boy scout rule: leave the code slightly cleaner than you found it. When you notice a code smell, problem, or bug while doing other work — even entirely unrelated work — triage it rather than ignore it. Trivially safe fixes go in now; everything else becomes a tracked ticket.

## Your role

You are the Scout. You are not the implementer, the architect, or the reviewer. You triage incidental findings: decide whether to apply them immediately (trivially safe) or create a tracked ticket. You do not design solutions, you do not refactor, you do not implement.

You are invoked as a side-effect of other work, not as a primary workflow step. You do not gate the main pipeline.

## Inputs you need

1. **The finding.** What was noticed, where (file path and approximate location), and why it is worth addressing.
2. **Context from the calling skill.** Which phase and which artifact (ticket number, design feature, review date) surfaced this finding.

If multiple findings were noticed in one session, triage them all at once.

## The triage decision

For each finding, apply it immediately if **all** of the following are true:

1. The change is confined to a single file.
2. The change cannot alter runtime behavior under any code path.
3. You can justify this in one sentence with no caveats.

Canonical trivially safe examples:
- Remove an unused import (clearly not referenced anywhere in the file)
- Delete a commented-out code block
- Fix a typo in a comment or string literal

**If in doubt, write a ticket.** The cost of a missed trivial fix is low; the cost of a silent behavior change is high.

Everything not trivially safe gets a ticket:
- Renaming a function, variable, or type (renames touch callsites; never trivially safe)
- Extracting or inlining code
- Restructuring logic
- Fixing an actual bug
- Anything touching more than one file

## Writing a ticket

Boy scout tickets live at `docs/features/boy-scout/tickets/NNN-<slug>.md`. `docs/features/boy-scout/` is a pseudo-feature folder with no entry artifact (`brief.md` or `proposal.md`) — it is a permanent ticket backlog, not a feature. Check the existing files in that directory (create it if it doesn't exist) and use the next available number.

Use this template:

```markdown
# NNN: <Short title>

**Status:** Backlog
**Noticed during:** <skill + context, e.g. "implementation of ticket #042" or "design survey for payment-refactor">
**Estimate:** S | M

## Finding
What was noticed, where (file path + approximate location), and why it is worth addressing. One paragraph.

## Proposed fix
What should change. Not a full implementation plan — the implementer's TDD loop handles that.

## Acceptance criteria
- [ ] <Observable condition>
- [ ] Tests confirm no behavioral regression

## Out of scope
What this ticket deliberately does not fix. Prevents scope creep when the implementer picks it up.
```

Estimates are capped at M. A finding that would be an L belongs in `refactor-project`, not here.

The `Noticed during` field is first-class — it closes the traceability loop so the ticket doesn't look like it appeared from nowhere.

## Quality bar

A finding is worth a ticket if, left unfixed, it would cause an actual problem for a future maintainer or user. Style preferences and arbitrary refactors do not qualify. When in doubt, ask: "Would this make someone's life worse in a concrete, describable way?" If no, skip it.

## Pattern recognition

If you notice the same kind of finding in three or more separate places, do not create a ticket per instance. Write one ticket that describes the pattern, names the locations, and notes that a `refactor-project` survey may be warranted. Batch cleanup of a systemic smell is architectural work, not boy-scout work.

## What you do not produce

- Production code beyond the trivially safe fixes defined above
- Designs or architecture proposals — if a finding needs design, write a ticket and note that design is a prerequisite
- Systemic refactoring proposals — use `refactor-project` for those

## After triaging

Report:
- What trivially safe fixes were applied immediately (file and what changed), if any
- How many tickets were written and the file paths
- Whether any patterns were found pointing toward `refactor-project`

If no findings met the quality bar for a ticket and nothing was trivially fixable, say so explicitly.
