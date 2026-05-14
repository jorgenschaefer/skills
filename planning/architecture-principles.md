# Architecture Principles

Structural principles that apply across design, implementation, and review in this project.

## Screaming Architecture

A project has a **screaming architecture** if the folder structure reveals its business purpose rather than its technical implementation details. The term is associated with Robert "Uncle Bob" Martin: a project's structure should scream what the application *does*, not what framework it runs on.

Good:
- `orders/`, `users/`, `payments/`, `billing/`

Bad:
- `services/`, `controllers/`, `models/`, `helpers/`, `utils/`

Grouping code by business domain keeps domain logic and feature-related code together, making systems more organized, navigable, and maintainable. When the existing codebase is layered, note it explicitly — either propose a migration path toward domain-first organization, or justify why new code extends the layered structure.

Prefer `orders/OrderService.ts` over `services/OrderService.ts`.

## Single Responsibility

A module has a single responsibility when it has only one reason to change — meaning its requirements come from only one actor. A module can be *used* by many actors; what matters is who has the authority to request changes to it. This is different from "does one thing": a module can do many things and still have a single responsibility if they all change for the same reason and at the direction of the same actor. This applies at every level — directories, files, classes, functions.

The diagnostic question is not "what does this module do?" but "whose requirements drive how this module should work?" If the answer is "the billing team *and* the operations team", the module has two responsibilities and should be split — even if the code looks unified today.

Smells:
- A `Report` module used by both accounting and HR for different purposes — their requirements will diverge; split now before the first conflict forces a messy conditional
- A `UserAccount` module handling both authentication rules (security/compliance team) and subscription logic (finance team) — a GDPR change should not risk breaking billing
- An `Employee` class with `calculatePay()` (CFO), `reportHours()` (COO), and `save()` (CTO) — Uncle Bob's canonical example: three actors, three reasons to change, should be three modules
- A service class where half the methods serve one use case and half serve another, with no shared state between them
- Needs "and" to describe what it does, or its contents can't be summarized without listing them
- Extracted names reference the caller or context ("helper", "util", numbered variants) — scattering, not simplifying
- More than three or four parameters on a function — usually a sign it does too much, or that the inputs form a concept that deserves its own type

When splitting: size is a symptom, not the disease — split when pieces have distinct, independently nameable purposes, not simply because something is large. Give each actor their own module, even if this introduces duplication initially. Duplication that answers to different actors is not the duplication that should be eliminated.

## Common Closure

Things that change together for the same reason should live together. Things that change for different reasons should be separated.

This is the module-level complement to Single Responsibility: where SRP asks "does this module answer to one actor?", Common Closure asks "are the things in this module likely to be changed by the same forces?" Code that is changed together belongs together — colocation reduces the blast radius of a change and makes it easier to understand what a change touches.

Implications:
- A utility function that only ever changes when the billing module changes belongs in billing, not in a shared `utils/` folder
- Generic-looking code that is tightly coupled to one domain concept should live in that domain, not be factored out as reusable
- When deciding where to place new code, ask: when this needs to change, what else will change at the same time? Put it there.

Common Closure is why domain-first organization (Screaming Architecture) works: grouping by domain naturally clusters things that change together.

## Adapter Boundaries

Business logic must touch only domain objects. Three layers, three rules:

1. **Inbound adapter** (route handler, controller): authenticate → validate input into a domain object → call business logic → map to response. No domain rules here.
2. **Business logic**: domain objects in, domain objects out. Contains all domain rules. No HTTP types, no validation-schema types (Zod inferred types, etc.), no ORM entities, no DB row types.
3. **Outbound adapter** (repository, data access): translates domain objects to and from DB/external format. No domain rules here.

Types mirror the same separation:
- Validation schemas (Zod, etc.) belong only in the inbound adapter
- Domain types belong with the business logic
- Database types (ORM entities, SQL row shapes) belong only in the outbound adapter

For simple CRUD all three layers can live in one file — but even then, the three concerns must be visibly distinct and not tangled.

## Deep Modules

A **deep module** (John Ousterhout, *A Philosophy of Software Design*) has a small interface hiding a large implementation. Callers get significant value from a simple interaction; internal complexity is genuinely hidden. Deep modules are more testable, more navigable, and let you test at the boundary instead of inside.

A **shallow module**'s interface is nearly as complex as its implementation — it adds overhead without encapsulation.

Shallow-module smells:
- Pass-through methods that add no logic
- Information leakage: a module exposes its internal data structures or config to callers (abstraction leakage)
- Abstractions too small or too thin to justify their existence
- Callers that are more complex after the abstraction than they would be without it

For each proposed module boundary, ask: is this module earning its abstraction? If it mostly delegates to another layer without hiding anything, merge the layers or rethink the boundary.
