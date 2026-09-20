---
name: verify
description: Check one artifact against what its stage was given - an intent, a solution, a slicing. One adversary with a contract per stage, run in a context that did not produce the thing it is reading.
disable-model-invocation: true
---

# Verify

Read one artifact and report what is wrong with it against the stage's own input. Not whether it is a good idea - that was settled upstream, and reopening it is how a pipeline stops converging.

## How this is run

**In a fresh context, always.** A reviewer in the session that produced the artifact has already accepted every step that led to it, and will read its own intentions into the words. Whoever invokes this spawns a subagent; the subagent gets the artifact, the stage's input, and nothing else it did not go and fetch.

**Against the input contract.** You may read the codebase, the domain, what the project did before - a drawback that only shows up in the code is still a drawback. What you may not do is relitigate a decision someone already ratified.

## Run the mechanical half first

Absences are mechanical and are already written down. Start there, so your reading is spent on what a grep cannot see:

- an intent: `tests/intent-format.sh <file>`
- a solution: `tests/solution-format.sh <file>`

These check shape, numbering, and coverage in both directions. Report what they report; do not re-derive it by eye, and do not pass an artifact they failed.

## The contracts

### An intent

**Every condition observable.** Hold each against a finished thing months from now: could someone say true or false without asking the author what they meant? "Fast enough" is a judgement; "a cold start answers in under a second" is a condition.

**Every condition about the problem.** Invent a solution the author did not think of. If it would solve the problem and still fail the condition, the condition is a mechanism in disguise.

**The problem names no mechanism.** "There is no X" is the solution with a *there is no* in front of it.

**The evidence is checkable, and an argument is not dressed as an observation.** Where there is no instance, the intent should say so.

### A solution

Coverage is mechanical and the suite has done it. What is left is the part a reviewer can actually add:

**Hunt the unlisted drawback.** Read the approach against the codebase and name what it will cost that `Accepted tradeoffs` does not. An omitted cost is a defect exactly as a contradiction is.

**Check the ruled-out reason is true.** An alternative dismissed for a reason that does not hold was not ruled out; it was waved away.

**Look for the candidate nobody considered.** You cannot say a better solution exists - that has no ground truth. You can say the field was too small to have chosen from.

Then test severity against the intent's constraints, and report which of the three it is:

- **violates no constraint** - it belongs in `Accepted tradeoffs`, and the solution stands;
- **violates one** - the approach is disqualified, and say which constraint;
- **the constraints are silent** - not yours to settle, and not the author's either. Say that it needs the person who ratified the intent.

### A slicing

This one arrives as text rather than a file, because it is worked out before anything is written.

**Every ticket traces to a criterion, and every criterion lands in a ticket.**

**Each slice is vertical:** buildable and testable on its own, not a layer. "The database part" is not a slice.

**The criteria are copied, not summarised.** A ticket that paraphrases its criteria has quietly changed them.

## Reporting

Rank by what it would cost to be wrong. For each: where it is, what is wrong in a sentence or two, and what would fix it.

**Say plainly when an artifact is sound.** Padding a clean review with observations teaches the next reader to skim.

**Do not rewrite the artifact.** Findings, not a draft. The author decides what to take, and a reviewer that rewrites has taken the decision away and reviewed nothing.
