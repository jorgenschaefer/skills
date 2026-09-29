# ADR format

The shape of an architecture decision record: one choice, the alternatives that were live when it was made, and what it costs. `CODING_STANDARDS.md` says which decisions earn one and that the decision goes to a person first; `/find-criteria` and `/criteria-to-tickets` write the ratified record on their yes, while the argument for it is still in context. `/critique` reads them, and so does anyone planning the next change.

An ADR is permanent-tier. It outlives the feature that produced it and the criteria that carried it, so it is never written autonomously - the decision and a recommendation are put to the user, and the ADR exists only once they say yes to it. What does not clear that bar is an implementation decision and belongs in `CRITERIA.md` or a ticket, where it is deleted with the rest of the change's paper on acceptance.

## Where they live

`docs/adr/NNNN-kebab-title.md`, numbered from `0001` in the order they were accepted. Never in the change's own directory: that is deleted on acceptance, and an ADR outlives the change that produced it.

Numbers are never reused: an ADR is cited by number and path - from other ADRs and from comments in the code it explains - and a reused number points those citations at a decision they were not written about.

A decision that changes is rewritten in place to say what holds now, and the decision it replaces moves into `## Alternatives` with why it lost this time. A decision that no longer applies at all is deleted, and its number goes with it. Either way, find every citation of it - its number and its filename, in the code and the other ADRs - and fix them in the same change. The file says what holds; git says what used to.

## The record

```markdown
# NNNN. <the decision, as a short statement - "Store money as integer cents", not "Money representation">

- **Status:** Accepted
- **Date:** <YYYY-MM-DD, the day it was last decided>

## Context

<What made this a decision rather than a default: the forces in tension, what the system already does, what is about to change. Enough that a reader who was not there can tell whether the forces still hold, which is the only way anyone can judge whether this decision is still the right one.>

## Decision

<What was chosen, in the present tense and as an instruction: "Money is stored as integer cents in the smallest currency unit." One decision per record.>

## Alternatives

- **<The option not taken>** - <why it was live, and what ruled it out.>

## Consequences

<What this buys and what it costs, both stated plainly. A record with only benefits was written to justify a decision already made rather than to record one, and it will not help the reader who has to decide whether to overturn it.>
```

## Worked example

```markdown
# 0004. Store money as integer minor units

- **Status:** Accepted
- **Date:** 2026-03-11

## Context

Prices, refunds and tax are currently floats. Two rounding bugs reached
customers this quarter, and the invoicing work about to start multiplies and
splits amounts far more than anything before it.

## Decision

Money is stored, passed and computed as an integer count of the currency's
minor unit. Formatting to a decimal string happens at the display edge only.

## Alternatives

- **Decimal type** - exact, and the obvious answer in a language with one in
  its standard library. Ours does not, and the third-party decimal we would
  depend on is unmaintained.
- **Float with rounding at the boundary** - no migration. It is what we have,
  and it is what produced both bugs.

## Consequences

Arithmetic is exact and comparisons are safe. Every existing column, API field
and fixture needs migrating, and currencies without minor units become a
special case at the display edge rather than in the data.
```
