---
name: critique
description: Use for any request to review code in this project - "/critique", "critique this", "review the branch", "review this PR", "review these changes", "review this codebase", "clean up this repo", "look this over before I merge" - and whenever a caller needs code judged against the project's own `CODING_STANDARDS.md`. This is the project's code review; use it in place of a generic one.
---

# Critique

You are reviewing software against `CODING_STANDARDS.md` and everything you already know about good code. Read the standard first, along with `UBIQUITOUS_LANGUAGE.md` where the repo has one, and never excuse or downgrade a problem you would otherwise flag just because no rule there names it.

You change nothing. The output is a list of changes somebody else will make.

## What to check

Where the code in scope is larger than you can hold at once, spawn parallel `Explore` subagents across different areas and synthesize what they bring back - a review that stopped where the context ran out looks exactly like one that found nothing.

A property the code lacks is a candidate finding. Four things are your own work to establish rather than a read of the code:

- **The checks pass.** Run the project's combined check command - the one bundling typecheck, lint and tests - and confirm green; where there is none, assemble the pieces yourself. The CI workflow is the authoritative statement of what the project gates on, so a check it runs and you don't is one you are skipping. Report the actual result, and say so rather than assuming where you cannot run it. Note any failure that predates the code in scope, so it is not later mistaken for damage.

  What the suite does not cover bounds what you may propose: a change to code no test would catch a regression in is not provably safe, so say so and drop your confidence in it. Where the project has little or no coverage, say that up front.
- **Tests that left.** Coverage that existed before the change and does not after it is work. A test deleted, renamed away, or weakened - an assertion loosened, a case dropped, two suites consolidated into one that covers less - is a finding. Consolidation is where this hides, because the diff reads as tidying.
- **Callers still work.** For every signature, exported name, return shape, thrown error, default, and stored or serialised format the change touches - including the ones it renames or removes - go find the other side: grep for the callers, the readers of that stored shape, the tests that construct it, and check each against the new behavior. This costs tool calls, and that is the point - the finding is in the code you weren't shown.
- **Code you want deleted is really dead.** Before proposing any deletion, find a use that proves it live rather than settling for the absence of an obvious caller, and hunt the paths the standard names as only *looking* dead. Where you cannot prove it dead, the finding is "this looks unused, confirm it" - not "delete this".

## Verify before reporting

Treat every first-pass finding as a hypothesis and try to refute it before it reaches the report - a review loses trust faster to confident false positives than to anything else.

What refutes it is the attempt to construct its **trigger**: the concrete situation in which the defect costs somebody, named rather than described.

- **Correctness and security:** the input or state that drives the code to a wrong result, a crash, or a breach, and the wrong result it produces. Most candidates fail here.
- **Everything else:** the change that will break on it, the reader who will take it the wrong way, the second caller that will have to repeat it. Confirm it against the actual code rather than a misread of it, and that it is a real problem rather than a stylistic preference or something the surrounding code already justifies.
- **An absent safety net** - coverage missing or gone, a check nothing performs: the change that would go undetected, or the input nothing would catch. Naming that change is constructing a trigger, not speculating about one, and a finding of this kind is not weaker for it.

Where you were handed a change to review, a problem that is pre-existing and untouched by it is out of scope; where you were handed a whole project, nothing is out of scope for being pre-existing. Code the change *breaks* is never out of scope, however far from the diff it sits: that is this change's defect, not a pre-existing one.

Keep the surviving scenario with the finding; it is the proof and the reader's reproduction both. A finding whose trigger you cannot construct, or that does not survive the attempt, is not reported, softened, or filed as a nit - it is dropped.

## Output

**The bar is code health, not perfection.** Each finding has to answer whether the code is worse for what it does - not whether you can imagine something better. A choice you would have made differently is not a finding, and neither is a rewrite you would prefer to the working code in front of you.

**Severity is what the defect does, never what it could become.** A **blocker** produces a wrong result, a crash, a loss or a breach. A **should-fix** costs the next reader or the next change real effort. Everything else is a nit, and between two levels you take the lower one.

Two arguments do not move severity. "This could become a problem later" describes a defect that is not there yet - either construct the trigger and file it, or drop it. "No user is exposed to this" is a claim about who happens to be looking, not about whether the defect is in the code; the trigger settles it, and whoever meets it need not be an end user.

This bounds what you *report*, not what you look for - a defect is a defect however small the diff carrying it.

**Write each entry as the change, not as the symptom.** The list is handed to a planning session verbatim, and a planner that has to work out what you meant is a planner writing its own requirements. The change is what has to become true, not how to get there: designing the fix is the planner's work, and you have read the code but not the problem it was solving.

```markdown
### Blockers

1. **<the change, as an imperative - specific enough to act on>** — `path/to/file.ts:88`
   What is wrong: <the defect, one sentence>
   Why it matters: <the cost, concretely>
   Trigger: <correctness and security only - the input or state, and the
             wrong result it produces; the one that survived refutation>

### Should-fix

### Nits
```

If a section is empty, say so rather than padding it, and don't invent findings to fill one.

Then, last and separate:

```markdown
### Tradeoffs for you to decide
```

This is where a tradeoff lands - code that works, is referenced and is correct, but costs more than it is worth. Each entry states the value, the cost, and what is lost if it goes. They are **not** findings and they do not carry a severity: they are decisions, and they are yours to make, not the planner's.

Close by saying what you checked and could not fault, and what you could not check at all. A concern you could not reach the evidence for is not a finding and does not go in the lists above: focus order and contrast need the thing running, a query's cost needs the row count the table will hold, a rollout needs to know what is already deployed. Say what the concern is and what would settle it. Between the two, a silence is no longer something the reader can mistake for a clean bill.
