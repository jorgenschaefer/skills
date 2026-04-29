Brownfield ADRs use this structure:

```markdown
# ADR <NNNN>: <Title>

**Status:** Accepted
**Date:** <YYYY-MM-DD>
**Context:** Retrospective — extracted from codebase

## Context

This ADR was extracted from the existing codebase. No prior design document exists for this decision.

[Describe what was observed in the code — where the decision is visible, what files or patterns show it, what the codebase commits to as a result.]

## Decision

[State what the codebase does, in the active voice. Do not invent rationale that isn't in the code, comments, or documentation.]

If the rationale is known (provided by the team):
> We use X because [reason].

If the rationale is unknown:
> We use X. (Reason: unknown — not evident from codebase or documentation.)

## Alternatives considered

[If the team provided this information, record it here.]

If unknown:
> Not recorded. This ADR documents an existing decision extracted from the codebase; the alternatives considered at the time of the original decision are unknown.

## Consequences

[What becomes easier. What becomes harder. What future engineers — and agents — are committed to. What is foreclosed. Be concrete: name the modules, patterns, or conventions that must stay consistent as a result of this decision.]
```

ADR numbering is sequential across the whole repo. Before writing, read all existing files in `docs/adr/` to find the next available number.
