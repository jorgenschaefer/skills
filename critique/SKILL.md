---
name: critique
description: Use for any request to review or clean up code - a diff, a branch, a PR or the whole codebase, including "look this over before I merge" - and whenever a caller needs code judged against `CODING_STANDARDS.md`. Use it in place of a generic code review.
---

# Critique

Read this skill's `CODING_STANDARDS.md` first, and `UBIQUITOUS_LANGUAGE.md` where the repo has one. Review against them and everything you already know about good code: a problem no rule names is still reported at full severity.

You change nothing. The output is a list of changes somebody else will make.

## What to check

Where the code in scope is larger than you can hold at once, spawn parallel `Explore` subagents across different areas and synthesize what they bring back - a review that stopped where the context ran out looks exactly like one that found nothing.

A property the code lacks is a candidate finding. Six things are your own work to establish rather than a read of the code:

- **The product, where a user sees the change.** Drive it in the running app and judge what you see against the standard: every screen the change touches - or the ones your caller names, as after a round of fixes - at the narrowest and widest supported size, with the feedback after each action. A builder checking its own work cannot stand in for this.

  The driving goes to one subagent with a fresh context. Every turn of it re-reads the context it runs in, and yours holds the diff and the standard, so every step you drive yourself pays for both. Write it the scenarios - each screen, each size, the actions, and what should be visible after each - and point it at how the project starts the app: a `run` skill, `CLAUDE.md`, the README. It gets neither the diff nor the standard, judges nothing and spawns nothing; it reports, step by step, what happened and what it saw, the console errors, and the path of each screenshot. Open the last screenshot of each screen at each size where how it looks is part of the judgement, not every step. Where it cannot get the app running, say so rather than judging the screens from the diff.

- **The checks pass.** Where the caller hands you the result of the project's combined check command for the tree in front of you, report it as handed and say you did not run it again. Otherwise run that command - the one bundling typecheck, lint and tests - and confirm green; where there is none, assemble the pieces yourself. The CI workflow is the authoritative statement of what the project gates on, so a check it runs and you don't is one you are skipping. Report the actual result, and say so rather than assuming where you cannot run it. Note any failure that predates the code in scope, so it is not later mistaken for damage.

  What the suite does not cover bounds what you may propose: a change to code no test would catch a regression in is not provably safe, so say so and drop your confidence in it. Where the project has little or no coverage, say that up front.

- **Tests that left.** Coverage that existed before the change and does not after it is work. A test deleted, renamed away, or weakened - an assertion loosened, a case dropped, two suites consolidated into one that covers less - is a finding. Consolidation is where this hides, because the diff reads as tidying.
- **Callers still work.** For every signature, exported name, return shape, thrown error, default, and stored or serialised format the change touches - including the ones it renames or removes - go find the other side: grep for the callers, the readers of that stored shape, the tests that construct it, and check each against the new behavior. This costs tool calls, and that is the point - the finding is in the code you weren't shown. When the change adds or renames a field of a domain object, grep for the name of a field next to it: every hand-written list of the fields outside the type's own file has to change in the same diff or check its own completeness.
- **Code you want deleted is really dead.** Before proposing any deletion, find a use that proves it live rather than settling for the absence of an obvious caller, and hunt the paths the standard names as only _looking_ dead. Where you cannot prove it dead, the finding is "this looks unused, confirm it" - not "delete this".
- **Sizes.** For every file and directory the change adds to, check its size against the limits in the standard - the diff shows neither.

## Verify before reporting

Treat every first-pass finding as a hypothesis and try to refute it before it reaches the report - a review loses trust faster to confident false positives than to anything else.

What refutes it is the attempt to construct its **trigger**: the concrete situation in which the defect costs somebody, named rather than described.

- **Correctness and security:** the input or state that drives the code to a wrong result, a crash, or a breach, and the wrong result it produces. Most candidates fail here.
- **Everything else:** the change that will break on it, the reader who will take it the wrong way, the second caller that will have to repeat it. Confirm it against the actual code rather than a misread of it, and that it is a real problem rather than a stylistic preference or something the surrounding code already justifies.
- **An absent safety net** - coverage missing or gone, a check nothing performs: the change that would go undetected, or the input nothing would catch. Naming that change is constructing a trigger, not speculating about one, and a finding of this kind is not weaker for it.

Where you were handed a change to review, a problem that is pre-existing and untouched by it is out of scope; where you were handed a whole project, nothing is out of scope for being pre-existing. Code the change _breaks_ is never out of scope, however far from the diff it sits: that is this change's defect, not a pre-existing one.

Keep the surviving scenario with the finding. A finding whose trigger you cannot construct, or that does not survive the attempt, is not reported, softened, or filed as a nit - it is dropped.

## Output

**Spawn every subagent in the foreground, and report only once all of them have reported back.** Several started in one message run in parallel, and the call returns when the last one does - so no `run_in_background`, and no waiting on them with `sleep`. Your last message is the review: a turn ended while one is still running hands your caller "waiting for the area reviews" in place of findings, and leaves that subagent working with nobody to read it.

**The bar is code health, not perfection.** Each finding has to answer whether the code is worse for what it does - not whether you can imagine something better. A choice you would have made differently is not a finding, and neither is a rewrite you would prefer to the working code in front of you.

**Severity is what the defect does, never what it could become.** A **blocker** produces a wrong result, a crash, a loss or a breach. A **should-fix** costs the next reader or the next change real effort. Everything else is a nit, and between two levels you take the lower one.

Two arguments do not move severity. "This could become a problem later" describes a defect that is not there yet - either construct the trigger and file it, or drop it. "No user is exposed to this" is a claim about who happens to be looking, not about whether the defect is in the code; the trigger settles it, and whoever meets it need not be an end user.

This bounds what you _report_, not what you look for - a defect is a defect however small the diff carrying it.

**Write each entry as the change, not as the symptom.** The list goes to a planning session verbatim. The change is what has to become true, not how to get there: designing the fix is the planner's work, and you have read the code but not the problem it was solving.

```markdown
### Blockers

1. **<the change, as an imperative - specific enough to act on>** — `path/to/file.ts:88`
   What is wrong: <the defect, one sentence>
   Why it matters: <the cost, concretely>
   Trigger: <the scenario that survived refutation - for correctness and
             security, the input or state and the wrong result it produces>

### Should-fix

### Nits
```

If a section is empty, say so rather than padding it.
