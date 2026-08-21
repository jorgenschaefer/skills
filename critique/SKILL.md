---
name: critique
description: Use when reviewing code for quality – a set of changes or a whole project. Triggers on "/critique", "critique this", "review the branch/PR/changes", "review this codebase".
---

# Critique

You are reviewing code for quality. The standard you review against is the `coding-conventions` skill (`coding-conventions/SKILL.md`) - read it first. **It supplements your own judgment; it does not bound it.** Apply everything you already know about good code, and never excuse or downgrade a problem you would otherwise flag just because no rule there names it.

## Scope

Decide what you're reviewing:
- **A set of changes** ("the branch", "this PR", "changes vs main"): review the diff (`git diff main...HEAD`, or the named range) plus enough surrounding code to judge it. The coverage rules apply to the changed code.
- **The whole project**: review the codebase as a whole. For anything sizeable, spawn parallel `Explore` subagents across different areas and synthesize their findings. The coverage rules apply to the whole codebase.

If which one is ambiguous, ask.

If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it first so vocabulary findings are grounded in the project's actual terms.

## What to check

Check the code in scope against every property in `coding-conventions`. A property the code lacks is a candidate finding (verify it before reporting - see below).

Two of these properties are the reviewer's own work to establish, not just a read of the code:

- **The checks pass.** Run the project's combined check command - `npm run check`, `make check`, `just check` and their kin, which bundle typecheck, lint and tests - and confirm green. Only where the project has no such command do you assemble the pieces yourself; its CI workflow is the authoritative statement of what it gates on, so a check CI runs and you don't is one you are skipping. Report the actual result; if you can't run it, say so rather than assuming.
- **Coverage maps.** For each piece of business logic in scope, name the test that pins it; if you can't, that's a coverage finding. The test qualifies on two counts, not one: it would fail if the behavior changed, *and* it asserts on what the code produces rather than on a collaborator having been called. A test that only checks the mock was invoked meets the first and proves nothing - count it as a gap, not as the test that pins the logic. (You don't need to mutate code; the mapping is the check.) An adapter that genuinely can't be tested is the exception `coding-conventions` allows - don't count it as a gap, but the business logic behind it must still be pinned.

## Verify before reporting

Treat every first-pass finding as a hypothesis, not a fact, and try to refute it before it reaches the report – a review loses trust faster to confident false positives than to anything else. Report only what survives.

- **Correctness and security: construct the trigger.** Name the concrete input or state that drives the code to the wrong result, a crash, or the breach. If you can't construct one, you don't have a finding – drop it. Keep the surviving scenario with the finding; it is both the proof and the reader's reproduction.
- **Everything else: confirm it holds here.** Check the finding against the actual code rather than a misread of it, and that it's a real problem rather than a stylistic preference or something the surrounding code already justifies. In diff mode, a problem that is pre-existing and untouched by the change is out of scope (in whole-project mode it isn't – see Scope).

Refuted or unconstructable findings don't get reported, softened, or filed as nits – they're dropped.

## Output

Critique reports findings to the conversation; it does not modify code.

**The bar is code health, not perfection.** Each finding has to answer whether the code is worse for what it does - not whether you can imagine something better. A choice you would have made differently is not a finding, and neither is a rewrite you would prefer to the working code in front of you. Severity follows consequence: assign it by what happens if nobody fixes this. A blocker breaks something, loses or exposes data, or lets something through. A should-fix costs the next reader or the next change real effort. Everything else is a nit, and between two levels you take the lower one. This bounds what you *report*; it does not bound what you look for - a defect is a defect however small the diff carrying it.

Group findings by severity:
- **Blockers** – must fix before this is acceptable.
- **Should-fix** – real problems worth addressing.
- **Nits** – minor.

For each: location (`file:line`), what's wrong, and why it matters; for a correctness or security finding, the concrete failure scenario that survived verification (the input or state and the wrong result it produces). If an area is clean, say so in a line rather than padding. Don't invent findings to fill a section.
