---
effort: L
utility: L
---

# The refactor decides from measurable signals

The user, on 2026-10-31: `refactor-codebase` should base its decisions on
what to refactor on measurable signals, not on general knowledge written
into the skill.

Today `refactor-codebase/SKILL.md` carries such knowledge in three places:

- the third source under "Gather the signals", "The code": coupling and
  names judged by reading the code;
- the ten "kinds of refactoring": colocate "grouped by feature", split a
  god file, collapse layers that spare their caller nothing, generalize,
  simplify "code you had to read twice to follow";
- the measure in its opening: "the code that has to change with it should
  be close by and easy to find".

The friction notes in `changes/friction/` and the git history are already
measurable signals.

This matters because nothing else steers the code's structure. The skills
leave it to the builder, and keep it out of the design (`design-user-journeys`:
"Do not put details of the code to the user"). In the workout-tracker run
of 2026-10-31, the layout came from a hand-written `TECHNICAL.md` that
copied `../weight-tracker`; no skill writes that file.

`SDLC.md` ("Refactor"): "and possibly other signals". These are directions
for the signals, not decisions:

- **Checks that warn early**, from cheap to expensive:
  1. coverage scatter: how many files and modules a journey's deciding code
     spans, from the journeys' tests alone;
  2. history: churn, the share of bug fixes, and special cases piling up
     with each fix;
  3. the change test: a fresh agent makes a plausible change in the
     journeys' terms on a throwaway branch, and the diff's spread is
     measured;
  4. the round trip: a fresh agent explains a journey's behaviour from the
     code, and its explanation has to predict the journey tests' verdicts.

  Run 1 and 2 on every journey, and 3 and 4 only on the top few. The trend
  matters more than the level: a journey getting worse since the last
  refactor is the warning.
- **Cases in a rule that are only cruft.** In the weight tracker, the rule
  for when a weight series shows as "gaining weight" grew so convoluted with
  fixes that the developer no longer understood it. Some of its cases may
  be leftovers nothing requires. Removing one changes what the software
  does, so each is a change for the developer, listed apart like the other
  behaviour changes. Depends on `ask-how-and-why-in-the-users-concepts`.
- **An access model that has outgrown itself.** The access checks collect
  special cases until a more general model would be simpler, for example
  from roles alone to roles plus conditions on the record. Nothing is
  broken when that is due, so only the refactor finds it. It is a refactor
  as long as what each journey's "Who" may do stays the same.
- **The project's process, too.** Some friction is not a structural
  problem but an invisible reason - a check missing, a `run` skill that
  starts the software wrong. `retro` finds such failures but, living in
  this repository, only gives the wording for a project fix. Its moments
  and its ladder of mechanisms (something that executes, then a check
  without a stake, then an instruction) are what the project side would
  reuse.
