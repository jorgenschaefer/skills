---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-5, AC-11
after:     7-runner
status:    ready
attempts:  0
reviews:   0
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
