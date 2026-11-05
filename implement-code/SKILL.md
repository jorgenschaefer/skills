---
name: implement-code
description: Build a small change to code that was agreed beforehand, in this session - from a bug's cause and reproducing test, a "Done when" list, one part of a plan or any other agreed spec. Use when an agreed change is to be built in this session, when another skill hands over its agreed spec to be built, and on "build this", "implement this" once what has to be true when it is finished is agreed. If the solution is still to be worked out, use solve-problem; if the change is too large for one session, create-plan.
---

# Implement code

Build a small change that was agreed beforehand, so that what the spec says is true, and have its code reviewed by an agent that did not write it.

## What you are given

**An agreed spec**: whatever says what has to be true when you are finished. A bug's report, intention, cause and reproducing test; a "Done when" list; a part of a plan. If nothing was agreed, ask what has to be true when you are finished. Do not build from a guess.

**Who commits.** Your caller says whether it commits your work or you do. If nobody says, you commit.

## Before you write anything

**Read the spec whole, and the code it touches.** Look for what already does this, or half of it, and for what the project calls things. The code uses the user's words for the same things: the words of the spec, and of `UBIQUITOUS_LANGUAGE.md` if the project has one.

**Find the project's checks**: the `Fast check:` and `Slow check:` lines in `CLAUDE.md`. A `Check:` line with no `Fast check:` line beside it is the fast check. If no line names a fast check, run the checks the project has, and say which you ran.

## Hard and soft

A decision or a test is **hard** if something outside the code depends on it: a revert removes the code, but not what the code wrote, sent or promised. Everything else is **soft**. When in doubt, it is hard.

**Hard decisions:**

- **Stored data**: schema, migrations that drop or transform data, files on disk, IDs and keys.
- **Wire formats**: public APIs, event and message schemas, webhooks, CLI output that scripts read, URLs people link to.
- **Names that leave the code**: in the UI, the API, the schema, the journeys, environment variables.
- **The access model**: roles, permissions, how login works.
- **What the code is built around**: a framework, a database engine, a third-party service, a UI library.
- **Effects in the world**: emails sent, payments made, data deleted, data collected.

Soft: file names, module boundaries, internal names, the structure of helpers. Soft decisions are yours, and you do not mention them.

**Before a hard decision the spec does not settle, ask the developer.** Give the options, the simplest first and called the simplest, and your recommendation.

**Soft tests are yours**: write what helps you build, and delete it when it gets in the way.

**A hard test is a file with `.hard.` before its test suffix**, such as `invoice-overdue.hard.test.ts`. Change, rename or delete an existing one only if the developer said yes. That yes is in the spec, or you ask for it before you touch the file. A new test is hard, and named `.hard.`, only if all three hold: it tests from the outside (the UI, the API or the stored data), it is named for its rule in the user's words, and you can name what breaks if the tested thing changes. Every other new test is soft.

## Build it

**Write the least code that does the job.** Nothing the spec does not ask for.

**Build a failure case the user sees only if the spec asks for it.** How the code handles failures underneath is yours.

**Leave the files you touch better than you found them**: a misleading name, a duplicate, dead code. Only small fixes, only in files this change already touches, in a commit of their own before the change. If your caller commits, leave them uncommitted with the rest. Anything larger is a change of its own.

**Keep your own context for the build.** Side work whose result is a conclusion, such as surveying code you do not know or chasing a failure you cannot yet explain, goes to a subagent with the question. Take back only the answer.

**Run the checks.** Run the fast check whole before each review, and before you commit or hand the change back. Skip a fast-check run only if nothing changed since the last one; a fix to a comment is a change. Run the slow check once, after the last review and before you commit or hand the change back. If your caller says it runs the slow check itself, run only the fast check. Commit nothing while a check is red. If you cannot make it green, stop and name the red check. Report the real result. If you cannot run a check, say so rather than assume.

## Stop rather than improvise

If a precondition you needed is not there, say what is missing and stop. Do not build it, however small it looks: a change that builds it contains a precondition nobody approved. If you would have to ask the developer about a hard decision or a hard test, and nobody is there to ask, your caller says how to stop.

## Have it reviewed

Every change gets reviewed, even a three-line one: the size of a diff says nothing about what it can break.

**Spawn `review-code` with a fresh context.** Give it the diff, the result of the checks, which checks that result is from, and the spec you were given. Give it nothing of the reasoning that produced the code: not your plan, not how you tested it, not why you skipped something, not background on the domain, not what to look at especially. A reviewer that has accepted every step of the reasoning reads its own intentions into the code.

**Fix the blockers and the should-fix**, including the "what could go" findings rated as either. Then have the fixed code reviewed the same way, by a new reviewer with a fresh context. If the first round found only nits, there is no second round. **Two rounds at most.**

## Finish

**Write down what was hard.** If the change was hard to make - you had to change it in more than one place, you could not find something, something surprised you - write a note to `changes/friction/YYYY-MM-DD-<slug>.md`: what was hard, where, and why. If nothing was hard, write no note.

**Commit, unless your caller commits.** Commit once the checks pass, with `git-commit-message`. Stage only the files you touched; never `git add -A`. If your caller commits, leave the change reviewed, green and uncommitted.

**End your report with what you leave standing.** Leave out an item that is empty:

- review findings not fixed, with the severity the reviewer gave each, and why;
- every fix made after the last review, each with the finding it answers, since no reviewer saw them, down to a changed comment;
- checks not run;
- every hard decision you made or met: what it was, and who decided it - the spec, or the developer when you asked;
- if your caller commits, the small fixes to touched files that you left uncommitted with the change.

Nothing else: no summary of what changed, of the checks, or of how to try it. A finding that goes unmentioned looks exactly like one that was fixed.
