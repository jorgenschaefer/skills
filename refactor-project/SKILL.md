---
name: refactor-project
description: Do a deep refactoring of the project to make the project more maintainable and easier to understand and reason about.
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

## Process

### 1. Explore the codebase

Use the Agent tool with subagent_type=Explore to navigate the codebase naturally. Do NOT follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small files?
- Where is business logic hidden behind framework or database adaption code?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested, or hard to test?

The friction you encounter IS the signal.

### 2. Propose a refactoring plan

What are the most important refactorings to make the codebase more maintainable and easier to understand and reason about?

Provide a list of proposed refactorings, with an explanation of why it is important and how it will help.
