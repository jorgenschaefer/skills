---
name: accept-criteria
description: Walk a finished change with the user - drive the running product through CRITERIA.md's acceptance criteria and against its problem, follow the user wherever they try it, and on acceptance delete the change's paper.
disable-model-invocation: true
---

# Accept the criteria

You are given a change's directory - `changes/<slug>/`, holding `CRITERIA.md`, its tickets and, where the run reviewed it, `REVIEW.md`. Walk the finished change with the user, and say whether it does what was agreed and solves the problem it was for.

This is a session with the user in it. Show what you do and what you see as you go, so they can look and try along.

## Drive the product

**Use it the way its user would**, in the running product. Do not read the diff and conclude: deciding by eye whether code would behave a certain way is prediction, and prediction is what this stage exists to replace.

Start it the way the project says to - a `run` skill, `CLAUDE.md`, the README - before building a harness of your own. Where you had to build one, write it up as the project's run skill, `.claude/skills/run/SKILL.md`, with the scripts it drives beside it, and leave it uncommitted - whether it stays is the user's call. A harness described only in a conversation is rebuilt by the next walk, and never reaches the builds.

Where you cannot get the product running at all, stop and say so - every AC is unchecked.

## Walk the criteria

**Take `CRITERIA.md`'s acceptance criteria by id**, and for each one say what you did and what you saw. An AC you could not check is not one you passed: say which it was and why.

**Compare what was built with the agreed design**, and with the specimen where there is one.

**Hold the whole against the Problem.** Where every AC is met and the problem is not solved, say so - that is the most important thing this stage can find, and nothing before it could.

## Read what the builds left

Each ticket's `## Left standing` says what its build did not settle - departures from a nudge, and ACs no automated test proves, among them. `REVIEW.md` says what the final review left. Read them as you walk.

Where an AC is not met in the product, look in the tests for the one that claims it. A green test over absent behaviour is the gap this stage exists to catch: name it plainly.

## Follow the user

Beyond the ACs, the user can use the change however they like, and you follow along. What comes up is reported the same way. A missing feedback message, a control squeezed on a narrow screen, a rarely used action shouting louder than the common one - those are what no AC caught.

## Report

Only what needs the user, most serious first, each item ending with the step that would settle it:

- An AC not met: what you did, and what you saw. Where a test claims it, name the test.
- An AC you could not check: why, and what it would take to check it.
- The problem not solved, where the ACs are met.
- What the user and you found beyond the ACs.
- The run skill, if you wrote one.

Then one line naming the ids you found met, so every id is accounted for.

## Settle what was left open

Every item in `REVIEW.md` and in each ticket's `## Left standing` needs an outcome before the change can be accepted - with a single ticket there is no final review, and the ticket is the only record. Drop, after checking, what the walk settled or the code no longer shows.

Show the rest as one list, each item with where it came from, a proposed outcome - for a fix, the fix itself - and a one-line reason:

- **Fix now** - small enough for this session: `/implement` it, then walk again the ACs it touches.
- **Re-slice** - too big for this session: back to `/criteria-to-tickets`, and the change is not accepted yet.
- **Skip** - not worth doing, with the reason. Where the reason is a decision this skill's `ADR_FORMAT.md` says earns an ADR, recommend one, and on a yes write it to `docs/adr/` in that file's shape.
- **Follow-up** - worth doing, but not in this change: the start of a later `/idea`.

The user agrees to the list or names items to discuss. Take those one at a time - and, even where the user agrees to the list, every item that departs from a nudge or needs a decision the criteria leave open: present it, suggest a concrete fix or decision, and wait for the user's view before the next.

Whether to accept is the user's call.

## Once the user accepts

Delete the change's directory - `CRITERIA.md`, the tickets, the specimens, `REVIEW.md` - and commit the deletion with any ADR you wrote, staging nothing else. The commit message lists each skip with its reason and each follow-up - the files that held them are gone. What the change was for survives in git history and in the commits that built it; ADRs live in `docs/adr/` and stay.

Where the user does not accept, delete nothing. An AC not met goes back to `/criteria-to-tickets` as a re-slice, and one that turned out wrong to `/find-criteria`.

When you are done, stop what you started and remove the scratch databases, worktrees and directories you created - all but the run skill - and name whatever you could not remove.
