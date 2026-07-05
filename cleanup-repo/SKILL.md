---
name: cleanup-repo
description: Clean up the current project by finding code to delete (dead code,
  unrequired code, absence-asserting tests) and code to refactor (YAGNI and KISS
  violations), then producing a reviewable plan. Triggers on "/cleanup-repo",
  "clean up this project", "find dead code", "what can we delete".
disable-model-invocation: true
---

# Cleanup Repo

You are a senior software developer. Your job is to clean up the current project (directory).
Work in two passes — find, then plan — and stop at the plan for approval before changing anything.

## Before starting

Confirm the test suite runs and is green. This baseline is what "without breaking requirements"
is measured against; note any pre-existing failures so they aren't mistaken for cleanup damage.
For a sizeable project, spawn parallel `Explore` subagents across different areas and synthesize.

## Find code suitable for deletion

- **Dead code** — unreachable, or never referenced.
- **Code deletable without breaking requirements** — where "requirements" means the tests, the
  public contract, and any written spec. If none of those capture the behavior, the deletion rests
  on judgment: say so and ask rather than assuming.
- **Tests that assert the absence of code** — e.g. a test that a removed endpoint 404s — unless
  reappearance of that code would be a real regression (a security or correctness guarantee); keep
  those.

Before proposing any deletion, verify it is actually unreferenced. Account for non-obvious use:
dynamic/reflective access, DI registration, string-referenced routes/config/env, framework entry
points, and public API consumed from outside this repo (an exported symbol with no internal caller
is not dead). If you cannot prove it is safe, mark it **needs confirmation**, not **delete**.

## Find code suitable for refactoring

- **YAGNI violation** — code that exists solely for an eventuality that is not here yet.
- **KISS violation** — code more complicated than the current requirements need, including trivial
  functions or modules whose naming and abstraction do not improve readability.

Refactors here are behavior-preserving, proven by the existing green tests. If a change would alter
behavior, it is not cleanup — leave it out and note it separately.

## Output

Produce a reviewable plan, deletions before refactors, each item with `file:line`, why it is safe
or warranted, and its confidence (**delete** / **needs confirmation**). Order deletions leaf-first
so each step leaves the suite green. Do not delete or refactor before the plan is approved; once it
is, apply changes in small steps, running the tests after each.
