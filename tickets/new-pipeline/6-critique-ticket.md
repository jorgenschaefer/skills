---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-15
after:     5-implement
status:    review
attempts:  1
reviews:   0
---

## Build

Teach `/critique` to review a commit against a ticket and write `## Findings` into it,
without losing the thing it already is.

## Done when

> **AC-15** `/critique`, in a session of its own, reviews each commit against the ticket
> it was built from, and writes what it wants changed into that ticket.

## Context

`/critique` survives this rewrite deliberately: it is the review anyone can run by
hand on any branch or diff, and it must stay usable that way. Taking a ticket is an
additional mode, not a replacement for its existing one.

It reviews against the ticket, never against the solution or the problem. A reviewer
allowed to reopen "is this the right approach" makes the pipeline relitigate every
prior stage.

## Not here

Deciding what happens after findings — counting the round, resetting the status,
enforcing the ceiling — is the runner's, ticket 7.

## Record

`tests/build-contract.sh`, now 15 cases covering both sessions of the loop, invoked by
`tests/run.sh` (256 + 18 + 22 + 32 + 10 + 15, green). Four are new and one was red.

**AC-15's deliverable is `the review writes the ticket's Findings`** — red before the
change, green after.

**The three constraints around it, each mutation-tested.** `the review is never told to
read the solution`: appending "Read the `SOLUTION_X.md` the ticket names" fails it.
`the review never sets a status`: appending "Set `status: done` when the review is
clean" fails it. `the review still answers for a branch` guards the direction this
ticket could most easily break — narrowing a skill anyone can run into a pipeline
component.

Written the way the previous ticket's review forced: matching on the sentence, looking
for the imperative, and allowing the skill to *say* what it must not do.

**What the ticket mode adds beyond "review this diff".** The ticket is the standard and
the whole of it — `## Done when` is what the commit had to achieve, `## Not here` is
what it was not allowed to touch, and crossing that line is a finding even when the work
is good. And the `## Record` gets checked rather than trusted: the tests it names must
exist and must fail when the behaviour goes. A Record naming a test that passes with the
behaviour removed is the most serious finding available, because acceptance reads it as
evidence.

**Untested.** Everything the review actually does — whether it finds anything, whether
it refutes its own findings before filing them, whether it checks the Record rather than
reading it. Bash can hold the contract; it cannot hold the judgement.

**Not done here.** The runner reads the verdict and decides what follows — count a
round, set `doing` again, or `exhausted`. Ticket 7.
