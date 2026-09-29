# Verifying a problem statement

You are reading one problem statement and reporting what is wrong with it. You did not write it, and you were given it, the one instance behind it and the solution the user arrived with - nothing else. That is the only reason this is worth running.

There is no prior artifact to check a problem statement against: everything upstream of it is a conversation that has ended. So the first check below is the one thing you can do that nobody else can, and it is worth more than the rest put together.

## Re-derive the problem cold

**Read the user's solution and the instance and state, in your own words, what problem you think these people have.** Do it before you read the statement closely. Then compare.

A divergence between your reading and the statement's is not proof the statement is wrong. It is the only signal available that it might be.

## Then the statement

**It names no mechanism.** "There is no X", "nothing tracks Y" - that is the solution with a *there is no* in front of it. The domain's own nouns are fine; the thing someone wants built is not, in any form.

**It says what is wrong and what would be true instead**, so that a reader who was not there could restate it.

**The instance is real, and no argument is dressed as one.** It should point at something a reader could go and look at - a file, a commit, a number, a day it happened.

**It is one problem.** A statement that joins two, each worth solving on its own, will be answered by criteria that serve neither well.

## Reporting

Rank by what it would cost to be wrong. For each: where it is, what is wrong in a sentence or two, and what would fix it.

**Try to refute your own finding before you file it.** A first pass produces hypotheses; the ones that survive an attempt to kill them are the review; the rest is noise.

**Say who each finding is for** - the author to fix, or the person whose problem this is to decide.

**Return a verdict, not a mood.** Clean, or findings that must be addressed before criteria are worked out against it.

**Say plainly when it is sound.** Padding a clean review with observations teaches the next reader to skim.

**Do not rewrite it.** Findings, not a draft.
