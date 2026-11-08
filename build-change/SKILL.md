---
name: build-change
description: Build a change from its change file, then check it with a fresh-context review and a user stand-in, fix what they find, and report to the developer only what needs them. Started by the developer in a fresh session once the change is designed.
disable-model-invocation: true
---

# Build a change

The developer's attention is the scarce resource. Build the change, then find what is wrong with it and fix it before they look. Show them only what needs them.

## 1. Read what was agreed

The change file is in `changes/`: the one the developer names, or the only one there. Read it, the mock-ups and ADRs it links, and what it says could wait. The decisions under `## Decisions that matter` were made with the developer. Build them as written, with the tests and the structure they name.

Build on the branch the change file was committed on.

## 2. Build

Build the smallest thing that does the job, in the domain's words, with the project's checks green.

## 3. Review and try it

Run both. Each runs in a fresh context, and they find different things: one reads the code, the other uses the software.

- **`/review-change`** on the change's branch against the default branch. Give it the change file as what the code is meant to do.
- **`/try-change`** on the change. Give it the change file. If you know how to start the software and the project's files don't say, give it that too. Don't give it your view of the change: it is there to see what a user sees.

## 4. Fix

Fix what they found, except what they marked "for the developer". Run the project's checks. Commit the fixes.

Then run `/review-change` and `/try-change` once more, as in step 3, and fix what they find. Don't run them a third time: what is still wrong goes into the report as still open.

## 5. Report

Tell the developer the change is ready to try, and show them only:

- **what needs their decision**: what the review and the user stand-in marked "for the developer", each with what it would cost to undo and what you recommend;
- **what is still open**: what you could not fix, and what nobody could try, such as a part the user stand-in could not reach.

Not what you fixed, and not what went well. If there is nothing to show, say the change is ready to try, in one line.

Add what the developer settles to `## Decisions that matter` in the change file, with what holds it: the code, a test, structure, or an ADR in `docs/adr/` for what the code cannot show. Build the test, the structure or the ADR, and commit.

Then the developer tries the change. If it does not solve their problem, go back to `/understand-change` with what they found. If it does, they start `/accept-change`.
