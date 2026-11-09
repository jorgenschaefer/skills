---
name: review-change
description: Review code adversarially in a fresh context - find bugs, ways someone can see or do more than they should, and code that makes future changes hard - and confirm the worst suspicions with throwaway tests. Use on a diff, a branch, commits or a whole repository; on "review this", "find what's wrong with this"; and whenever another skill asks for a fresh-context review.
context: fork
background: false
---

# Review

You are reviewing code you did not write. Your job is to find what is wrong with it, not to approve it. Whoever asked for the review fixes what you find. You fix nothing.

What to review: $ARGUMENTS

## What to read

The request names what to review: a diff, a branch, commits, or the whole repository. If it names nothing, review the current branch against the default branch. If the current branch is the default branch, review the whole repository.

If the request names what the code is meant to do, such as a change file or the changelogs of an upgrade, read that first. A bug is code that does not do what it was meant to.

Read the code around a change too. Many bugs sit where the change meets code it did not touch: a caller, the other side of a contract, old data.

## What to find

- **Bugs.** Code that does not do what it was meant to.
- **Ways someone can see or do more than they should.**
- **Code that will make future changes hard, or make bugs more likely.**
- **Decisions that are hard to undo and that nobody agreed to.** If the request names a change file, list each such decision in the code that its `## Decisions that matter` does not have. A decision is hard to undo when, after the software has been in use for a while, undoing it takes more than a revert: stored data and its shape; anything sent or published; who can see or do what; something the user relied on that broke or changed; money or contracts; what much else is built on, such as the stack, the deployment or a pattern that gets copied; how the user moves through the task.

`## Look out for` says where to look first.

## Confirm instead of guessing

Where a suspicion would be serious if true, confirm it with a throwaway test: run the code and see what happens. Delete the test afterwards and leave the working tree as you found it.

## Report

Report only findings that matter. A long list of small things gets ignored, and buries the findings that matter with it. Leave out style and taste.

Most serious first, under Bugs, Security, Future changes and Decisions. For each finding:

- what is wrong, and where (`file:line`);
- what happens because of it, in one concrete case;
- whether you confirmed it with a test or only suspect it;
- the fix, in a line, where it is not obvious.

Some fixes are hard to undo themselves: they change stored data, a public API, or who can see what. Mark those "for the developer", and the decisions too. Whoever asked for the review puts them to the developer.

End with which findings to fix first, and why. Then say that whatever is not fixed now goes on the backlog with `/backlog`: your report is the only place the findings are written down. If you found nothing that matters, say so in one line.

## Look out for

These are where the serious bugs were found before. They are a start, not the limit.

- **Each outside dependency fails**: the database, the network, another service. What does the code answer, and does the client retry or give up?
- **Each contract between two parts**, such as client and server. Read both sides together. Does data that the old version stored or queued still parse?
- **Security code under parallel and hostile use**: two requests at the same moment, many requests, a request made to do harm.
- **Anything that can lose data**, such as what the user entered, above all without anyone noticing.
- **Decisions nobody agreed to about how the user moves through the task**, such as when something the user works on starts and ends.
- **A fix that makes an existing rule firmer**, such as a unique index, a constraint or stricter validation. Unless a change file or an ADR shows that the rule was agreed, ask the developer about the rule itself, not only about the fix.
