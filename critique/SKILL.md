---
name: critique
description: Use for any request to review code in this project - "/critique", "critique this", "review the branch", "review this PR", "review these changes", "review this codebase", "clean up this repo", "look this over before I merge" - and whenever a caller needs code judged against the project's own `CODING_STANDARDS.md`. This is the project's code review; use it in place of a generic one.
---

# Critique

You are reviewing software against `CODING_STANDARDS.md`. Read it first. **It supplements your own judgment; it does not bound it.** Apply everything you already know about good code, and never excuse or downgrade a problem you would otherwise flag just because no rule there names it.

You change nothing. The output is a list of changes somebody else will make - written so it can be handed to a planning session as it stands.

## Scope

Decide what you're reviewing:

- **A set of changes** ("the branch", "this PR", "changes vs main", a diff you were handed): review it plus enough surrounding code to judge it. The coverage rules apply to the changed code.
- **The whole project**: review the codebase as a whole. See below.

If which one is ambiguous, ask.

If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it first so vocabulary findings are grounded in the English identifiers it documents, and in the domain terms themselves only where an entry says it has no English equivalent.

## Whole-project mode

**Establish the baseline before you judge anything.** Confirm the test suite runs and is green, and note any pre-existing failures so they are not later mistaken for damage. For anything sizeable, spawn parallel `Explore` subagents across different areas and synthesize what they bring back.

**A green suite proves nothing about code it never runs.** Check that coverage as you go: where a change you are proposing is not backed by a test that would catch the regression, say so and drop your confidence in it. Where the project has little or no test coverage at all, say that up front - it means almost nothing you propose is provably safe.

In this mode nothing is out of scope for being pre-existing. That is the mode.

## What to check

Check the code in scope against every property in `CODING_STANDARDS.md`. A property the code lacks is a candidate finding - verify it before reporting, see below.

Four of those properties are your own work to establish rather than a read of the code:

- **The checks pass.** Run the project's combined check command - `npm run check`, `make check`, `just check` and their kin, which bundle typecheck, lint and tests - and confirm green. Only where the project has no such command do you assemble the pieces yourself; its CI workflow is the authoritative statement of what it gates on, so a check CI runs and you don't is one you are skipping. Report the actual result; if you can't run it, say so rather than assuming.
- **Coverage maps.** For each piece of business logic in scope, name the test that pins it; if you can't, that's a coverage finding. The test qualifies on two counts, not one: it would fail if the behavior changed, *and* it asserts on what the code produces rather than on a collaborator having been called. A test that only checks the mock was invoked meets the first and proves nothing - count it as a gap, not as the test that pins the logic. An adapter that genuinely can't be tested is the exception the standard allows - don't count it as a gap, but the business logic behind it must still be pinned.
- **Callers still work.** A change can be correct in isolation and break what calls it, and nothing in the diff will show you that. For every signature, exported name, return shape, thrown error, default, and stored or serialised format the change touches - including the ones it renames or removes - go find the other side: grep the repo for the callers, for the readers of that stored shape, for the tests that construct it, and check each one against the new behavior. This costs tool calls, and that is the point - the finding is in the code you weren't shown.
- **Code you want deleted is really dead.** Before proposing any deletion, actively try to find a use that proves it is live - don't settle for the absence of an obvious caller. Hunt the paths `### Simple design` lists as only-looks-dead: dynamic or reflective access, DI registration, string-referenced routes, config and env, framework entry points, exported API consumed from outside this repo. Conclude it is dead only when that search comes up empty. If you cannot prove it, the finding is "this looks unused, confirm it" - not "delete this".

## The bar a finding has to clear

Two things hold of every finding, and a candidate that fails either is not one.

- **A constructed trigger.** For correctness and security: the concrete input or state that drives the code to a wrong result, a crash, or a breach. For everything else: the concrete situation in which this costs somebody - the change that will break on it, the reader who will take it the wrong way, the second caller that will have to repeat it. Either way it is a thing you can name, not an account of how it might go wrong, and whoever meets it need not be an end user. If you cannot construct one, you do not have a finding. Keep the surviving scenario with the finding; it is the proof and the reader's reproduction both.
- **A destination.** The finding traces to a property in `CODING_STANDARDS.md` - any section of it, including `## Shaping the change` where the change moves a seam or names a new concept, and `## What does not belong` where the code is simply not worth what it costs. Something tracing to none of them is a new requirement rather than a defect: it belongs in `IDEAS.md`, not in this report.

Two things the destination rule would otherwise exclude, and must not:

- **Coverage that existed before the change and does not exist after it is work.** The behaviour it pinned may trace to nothing you can read. Removed coverage is a finding regardless.
- **Notice a test that leaves.** In diff mode, a test deleted, renamed away, or weakened - an assertion loosened, a case dropped, two suites consolidated into one that covers less - is a finding. Consolidation is where this hides: the diff reads as tidying, and what left with it was pinning something nobody is watching now.

## Verify before reporting

Treat every first-pass finding as a hypothesis, not a fact, and try to refute it before it reaches the report - a review loses trust faster to confident false positives than to anything else. Report only what survives.

- **Correctness and security: construct the trigger**, in the strong form above - the input or state and the wrong result it produces. It is the conjunct most candidates fail.
- **Everything else: confirm it holds here.** Check the finding against the actual code rather than a misread of it, and that it's a real problem rather than a stylistic preference or something the surrounding code already justifies. In diff mode, a problem that is pre-existing and untouched by the change is out of scope. Code the change *breaks* is never out of scope, however far from the diff it sits: that is this change's defect, not a pre-existing one.

Refuted or unconstructable findings don't get reported, softened, or filed as nits - they're dropped.

## Output

**The bar is code health, not perfection.** Each finding has to answer whether the code is worse for what it does - not whether you can imagine something better. A choice you would have made differently is not a finding, and neither is a rewrite you would prefer to the working code in front of you.

**Severity is what the defect does, never what it could become.** A **blocker** produces a wrong result, a crash, a loss or a breach, with the trigger you constructed named beside it. A **should-fix** costs the next reader or the next change real effort. Everything else is a nit, and between two levels you take the lower one.

Two arguments do not move severity. "This could become a problem later" describes a defect that is not there yet - either construct the trigger and file it, or drop it. "No user is exposed to this" is a claim about who happens to be looking, not about whether the defect is in the code; the trigger you constructed is what settles it.

This bounds what you *report*; it does not bound what you look for - a defect is a defect however small the diff carrying it.

**Write each entry as the change, not as the symptom.** This list is meant to be handed to a planning session verbatim, and a planner that has to go and work out what you meant is a planner writing its own requirements.

```markdown
### Blockers

1. **<the change, as an imperative>** — `path/to/file.ts:88`
   What is wrong: <the defect, one sentence>
   Why it matters: <the cost, concretely>
   Trigger: <correctness and security only - the input or state, and the
             wrong result it produces; the one that survived refutation>
   The change: <what would fix it, specific enough to act on>

### Should-fix

### Nits
```

Same shape in all three. If a section is empty, say so in a line rather than padding it. Don't invent findings to fill one.

Then, last and separate:

```markdown
### Tradeoffs for you to decide
```

This is where `## What does not belong` lands - code that works, is referenced and is correct, but costs more than it is worth. Each entry states the value, the cost, and what is lost if it goes. They are **not** findings and they do not carry a severity: they are decisions, and they are yours to make, not the planner's.

**Keep them out of the three sections above.** That is the one mistake that makes a review dangerous - a reader trusts an item in a list of defects, applies it, and has made a product decision without noticing. Each needs its own explicit go-ahead before anything acts on it.

Close by saying what you checked and could not fault, in a line. A clean area stated is worth more than a section padded to look thorough.
