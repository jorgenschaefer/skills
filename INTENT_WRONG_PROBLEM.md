# Intent: nothing establishes that the work solved the problem

## Problem

Every check in the pipeline compares an artifact to the artifact before it. Tickets
are checked against the spec, code against the ticket, the finished feature against
the spec again. Each link is sound, and the chain still proves nothing about the thing
that started it: if the spec was a good answer to the wrong question, every check
passes and the work ships.

The problem statement exists — `/idea` writes one — and then nothing reads it again.
It is consumed once, to produce a spec, and from that moment the spec is the only
standard anything is measured against. The customer's problem leaves the building at
stage two.

This is the failure mode that costs the most, because it is invisible from inside. A
run that halts is obvious. A run that delivers exactly what was specified, on time,
with every criterion met, and does not help anyone, produces no signal at all — and
the pipeline reports success.

It is also self-concealing in a second way: the parties best placed to notice are the
ones that produced the work. An agent reviewing its own output has already accepted
every step that led to it, and will read its own intentions into the words rather than
what is on the page.

## Evidence

- `check-against-spec` calls itself "the acceptance" and drives the feature against
  *the spec it was built from*. Its own description names the spec as the standard.
- `idea/SKILL.md` is the only skill in the repository that mentions `INTENT_` at all.
  Every other stage works from the spec: once the intent has been turned into one,
  nothing opens it again.
- `INTENT_FORMAT.md` has `## Proposed outcome` as unnumbered prose, and contains no
  numbered conditions of any kind. Nothing downstream could cite a condition from it
  even in principle, because there is nothing to cite.

## Done when

- **C-1** For every change, the question "did this solve the problem that was brought
  to us" is answered explicitly, against a problem statement written before the
  solution existed, and the answer is recorded.
- **C-2** The problem statement is written so that answer is possible: each condition
  in it can be checked true or false later without asking its author what it meant.
- **C-3** A "no" is actionable — it names which part of the chain failed, not merely
  that the result was unsatisfactory.
- **C-4** The answer is not self-confirming. Whatever declares the work done has not
  also done the work, and does not depend on the reasoning that produced it — so a
  "yes" would have been a "no" had the work been wrong.

## Constraints

- **The check must be cheap enough to run every time.** A check that is skipped under
  deadline answers nothing; this one is worthless if it is the first thing dropped.
- **It must judge against what was written, not against a reconstruction.** A reviewer
  that re-derives the problem from context will drift toward whatever was built.
- **The answer must be legible to the person who arrived with the problem**, without
  reading the code or the spec.
- **No new stage whose output nothing reads.** Whatever produces the answer must have a
  named consumer, or it recreates the problem in `INTENT_PROCESS_COST.md`.

## Not this

- The cost of the process itself. That is `INTENT_PROCESS_COST.md`. The two are
  independent: this one could be satisfied by adding a single stage to the existing
  pipeline, and that one could be satisfied without ever answering this.
- Whether the problem statement described the world correctly. Only production answers
  that, and it is out of scope here.
- Code quality.

## Whatever they arrived with

Not stated as a complaint. It surfaced while working out the stages: the proposed
five-stage shape ended with acceptance, and the question of what acceptance is
measured against turned out to have a different answer than the existing pipeline's.

## Open questions

- Does a condition that turns out to be uncheckable indict the intent, the work, or
  neither?
- Is one pass over the finished feature enough to answer C-1, or does answering it
  honestly require using the thing more than once, over time?

## Ratified

Not yet. This one was inferred rather than reported — it was never raised as a
complaint, which is either a sign that it is real and invisible, or a sign that it is
the author's problem and not the customer's. Worth confirming before anything is built
for it.

## Routed back

Nothing yet.
