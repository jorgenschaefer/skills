---
name: review-change
description: Review a whole change's code - a diff, a branch or a PR, including "look this over before I merge" - against what was asked for, its user journeys, the four goals (utility, security, usability, maintainability), its hard tests and the project's constraints, reporting what could go and what is hard to undo. Spawned by accept-change on the whole change; use it in place of a generic code review.
---

# Review a change

Review the code of one whole change against what was asked for, its journeys and the four goals in this order: utility, security, usability, maintainability. A problem nothing here names is still reported at full severity.

You change nothing. The output is a list of changes somebody else will make.

You review the code. Walking the running software as a user is `walk-user-journeys`' work, done by an agent that never reads the code.

## What you are given

The diff, the result of the checks where your caller has one, and what was asked for: the change's `spec.md`, its `intent.md` where there is one, the hard tests its `plan.md` lists, and the journeys it names, in this skill's `JOURNEY_FORMAT.md` shape. Called directly before a merge, ask what the change is for; where nobody can say, review against the four goals alone and say so first.

Not the reasoning that produced the code. Where you are handed it anyway, set it aside: judge the change, not the writer's account of it.

## Review the code with `/review-code`

Load `/review-code` and do what it says, with the diff, the checks' result and what was asked for as its spec. Its checks, how it verifies a finding before reporting it, its severities and its output hold here too: what could go, and what is hard to undo, included. Then add what only the pipeline has, below.

## What the pipeline adds

**Utility.** The code does what the journeys say and solves the problem in `intent.md`, or the bug, or the "Done when" list. A problem that stays while every journey step holds as written is a should-fix: say that the design does not settle it.

**Security.** Everything is denied unless a journey gives it. For every way in the change adds or touches, hold the check that decides who is asking against the journeys' "Who", and try to get past it: another user's id, no login, a role no journey names.

**Usability**, as far as the code shows it: what the user sees when something fails, feedback after every action, an action that cannot be undone. The walk judges the rest.

**Maintainability.** The next change is made by an agent that remembers nothing of this one. Would it find what it needs and make its change correctly? The code uses the journeys' words, and `UBIQUITOUS_LANGUAGE.md`'s where there is one, for the same things.

**The hard tests.** A file with `.hard.` in its name is a hard test: it needs the developer's yes to change.

- **Each journey has a hard test that would catch it breaking.** For every journey step the change builds, and every "When it goes wrong" case, find the test that walks it from the outside - clicking, typing, calling the API, never the code's internals - and names its journey and step. Read what it asserts: a test that would still pass with the step broken is no test. A step marked *(judged)* needs none. A step with none is a should-fix; one whose break would cost the user money, data or access is a blocker.
- **Every changed, renamed or deleted `.hard.` file is listed** under "Hard tests" in the output, so the developer sees it, with whether the plan lists the change as approved.

**The constraints.** Hold the change against each line under `## Constraints` in the project's `CLAUDE.md`. A constraint the change breaks is a blocker.

## Output

`/review-code`'s output, with one more section after "Hard to undo":

```markdown
### Hard tests
<each changed, renamed or deleted `.hard.` file, with its place in the diff, and whether the plan lists the change as approved>
```

If a section is empty, say so rather than padding it.
