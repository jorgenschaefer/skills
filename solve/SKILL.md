---
name: solve
description: Turn a ratified intent into a solution spec - candidates weighed, one chosen, its criteria tagged to the conditions they serve and its costs named. Typed, not inferred.
disable-model-invocation: true
---

# Solve

Design several genuinely different answers to an intent, choose one with the user, and write it down thoroughly enough that whoever builds it needs nothing from you.

`SOLVE_FORMAT.md` settles the shape of the spec. This file is what you do.

## Start from the conditions

**Read the intent's `Done when` before anything else, and take its numbers with you.** Those conditions are what your criteria will tag, and what the acceptance stage will walk back. A criterion that serves no condition is work nobody asked for.

**Read `Constraints` as disqualifiers, not preferences.** They are what makes a choice between candidates decidable without asking. A candidate that violates one is out, whatever else it has going for it.

**An unratified intent is a draft.** If `## Ratified` says nobody has confirmed it, stop and ask for that first. Everything you are about to write is measured against conditions no one has agreed to.

### Given prose instead of a file

A small change arrives as a sentence, and writing an intent document for it would cost more than the change. That path is open, in one order and no other:

1. **Derive the conditions and constraints from what they said. Before you have an approach.**
2. **Show them and wait for the yes.**
3. **Then design.** The conditions open the solution file, in place of a link to an intent.

**The order is the whole of it.** Conditions written once an approach exists describe the approach: they will be exactly what it happens to satisfy, the review will check coherence against a target the solution wrote for itself, and acceptance will grade the answer against the answer. Nobody will be able to see this from the finished file.

**Refuse the short path rather than guess.** Hand back to `/idea` when you cannot state the conditions so someone could check them later, when the list runs long, or when the request is a solution with no problem visible behind it. A short request is not a small problem.

## The field

**Design genuinely different answers, not one answer at three sizes.** Two candidates that differ only in how much of the same thing they do is one candidate.

**Agree what decides before you score anything.** Say which properties will pick the winner, and get that agreed while the candidates are still open. Criteria proposed afterwards are criteria chosen to make the answer you already like come out on top, and neither of you will be able to tell.

**Kill on constraints first.** What remains is a choice, and the choice is the user's. Give a recommendation - a survey with no opinion in it is work handed back.

**Look at what is already here before inventing.** What the project calls things, what it already does, what it decided before. A solution that ignores the shape of the codebase is a rewrite in disguise.

## The record

**Write it to `SOLUTION_<TOPIC>.md`, and ask where it goes** if the project has not settled that. The topic is the intent's, so the paper for one change stays findable as a set.

**Tag every criterion with the conditions it serves.** Then check the other direction: every condition in the intent is carried by at least one criterion. A condition with no criterion is the intent's most important sentence going unbuilt.

**`Accepted tradeoffs` and `Ruled out` are not optional and not decoration.** A reviewer can find a cost you failed to name; no reviewer can find the better solution you never considered. These two sections are the only thing standing between "this works" and "this was chosen".

Write what this costs against what it was chosen over. "Adds some complexity" is a shrug. "Two round trips instead of one, bought for a schema that does not need migrating" is a tradeoff.

**Where a cost the intent's constraints forbid turns up, the approach is disqualified.** Not a tradeoff to accept - a candidate to replace.

**Where a cost turns up that the constraints are silent on, ask.** The intent did not anticipate this axis, so it is not yours to settle. Their answer belongs in the intent as a new constraint, not in your tradeoff list as a fait accompli.

## Throughout

**Do not reopen the problem.** The intent is ratified; a solution that argues with it is a solution that has not been written yet. Where you are convinced the problem is wrong, say so plainly and stop - that is a route back to `/idea`, not something to design around.

**End your turn at the first question mark.** One turn, one open question.

**Push back once.** A decision reaffirmed after hearing the objection is theirs - record it as such.

**Stopping here is an ending.** A solution recorded and not built is a whole use of this skill. Say that the slicing is what turns it into work, and leave that to them to ask for.
