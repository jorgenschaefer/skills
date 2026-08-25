# ADR format

The shape of an architecture decision record: one choice, the alternatives that were live when it was made, and what it costs. `/discovery` writes them, `/spec-to-tickets` and `/critique` read them.

An ADR is permanent-tier. It outlives the feature that produced it and the spec that carried it, so it is never written autonomously - the decision and a recommendation are put to the user, and the ADR exists only once they say yes to it. What does not clear that bar is an implementation decision and belongs in the spec, where it is deleted with the rest of the paper on acceptance.

## Where they live

`docs/adr/NNNN-kebab-title.md`, numbered from `0001` in the order they were accepted. A project that already keeps ADRs somewhere else keeps them there - follow what is in the repository rather than moving it.

Numbers are never reused and never renumbered: an ADR is cited by number and path - from other ADRs, from a spec's `## ADRs`, and from comments in the code it explains. A superseded ADR stays where it is with its status changed and the record that replaced it named, because the reasoning that was superseded is half of why the new decision is right.

There is no status for a decision that has quietly stopped fitting. One that no longer holds is answered by a new record saying what holds now, and becomes `Superseded by` it - so the question "does this still apply?" is settled in writing by whoever asked it rather than left as a suspicion in the file.

## The record

```markdown
# NNNN. <the decision, as a short statement - "Store money as integer cents", not "Money representation">

- **Status:** Accepted | Superseded by [NNNN](NNNN-slug.md)
- **Date:** <YYYY-MM-DD, the day it was accepted>

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
