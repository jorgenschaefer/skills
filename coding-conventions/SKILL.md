---
name: coding-conventions
description: The single source of truth for this project's code-quality standards - the criteria used both when writing code (/implement) and when reviewing it (/critique). Covers simple design, structure and locality, naming after the domain, layering across deep seams, validation at the boundary, test coverage, and security. Read it before writing or reviewing feature code; it supplements your own judgment, it does not bound it.
---

# Coding Conventions

These are the standards this project holds code to. They apply at every moment code is shaped - planning, writing, and reviewing - and both `/implement` and `/critique` read this file rather than restating the rules.

**They supplement your own judgment; they do not bound it.** Apply everything you already know about good code. The rules below sharpen focus on things that are easy to miss or where this project has a specific preference. Never excuse or downgrade a problem you would otherwise flag just because no rule here names it.

## Simple design

Apply Kent Beck's four rules of simple design, in priority order:

1. **Passes the tests.** Correct behavior comes first.
2. **Reveals intention.** Names and structure make the purpose obvious to the next reader.
3. **No duplication.** Each piece of knowledge has one representation.
4. **Fewest elements.** No classes, methods, or abstractions beyond what the first three rules require.

- **YAGNI.** Minimum code that solves the problem, nothing speculative, in the simplest and most boring version that works - prefer the conventional solution over the clever one. Flag speculative generality: code added for an imagined future need. (Tests of spec-mandated behavior are not YAGNI candidates - write them even when the production logic looks trivial.)
- **KISS.** Prefer the simplest thing that works. Flag needless complexity - an abstraction where a function would do, convoluted control flow, a clever construct where plain code reads better - even when nothing is speculative.
- **Duplication is justified or removed.** Two copies that will change for the same reason belong in one place; flag from the second copy on. Duplication is acceptable only when the copies will change for *different* reasons - then prefer it over the wrong abstraction.
- **No dead code.** Code that is unreachable or never referenced is a finding. Before flagging, rule out non-obvious use: dynamic/reflective access, DI registration, string-referenced routes/config/env, framework entry points, and exported API consumed from outside this repo (an exported symbol with no internal caller is not dead).

## Structure and locality

Code that changes together should live close together - same file, then same module, then same directory. Having to jump between distant locations to follow one piece of logic is a smell; the further the jump, the worse it is.

- **Feature-based modules.** Combine a feature's code into the same module, each feature in its own directory or file, rather than splitting by type (all controllers in one directory, all models in another).
- **Co-locate tests.** Put a test next to the file it tests, not in a separate `tests/` tree - unless the project's existing layout clearly says otherwise.
- **Reads top to bottom** (the stepdown rule / newspaper metaphor). Files open with the abstract idea and grow concrete; a helper sits below its caller, so a reader meets a function before its details.
- **Indirection pays for itself** (deep modules, not shallow ones). Test a boundary by whether a caller can use it correctly without understanding what's behind it. Flag the boundary you have to see through anyway: a wrapper that relays the same vocabulary and shape it received, a delegate-only class, a hop that adds a name but no meaning. Thinness isn't the defect; a boundary that spares the caller nothing is.

## Domain layering

One idea runs through everything here: **a domain action has one name, and that name is carried unchanged through every layer that touches it.** `archivePost` is `archivePost` in the hook, in the action, in the business logic, and in the database helper. Only the database itself, at the very bottom, turns it into a generic `UPDATE`.

Two things follow: the layers are a small number of **deep seams** (not a stack of thin pass-through functions), and the objects that cross those seams are **domain objects**, named the same way. The payoff is traceability - you can grep a single domain name from the click that triggers it down to the SQL, and the whole path lights up.

### Anchor names in the domain

Name after the *fachliche Handlung* (the domain action), never after the technical operation.

- Publishing and later archiving a blog post are `publishPost` / `archivePost` - not `updatePost`, even though both end as a database `UPDATE`.
- Changing an article's category is `updateCategory` if that is the domain action. If the category is just one of several editable fields, the action is `updateDetails`, and category is one value inside it. Let the domain decide the granularity, not the schema.
- The source of truth for these names is `UBIQUITOUS_LANGUAGE.md` if it exists. Use the terms documented there; if you coin a new domain term while working, it belongs in that glossary.

The rule holds even at the leaf: an async function may call `fetch`/`axios` or issue a query, but it is still named `archivePost`, never `postPatch` or `updatePostRow`.

### The seams

There are a small number of boundaries. Each is a real translation point; everything between two seams speaks the same domain language.

**Write path** (and any client-initiated read):

```
client component → (custom) hook → async function / server action → business logic → async function → DB layer
```

**Read path from a server component** is leaner - no hook, no controller:

```
server component → async function → DB layer
```

Responsibilities along the path:

- **Client component** - presentation only. Uses (custom) hooks; never calls `fetch`/`axios` directly.
- **Custom hook** - encapsulates presentation logic (e.g. TanStack Query for reads). Calls async functions; holds no business logic.
- **Async function** - encapsulates the actual `fetch`/`axios` (client side) or the DB access (server side). This is the seam named "API". **In Next.js, Server Actions already are these encapsulated functions** - the hook calls the action, so you rarely write `fetch`/`axios` by hand.
- **Controller** (the server-receiving function: a Server Action or route handler) - does only the minimal translation between the interface and the business logic, then calls a business-logic function. No business rules live here.
- **Business logic** - the domain rules. Lives in its own functions, not in the hook or the controller. Many are async because they talk to the backend; logic that works only on already-loaded frontend data may be synchronous. **Business logic never touches the database directly** - it goes through an async function that calls the DB layer.
- **DB layer** - the only place that knows the persistence representation.

**Reach external systems through intention-revealing functions.** These seams are how business logic talks to the outside: it calls domain-named queries (`getActiveFoo()`, `getFooByCompanyId()`) that name the intent and keep framework/ORM detail out of the logic, ideally returning a domain type (same shape is fine). A passthrough that just relays a framework query object (`getFoo(prismaWhereClause)` → `prisma.foo.findMany(...)`) does not count - it leaks the composable ORM query through a thin disguise. This is abstraction, not dependency injection; don't over-abstract (YAGNI). A one-line `getActiveFoo()` is not a shallow-module finding: its payment is isolating the ORM, so the caller thinks "active foos," not "this where-clause."

### Domain objects across the seams

Domain objects are what flow between the seams, and each seam translates:

- **Component / hook** translate presentation data into domain objects.
- **The API boundary** (Server Actions, route handlers) is where incoming data is **validated once** - e.g. with Zod - and from there on only domain objects are passed inward.
- **Parse, don't validate.** Validation happens exactly once, at that boundary. Inside the domain, trust the type rather than re-checking it. This is what makes the boundary worth having.
- **The DB layer** is the only place that translates a domain object to and from its database representation.
- **Define domain types early**, from the domain analysis, and use them throughout. Do not drag `Prisma` (or other ORM) types through the whole application - that couples every layer to storage and defeats the seams.

### Conceptual granularity, not premature abstraction

The layers above describe *conceptual* granularity - the boundaries at which you abstract *once it pays off*. They are not a mandate to create half a dozen one-line functions for every trivial action.

- **Inline the trivial.** A pass-through that does nothing but forward its argument, or a 1:1 domain-to-storage mapping, can stay inline. Do not manufacture a seam for it.
- **Abstract when it gets complex.** The moment a responsibility grows past trivial - real translation, real rules, more than one caller - pull it out along exactly these boundaries.
- **Few, deep seams.** Prefer a small number of boundaries that each hide real substance over many thin layers that only relay calls. Indirection has to earn its place.

## Clarity and least astonishment

- **Intent is obvious.** No gap between what the code says and what it does. Names are descriptive, and the wider a name's scope the more descriptive it should be (`i` is fine for a loop index, not for a function).
- **Least astonishment.** Behavior matches the contract a caller infers from the name, signature, and type *before* reading the body. Flag hidden surprises: a query that mutates (a `get`/`is`/pure-looking call with side effects), error handling that diverges from its siblings (one throws where the next returns null for the same condition), a parameter or default whose effect contradicts its name. Constructable test, not taste - name the wrong assumption a caller would make and how it breaks; "I'd have written it differently" is not a finding.
- **Reuse the established vocabulary.** Use the term already in use for a concept rather than coining a synonym. If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, names in code, tests, and comments should match its terms; a fresh name for a concept the glossary already defines is a finding.

## Test coverage

- **Every piece of business logic is pinned by a test:** removing or changing it would make a test fail. For each piece, you should be able to name the test that pins it; if you can't, that's a coverage gap.
- **External adapters** - the thin edge that talks to a third-party SDK, the network, or IO - may be untested when they genuinely can't be tested at all. The business logic behind them must be fully tested. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested.

## Security

These hold even when the spec doesn't name them.

- Every internet-reachable endpoint enforces authentication and authorization.
- All user input is validated and sanitized.

## Dependency versions

When adding a dependency, look up its current latest stable release (or latest LTS line, where the ecosystem distinguishes one) and use that. Do not rely on a version from memory - it is almost always stale.
