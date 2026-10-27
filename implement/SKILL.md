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

**Given a `CRITERIA.md` rather than a ticket**, its ACs are what has to be true, and a test that pins one names its id. Its technical decisions and its AC groups are limits: anything you add that they do not name is a departure. For the technical decisions, that is a concept, a wire format, deleted data, or a dependency the code gets built around. For the AC groups, it is a permission, an alert, or data the system keeps. Depart only where the code calls for it. Write what you leave standing, as _Finish_ lists it, into a `## Left standing` section at the end of `CRITERIA.md` as well as your report. Hand `critique` the ACs, the technical decisions and `Out of scope`. Commit `CRITERIA.md` with the change, so what it was for survives the directory's deletion.

**Where the project has a `SECURITY_POLICY.md`**, the change's Security policy ACs - each one starts "adds:", "changes R-n to:" or "removes R-n:" - are the only rules it adds to the policy, changes or removes. Write each in as its AC words it, in this skill's `SECURITY_POLICY_FORMAT.md` shape, with its test and with what the policy check allows for it, in the change's own commits. Make sure the policy check finds and tries every way in the change adds. Where the policy check fails because the change lets someone see or do what no rule allows, fix the code. Where the code calls for that access, add the rule, and leave it standing as a departure from the Security policy group. With no criteria or ticket behind the change, nobody approved that access: add no rule, stop, and say it needs a rule agreed through `/find-criteria`. Never weaken the policy check or a rule's test to make the change pass; where it has to change, leave that standing too, saying what it no longer protects.

**Find the project's way of running the product** - a `run` skill, `CLAUDE.md`, the README - where the change reaches its user through an app, a command or an API. The review starts it that way. Where there is none, build one, write it up as the project's run skill, `.claude/skills/run/SKILL.md`, with the scripts it drives beside it, and commit it with the change.

**Find the project's check command** - the `Check:` line in `CLAUDE.md`. Where there is none, run what exists and say so; creating it is a ticket of its own.

## Build it

Build it in the order the standard says the work happens. While you build, run the tests the change touches. The project's checks run whole before each review and before the commit, and not again where nothing changed since. Report the real result; if you cannot run them, say so rather than assuming.

**Keep your own context for the build.** Side work whose result is a conclusion - surveying code you do not know, chasing a failure you cannot yet explain - goes to a subagent with the question, and only the answer comes back. The red-green cycles stay here.

**Leave the files you touch better than you found them.** A small fix in passing - a misleading name, a duplicate, dead code, a test for behaviour nothing pins - goes in where it lies in a file this change already touches, follows the idioms already there, and keeps behaviour, proved as the standard proves a refactor, in a commit of its own before the change. Anything larger, anything in another file, and anything a user or another program would notice is a change of its own.

## Review it in a session that did not write it

**Spawn `critique` as a subagent with a fresh context.** Hand it the diff, the result of the checks, and what was asked for - the criteria and what is out of scope, as the request states them, and the problem they serve where it states one. Do not hand it the reasoning that produced the code: not the plan, and not how you tested it. A reviewer that has accepted every step of the reasoning reads its own intentions into the code; the subagent starts cold, which is the only reason its findings are worth anything.

**The review is where the running product is checked.** Do not drive it yourself before it: in one run the build and its reviewer drove the app at the same time, fought over the dev server, and paid for the same check twice.

## Fix what comes back

Work the blockers and the should-fix, test-first. Then review again the same way, with a fresh reviewer - except that in the second round critique's driver does only the tasks, or visits only the screens, your fixes touched, and you name them in the hand-off.

**A first round of only nits gets no second** - nits by the reviewer's rating, not yours. Fix the ones worth fixing and stop there, unless one of those fixes changes what the user sees or gets back, or where an action leads: then the second round does the tasks or visits the screens it touched.

**Two rounds at most.** Stop when a review comes back clean or with only nits, or when the second round is done, and report what is still standing: the nits, anything you disagreed with and why, anything you chose not to fix and why. The pull is to quietly drop a finding, and one that goes unmentioned looks exactly like one that was fixed.

## Every change gets one, whatever its size

The fresh-context review runs on every change this skill builds, down to the three-line one. The size of a diff is not evidence about the size of what it can break, and a build run with nobody watching has nothing behind this review.

## Stop rather than improvise

Where a precondition you needed is not there, say what is missing and stop. It will look like five minutes of work, and then the change builds a precondition nobody approved, in a commit that claims to do something else. The same goes for a decision the request does not settle and that is not yours to settle: a tradeoff that changes what was approved, or that the request leaves to the person, is not a detail. Any other tradeoff you weigh yourself, and report.

## Finish

Commit when the behaviour is green and the checks pass. `git-commit-message` is the shape. Stage only the files this change touched; never `git add -A`.

**End your report with what you leave standing**, whoever called you, leaving out what is empty:

- review findings not fixed, with the severity the reviewer gave each, and why;
- fixes made after the last review, each with the finding it answers, since no reviewer saw them;
- checks not run;
- each criterion no automated test proves, and how it was checked instead;
- each departure from a technical decision or an AC group: what it says, what you built instead, and why;
- each name for a domain concept not taken from the glossary, for the developer to confirm;
- tradeoffs: where you weighed one law of the standard against another, and which way you leaned;
- each dependency you took on: what it gives and what it costs;
- blast radius and revert: what a failure of this change would affect beyond the code it changed, and what a revert would not undo;
- other decisions that would be costly to reverse - a format other code will be written against, a name that spreads;
- what was hard to change, and why - what surprised you, what you had to change in more than one place, what you could not find - each with a suggestion: a refactoring for a structural problem, a check for an invisible reason;
- a better approach than the one you were asked for, or a fix that is a change of its own, where it was not yours to take - named here rather than built.

Nothing else. A user who ran you reads it there; a skill or runner that called you collects it into its own `## Left standing`.
