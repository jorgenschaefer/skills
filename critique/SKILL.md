---
name: critique
description: Use when reviewing code for quality – either a set of changes (a branch diff vs main, a PR) or a whole project. Triggers on "/critique", "critique this", "review the branch/PR/changes", "review this codebase".
---

# Critique

You are reviewing code for quality. **These standards supplement your own judgment – they do not bound it.** Apply everything you already know about good code. The rules below sharpen focus on things that are easy to miss or where this project has a specific preference. Never excuse or downgrade a problem you would otherwise flag just because no rule here names it.

## Scope

Decide what you're reviewing:
- **A set of changes** ("the branch", "this PR", "changes vs main"): review the diff (`git diff main...HEAD`, or the named range) plus enough surrounding code to judge it. The coverage rules apply to the changed code.
- **The whole project**: review the codebase as a whole. For anything sizeable, spawn parallel `Explore` subagents across different areas and synthesize their findings. The coverage rules apply to the whole codebase.

If which one is ambiguous, ask.

If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it first so vocabulary findings are grounded in the project's actual terms.

## What to check

In addition to your own standards, focus on these.

### Correctness
- Run the project's test command and confirm green. Report the actual result; if you can't run it, say so rather than assuming.
- Every piece of business logic in the scope under review is pinned by a test: removing or changing it would make a test fail. For each piece, name the test that pins it; if you can't, that's a coverage finding. (You don't need to mutate code – the mapping is the check.)
- External adapters – the thin edge that talks to a third-party SDK, the network, or IO – may be untested when they genuinely can't be tested at all. The business logic behind them must be fully tested.

### Maintainability
- **Intent is obvious.** No gap between what the code says and what it does. Names are descriptive, and the wider a name's scope the more descriptive it should be (`i` is fine for a loop index, not for a function).
- **Names reuse the established vocabulary.** Use the term already in use for a concept rather than coining a synonym. If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, names in code, tests, and comments should match its terms; a fresh name for a concept the glossary already defines is a finding.
- **Reads top to bottom.** Files open with the abstract idea and grow concrete; a helper sits below its caller. Needing to jump between files to follow the logic is a smell.
- **What changes together lives together** – same file or folder; tests co-located with the code they test.
- **Duplication is justified or removed.** Two copies that will change for the same reason belong in one place – flag from the second copy on. Duplication is acceptable only when the copies will change for *different* reasons; then prefer it over the wrong abstraction.
- **Business logic talks to external systems through intention-revealing functions, not raw framework calls.** It calls domain-named queries like `getActiveFoo()` or `getFooByCompanyId()`: the wrapper names the intent in domain terms and keeps framework/ORM detail out of the logic.
  - A passthrough that just relays a framework query object (`getFoo(prismaWhereClause)` → `prisma.foo.findMany(...)`) does not count: it leaks the composable ORM query through a thin disguise.
  - Ideally the wrapper returns a domain type rather than a framework type (same shape is fine). This is about abstraction, not dependency injection: don't expect injected dependencies, and don't over-abstract – a named query returning a domain type is enough (YAGNI).
- **YAGNI.** Flag speculative generality – code added for an imagined future need.
- **KISS.** Prefer the simplest thing that works. Flag needless complexity – an abstraction where a function would do, convoluted control flow, a clever construct where plain code reads better – even when nothing is speculative.
- **No dead code.** Code that is unreachable or never referenced is a finding. Before flagging, rule out non-obvious use: dynamic/reflective access, DI registration, string-referenced routes/config/env, framework entry points, and exported API consumed from outside this repo (an exported symbol with no internal caller is not dead).

### Security
- Every internet-reachable endpoint enforces authentication and authorization.
- All user input is validated and sanitized.

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
