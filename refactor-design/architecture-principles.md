# Architecture Principles

Three structural principles that apply across design, implementation, and review in this project.

## Screaming Architecture

A project has a **screaming architecture** if the folder structure reveals its business purpose rather than its technical implementation details. The term is associated with Robert "Uncle Bob" Martin: a project's structure should scream what the application *does*, not what framework it runs on.

Good:
- `orders/`, `users/`, `payments/`, `billing/`

Bad:
- `services/`, `controllers/`, `models/`, `helpers/`, `utils/`

Grouping code by business domain keeps domain logic and feature-related code together, making systems more organized, navigable, and maintainable. When the existing codebase is layered, note it explicitly — either propose a migration path toward domain-first organization, or justify why new code extends the layered structure.

Prefer `orders/OrderService.ts` over `services/OrderService.ts`.

## Deep Modules

A **deep module** (John Ousterhout, *A Philosophy of Software Design*) has a small interface hiding a large implementation. Callers get significant value from a simple interaction; internal complexity is genuinely hidden. Deep modules are more testable, more navigable, and let you test at the boundary instead of inside.

A **shallow module**'s interface is nearly as complex as its implementation — it adds overhead without encapsulation.

Shallow-module smells:
- Pass-through methods that add no logic
- Information leakage: a module exposes its internal data structures or config to callers (abstraction leakage)
- Abstractions too small or too thin to justify their existence
- Callers that are more complex after the abstraction than they would be without it

For each proposed module boundary, ask: is this module earning its abstraction? If it mostly delegates to another layer without hiding anything, merge the layers or rethink the boundary.

## Adapter Boundaries

Business logic must touch only domain objects. Three layers, three rules:

1. **Inbound adapter** (route handler, controller): authenticate → validate input into a domain object → call business logic → map to response. No domain rules here.
2. **Business logic**: domain objects in, domain objects out. Contains all domain rules. No HTTP types, no validation-schema types (Zod inferred types, etc.), no ORM entities, no DB row types.
3. **Outbound adapter** (repository, data access): translates domain objects to and from DB/external format. No domain rules here.

Types mirror the same separation:
- Validation schemas (Zod, etc.) belong only in the inbound adapter
- Domain types belong with the business logic
- Database types (ORM entities, SQL row shapes) belong only in the outbound adapter

Passing a Zod-inferred type or an ORM entity into the business logic is a boundary violation.

For simple CRUD all three layers can live in one file — but even then, the three concerns must be visibly distinct and not tangled.
