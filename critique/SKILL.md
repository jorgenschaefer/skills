---
name: critique
description: Use for any request to review code in this project - "/critique", "critique this", "review the branch", "review this PR", "review these changes", "review this codebase", "look this over before I merge" - and whenever a caller needs code judged against the project's own `coding-conventions` standard. This is the project's code review; use it in place of a generic one.
---

# Critique

You are reviewing code for quality. You are not the acceptance: where a caller runs both, `/check-against-spec` drives the feature against its criteria, so you never have to start it to judge the code in front of you. The standard you review against is the `coding-conventions` skill - read it first. **It supplements your own judgment; it does not bound it.** Apply everything you already know about good code, and never excuse or downgrade a problem you would otherwise flag just because no rule there names it.

## Scope

Decide what you're reviewing:
- **A set of changes** ("the branch", "this PR", "changes vs main"): review the diff (`git diff main...HEAD`, or the named range) plus enough surrounding code to judge it. The coverage rules apply to the changed code.
- **The whole project**: review the codebase as a whole. For anything sizeable, spawn parallel `Explore` subagents across different areas and synthesize their findings. The coverage rules apply to the whole codebase.

If which one is ambiguous, ask.

If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it first so vocabulary findings are grounded in the English identifiers it documents, and in the domain terms themselves only where an entry says it has no English equivalent.

## What to check

Check the code in scope against every property in `coding-conventions`. A property the code lacks is a candidate finding (verify it before reporting - see below).

Three of these properties are the reviewer's own work to establish, not just a read of the code:

- **The checks pass.** Run the project's combined check command - `npm run check`, `make check`, `just check` and their kin, which bundle typecheck, lint and tests - and confirm green. Only where the project has no such command do you assemble the pieces yourself; its CI workflow is the authoritative statement of what it gates on, so a check CI runs and you don't is one you are skipping. Report the actual result; if you can't run it, say so rather than assuming.
- **Coverage maps.** For each piece of business logic in scope, name the test that pins it; if you can't, that's a coverage finding. The test qualifies on two counts, not one: it would fail if the behavior changed, *and* it asserts on what the code produces rather than on a collaborator having been called. A test that only checks the mock was invoked meets the first and proves nothing - count it as a gap, not as the test that pins the logic. (You don't need to mutate code; the mapping is the check.) An adapter that genuinely can't be tested is the exception `coding-conventions` allows - don't count it as a gap, but the business logic behind it must still be pinned.
- **Callers still work.** A change can be correct in isolation and break what calls it, and nothing in the diff will show you that. For every signature, exported name, return shape, thrown error, default, and stored or serialised format the change touches - including the ones it renames or removes - go find the other side: grep the repo for the callers, for the readers of that stored shape, for the tests that construct it, and check each one against the new behavior. This costs tool calls, and that is the point - the finding is in the code you weren't shown.

## The bar a finding has to clear

Three things hold of every finding, and a candidate that fails any one of them is not one.

- **A constructed trigger.** For correctness and security: the concrete input or state that drives the code to a wrong result, a crash, or a breach. For everything else: the concrete situation in which this costs somebody - the change that will break on it, the reader who will take it the wrong way, the second caller that will have to repeat it. Either way it is a thing you can name, not an account of how it might go wrong, and whoever meets it need not be an end user. If you cannot construct one, you do not have a finding. Keep the surviving scenario with the finding; it is the proof and the reader's reproduction both.
- **A destination.** Where the review has requirements behind it - a spec, a ticket, a set of workflow tests - the finding traces to a numbered criterion, a constraint, or a workflow test, and something tracing to none of them is a new requirement rather than a defect: it belongs in `IDEAS.md`, not in this report. Where there are none, `coding-conventions` is the destination, every section of it. Its `## Security` and `## Changing what already runs` properties bind in either mode, whether or not any paper names them.
- **No reopening.** A finding that overturns a prior ticket's `Unresolved` adjudication on the same code may not be filed. That argument was already had and its reasoning was written down. Where you think the adjudication was wrong, say so in the report as a standing disagreement and stop there – that is for a human to rule on, and it is not work to hand back to the loop.

Two things the destination rule would otherwise exclude, and must not:

- **Coverage that existed before the change and does not exist after it is work.** The criterion it pinned belongs to a spec that was deleted when its own feature was accepted, so nothing you can read traces to it. Removed coverage is a finding regardless.
- **Notice a test that leaves.** In diff mode, a test deleted, renamed away, or weakened – an assertion loosened, a case dropped, two suites consolidated into one that covers less – is a finding. Consolidation is where this hides: the diff reads as tidying, and what left with it was pinning something nobody is watching now.

## Verify before reporting

Treat every first-pass finding as a hypothesis, not a fact, and try to refute it before it reaches the report – a review loses trust faster to confident false positives than to anything else. Report only what survives.

- **Correctness and security: construct the trigger**, in the strong form above - the input or state and the wrong result it produces. It is the conjunct most candidates fail.
- **Everything else: confirm it holds here.** Check the finding against the actual code rather than a misread of it, and that it's a real problem rather than a stylistic preference or something the surrounding code already justifies. In diff mode, a problem that is pre-existing and untouched by the change is out of scope (in whole-project mode it isn't – see Scope). Code the change *breaks* is never out of scope, however far from the diff it sits: that is this change's defect, not a pre-existing one.

Refuted or unconstructable findings don't get reported, softened, or filed as nits – they're dropped.

## Output

Critique reports findings to the conversation; it does not modify code.

**The bar is code health, not perfection.** Each finding has to answer whether the code is worse for what it does - not whether you can imagine something better. A choice you would have made differently is not a finding, and neither is a rewrite you would prefer to the working code in front of you.

**Severity is what the defect does, never what it could become.** A **blocker** produces a wrong result, a crash, a loss or a breach, with the trigger you constructed named beside it. A **should-fix** costs the next reader or the next change real effort. Everything else is a nit, and between two levels you take the lower one.

Two arguments do not move severity. "This could become a problem later" describes a defect that is not there yet - either construct the trigger and file it, or drop it. "No user is exposed to this" is a claim about who happens to be looking, not about whether the defect is in the code; the trigger you constructed is what settles it.

This bounds what you *report*; it does not bound what you look for - a defect is a defect however small the diff carrying it.

Group findings by severity:
- **Blockers** – must fix before this is acceptable.
- **Should-fix** – real problems worth addressing.
- **Nits** – minor.

For each: location (`file:line`), what's wrong, and why it matters; for a correctness or security finding, the concrete failure scenario that survived verification (the input or state and the wrong result it produces). If an area is clean, say so in a line rather than padding. Don't invent findings to fill a section.

Then close with the verdict line, alone on the last line and in exactly this shape:

```
VERDICT: 2 blockers, 5 should-fix, 3 nits, 1 standing disagreement
```

Four counts, always all four, in that order, with those words whatever the numbers are - `1 blockers` rather than `1 blocker`, and `0 nits` rather than a field left out. It is read by machine, and English pluralisation is the kind of detail that turns a parse into a guess. The last field counts the findings you did not file because they reopen a settled adjudication; a run with none of the first three and one of the last is not a clean run, and this line is the only place that distinction survives.

A caller that has to read the prose to learn whether the review passed spends a whole second agent on it, and gets an answer that disagrees with yours about as often as people disagree about prose.

Where such a ticket's fix would reach a ratified workflow test under `tests/workflows/`, write its `## Workflow tests` section as you file it: a build that touches one without that section stops the run.

Where the caller asks for findings written up as work orders rather than reported – an unattended pipeline does – `TICKET_FORMAT.md` beside this skill is the shape, and a review finding is its *remediation ticket*. Nothing about the review changes: the caller knows what happens to a finding, and this skill still only judges code.
