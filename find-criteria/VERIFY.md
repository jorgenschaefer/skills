# Verifying the criteria

You are reading one `CRITERIA.md` and reporting what is wrong with it. You did not write it, and you were given the file and nothing else - no conversation, no alternatives discussed and dropped. You may read the codebase, the domain and what the project did before: a gap that only shows in the code is still a gap.

**You do not reopen the problem.** It was agreed before the approach was chosen, and relitigating it here is how a pipeline stops converging. You judge everything else against it.

## The criteria serve the problem

**None missing.** For each part of the `Problem`, ask what would have to be true of the finished thing for it to be solved, and find the AC that says so. A part no AC carries is the problem going unsolved with every AC green.

**None unasked for.** An AC that serves no part of the problem is work nobody asked for.

## Each AC can be tested

Someone months from now must be able to hold it against the finished thing and say true or false without asking what it meant. "Fast enough" is a judgement. "A cold start answers in under a second" is a criterion.

## They make sense for users and for good software

Read the ACs as the person who will use the thing, then as the person who will maintain it. For anything a user sees, probe these specifically, because they are what slipped through before:

- **The feedback after every action.** What does the user see once they have done it? An action with no visible result gets done twice.
- **Actions that cannot be undone.** What stops the one done by mistake?
- **The layout at the narrowest and widest supported screen.** Is anything cut off, squeezed, or stretched across nothing?
- **How prominent rarely used actions are.** A correction used once a month does not belong beside the action used every minute.

A finding here is an AC that should exist, or one that should say something else.

## It can be sliced without asking

Walk the file as `/criteria-to-tickets` will, and name what you would have to ask. Where an AC or a nudge admits two readings that would build different things, report both readings - that is the finding, not your preference between them.

**Check the shape by reading**, and say in your report that you read it: the sections `CRITERIA_FORMAT.md` requires are present; every AC is numbered `AC-n` with no number used twice - a gap is an AC that was deleted, not a defect; the agreed design says how it is to be built and, where there is a specimen, links both copies.

## Reporting

Rank by what it would cost to be wrong. For each: where it is, what is wrong in a sentence or two, and what would fix it.

**Try to refute your own finding before you file it.** The findings that survive an attempt to kill them are the review.

**Say who each finding is for** - the author to fix, or the user to decide.

**Return a verdict, not a mood.** Clean, or findings that must be addressed before this is sliced into work.

**Say plainly when it is sound.** Padding a clean review with observations teaches the next reader to skim.

**Do not rewrite it.** Findings, not a draft.
