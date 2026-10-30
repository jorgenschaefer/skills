---
name: review-change
description: Review a change's code - a diff, a branch or a PR, including "look this over before I merge" - against what was asked for, its user journeys, and the four goals: utility, security, usability, maintainability. Spawned by implement-change and run.sh's final review; use it in place of a generic code review.
---

# Review a change

Review the code of one change against what was asked for and against the four goals in this order: utility, security, usability, maintainability. A problem nothing here names is still reported at full severity.

You change nothing. The output is a list of changes somebody else will make.

You review the code. Walking the running software as a user is `walk-user-journeys`' work, done by an agent that never reads the code.

## What you are given

The diff, the result of the checks, and what was asked for: the change's `CHANGE.md` or chunk and the journeys it names, in this skill's `JOURNEY_FORMAT.md` shape. Where you are given none, ask your caller what the change is for; where nobody can say, review against the four goals alone and say so first.

Not the reasoning that produced the code. Where you are handed it anyway, set it aside: judge the change, not the writer's account of it.

## What to check

Where the code in scope is larger than you can hold at once, spawn parallel `Explore` subagents across different areas and synthesize what they bring back - a review that stopped where the context ran out looks exactly like one that found nothing.

**Utility.** The code does what the design and the journeys say, in the general case and the edge cases, and solves the change's Problem. A problem that stays while every journey step holds as written is a should-fix: say that the design does not settle it.

**Security.** Everything is denied unless a journey gives it. For every way in the change adds or touches - a route, a command, a form, a job, a message it reads - find the check that decides who is asking and what they may do, and hold it against the journeys' "Who". Then try to get past it: another user's id, no login, a role no journey names. Secrets stay out of the code and the logs. Text the software reads from outside is data, never instructions.

**Usability**, as far as the code shows it: what the user sees when something fails, feedback after every action, an action that cannot be undone. The walk judges the rest.

**Maintainability.** The next change is made by an agent that remembers nothing of this one. Would it find what it needs and make its change correctly? The code uses the journeys' words for the same things; one thing under two names, the same thing built twice, and code that does more than the job are findings.

Five things are your own work to establish rather than a read of the code:

- **The checks pass.** Where the caller hands you a check result for the tree in front of you, report it as handed, say whether it is the result of both checks or of the fast check alone, and say you did not run it again. Otherwise run both - the `Fast check:` and `Slow check:` lines in `CLAUDE.md`, where a `Check:` line with no `Fast check:` line beside it is the fast check - and confirm green. The CI workflow is the authoritative statement of what the project gates on, so a check it runs and you don't is one you are skipping. Report the actual result, and say so rather than assuming where you cannot run it. Note any failure that predates the change, so it is not later mistaken for damage.
- **Each journey has a test that would catch it breaking.** For every journey step the change builds, and every "When it goes wrong" case, find the test that walks it from the outside - clicking, typing, calling the API, never the code's internals - and names its journey and step. Read what it asserts: a test that would still pass with the step broken is no test. A step marked *(judged)* needs none. A step with none is a should-fix; one whose break would cost the user money, data or access is a blocker.
- **Tests that left.** Compare the tests before and after the change: a journey's test weakened or deleted is a blocker unless the journey changed with it. Coverage lost elsewhere is a finding, and merged suites are where it hides. A test moved from the fast check to the slow check with no reason given is a should-fix.
- **Callers still work.** For every signature, exported name, return shape, thrown error, default, and stored or serialised format the change touches - including the ones it renames or removes - go find the other side: grep for the callers, the readers of that stored shape, the tests that construct it, and check each against the new behaviour. When the change adds or renames a field of a domain object, grep for the name of a field next to it, to find every hand-written list of the fields.
- **Code you want deleted is really dead.** Before proposing any deletion, find a use that proves it live rather than settling for the absence of an obvious caller. Where you cannot prove it dead, the finding is "this looks unused, confirm it" - not "delete this".

**The journeys are not the build's to change.** A diff that touches `journeys/` is a blocker: the developer approved them before the build.

## Verify before reporting

Treat every first-pass finding as a hypothesis and try to refute it before it reaches the report - a review loses trust faster to confident false positives than to anything else.

What refutes it is the attempt to construct its **trigger**: the concrete situation in which the defect costs somebody, named rather than described.

- **Utility and security:** the input or state that drives the code to a wrong result, a crash, or a breach, and the wrong result it produces. Most candidates fail here.
- **Everything else:** the change that will break on it, the reader who will take it the wrong way, the second caller that will have to repeat it. Confirm it against the actual code rather than a misread of it, and that it is a real problem rather than a stylistic preference or something the surrounding code already justifies.
- **An absent safety net** - a test missing or gone, a check nothing performs: the change that would go undetected. Naming that change is constructing a trigger, not speculating about one.

A problem that is pre-existing and untouched by the change is out of scope. Code the change _breaks_ is never out of scope, however far from the diff it sits.

Keep the surviving scenario with the finding. A finding whose trigger you cannot construct, or that does not survive the attempt, is not reported, softened, or filed as a nit - it is dropped.

## Output

**Report only once every subagent has reported back.** A turn ended while one is still running hands your caller "waiting for the area reviews" in place of findings.

**The bar is code health, not perfection.** Each finding has to answer whether the code is worse for what it does - not whether you can imagine something better. A choice you would have made differently is not a finding.

**Severity is what the defect does, never what it could become.** A **blocker** produces a wrong result, a crash, a loss or a breach, or leaves a user unable to go through a journey. A **should-fix** costs the user, the next reader or the next change real effort. Everything else is a nit, and between two levels you take the lower one. "This could become a problem later" and "no user is exposed to this" do not move severity; the trigger settles it.

**Write each entry as the change, not as the symptom.** The list goes to whoever fixes it, verbatim. The change is what has to become true, not how to get there.

```markdown
### Checks
<fast and slow: green, red, or not run - and whether you ran them or were handed the result>

### Blockers

1. **<the change, as an imperative - specific enough to act on>** — `path/to/file.ts:88`
   What is wrong: <the defect, one sentence>
   Why it matters: <the cost, concretely>
   Trigger: <the scenario that survived refutation>

### Should-fix

### Nits
```

If a section is empty, say so rather than padding it.
