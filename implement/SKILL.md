---
name: implement
description: Write, build or change software - a feature, a fix, a refactor. Fires on "implement", "build", "write the code", "add", "fix", and on any request to change what a codebase does.
---

# Implement

Build the thing, to the standard, and have it reviewed by someone who did not build it.

Read this skill's `CODING_STANDARDS.md` whole and apply all of it - no part of it is for somebody else. It says how the work is ordered as well as how the code ends up.

## Before you write anything

**Look at what is there.** What already exists that does this, or half of it. What the project calls things. What it decided before.

**Know what has to be true when you are finished**, specifically enough that you could hand it to someone else as the test of whether it worked. Where the request does not settle something that changes what gets built, ask - before or during the build - and do not build past it. Where it settles it badly, say so once and build it.

**Find the project's way of running the app**, where the change needs seeing - a `run` skill, `CLAUDE.md`, the README. The review drives the app that way. Where there is none, build one, write it up as the project's run skill, `.claude/skills/run/SKILL.md`, with the scripts it drives beside it, and commit it with the change.

**Find the project's verification command** - the one that runs the tests, the type check and the linter. Where there is none, run what exists and say so; creating one is a separate change.

## Build it

Build it in the order the standard says the work happens. While you build, run the tests the change touches. The project's checks run whole before each review and before the commit, and not again where nothing changed since. Report the real result; if you cannot run them, say so rather than assuming.

**Keep your own context for the build.** Side work whose result is a conclusion - surveying code you do not know, chasing a failure you cannot yet explain - goes to a subagent with the question, and only the answer comes back. The red-green cycles stay here.

## Review it in a session that did not write it

**Spawn `critique` as a subagent with a fresh context, in the foreground** - a turn ended while it runs in the background loses it. Hand it the diff, the result of the checks, and what was asked for - the criteria and what is out of scope, as the request states them. Do not hand it the reasoning that produced the code: not the plan, and not how you tested it. A reviewer that has accepted every step of the reasoning reads its own intentions into the code; the subagent starts cold, which is the only reason its findings are worth anything.

**The review is where the running app is checked.** Do not check the screens yourself before it: in one run the build and its reviewer drove the app at the same time, fought over the dev server, and paid for the same check twice.

## Fix what comes back

Work the blockers and the should-fix, test-first. Then review again the same way, with a fresh reviewer - except that in the second round critique drives only the screens your fixes touched, and you name them in the hand-off.

**A first round of only nits gets no second** - nits by the reviewer's rating, not yours. Fix the ones worth fixing and stop there.

**Two rounds at most.** Stop when a review comes back clean or with only nits, or when the second round is done, and report what is still standing: the nits, anything you disagreed with and why, anything you chose not to fix and why. The pull is to quietly drop a finding, and one that goes unmentioned looks exactly like one that was fixed.

## Every change gets one, whatever its size

The fresh-context review runs on every change this skill builds, down to the three-line one. The size of a diff is not evidence about the size of what it can break, and a build run with nobody watching has nothing behind this review.

## Stop rather than improvise

Where a precondition you needed is not there, say what is missing and stop. It will look like five minutes of work, and then the change holds something nobody asked for, in a commit that claims to do something else. The same goes for a decision the request does not settle and that is not yours to settle: a tradeoff nobody accepted is not a detail.

## Finish

Commit when the behaviour is green and the checks pass. `git-commit-message` is the shape. Stage only the files this change touched; never `git add -A`.

Where you saw a better approach than the one you were asked for and it was not yours to take, say so now, once, rather than building it.
