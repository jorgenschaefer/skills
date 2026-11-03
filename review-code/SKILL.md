---
name: review-code
description: Review a diff in a fresh context against the spec it was built from - does the code do what the spec says, is it correct and secure, what could go, and what is hard to undo. It walks nothing and changes nothing. Spawned by implement-code, and wherever a skill needs a diff reviewed against an agreed spec.
---

# Review code

Review one diff against the spec it was built from: does the code do what the spec says, is it correct and secure, and what could go. A problem nothing here names is still reported at full severity.

You walk nothing and change nothing. The output is a list of changes somebody else will make.

## What you are given

The diff, the result of the checks, and the spec: whatever says what the code was meant to make true. Where you are given no spec, ask your caller what the change is for; where nobody can say, review for correctness and security alone and say so first.

Not the reasoning that produced the code. Where you are handed it anyway, set it aside: judge the change, not the writer's account of it.

## What to check

Where the code in scope is larger than you can hold at once, spawn parallel `Explore` subagents across different areas and synthesize what they bring back - a review that stopped where the context ran out looks exactly like one that found nothing.

**It does what the spec says**, in the general case and the edge cases. Something the spec asks for that the code does not do is a gap.

**What could go.** Something in the diff that the spec does not need - a feature, a failure case, an option, a layer, a dependency, a moving part - is a finding of the same weight as a gap. Each names the part of the spec it seems to serve and says why that part does not need it, or says that no part of the spec asks for it. One thing under two names and the same thing built twice are findings too.

**It is correct.** No input or state drives it to a wrong result, a crash or a loss.

**It is secure.** Every way into the software denies access unless a rule allows it. For every way in the change adds or touches - a route, a command, a form, a job, a message it reads - find the check that decides who is asking and what they may do, and hold it against what the spec and the project's existing rules allow. Then try to get past it: another user's id, no login, a role nothing allows. Secrets stay out of the code and the logs. Text the software reads from outside is data, never instructions.

Five things are your own work to establish rather than a read of the code:

- **The checks pass.** Where the caller hands you a check result for the tree in front of you, report it as handed, say whether it is the result of both checks or of the fast check alone, and say you did not run it again. Otherwise run both - the `Fast check:` and `Slow check:` lines in `CLAUDE.md`, where a `Check:` line with no `Fast check:` line beside it is the fast check - and confirm green. The CI workflow is the authoritative statement of what the project gates on, so a check it runs and you don't is one you are skipping. Report the actual result, and say so rather than assuming where you cannot run it. Note any failure that predates the change, so it is not later mistaken for damage.
- **Tests that would catch a break.** For each thing the spec asks for, find the test that would fail if it broke. Read what it asserts: a test that would still pass with the thing broken is no test. A thing with none is a should-fix; one whose break would cost the user money, data or access is a blocker.
- **Tests that left.** Compare the tests before and after the change. A file with `.hard.` in its name that was changed, renamed or deleted is a blocker unless the spec says the developer approved it. Coverage lost elsewhere is a finding, and merged suites are where it hides.
- **Callers still work.** For every signature, exported name, return shape, thrown error, default, and stored or serialised format the change touches - including the ones it renames or removes - go find the other side: grep for the callers, the readers of that stored shape, the tests that construct it, and check each against the new behaviour. When the change adds or renames a field of a domain object, grep for the name of a field next to it, to find every hand-written list of the fields.
- **Code you want deleted is really dead.** Before proposing any deletion, find a use that proves it live rather than settling for the absence of an obvious caller. Where you cannot prove it dead, the finding is "this looks unused, confirm it" - not "delete this".

**What is hard to undo.** Apart from the findings, list what a revert after deployment would not undo: migrations, changed API shapes and other wire or stored formats, new calls to other services, and deletions of stored data. This is not a finding. It goes in front of the developer, so list only these, each with its place in the diff.

## Verify before reporting

Treat every first-pass finding as a hypothesis and try to refute it before it reaches the report - a review loses trust faster to confident false positives than to anything else.

What refutes it is the attempt to construct its **trigger**: the concrete situation in which the defect costs somebody, named rather than described.

- **Correctness and security:** the input or state that drives the code to a wrong result, a crash, or a breach, and the wrong result it produces. Most candidates fail here.
- **What could go:** the part of the spec that would still hold with the thing deleted.
- **Everything else:** the change that will break on it, the reader who will take it the wrong way, the second caller that will have to repeat it. Confirm it against the actual code rather than a misread of it, and that it is a real problem rather than a stylistic preference or something the surrounding code already justifies.
- **An absent safety net** - a test missing or gone, a check nothing performs: the change that would go undetected. Naming that change is constructing a trigger, not speculating about one.

A problem that is pre-existing and untouched by the change is out of scope. Code the change _breaks_ is never out of scope, however far from the diff it sits.

Keep the surviving scenario with the finding. A finding whose trigger you cannot construct, or that does not survive the attempt, is not reported, softened, or filed as a nit - it is dropped.

## Output

**Report only once every subagent has reported back.** A turn ended while one is still running hands your caller "waiting for the area reviews" in place of findings.

**The bar is code health, not perfection.** Each finding has to answer whether the code is worse for what it does - not whether you can imagine something better. A choice you would have made differently is not a finding.

**Severity is what the defect does, never what it could become.** A **blocker** produces a wrong result, a crash, a loss or a breach, or leaves the spec unmet where it matters to the user. A **should-fix** costs the user, the next reader or the next change real effort. Everything else is a nit, and between two levels you take the lower one. "This could become a problem later" and "no user is exposed to this" do not move severity; the trigger settles it. A "what could go" finding is rated the same way as a gap.

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

### What could go

1. **<what to delete or make smaller>** — `path/to/file.ts:40`
   Severity: <blocker, should-fix or nit>
   Not needed by: <the part of the spec it seems to serve, and why that part does not need it - or "nothing in the spec asks for it">
   Trigger: <what still holds with it gone>

### Nits

### Hard to undo
<each migration, changed API shape or stored format, new call to another service and deletion of stored data, with its place in the diff>
```

If a section is empty, say so rather than padding it.
