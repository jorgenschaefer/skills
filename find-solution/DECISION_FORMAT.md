# Decision record format

The shape of a decision record: the problem it answers, the field that was live when it was answered, what was chosen, and what would overturn it. `/find-solution` offers one at the end of a run.

A record is never written autonomously. What it would say is put to the user - the problem, the criteria, the choice, the losers - and the file exists only once they say yes to it. Most decisions do not earn one: offer it when the decision cost real effort to reach, when more than one person lives with it, or when the reasoning will be invisible to whoever meets the result later.

## Where it lives

`DECISION_<topic>.md`, in the directory the decision is about - the repository it changes, the project folder it belongs to - with the path proposed and confirmed rather than assumed. A repository that already keeps decision records somewhere keeps them there.

A decision that has stopped fitting is answered by a new record saying what holds now, naming the one it replaces. The superseded record stays: the reasoning that was overtaken is half of why the new decision is right.

## The record

```markdown
# <the decision, as a short statement - "Run the newsletter on Buttondown", not "Newsletter tooling">

- **Date:** <YYYY-MM-DD>
- **Status:** Current | Superseded by <path>

## Problem

<What was actually wrong, in the words it was agreed in, with the instance
behind it: what happened, how often, what it cost. Not the solution with a
"there is no" in front of it.>

## Criteria

<What the candidates were ranked on, in the order that was agreed, and the
constraints that eliminated rather than ranked. A reader judging whether this
decision still holds is really asking whether these still hold.>

## Choice

<What was chosen, in the present tense. Where it was the user's call against
the recommendation, say so - that is what stops it being reopened as though
nobody had thought about it.>

## Field

- **<candidate>** - <what it was, and the criterion or constraint it lost on.>

## What would overturn it

<The load-bearing claims: what has to stay true for this to remain the right
answer, and what would make it wrong. A record with no overturning conditions
is an argument for a decision already made rather than a record of one.>
```

## Worked example

```markdown
# Keep invoices in the accountant's tool, not ours

- **Date:** 2026-04-02
- **Status:** Current

## Problem

Invoices are written by hand into a spreadsheet, then retyped by the
accountant. It happens about nine times a month and takes twenty minutes each
time, and in March two invoices went out with the wrong VAT rate because the
rate was copied from the previous row.

## Criteria

Ranked: correctness of the VAT handling, then the time the retyping costs,
then what it costs to run per year. Eliminating: it has to be something the
accountant already accepts, and no customer data leaves the EU.

## Choice

Invoices are raised in the accountant's existing tool, and we send them the
line items rather than a finished invoice. We build nothing.

## Field

- **Build invoicing into the admin app** - the original plan. Lost on
  correctness: VAT rules change yearly and we would own that forever.
- **An invoicing SaaS** - solves the retyping. Lost on the accountant
  constraint; they would still re-enter everything into their own system.
- **Do nothing** - lost on the VAT errors, which are the expensive half of the
  problem and would keep happening.

## What would overturn it

The accountant changing tools, or invoice volume passing roughly fifty a
month, where handing over line items stops being cheaper than raising them
ourselves.
```
