---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-5, AC-11
after:     7-runner, 11-software-design
status:    done
attempts:  1
reviews:   1
---

## Build

`/accept`: the verdict, and the deletion. Replaces `/check-against-spec`, `/handover`
and `accept.sh`, all of which go.

## Done when

> **AC-5** `/accept` uses the finished feature, walks the `C-n` conditions, and emits
> `VERDICT_<TOPIC>.md` with a routing destination on rejection. It is the only stage
> that judges against the problem rather than against the previous artifact.

> **AC-11** On acceptance the paper is deleted in one commit, after promoting anything
> durable. The verdict survives and doubles as the pull request description.

## Context

It judges against the intent's written conditions, never a reconstruction of them.
Routing destinations: (a) misframed, (b) solution does not address it, (c) a criterion
nobody claimed, (d) code does not match the ticket, and (a) again for a condition that
turns out unverifiable.

`accept.sh`'s refusals survive: in a repo, on its own branch, every ticket done, tree
clean. `--abandon` waives the every-ticket-done check and only that one.

The verdict carries the pull request description — what changed, where to look, what
is still uncertain — because it is the only page that survives the deletion.

`INTENT_WRONG_PROBLEM.md` records what would falsify this whole stage: verdicts that
never contradict the per-ticket checks. Build it so that is observable.

## Not here

The merge. A person reads the verdict and merges; nothing merges on a verdict alone.

## Record

`accept-run.sh`, `accept/SKILL.md`, `accept/VERDICT_FORMAT.md`, and `tests/accept.sh` —
24 cases after the review, invoked by `tests/run.sh`
(257 + 18 + 22 + 32 + 10 + 16 + 29 + 24, green). Eleven of the original sixteen were red
before the script existed — not twelve, as this Record first claimed; five passed
against nothing, and two of those five were the defects below.

**AC-11 is the testable half, and the tests are refusals.** Six of them: the main
branch, a dirty tree, an unfinished ticket named by file, a missing verdict, a verdict
that says rejected, a topic with no paper. Plus `a refusal deletes nothing`, because a
refusal that has already removed something is not one. Then the accepting case: the
paper gone, the verdict surviving, the code untouched, one commit, and that commit
containing deletions only.

`--abandon` has three: it retires a run whose tickets are unfinished, it still refuses
the main branch, and it needs a verdict that says `abandoned`. That last is what keeps
it from being a way around the check it waives.

Each refusal was mutation-tested. One did not bite at first — removing the
missing-verdict check still refused, because the next check fails on a file that is not
there. It refused with a message telling the person their verdict said the wrong thing,
which is a lie about what is wrong. The case now pins the message rather than the
refusal.

**The split is the same one the runner made.** The judgement is `/accept`, a skill; the
deletion and its refusals are `accept-run.sh`, a script — because a guard a session can
talk itself past is not a guard, and this is the one act in the pipeline that destroys
something.

**A deviation from the plan, which ticket 12 needs to know.** The design said `/accept`
absorbs `accept.sh` and the script goes. It did not: the mechanical half is real, and it
is now `accept-run.sh`, written against the new paper layout while the old `accept.sh`
stays untouched for the old pipeline. Ticket 12 deletes `accept.sh` and keeps
`accept-run.sh`.

**Untested, and this is most of the stage.** Using the feature, walking the conditions,
reading the Records as claims rather than evidence, choosing a routing destination. A
script can refuse to delete paper; nothing in bash can tell whether a verdict was earned
by driving the feature or written from the diff.

## Findings

One review round, fifteen findings, six of them blockers. Fourteen taken.

**The case this Record singled out as the point of the exercise was vacuous.** `a
refusal deletes nothing` ran once, at the end, against whatever workspace the previous
case had left — the topic-with-no-paper one, where there was nothing to lose. A refusal
that deleted the entire paper first passed all sixteen cases. It is a helper now, called
after each refusal that had paper on disk to lose.

**And the defect I had just fixed elsewhere, one case later.** `it refuses a topic with
no paper` checked only the exit code, so removing the check still passed: the script
fell through and refused about a verdict, which is not what is wrong. The same shape as
the missing-verdict case tightened in the same commit, left unfixed beside it.

**Three refusals the ticket said would survive from `accept.sh` did not.** A detached
HEAD was accepted, and that retirement commit is unreachable the moment anyone switches
branch. A commit that fails left the paper deleted and staged while reporting a refusal,
against the script's own promise that a refusal changes nothing; it puts the paper back
now. And a git-ignored file inside the paper stayed on disk while the run reported
success, because what git ignores git cannot delete.

**The skill's own order of operations could not be executed.** Promote, then run the
script — and promoting dirties the tree, which the script refuses. It now says to commit
the verdict and the promotions first, and why the script is right to insist.

**Three fidelity defects.** AC-5 names `VERDICT_<TOPIC>.md` and nothing delivered named
it; the derivation lived only in a `tr` inside the script. The routing list had four of
five destinations. And `Tradeoffs paid` declared itself to have no consumer, a defect
against AC-9 — `/solve` now reads the verdicts in the tree before writing its own
tradeoffs, which is the only correction an estimate ever gets.

**The falsification clause was in the ticket and in neither deliverable.**
`INTENT_WRONG_PROBLEM.md` was ratified on an argument and carries what would disprove
it: verdicts that never contradict the per-ticket checks. `VERDICT_FORMAT.md` now says
the verdicts in the tree are where that is read off — the other reason this page survives
the paper.

**Smaller.** `git rm` was given pathspecs rather than literals; a topic was not
validated, so `../src` resolved outside the paper; `--abandon` after the topic was
silently ignored; the not-a-repository refusal had no case.

**Recorded as thin.** `field()` in this script and in `run.sh` are identical and
separate. They agree today because they were written together, which is not a mechanism.
