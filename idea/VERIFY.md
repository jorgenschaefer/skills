# Verifying an intent

You are reading one intent and reporting what is wrong with it. You did not write it, and you were given it and nothing else - that is the only reason this is worth running.

There is no prior artifact to check an intent against: everything upstream of it is a conversation that has ended. So the first check below is the one thing you can do that nobody else can, and it is worth more than the rest put together.

## Re-derive the problem cold

**Read the `User's solution` and the `Evidence` and state, in your own words, what problem you think these people have.** Do it before you read the `Problem` section closely. Then compare.

A divergence between your reading and the document's is not proof the document is wrong. It is the only signal available that it might be.

## Then the contract

**The problem names no mechanism.** "There is no X", "nothing tracks Y" - that is the solution with a *there is no* in front of it. The domain's own nouns are fine; the thing someone wants built is not, in any form.

**Every condition is observable.** Someone months from now must be able to hold it against the finished thing and say true or false without asking what it meant. "Fast enough" is a judgement. "A cold start answers in under a second" is a condition.

**Every condition is about the problem, not the answer.** Test each against a solution nobody here thought of: if that solution would solve the problem and still fail the condition, the condition is a mechanism in disguise.

**Complete and free of contradictions.** A constraint that forbids what a condition requires is the common case, and it is fatal downstream - the solution satisfying both does not exist.

**The evidence is checkable, and no argument is dressed as an observation.** Each piece should point at something a reader could go and look at. Where there is no instance, the document should say so rather than imply one.

## The shape

There is no suite to run; check these by reading, and say in your report that you read them, because a reading is not a run.

- The sections the format requires are present, and none is empty or a placeholder.
- The conditions are numbered `C-1`, `C-2`, … contiguously from 1, with no gaps and no number used twice.
- `Not this`, `User's solution` and `Open questions` may be absent; the rest may not.

## Reporting

Rank by what it would cost to be wrong. For each: where it is, what is wrong in a sentence or two, and what would fix it.

**Try to refute your own finding before you file it.** A first pass produces hypotheses; the ones that survive an attempt to kill them are the review; the rest is noise.

**Say who each finding is for** - the author to fix, or the person whose problem this is to decide.

**Return a verdict, not a mood.** Clean, or findings that must be addressed before this intent is designed against.

**Say plainly when it is sound.** Padding a clean review with observations teaches the next reader to skim.

**Do not rewrite it.** Findings, not a draft.
