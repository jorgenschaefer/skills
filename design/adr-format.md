ADRs use this structure:

```markdown
# ADR <NNNN>: <Title>

**Status:** Proposed | Accepted | Superseded by ADR-XXXX
**Date:** <YYYY-MM-DD>
**Context:** Link to Design Doc or Feature Brief

## Context
What's the situation. What problem does this decision address. What constraints apply.

## Decision
What we're going to do. One or two sentences in the active voice.

## Alternatives considered
Each alternative gets a short paragraph: what it is, why it's plausible, why we didn't pick it.

## Consequences
What becomes easier. What becomes harder. What we're committing to. What this forecloses.
```

ADR numbering is sequential across the whole repo. Before writing a new ADR, read all existing ADRs in `docs/adr/` to find the next number and to verify your proposed design doesn't contradict an accepted decision. If it does, address the contradiction explicitly — either write an ADR that supersedes the old one, or revise your design to respect the existing decision and explain the constraint in the Risks section.
