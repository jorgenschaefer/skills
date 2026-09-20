---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-2
after:     1-intent-format
status:    done
attempts:  1
reviews:   1
---

## Build

`/solve`, replacing `/to-solution`: an intent in, a solution spec out, with the
tradeoff sections required rather than optional, and a prose entry path.

## Done when

> **AC-2** `/solve` produces `SOLUTION_<TOPIC>.md` with required `Accepted tradeoffs`
> and `Ruled out` sections, and acceptance criteria `AC-n` each tagged with the `C-n`
> they serve. Given prose instead of an intent file, it derives the conditions first,
> stops for confirmation, and only then forms an approach.

## Context

`SOLUTION_NEW_PIPELINE.md` is a worked example. Note it answers two intents, so its
tags are qualified (`cost:C-1`, `problem:C-1`) — the format has to allow that.

The ordering on the prose path is the whole point: conditions derived after an
approach exists describe the approach. `/solve` must also refuse the prose path and
hand back to `/idea` when the conditions cannot be stated observably.

## Not here

The lean format drops `## Domain`, ubiquitous language, `## ADRs`, the defaults tiers
and `## Journeys` from `to-solution/SOLUTION_FORMAT.md`. Dropping them is this
ticket's business; the software-design skill that picks up domain language and ADRs is
not, and is not in this run at all.

## Record

`tests/solution-format.sh`, 20 cases, invoked by `tests/run.sh` (253 + 16 + 20, green).

**AC-2, the format half** — `the template specifies ## Intent`, `## Approach`,
`## Behaviour`, `## Accepted tradeoffs`, `## Ruled out`; `the template numbers the
criteria`; `the template tags criteria with conditions`; and four cases asserting the
dropped machinery stays dropped — `the template drops ## Domain`, `## Journeys`,
`## Defaults`, `## ADRs`.

**AC-2, the conformance half** — `SOLUTION_NEW_PIPELINE.md conforms`, checking required
sections, contiguous `AC-n`, a condition tag on every criterion, and non-empty
`Accepted tradeoffs` and `Ruled out`. Plus `there are solutions to check`, so an empty
glob cannot report success.

**The checker itself** — `a well-formed solution passes`, `a gap in the criteria is
caught`, `an untagged criterion is caught`, `an empty tradeoff list is caught`. The
first of these failed on the first run and was right to: the tag regex accepted
`(cost:C-1)` but not plain `(C-1)`, so every unqualified tag in a future solution would
have been reported as missing.

**Untested, because it is instruction to a model.** The ordering rule on the prose path
— conditions derived and confirmed before an approach exists — is `### Given prose
instead of a file` in the skill. It is the single most important thing this skill does
and no bash case can hold it to it. Same for the refusal back to `/idea`, and for
designing genuinely different candidates rather than one answer at three sizes.

**A name.** The format is `solve/SOLVE_FORMAT.md`. `SOLUTION_FORMAT.md` would collide
with the superseded copies in `to-solution/` and `spec-to-tickets/`, which the repo
requires to be byte-identical; the first attempt used `FORMAT.md`, which dodged the
collision by falling outside both format guards — including the one checking that a
skill ships the format it tells the agent to read. `SOLVE_FORMAT.md` is unique and
stays inside both.

**Not done here.** `/to-solution` is untouched, including its reference to the intent's
`## Proposed outcome`, a section ticket 1 deleted. It is already
`disable-model-invocation: true`, so it does not compete with `/solve` for discovery,
and ticket 12 deletes it.

## Findings

One review round. Eight findings, seven taken.

**Fixed, and it was the serious one.** The conformance checker could be bypassed by
indentation: the "criteria exist" assertion grepped the whole `## Behaviour` body while
the loop enforcing contiguity and tags matched only top-level bullets, so a solution
with every criterion indented and every tag stripped passed 17 of 17. The two counts
are now compared, and a criterion the loop cannot see is a failure rather than a
silence.

**Fixed.** `SOLVE_FORMAT.md` claimed "both directions are checked" while only criterion
→ condition was enforced. The reverse walk is now real: for every intent the solution
names, every `C-n` must be carried by some criterion. Writing it found two further bugs
in the checker — only the first tag of `(cost:C-1, cost:C-3)` was read, and `AC-1`
contains the substring `C-1`, so every criterion had been quietly satisfying the
condition of its own number. `SOLUTION_NEW_PIPELINE.md` passes the walk on its merits
now; before the fix its pass meant nothing.

**Fixed.** AC-2's own artifact name appeared nowhere in what was delivered — no
`SOLUTION_<TOPIC>.md`, no location question, no handoff. `## The record` now names the
file, and the ending points at the slicing.

**Fixed.** `/idea` still routed to `/to-solution`, so the stage handing off to this one
pointed at the skill it replaces. The README catalogue had no `solve` entry, and now
marks `to-solution` superseded.

**Fixed.** The suites duplicated about eighty lines of scaffold. `tests/format-lib.sh`
now holds the counting, the fenced-template extraction, section reading, and the two
guards every such suite needs. Done now rather than at the third copy.

**Taken in part.** `/to-solution`'s method was dropped wholesale without a note: the
decision criteria agreed before scoring, cheap specimens over descriptions, a candidate
floor including *do nothing*, the reuse survey. One is carried — agreeing what decides
before anything is scored, which is the same anti-post-hoc device as the ordering rule
this skill is built around. The rest stay dropped, deliberately: they are method rather
than shape, and this pipeline's bet is that an unproven practice is not worth its
instruction budget.
