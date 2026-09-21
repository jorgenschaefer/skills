---
name: implement
description: Write, build or change software - a feature, a fix, a refactor. Fires on "implement", "build", "write the code", "add", "fix", and on any request to change what a codebase does.
---

# Implement

Build the thing, to the standard, and have it reviewed by someone who did not build it.

`CODING_STANDARDS.md` is what the software has to look like. Read it. Its `## Shaping the change` applies when the change introduces a concept the codebase has no name for or moves a boundary between the ones it does; its `## Writing the code` applies always; its `## How it gets written` is the loop below, and is not restated here.

## Before you write anything

**Look at what is there.** What already exists that does this, or half of it. What the project calls things. What it decided before. A change that ignores the shape of the codebase is a rewrite in disguise.

**Know what has to be true when you are finished**, specifically enough that you could hand it to someone else as the test of whether it worked. Where the request does not settle something that changes what gets built, ask. Where it settles it badly, say so once and build it.

**Find the project's verification command** - the one that runs the tests, the types and the linter. Where there is none, run what exists and say so.

## Build it

Follow `## How it gets written`: a failing test first, always, for every piece of behaviour this change is meant to have. Then the project's checks, and report the real result - if you cannot run them, say so rather than assuming.

## Review it in a session that did not write it

**Spawn `critique` as a subagent with a fresh context.** Hand it the diff, the result of the checks, and what was asked for. Do not hand it the reasoning that produced the code.

That last part is the whole point. A reviewer that has already accepted every step of the reasoning is not a reviewer - it will read its own intentions into the code and find the defects it was already looking for. The subagent starts cold, which is the only reason its findings are worth anything.

## Fix what comes back

Work the blockers and the should-fix, test-first like anything else. Then review again, the same way.

**Two rounds at most.** Stop when a review comes back clean or when the second round is done, and report what is still standing: the nits, anything you disagreed with and why, anything you chose not to fix and why.

**The pull is to quietly drop a finding.** A budget on the rounds makes that cheap - one more round is expensive, saying nothing is free, and a finding that goes unmentioned looks exactly like a finding that was fixed. Say what you left.

## Proportion

A three-line change does not need two review rounds, and a typo needs none. Scale what you do to what you are changing: the fresh-context review is the floor for anything with behaviour in it, not a ritual to perform on everything.

This is judgement, and it is the one place here where you have it. It is not licence to skip the failing test - that holds at every size.

## Stop rather than improvise

Where a precondition you needed is not there, say what is missing and stop.

It will look like five minutes of work, and often it is - and then the change contains something nobody asked for, in a commit that claims to do something else. The same goes for a decision the request does not settle and that is not yours to settle: a tradeoff nobody accepted is not a detail.

## Finish

Commit when the behaviour is green and the checks pass. `git-commit-message` is the shape. Stage the files this change touched and nothing else; never `git add -A`.

Where you saw a better approach than the one you were asked for and it was not yours to take, say so now, once, rather than building it. Where it is smaller than that, `IDEAS.md` is the parking lot.
