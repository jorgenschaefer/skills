---
name: implement-change
description: Build a change from its CHANGE.md, or from one of its chunks, and the user journeys it names - with a test for each journey that uses the software from the outside, reviewed by agents that did not build it. Run by run.sh for each chunk; also on "implement this change".
---

# Implement a change

Build what the change's file describes, so the user can go through its journeys, and have it reviewed by agents that did not build it.

This skill's `CHANGE_FORMAT.md` and `JOURNEY_FORMAT.md` settle the shape of what you are given.

## Before you write anything

**Read the file whole, every journey its frontmatter names, and the prototype its design links.** They were agreed with the developer: they are what has to be true when you are finished. Where the change was split, read your chunk and not `CHANGE.md`; the chunk carries what it needs.

**Never change a file in `journeys/`.** The journeys were approved before the build. Where you cannot build a journey as it is written, that is the developer's to decide: stop, as below.

**Look at what is there.** What already does this, or half of it, and what the project calls things. The code uses the user's words for the same things - the words in the journeys.

**Find the project's way of running the software** - a `run` skill, `CLAUDE.md`, the README. The reviewers start it that way. Where there is none, build one, write it up as the project's run skill, `.claude/skills/run/SKILL.md`, with the scripts it drives beside it, and commit it with the change.

**Find the project's checks** - the `Fast check:` and `Slow check:` lines in `CLAUDE.md`. A `Check:` line with no `Fast check:` line beside it is the fast check. Where no line names a fast check, run what exists and say so.

## Build it

**Build to the design**, and where it links a prototype, to the prototype. Its `## Not in this change` is not yours to build.

**Each journey gets a test that walks it the way a user would**: it clicks, types or calls the API, and never calls the code's internals. An integration test is fine - a component rendered in jsdom and clicked through, a request sent to the app. The test names its journey and step, so a failure says which step broke. It walks the steps this file builds and their "When it goes wrong" cases. Where a journey's steps were renumbered, its test follows. The test stays.

**A step that ends in *(judged)* gets no test.** Check it by hand on the running software, and report how.

**Every other test is yours.** Write what helps you build; delete it later if it gets in the way. Never weaken or delete a journey's test to make the change pass.

**Access is denied unless a journey gives it.** Every way in the change adds checks who is asking, and allows exactly what the journeys' "Who" gives them. Access no journey gives is not yours to add: stop, as below. Secrets stay out of the code and the logs.

**Write the least code that does the job.** Leave the files you touch better than you found them: a misleading name, a duplicate, dead code - small, in a file this change already touches, in a commit of its own before the change. Anything larger is a change of its own.

**Keep your own context for the build.** Side work whose result is a conclusion - surveying code you do not know, chasing a failure you cannot yet explain - goes to a subagent with the question, and only the answer comes back.

**Run the tests the change touches while you build.** The fast check runs whole before each review and before the commit, and not again where nothing changed since. The slow check runs once, after the last review and before the commit - unless your caller says it runs the slow check on your commit itself, and then you run only the fast check. Nothing is committed while a check is red. Where you cannot make it green, stop, and name the red check. Report the real result; if you cannot run them, say so rather than assuming.

## Review it with agents that did not build it

Every change gets this, down to the three-line one. The size of a diff is not evidence about the size of what it can break.

**Spawn two subagents with fresh contexts, side by side:**

- **`review-change`**, with the diff, the result of the checks, saying which checks it is the result of, the file you built from and the journeys it names, as what was asked for.
- **`walk-user-journeys`**, with the journeys the file names and how to run the software. Not the diff, the code or the design: it uses the software as a user would, and a walker that read the code knows what a screen means and does not get stuck where a user would.

Neither gets the reasoning that produced the code - not your plan, not how you tested it. A reviewer that has accepted every step of the reasoning reads its own intentions into the code.

**Do not drive the software yourself before the review.** In one run the build and its reviewer drove the app at the same time, fought over the dev server, and paid for the same check twice.

## Fix what comes back

Work the blockers and the should-fix. Then review again the same way, with fresh reviewers - except that in the second round the walker walks only the journeys your fixes touched, and you name them in the hand-off.

**A first round of only nits gets no second** - nits by the reviewer's rating, not yours. Fix the ones worth fixing and stop there, unless one of those fixes changes what the user sees or gets back, or where an action leads: then the second round walks the journeys it touched.

**Two rounds at most.** Stop when a review comes back clean or with only nits, or when the second round is done, and report what is still standing. A finding that goes unmentioned looks exactly like one that was fixed.

## Stop rather than improvise

Where a precondition you needed is not there, say what is missing and stop. It will look like five minutes of work, and then the change builds a precondition nobody approved. The same goes for a decision that is the developer's: what the user sees that the design and the journeys do not settle, a journey you cannot build as written, access no journey gives. Run by `run.sh`, its brief says how to stop. Run by a person, ask them.

## Finish

**Write down what was hard.** Where the change was hard to make - you had to change it in more than one place, you could not find something, something surprised you - write a note to `changes/friction/YYYY-MM-DD-<slug>.md`: what was hard, where, and why. The refactor reads these notes. Leave it out where nothing was hard.

**Commit** when the journeys' tests are green and the checks pass, with `git-commit-message`. Stage only the files this change touched; never `git add -A`.

**End your report with what you leave standing**, leaving out what is empty:

- review findings not fixed, with the severity the reviewer gave each, and why;
- fixes made after the last review, each with the finding it answers, since no reviewer saw them;
- checks not run;
- each test moved from the fast check to the slow check: which test, why it could not be made fast, and what the fast check no longer catches;
- each step no test shows, and how it was checked instead;
- anything you built beyond the design: a dependency the code gets built around, data kept or deleted, a format other programs read;
- each name for a thing the user sees that is not taken from the journeys, for the developer to confirm;
- tradeoffs: where you weighed one goal against another - utility, security, usability, maintainability - and which way you leaned;
- blast radius and revert: what a failure of this change would affect beyond the code it changed, and what a revert would not undo;
- a better approach than the one you were asked for, named here rather than built.

Nothing else. A person who ran you reads it there; `run.sh` has you write it into the file's `## Left standing`.
