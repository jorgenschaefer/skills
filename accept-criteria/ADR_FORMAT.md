# ADR format

Which decisions earn an architecture decision record, and the shape of one: one choice, the alternatives that were live when it was made, and what it costs. `/find-criteria` and `/criteria-to-tickets` write the ratified record on the person's yes, while the argument for it is still in context. `/critique` reads them, and so does anyone planning the next change.

## When to write one

An ADR outlives the feature that produced it and the criteria that carried it, so a record is rare. Write one only when a later change made without it would harm the project - by undoing or re-deciding this choice without a fact or argument the code cannot carry - and no comment, test or structure in the code can guard against that. Harm means concrete damage: lost data, broken operations, a costly mistake repeated. Taste, style and tidiness are not harm.

It takes one of two shapes:

- **Looks wrong, and fixing it does damage.** A competent developer or agent reading the code would take the choice for a mistake and "fix" it, or add the obvious missing piece - a cache, an ORM, a volume - and doing so would cause harm. Uploaded files stored in Postgres rather than on a volume, because only the database is backed up, is one.
- **Contested, and will be re-proposed.** Harm, plus at least two of: the person argued it out themselves - an agent listing options and the person agreeing does not count; the losing option is likely to be proposed again; the winning reasons are specific to this project, not general best practice.

Not a record:

- What the code, schema or glossary already shows, even a domain model that took real thought.
- A surprising choice confined to one place. It gets a comment there.
- A design guideline for the change in front of you, such as "one writer per file". If it still holds later, the next design rediscovers it; if it does not, it should be free to drop it without overruling anything.
- A big, expensive choice that looks normal - Postgres, an ORM - unless it is contested as above.
- Anything a test or the structure can enforce. Enforce it instead.

Anything else decided during a change belongs in `CRITERIA.md` or a ticket, which are deleted with the rest of the change's paper on acceptance.

When unsure, mention it in one line in the plan and write nothing unless the person says yes.

**Never write one unilaterally.** Put the decision and a recommendation to the person, and write the record only once they have said yes.

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
