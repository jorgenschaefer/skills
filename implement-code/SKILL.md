---
name: implement-code
description: Build a small change to code that was agreed beforehand - from any agreed spec, such as a bug's cause and reproducing test, a "Done when" list or one part of a plan - with the least code that does the job, asking the developer before every hard decision and every change to a hard test, and reviewed by review-code in a fresh context. Use when an agreed change is to be built in this session, and when another skill hands its agreed spec over to be built.
---

# Implement code

Build a small change that was agreed beforehand, so that what the spec says is true, and have its code reviewed by an agent that did not write it.

## What you are given

**An agreed spec**: whatever says what has to be true when you are finished. A bug's report, intention, cause and reproducing test; a "Done when" list; a part of a plan. Where nothing was agreed, ask what has to be true when you are finished. Do not build from a guess.

**Who commits.** Your caller says whether it commits your work or you do. Where nobody says, you commit.

## Before you write anything

**Read the spec whole, and the code it touches.** Look at what is there: what already does this, or half of it, and what the project calls things. The code uses the user's words for the same things - the words of the spec, and of `UBIQUITOUS_LANGUAGE.md` where the project has one.

**Find the project's checks** - the `Fast check:` and `Slow check:` lines in `CLAUDE.md`. A `Check:` line with no `Fast check:` line beside it is the fast check. Where no line names a fast check, run what exists and say so.

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

**A hard test is a file with `.hard.` before its test suffix**, such as `invoice-overdue.hard.test.ts`. Change, rename or delete an existing one only with the developer's yes, asked before you touch it. A new test is hard only if it tests from the outside - the UI, the API or the stored data - is named for its rule in the user's words, and you can name what breaks if the tested thing changes. Otherwise it is soft.

## Build it

**Write the least code that does the job.** Nothing the spec does not ask for.

**A failure case the user sees is built only where the spec asks for it.** How the code handles failures underneath is yours.

**Leave the files you touch better than you found them**: a misleading name, a duplicate, dead code - small, in a file this change already touches, in a commit of its own before the change. Where your caller commits, leave it uncommitted with the rest and name it in your report. Anything larger is a change of its own.

**Keep your own context for the build.** Side work whose result is a conclusion - surveying code you do not know, chasing a failure you cannot yet explain - goes to a subagent with the question, and only the answer comes back.

**Run the tests the change touches while you build.** The fast check runs whole before each review and before the commit, and not again where nothing changed since. The slow check runs once, after the last review and before the commit - unless your caller says it runs the slow check itself, and then you run only the fast check. Nothing is committed while a check is red. Where you cannot make it green, stop, and name the red check. Report the real result; if you cannot run a check, say so rather than assuming.

## Stop rather than improvise

Where a precondition you needed is not there, say what is missing and stop. It will look like five minutes of work, and then the change builds a precondition nobody approved. The same goes for a hard decision the spec does not settle, and a hard test you would have to change. Ask the developer. Where nobody is there to ask, your caller says how to stop.

## Have it reviewed

Every change gets this, down to the three-line one. The size of a diff is not evidence about the size of what it can break.

**Spawn `review-code` with a fresh context.** Give it the diff, the result of the checks, saying which checks it is the result of, and the spec you were given. Not the reasoning that produced the code: not your plan, not how you tested it. A reviewer that has accepted every step of the reasoning reads its own intentions into the code.

**Fix the blockers and the should-fix**, and the "what could go" findings rated as either. Then review again the same way, with a fresh reviewer. A first round of only nits gets no second. **Two rounds at most.**

## Finish

**Write down what was hard.** Where the change was hard to make - you had to change it in more than one place, you could not find something, something surprised you - write a note to `changes/friction/YYYY-MM-DD-<slug>.md`: what was hard, where, and why. The refactor reads these notes. Leave it out where nothing was hard.

**Commit, unless your caller commits.** Where you commit, do it when the checks pass, with `git-commit-message`. Stage only the files you touched; never `git add -A`. Where your caller commits, leave the change reviewed, green and uncommitted.

**End your report with what you leave standing**, leaving out what is empty:

- review findings not fixed, with the severity the reviewer gave each, and why;
- fixes made after the last review, each with the finding it answers, since no reviewer saw them;
- checks not run;
- every hard decision you made or met: what it was, and who decided it - the spec, or the developer when you asked.

Nothing else. A finding that goes unmentioned looks exactly like one that was fixed.
