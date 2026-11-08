# Evidence: workout-tracker, 2026-11-08

What we saw when one new change ran through the whole workflow on a new
project. Each observation says what happened, where to look, and why, as far
as the sessions show.

## The project and the sessions

`~/Projects/workout-tracker` is a phone web app for one person's workouts:
plans, and trainings in which each set is prefilled with last time's value.
The repository was empty when the change started.

| Step | Session |
|------|---------|
| `understand-change`, then `design-change` | `c6098c3a` |
| `build-change`, with two rounds of `review-change` and `try-change` | `1c9ca104` |
| `accept-change` | `6328d97c` |

The session logs are in
`~/.claude/projects/-home-jorgen-Projects-workout-tracker/`.

## Observations

### 1. One short label stood for two decisions, and the builder filled in the second

The design mock-up said that every input is saved at once and that there is
no "done" button ("kein Fertig"). That label covers two decisions:

- there is no save button;
- a training never ends, so nobody decides when it is over.

The developer read it as the first. Their next question was about saving
only: when does a phone save, if there is no blur? Only that was then
discussed and decided (`c6098c3a`).

How a training starts and ends was never asked. The design only said that
tapping a plan starts a training with today's date. The builder decided the
rest alone: tapping the same plan again on the same day reopens that day's
training. The build report did not mention it. Both reviews read that code
and did not list it as a decision nobody agreed to, although `review-change`
asks for exactly that (`1c9ca104`).

When the developer tried the app, they were confused: the training is never
marked as done, so which plan comes next? The builder explained its own
rule as "how it's meant to work (from the change file …)", and said an
explicit "done" would "change a decision in the change file". The developer
had never agreed to that decision.

Why: `design-change` names "how the user moves through the task" as hard to
undo, but nothing asks when each thing the user works on starts and ends.
One label stood for two decisions, and the developer agreed to the meaning
they saw. The builder then treated its own gap-filling as part of what was
agreed. This adds to observations 1 and 5 of the workout logbook and to
observation 10 of kh-finder.

### 2. The user stand-in's test data confused the developer's own try

The developer tried the app on the database the stand-in had filled. The
stand-in had trained both gym plans on the same day. So the developer saw
reps already filled in, and the wrong plan as "next". The builder had to
explain that most of it came from the stand-in's data, not from the normal
flow. The report had only said in passing that the database held the
stand-in's test data (`1c9ca104`).

Why: neither `try-change` nor `build-change` says what happens to the data
the stand-in leaves behind before the developer tries the change.

### 3. In an empty repository, the change branch leaves no default branch

`understand-change` started on a repository with no commits and created the
change's branch from it, as its branch rule says. So `main` never existed.
The reviewer, the builder and `accept-change` each had to work around it:
the reviewer diffed from a commit instead of the default branch, and
`accept-change` said the branch was ready to merge but that `main..HEAD`
failed, and asked the developer to check the base (`c6098c3a`, `1c9ca104`,
`6328d97c`).

Why: the branch rule in `understand-change` and `design-change` assumes a
default branch with at least one commit. This adds to observations 3 and 4
of the workout logbook.

## What this suggests

Not yet agreed. For discussion.

- **`design-change` should ask when each thing the user works on starts and
  ends**, and should split a label that covers more than one decision (1).
- **The builder's report should name the gaps it filled in how the user
  moves through the task**, and `review-change` should catch them (1).
- **The developer should try the change on a clean or plainly described
  database**, not on the stand-in's leftovers (2).
- **The branch rule needs a case for an empty repository**, such as a first
  commit on `main` before the change branch (3).
