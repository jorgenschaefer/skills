# Evidence: workout-tracker, 2026-11-09

What we saw in the sessions after the first change of workout-tracker: a
review of the whole repository with its fixes, and a second change that ran
through `discover-change`, `design-change`, `build-change` and
`accept-change`. Each observation says what happened, where to look, and why,
as far as the sessions show.

## The project and the sessions

`~/Projects/workout-tracker` is a phone web app for one person's workouts:
plans, and trainings in which each set is prefilled with last time's value.

| Step | Session |
|------|---------|
| `review-change` on the whole repository, then `build-change` and `accept-change` for the fixes, then a deploy | `34ee2d42` |
| `discover-change`, then `design-change`, for ending a training | `f86504da` |
| `build-change` and `accept-change` for ending a training | `c20ff0ec` |

The session logs are in
`~/.claude/projects/-home-jorgen-Projects-workout-tracker/`.

## Observations

### 1. A decision nobody agreed to got firmer with each session, until it was undone

The rule "one training per plan and day" came from the builder alone
(observation 1 of 2026-11-08). The developer had never agreed to it.

The review of the whole repository then found a race in that rule: two quick
taps could start two trainings. It proposed a unique index, and said the index
would make the rule a firm one. It marked this as a decision for the
developer, and the developer agreed. The fix, the index and a test were built
and deployed (`34ee2d42`).

The next day the developer started `discover-change`, because the app had
confused them "several times": they could not start a new training, because
the old one only ended at midnight. That change removed the rule and the
index again (`f86504da`, `c20ff0ec`).

An earlier `learn-from-sessions` run had already pointed out that nobody had
agreed to the rule. The developer chose to deal with it later.

Why: once a rule is in the code, a later review treats it as the way things
are, and builds on it. The review did ask the developer, but it asked about
the index, not about the rule underneath. Nothing asks at that point whether
the rule itself was ever agreed. This adds to observation 1 of 2026-11-08.

### 2. `build-change` asked the developer about decisions it called cheap

The build report listed four points under "needs your decision". For two of
them, the report itself said they were cheap: "only the interface, easy to
change at any time" (ask before ending a training) and "cheap, only the
interface" (a hint on the plan page). The developer answered "as recommended"
for both (`c20ff0ec`).

Why: the review marks findings "for the developer", and `build-change` passes
all of them on. It does not check how hard each one is to undo, although the
manifesto says the cheap decisions belong to the agent. This is related to
observation 10 of kh-finder, where some cheap questions were worth asking
because they needed the developer's knowledge of the domain. Here they did
not: the developer had nothing to add.

## What worked

- **`discover-change` found the real problem.** The developer asked to
  separate plans and trainings clearly. The agent read the code first, and
  found that the data already kept them apart. What confused the developer was
  that a training never ended in a way they could see. It asked one question
  to tell two cases apart, then offered three approaches, the simplest first
  (`f86504da`).
- **The fixes from 2026-11-08 held.** `design-change` now names "when each
  thing the user works on starts and ends". The build report had the new
  section "what you decided alone", and it put the open questions about when
  a training ends in front of the developer (`c20ff0ec`).
- **The fresh review and the user stand-in found a crash the checks missed.**
  A theme change broke every page, while type check, linter and all tests
  passed (`34ee2d42`). This adds to observation 4 of kh-finder.

## What this suggests

Not yet agreed. For discussion.

- **When a review touches a rule that is hard to undo, it should ask whether
  the rule itself was agreed**, not only about the fix on top of it (1).
- **`build-change` should decide cheap findings itself**, even when the review
  marks them "for the developer", unless they need the developer's knowledge
  of the domain (2).
