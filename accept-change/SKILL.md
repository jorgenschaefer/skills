---
name: accept-change
description: Check a built change before the developer looks at it - a fresh-context review and a user stand-in, then fix what they find - report to the developer only what is hard to undo and what is still open, and wrap the change up once the developer accepts it. Use when the build of a change is done, before telling the developer it is ready; and on "is this ready", "check the change", "wrap this up".
---

# Accept a change

The developer's attention is the scarce resource. Before they look at a change, find what is wrong with it and fix it. Then show them only what needs them.

The change is on its own branch. Its change file is in `changes/`, if it has one.

## 1. Review and try it

Run both, each in a fresh context. They find different things: one reads the code, the other uses the software.

- **`/review-change`** on the change's branch against the default branch. Give it the change file as what the code is meant to do.
- **`/try-change`** on the change. Give it the change file. If you know how to start the software and the project's files don't say, give it that too. Don't give it your view of the change: it is there to see what a user sees.

## 2. Decisions you made alone

While building, you made decisions. Some of them may be hard to undo, and the developer has not heard of them. Go through the diff and list every decision that is hard to undo and not under `## Decisions that matter` in the change file. A decision is hard to undo when, after the software has been in use for a while, undoing it takes more than a revert:

- data that was stored: where it lives, its shape, what past records mean;
- things sent or published: an API, a wire format, URLs;
- who can see or do what, and where data stays;
- what happens to the user's input when something fails;
- money or contracts;
- what much else is built on: the stack and its versions, the deployment, the design system, a pattern that gets copied.

Don't list the rest.

## 3. Fix

Fix what the review and the user stand-in found, except what they marked "for the developer". Run the project's checks. Commit the fixes.

If a fix changed the code a lot, run `/review-change` again on the fixes.

## 4. Report

Tell the developer the change is ready to try, and show them only:

- **what needs their decision**: the decisions from step 2, and the findings marked "for the developer", each with what it would cost to undo and what you recommend;
- **what is still open**: what you could not fix, and what nobody could try, such as a part the user stand-in could not reach.

Not what you fixed, and not what went well. If there is nothing to show, say the change is ready to try, in one line.

What the developer settles needs a record that outlives the change file, as `/decide` would give it: a test for a promise about behaviour, an ADR for what the code cannot show.

Then the developer tries it. If it does not solve their problem, go back to `/explore` with what they found.

## 5. Accept

When the developer says the change solves their problem:

1. Put what could wait on the backlog with `/backlog`, one item each, unless that was done already.
2. Delete the change file and its mock-ups in `changes/`.
3. Commit.

The developer merges the branch. Don't merge it yourself.
