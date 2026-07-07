---
name: cleanup-repo
description: Clean up the current project by finding code to delete (dead code,
  unrequired code, absence-asserting tests), code to refactor (YAGNI and KISS
  violations), and code whose complexity outweighs its value, then producing a
  reviewable plan. Triggers on "/cleanup-repo", "clean up this project", "find
  dead code", "what can we delete", "simplify this codebase".
disable-model-invocation: true
---

# Cleanup Repo

You are a senior software developer. Your job is to clean up the current project (directory).
Work in two passes – find, then plan – and stop at the plan for approval before changing anything.

The findings fall into three tiers by safety, and you must keep them apart. Tiers 1 and 2 are
safe – applied correctly they never change what the system does. Tier 3 is a judgment call that *may* remove
working, correct functionality on purpose. Mixing a tier-3 tradeoff into the safe tiers is the one
mistake that makes a cleanup plan dangerous – a reader trusts a "safe" item and applies it without
realizing they made a product decision. Never let that happen.

## Before starting

Confirm the test suite runs and is green. This baseline is what "without breaking requirements"
is measured against; note any pre-existing failures so they aren't mistaken for cleanup damage.

The safety of tiers 1 and 2 rests on tests actually exercising the code you touch – a green suite
proves nothing about code it never runs. Check that coverage as you go: where a deletion or refactor
is not backed by a test that would catch the regression, drop its confidence to **needs
confirmation**. If the project has little or no test coverage, say so upfront – it means almost
nothing here is provably safe, and most items belong in tier 3 or **needs confirmation**.

For a sizeable project, spawn parallel `Explore` subagents across different areas and synthesize.

## Tier 1 – code suitable for deletion (safe)

- **Dead code** – unreachable, or never referenced.
- **Code deletable without breaking requirements** – where "requirements" means the tests, the
  public contract, and any written spec. Absence of a test is not license to delete: code that is
  still referenced or reached by users but that no test or spec pins down is a tier-3 tradeoff, not
  a Tier 1 **delete** – say so and ask rather than assuming.
- **Tests that assert the absence of code** – e.g. a test that a removed endpoint 404s – unless
  reappearance of that code would be a real regression (a security or correctness guarantee); keep
  those.

Before proposing any deletion, verify it is actually unreferenced. Account for non-obvious use:
dynamic/reflective access, DI registration, string-referenced routes/config/env, framework entry
points, and public API consumed from outside this repo (an exported symbol with no internal caller
is not dead). If you cannot prove it is safe, mark it **needs confirmation**, not **delete**.

## Tier 2 – code suitable for behavior-preserving refactor (safe)

- **YAGNI violation** – code that exists solely for an eventuality that is not here yet.
- **KISS violation** – code more complicated than the current requirements need, including trivial
  functions or modules whose naming and abstraction do not improve readability.

Refactors here are behavior-preserving, proven by the existing green tests. If a change would alter
behavior, it is not a tier-2 refactor – it belongs in tier 3 or nowhere.

## Tier 3 – code whose complexity outweighs its value (judgment, may reduce functionality)

For each area, weigh two things against each other:

- **What it brings** – how important is it to the project's functionality and usability?
- **What it costs** – how complex, hard to understand, and hard to maintain is it?

Where the cost clearly outweighs the value, propose simplifying or removing it – *even if the code
works, is referenced, and is correct*. This is the lens tiers 1 and 2 cannot reach: it can drop a
feature that is used but not worth what it costs to carry.

Because these items can reduce functionality, they carry strict handling:

- They are **always `needs confirmation`**, never `delete` or `safe`.
- They are framed as a **tradeoff decision for the user**, not an instruction – state the value, the
  cost, and what is lost if it goes, then let the user choose.
- They are **never auto-applied**, even after the rest of the plan is approved. Each needs its own
  explicit go-ahead.

## Output

Produce a reviewable plan, organized by tier in order – tier 1, then tier 2, then tier 3 – so the
safe, provable work is visibly separated from the judgment calls. For each item give `file:line`,
why it is safe or warranted, and its confidence (**delete** / **needs confirmation**); tier-3 items
are always **needs confirmation** and additionally state the value-vs-cost tradeoff and what is lost.

Do not delete or refactor before the plan is approved. Once tiers 1 and 2 are approved, apply them
in small steps, deletions leaf-first so each step leaves the suite green, running the tests after
each. Apply a tier-3 item only after its own explicit confirmation.
