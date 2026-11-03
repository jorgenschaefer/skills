---
name: solve-problem
description: Work out a solution to an agreed problem together with the user - alternatives at every decision, questions instead of guesses - and once you both see the same result, build it in this session with implement-code, or hand it to create-plan where it does not fit one session. Use when /idea hands over to it, and on "let's work this out together and build it".
---

# Solve a problem

Work out with the user how to solve the problem until you both see the same finished result. Then build it.

## Start from the problem

Take the agreed problem from the conversation. Where there is none, run `/idea` first, and carry on here once it has ended, unless the user takes the other way it names.

Read what the problem touches before you propose anything: the files, what the project calls things, what it already has for this.

## Settle the solution

- Walk it one decision at a time. At each one, propose at least three genuinely different alternatives, or say why there are fewer. Put the simplest first, and call it the simplest. Give each one its effort (XS to XL) and the complexity it adds, then recommend one and say why.
- Where only the user knows something, ask; do not guess.
- Weigh what the user says before following it: propose what would make it better, or object where you think it is wrong. Once: a decision they reaffirm is theirs.
- End your turn at the first question mark.
- Agree with the user what "done" means: a "Done when" list. Each criterion on it says something about the result, how to check it, and, where it is not obvious, who checks it. Write it before you build. Each criterion must be able to fail. At least one checks that the problem itself is gone. If you can only see that later, it says when, and who checks it then.
- Settled means you can describe the finished result in a few sentences, the user says that is what they have in mind, and they agree to the "Done when" list. Edit nothing before that yes.

## Build it

**Where the work does not fit this session, or has a hard decision the user has not seen, plan it.** Where you are on `main` or `master`, make a branch named `YYYY-MM-DD-<slug>`. Write `changes/YYYY-MM-DD-<slug>/spec.md` with the problem, the agreed result and the "Done when" list, commit it on the branch with `git-commit-message`, and hand it to `/create-plan`. Stop there.

**Otherwise, build it with `/implement-code`.** Give it the agreed result and the "Done when" list as its spec, and tell it that you commit. It builds the change, runs the project's checks and has it reviewed by `review-code`.

Then check every criterion on the "Done when" list that you can check now, and fix what fails.

Show the user what changed, what `implement-code` left standing, and each criterion on the "Done when" list: met, not met and why, or still to check, by whom and when. Once they say yes, commit with `git-commit-message`, if the work is in a repository. Where the problem came from a backlog item, delete the item in the same commit.
