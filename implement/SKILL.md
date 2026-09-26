---
name: implement
description: Write, build or change software - a feature, a fix, a refactor. Fires on "implement", "build", "write the code", "add", "fix", and on any request to change what a codebase does.
---

# Implement

Build the thing, to the standard, and have it reviewed by someone who did not build it.

This skill's `CODING_STANDARDS.md` is what the software has to look like. Read it whole and apply all of it - it is one page, and no part of it is for somebody else. It says how the work is ordered as well as how the code ends up, and neither is restated here.

## Before you write anything

**Look at what is there.** What already exists that does this, or half of it. What the project calls things. What it decided before. A change that ignores the shape of the codebase is a rewrite in disguise.

**Know what has to be true when you are finished**, specifically enough that you could hand it to someone else as the test of whether it worked. Where the request does not settle something that changes what gets built, ask. Where it settles it badly, say so once and build it.

**Find the project's way of running the app**, where the change needs seeing - a `run` skill, `CLAUDE.md`, the README - before building a harness of your own. Where you had to build one, write it up as the project's run skill, `.claude/skills/run/SKILL.md`, with the scripts it drives beside it, and commit it with the change.

**Find the project's verification command** - the one that runs the tests, the type check and the linter. Where there is none, run what exists and say so.

## Build it

Build it to the standard, in the order the standard says the work happens. Then the project's checks, and report the real result - if you cannot run them, say so rather than assuming.

**Keep your own context for the build.** Side work whose result is a conclusion - surveying code you do not know, a manual check in the running app, chasing a failure you cannot yet explain - goes to a subagent with the question, and only the answer comes back - a large context is paid for on every turn, and again on every resume. The red-green cycles stay here.

## Review it in a session that did not write it

**Spawn `critique` as a subagent with a fresh context.** Hand it the diff, the result of the checks, and what was asked for. Do not hand it the reasoning that produced the code.

That last part is the whole point. A reviewer that has already accepted every step of the reasoning is not a reviewer - it will read its own intentions into the code and find the defects it was already looking for. The subagent starts cold, which is the only reason its findings are worth anything.

## Fix what comes back

Work the blockers and the should-fix, test-first like anything else. Then review again, the same way.

**Two rounds at most.** Stop when a review comes back clean or when the second round is done, and report what is still standing: the nits, anything you disagreed with and why, anything you chose not to fix and why.

**The pull is to quietly drop a finding.** A budget on the rounds makes that cheap - one more round is expensive, saying nothing is free, and a finding that goes unmentioned looks exactly like a finding that was fixed. Say what you left.

## Every change gets one, whatever its size

The fresh-context review runs on every change this skill builds, down to the three-line one. The failing test holds at every size in the same way.

The size of a diff is not evidence about the size of what it can break, and a build driven with nobody watching has nothing behind this review - what it does not catch is what ships.

## Stop rather than improvise

Where a precondition you needed is not there, say what is missing and stop.

It will look like five minutes of work, and often it is - and then the change contains something nobody asked for, in a commit that claims to do something else. The same goes for a decision the request does not settle and that is not yours to settle: a tradeoff nobody accepted is not a detail.

## Finish

Commit when the behaviour is green and the checks pass. `git-commit-message` is the shape. Stage the files this change touched and nothing else; never `git add -A`.

Where you saw a better approach than the one you were asked for and it was not yours to take, say so now, once, rather than building it. Where it is smaller than that, `IDEAS.md` is the parking lot.
