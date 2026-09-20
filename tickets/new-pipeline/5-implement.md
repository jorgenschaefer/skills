---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-4
after:     4-slice, 10-coding-standard
status:    review
attempts:  1
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

## Record

`tests/build-contract.sh`, 10 cases, invoked by `tests/run.sh` (256 + 18 + 22 + 32 + 9
+ 10, green). Five were red before the rewrite.

**AC-4's two prohibitions are the testable part, and are tested.** `the session is
never told to write status: done` — allowing the skill to *say* it never does, which is
different from instructing it. `the session is told to write status: review` and
`status: halted`, the only two ends it owns. `the review is named as another session's`.
Plus the halt kinds: it knows `blocked`, `undecided` and `mystery`, and is not told to
raise `exhausted` or `drift`, which belong to the runner because a session out of
attempts is not running and a session never reads the solution.

**The first version of two cases were false positives of my own making** — one grepped
for `status: done` anywhere, which the skill's own prohibition matched, and one looked
for a section name the skill did not use. Both were the test misreading, not the skill.

**TDD landed here, not in the standard.** Ticket 10 recorded that `coding-standard` has
no red/green/refactor rule — the original never had one, and that ticket's `## Not here`
forbade adding content. So the loop lives in `/implement`, with the RED-run argument
intact: the red run is the only thing that proves a test exercises the behaviour. That
is a defensible home, because it is a discipline for building to a criterion. It is
also not what `NEW_PIPELINE_IDEA.md` says, which has TDD in the standard, and the next
person to write code outside a ticket gets no instruction about it. Parked rather than
fixed here.

**What was carried from the old skill and what was not.** Carried: the red/green/refactor
loop, and *prove the contract* with "break it twice" — name the test, remove the
behaviour, then move its edge, because a test can notice a behaviour vanish and still
pass when a comparison shifts by one. Both are constraints against what an agent would
otherwise do, which is the bar this skill is held to. Dropped: the whole review section
and the review-findings loop, now `/critique`'s and the runner's; the standards
restatement, now `coding-standard`'s.

**Untested.** Every constraint that is prose: not opening the solution, halting rather
than working around, not reopening the approach, the TDD loop itself. Bash can check
that the skill says these things, which is what the ten cases do; nothing can check
that a session obeyed them.
