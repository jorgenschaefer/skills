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
- Agree with the user what "done" means: a "Done when" list. Each criterion on it says something about the result, how to check it, and, where it is not obvious, who checks it. Write it before you build. Each criterion must be able to fail. At least one checks that the problem itself is gone. If you can only see that later, it says when, and who checks it then.
- Settled means you can describe the finished result in a few sentences, the user says that is what they have in mind, and they agree to the "Done when" list. Edit nothing before that yes.

## Build it

The project's checks, if there are any, are the `Fast check:` and `Slow check:` lines in `CLAUDE.md`; a `Check:` line with no `Fast check:` line beside it is the fast check.

1. Make the change, and run the fast check as you go.
2. Spawn a fresh agent that has not seen this conversation to review the change. Give it the problem, the agreed result and the "Done when" list, and let it review in whatever way fits the change.
3. Fix every finding that holds up.
4. Check every criterion on the "Done when" list that you can check now, and run the slow check. Fix what fails.
5. Show the user what changed, the fixes, the findings you rejected and why, and each criterion on the "Done when" list: met, not met and why, or still to check, by whom and when. Once they say yes, commit, if the work is in a repository. Where the problem came from a backlog item, delete the item in the same commit.
