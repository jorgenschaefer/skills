---
name: solve-problem
description: Work out a solution to an agreed problem together with the user - alternatives at every decision, questions instead of guesses - and build it in this session once you both see the same result, reviewed by an agent that did not build it. Use when /idea hands over to it, and on "let's work this out together and build it".
---

# Solve a problem

Work out with the user how to solve the problem until you both see the same finished result. Then build it.

## Start from the problem

Take the agreed problem from the conversation. Where there is none, run `/idea` first, and carry on here once it has ended, unless the user takes the other way it names.

Read what the problem touches before you propose anything: the files, what the project calls things, what it already has for this.

## Settle the solution

- Walk it one decision at a time. At each one, propose at least three genuinely different alternatives, or say why there are fewer. Give each one its effort (XS to XL) and the complexity it adds, then recommend one and say why.
- Where only the user knows something, ask; do not guess.
- Weigh what the user says before following it: propose what would make it better, or object where you think it is wrong. Once: a decision they reaffirm is theirs.
- End your turn at the first question mark.
- Settled means you can describe the finished result in a few sentences and the user says that is what they have in mind. Edit nothing before that yes.

## Build it

1. Make the change, and run the project's fast check.
2. Spawn a fresh agent that has not seen this conversation to review the change. Give it the problem and the agreed result, and let it review in whatever way fits the change.
3. Fix every finding that holds up, and run the fast check again.
4. Show the user what changed, the fixes, and the findings you rejected and why. Commit once they say yes. Where the problem came from a backlog item, delete the item in the same commit.
