# Verdict: accepted

## Conditions

- **C-1** met. Driven, not read: a throwaway repository, a stub standing in for `claude`
  that writes `status: review` and commits nothing, and the real `run.sh` against it. The
  ticket was retried once and then halted; it did not reach `done`. Before this change
  the same stub produced a clean review and a `done` ticket.
- **C-2** met. The halt reads `unbuilt - the session reported a build and committed
  nothing, and the last of 2 attempts is spent - read the build output for what stopped
  it committing`, written into the ticket, in the vocabulary `implement/SKILL.md` and
  `NEW_PIPELINE_IDEA.md` now teach.
- **C-3** met. `tests/runner.sh` went from 29 cases to 37, among them a session that
  claims a build and commits nothing, a rework that legitimately commits again, and a
  repository with no commits. `tests/stub-session` gained the outcome that makes the
  first possible - the instrument that was missing, and the reason the gap survived 29
  cases.

## Tradeoffs paid

The solution said a sixth halt kind, and the vocabulary grew by one as predicted. It
also said the check proves a commit happened rather than that the commit is the work,
and that is exactly what it does.

What it did not predict: the two tickets cost eight sessions and two operator decisions
rather than the four sessions the shape suggests. Ticket 2 - three lines in two
documents - took four review rounds and was accepted with its findings open, because a
documentation criterion pinned by greps over prose has no natural stopping point. A
solution that estimates by seams will underestimate a seam made of sentences.

## What changed

The runner records `HEAD` before each build session. A session reporting `status:
review` without having moved it is retried inside the attempt budget, as a crashed one
is, and halts as `unbuilt` when the budget is spent. The runner also refuses a
repository with no commits, where the check would otherwise pass by accident.

Before this, a session could write `review`, commit nothing, be reviewed against an
empty diff, come back clean, and reach `done` - with the next ticket starting on a
dependency that did not exist.

## Look here

`run.sh`'s `review` branch and the refusal beside the branch check. In the tests, the
five new cases in `tests/runner.sh` and the outcome added to `tests/stub-session`: that
stub always committed, which is why no case in 29 had ever exercised this.

The comment justifying the empty-repository refusal was wrong in the first build and was
corrected in review - `git rev-parse HEAD` prints the literal string `HEAD` there, so the
check does distinguish the two cases. The refusal stands for the reason the ticket gave.

## Still uncertain

Whether a session that commits only its own `## Record` should pass. It does, by a
constraint ratified during the run. The check reads movement and does not ask what moved.

Whether the review ceiling is calibrated. Ticket 2 exhausted it on a real sequence of
real findings, and nothing here says what a fifth round would have been worth.
