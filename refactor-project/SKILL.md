---
name: refactor-project
description: Use this skill when the user wants a comprehensive structural review of a codebase — not a targeted fix for a specific bug or feature, but a survey of where the architecture is creating friction. Trigger when the user says things like "the codebase is getting hard to change", "clean up the architecture", "do a structural review", "improve our module boundaries", or asks to improve maintainability project-wide. Do NOT use for feature design (use the design skill) or for reviewing a specific recent change (use review/implementation).
---

# Refactor Project

Code bases tend to grow over time and accumulate small areas of friction and complexity. By themselves, they are usually not a big issue, but if you do not clean up from time to time, they can accumulate to make the project hard to maintain.

## Goal

Your goal is to make the code base easy to change and easy to reason about to make it easier to add new features and fix bugs. To facilitate this, the project should have a  **screaming architecture** and be composed of **deep modules** that implement **clear business logic**.

### Screaming Architecture

A project has a **screaming architecture** if the folder structure reveals the business purpose of the project, as opposed to the technical implementation details.

It is a software design philosophy coined by Robert "Uncle Bob" Martin, emphasizing that a project's folder structure should reveal its business purpose (use cases) rather than the frameworks or technical tools (e.g., Rails, React) it uses. It keeps domain logic and feature-related code together, making systems more organized, navigable, and maintainable, acting as a "screaming" indicator of what the application does (e.g., Health Care System).

Good:
- src/todo-items
- src/users
- src/plans

Bad:
- src/controllers
- src/services
- src/models
- src/views
- src/helpers

### Deep Modules

A **deep module** (John Ousterhout, "A Philosophy of Software Design") has a small interface hiding a large implementation. Deep modules are more testable, more AI-navigable, and let you test at the boundary instead of inside.

### Clear Business Logic

A project has **clear business logic** if the code that implements a feature is not hidden behind framework or database adaption code.

Code that touches the outside world lives at the edges; business logic in the middle works only with domain objects:

1. **Inbound adapter** (route handler, controller): authenticate, validate input into a domain object, call business logic, map the result to a response. No domain rules here.
2. **Business logic**: operates on domain objects only, applies domain rules, returns domain objects or raises domain errors. No HTTP types, no validation-schema types, no ORM entities or DB row types.
3. **Outbound adapter** (repository, data access): translates domain objects to DB format, calls the DB, returns domain objects. No domain rules here.

Types mirror the same separation — **validation schemas** (Zod, etc.) belong only in the inbound adapter, **domain types** belong with the business logic, and **database types** (ORM entities, SQL row shapes) belong only in the outbound adapter. Passing a Zod inferred type or an ORM entity into the business logic is a boundary violation.

For simple CRUD, all three layers can live in one function or file — but even then, the three concerns must be visibly distinct and not tangled together.

## Before starting

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding.

## Process

### 1. Explore the codebase

Use the Agent tool with subagent_type=Explore to navigate the codebase naturally. Use these questions to guide your attention — they name the patterns most likely to cause long-term friction. Don't treat them as an exhaustive checklist; if you encounter friction not on this list, note it.

- Where does understanding one concept require bouncing between many small files?
- Where is business logic hidden behind framework or database adaption code?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested, or hard to test?

Document each friction point as you encounter it: note the file or module, the pattern creating friction, and why it makes the code hard to change or understand. These notes become the "Friction points found" section of the proposal.

### 2. Propose a refactoring plan

Save the proposal to `docs/features/<slug>/proposal.md`. If the target directory doesn't exist, create it. If you can't write the file, tell the user the artifact path and paste the content inline so they can save it manually.

Use this structure:

```markdown
# Refactoring Proposal: <project or area>

**Date:** <YYYY-MM-DD>

## Summary
One paragraph: the headline finding — what kind of friction dominates?

## Friction points found
A list of specific locations with notes on what makes each one hard to change or understand.

## Proposed refactorings
For each proposed refactoring:
- **What:** the specific change (rename, move, merge, split, add boundary)
- **Why:** what friction it removes
- **Impact:** how much code is affected; how risky
- **Approach:** a starting point for implementation

## Suggested order
Which refactorings to do first and why.
```

Do not implement any refactoring in this skill. The output is a proposal; implementation follows the normal ticket workflow. If the user asks you to implement, redirect: create tickets for the highest-priority refactorings using the planning skill instead.
