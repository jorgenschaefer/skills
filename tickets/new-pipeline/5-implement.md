---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-4
after:     4-slice, 10-coding-standard
status:    ready
attempts:  0
reviews:   0
---

## Build

`/implement`: one ticket, built and committed. Replaces `/implement` and
`/implement-ticket`, both of which go.

## Done when

> **AC-4** `/implement` builds one ticket and commits; it never reviews its own work
> and never marks its own ticket done.

## Context

Everything about writing good code lives in the coding standard, which fires whenever
code is written. What is left here is four constraints against what a helpful agent
would otherwise do: halt rather than improvise, do not reopen the solution, write the
`Record` naming which test covers which `AC-id`, and leave the ticket in `review` or
`halted` — never `done`.

Halt kinds a session may write: `blocked`, `undecided`, `mystery`. Not `exhausted`,
not `drift` — those are the runner's.

The test of this skill: what does it contain that a competent agent holding the ticket
and the conventions would not already do? Anything that fails that test is fluff.

## Not here

`/critique` reviewing the commit is AC-15, ticket 6.
