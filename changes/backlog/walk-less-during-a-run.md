---
effort: S
utility: L
---

# Walk less during a run

The walkers set the pace of a run. In the `workout-tracker` run of
2026-11-02 (20:25 to 05:28, 10 chunks and the final review), the
`walk-user-journeys` subagents took 184 of about 540 minutes. Reviewers ran
beside them and always finished first: 56 minutes in all.

Two things in `implement-change/SKILL.md` ("Fix what comes back") make it
that much:

- **Every chunk had a second round.** A first round with a should-fix gets a
  second round, and every chunk's first round had one. The second-round
  walks took about 72 minutes together. None of the reports that say so
  found a blocker; in chunk 07 the round-2 should-fixes were left standing.
- **Walkers walked beyond their chunk.** Chunk 08's walker: "1. As written
  (not in scope, but checked)". A walker also builds the app, starts it, and
  waits for the 2-second save before each check.

Most walker findings were polish. The ones that mattered - „Letztes Mal“
missing as a label in the training, the grey weight that saves body weight
when only the reps are typed - ended up in `REVIEW.md`'s "For you", and the
final review's walk of all four journeys found them too.

Proposed in the retro: the second round gets only a reviewer, unless the
first round's walk found a blocker; and the walker walks only the steps the
chunk builds. `plan-the-build-and-decide-only-what-is-hard-to-change.md`
goes further and walks once, at acceptance; this is a step that stands on its
own before it.

Evidence: `~/Projects/workout-tracker/.git/run-logs/`, the `task_notification`
durations in each chunk's log.
