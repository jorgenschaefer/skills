---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-4
after:     4-slice, 10-coding-standard
status:    done
attempts:  1
reviews:   1
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

**AC-4's two prohibitions are the testable part, and are tested — after the review
found that two of the cases had never worked at all.** See `## Findings`. `the session is
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

## Findings

One review round, eight findings. Seven taken, one recorded.

**Two of the ten cases had never detected anything, and the proof was already on
disk.** The `exhausted` and `drift` ownership cases matched `writes \`kind\`` or
`raise \`kind\`` — case-sensitive, verb-specific — and the *old* skill said "halt
\`drift\`", an explicit instruction to raise the runner's halt, and passed. A case that
green-lights the exact text it was written to reject is worse than no case: it reports
coverage where there is none.

**The headline prohibition was evadable three ways.** The filter excluded a line
containing "never", so `Never leave it dirty: set \`status: done\`.` passed; so did
`When the checks pass and the runner owns nothing further, set \`status: done\`.`; and
so did `Mark the ticket done in the frontmatter`, which never uses the literal string.
All three now fail. The cases match on the *sentence* rather than the line, and look
for the imperative rather than the token — because a skill is allowed to say what it
must not do, and that is precisely what made the naive version blind.

The `review`/`halted` cases were direction-blind too: appending `Never write
\`status: review\`` left them green. They now fail on a skill that instructs and
disclaims the same thing, because a document can contradict itself in two sentences and
the reader remembers the later one.

**Two constraints had been dropped with no home and no mention.** Respecting the
ticket's `## Not here` — building the neighbouring slice is not generosity, it is two
tickets building the same code — and staging only the files the ticket touched, never
`git add -A`, which existed nowhere else in the repo. Both restored.

**The rework pass was unspecified.** `/critique` writes `## Findings` and the runner
re-runs the build, and the skill said nothing about what a second invocation is
building. It does now, with the boundary: a finding is not a licence to reopen what the
ticket asks for. The commit was also under-specified — it now says the ticket file goes
in with the code, so the evidence and the work arrive as one change.

**The TDD gap is parked where it survives.** It was recorded only in this ticket's
`Record`, and `/accept` deletes the paper. `IDEAS.md` now carries it: the loop is in
`/implement`, the design doc says it belongs in the standard, and code written outside a
ticket gets the outcome rules with no instruction to arrive at them test-first.

**`implement-ticket` described a skill that no longer exists** — naming halts the new
`/implement` does not raise and two reviews it does not run. Ticket 10's review
established that "deleted in ticket 12" is not a defence for a live dangling reference,
so it now says at the top that it is superseded and that nothing below was updated.

**Recorded, not fixed.** Several things left with the old skill and are gone
deliberately: the decision log, the design pass over the whole diff, "do not stop at the
seam". The first is the one worth watching — the old skill called it the only channel
between an unattended run and a person, and a fork below the `undecided` bar now reaches
nobody.
