---
name: critique
description: Use when reviewing code for quality – either a set of changes (a branch diff vs main, a PR) or a whole project. Triggers on "/critique", "critique this", "review the branch/PR/changes", "review this codebase".
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

Check the code in scope against every property in `coding-conventions` - simple design, structure and locality, domain layering, clarity and least astonishment, test coverage, and security. A property the code lacks is a candidate finding (verify it before reporting - see below). Apply your own standards on top; the file focuses attention, it doesn't limit it.

Two of these properties are the reviewer's own work to establish, not just a read of the code:

- **Tests pass.** Run the project's test command and confirm green. Report the actual result; if you can't run it, say so rather than assuming.
- **Coverage maps.** For each piece of business logic in scope, name the test that pins it - one that would fail if the behavior changed. If you can't, that's a coverage finding. (You don't need to mutate code; the mapping is the check.) External adapters that genuinely can't be tested may be untested; the business logic behind them must not.

## Verify before reporting

Treat every first-pass finding as a hypothesis, not a fact, and try to refute it before it reaches the report – a review loses trust faster to confident false positives than to anything else. Report only what survives.

- **Correctness and security: construct the trigger.** Name the concrete input or state that drives the code to the wrong result, a crash, or the breach. If you can't construct one, you don't have a finding – drop it. Keep the surviving scenario with the finding; it is both the proof and the reader's reproduction.
- **Everything else: confirm it holds here.** Check the finding against the actual code rather than a misread of it, and that it's a real problem rather than a stylistic preference or something the surrounding code already justifies. In diff mode, a problem that is pre-existing and untouched by the change is out of scope (in whole-project mode it isn't – see Scope).

Refuted or unconstructable findings don't get reported, softened, or filed as nits – they're dropped.

## Output

Critique reports findings to the conversation; it does not modify code. Group findings by severity:
- **Blockers** – must fix before this is acceptable.
- **Should-fix** – real problems worth addressing.
- **Nits** – minor.

For each: location (`file:line`), what's wrong, and why it matters; for a correctness or security finding, the concrete failure scenario that survived verification (the input or state and the wrong result it produces). If an area is clean, say so in a line rather than padding. Don't invent findings to fill a section.
