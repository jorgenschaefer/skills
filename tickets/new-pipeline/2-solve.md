---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-2
after:     1-intent-format
status:    review
attempts:  1
reviews:   0
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

`tests/solution-format.sh`, 17 cases, invoked by `tests/run.sh` (252 + 15 + 17, green).

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

**A name deferred.** The format is `solve/FORMAT.md`, not `SOLUTION_FORMAT.md`. The
repo requires every copy of a shared format file to be byte-identical, and the
superseded copies in `to-solution/` and `spec-to-tickets/` still carry that name with
the old shape. Renaming it here would have meant either breaking the pipeline that
still works or weakening the guard that caught it. The name comes back in ticket 12.

**Not done here.** `/to-solution` is untouched, including its reference to the intent's
`## Proposed outcome`, a section ticket 1 deleted. It is already
`disable-model-invocation: true`, so it does not compete with `/solve` for discovery,
and ticket 12 deletes it.
