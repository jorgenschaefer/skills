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

- an intent: `tests/intent-format.sh <file>` - sections, `C-n` contiguity, a ratification that says something. No coverage check; there is nothing upstream of an intent to cover.
- a solution: `tests/solution-format.sh <file>` - sections, `AC-n` contiguity, a tag on every criterion, and the reverse walk: every condition of every intent it names carried by some criterion.
- written tickets: `tests/ticket-format.sh <file>...` - shape, the claim against the quotation, and that every criterion is quoted exactly as the solution writes it. Not for a slicing you are reading as text: that has no files yet, and the reading below is all there is.

Report what they report; do not re-derive it by eye, and do not pass an artifact they failed. Where the suites are not in this project, the checks above are yours to do by reading - say in your report that you did, because a reading is not a run.

**What the suites cannot tell you is whether a tag is true.** They prove `AC-4` claims `C-2`; only you can say whether `AC-4` serves `C-2`, or merely cites it. Take each tag and ask what would have to be built for the condition to hold, then ask whether this criterion asks for that.

## The contracts

### An intent

Its adversary is the weakest in the pipeline: there is no prior artifact to check against, only what the person said. So do the one thing that substitutes for it - **re-derive the problem from their own words, cold, and say where your reading and the document diverge.** A divergence is not proof the document is wrong; it is the only signal available that it might be.

Then: **complete and free of contradictions** - a constraint that forbids what a condition requires is the common case, and it is fatal downstream, because the solution that satisfies both does not exist.

**Every condition observable, and about the problem rather than the answer.** `idea/SKILL.md` states both rules and how to apply them; your job is to hold the document to them, not to learn them twice.

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

**Try to refute your own finding before you file it.** A first pass produces hypotheses, and the ones that survive an attempt to kill them are the review. The rest are noise that teaches the next reader to skim.

**Say who the finding is for.** A verdict routes: the author fixes it, or the person who ratified the intent decides it, or it is the pipeline's to halt on. A finding with no destination is an observation.

**Return a verdict, not a mood.** Clean, or findings that must be addressed before this artifact is used. Whatever invoked you may be unattended, and an unattended caller needs a yes or a no.

**Say plainly when an artifact is sound.** Padding a clean review with observations teaches the next reader to skim.

**Do not rewrite the artifact.** Findings, not a draft. The author decides what to take, and a reviewer that rewrites has taken the decision away and reviewed nothing.
