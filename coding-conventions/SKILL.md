---
name: coding-conventions
description: The single source of truth for this project's code-quality standards - the criteria used both when writing code (/implement) and when reviewing it (/critique). Covers simple design, structure and locality, naming after the domain, layering across deep seams, validation at the boundary, test coverage, and security. Read it before writing or reviewing feature code; it supplements your own judgment, it does not bound it.
---

# Coding Conventions

These are the standards this project holds code to. They apply both when writing code and when reviewing it, and both `/implement` and `/critique` read this file rather than restating the rules.

**They supplement your own judgment; they do not bound it.** Apply everything you already know about good code. The rules below sharpen focus on things that are easy to miss or where this project has a specific preference. Never excuse a problem you would otherwise catch just because no rule here names it.

Each rule states a property the code should have. Whoever reads it supplies the verb: when writing, build to the property; when reviewing, treat code that lacks it as a problem to raise.

## Simple design

Apply Kent Beck's four rules of simple design, in priority order:

1. **Passes the tests.** Correct behavior comes first.
2. **Reveals intention.** Names and structure make the purpose obvious to the next reader.
3. **No duplication.** Each piece of knowledge has one representation.
4. **Fewest elements.** No classes, methods, or abstractions beyond what the first three rules require.

- **YAGNI.** Minimum code that solves the problem, nothing speculative, in the simplest and most boring version that works - prefer the conventional solution over the clever one. Speculative generality - code added for an imagined future need - does not belong in the codebase. (Tests of spec-mandated behavior are not YAGNI candidates - write them even when the production logic looks trivial.)
- **KISS.** Prefer the simplest thing that works. Needless complexity does not belong even when nothing is speculative - an abstraction where a function would do, convoluted control flow, a clever construct where plain code reads better.
- **Duplication is justified or removed.** Two copies that will change for the same reason belong in one place. Duplication is acceptable only when the copies will change for *different* reasons - then prefer it over the wrong abstraction.
- **No dead code.** Unreachable or unreferenced code should not exist. Note what only *looks* dead but is live: dynamic/reflective access, DI registration, string-referenced routes/config/env, framework entry points, and exported API consumed from outside this repo (an exported symbol with no internal caller is not dead).

## Structure and locality

Code that changes together should live close together - same file, then same module, then same directory. Having to jump between distant locations to follow one piece of logic is a smell; the further the jump, the worse it is.

- **Feature-based modules.** Combine a feature's code into the same module, each feature in its own directory or file, rather than splitting by type (all controllers in one directory, all models in another).
- **Co-locate tests.** Put a test next to the file it tests, not in a separate `tests/` tree - unless the project's existing layout clearly says otherwise.
- **Reads top to bottom** (the stepdown rule / newspaper metaphor). Files open with the abstract idea and grow concrete; a helper sits below its caller, so a reader meets a function before its details.
- **Indirection pays for itself** (deep modules, not shallow ones). A boundary earns its place only if a caller can use it correctly without understanding what's behind it. A boundary you have to see through anyway does not - a wrapper that relays the same vocabulary and shape it received, a delegate-only class, a hop that adds a name but no meaning. Thinness isn't the defect; a boundary that spares the caller nothing is.

## Domain layering

One idea runs through everything here: **a domain action has one name, and that name is present in the identifier at every layer that touches it.** The core `archivePost` runs through the hook, the action, the business logic, and the database helper; a layer may add a qualifier (`archivePostAction`, `archivePostSync`) but never replace or hide the domain name - never `updatePost` or `postPatch`. Only the database itself, at the very bottom, turns it into a generic `UPDATE`.

Two things follow: the layers are a small number of **deep seams** (not a stack of thin pass-through functions), and the objects that cross those seams are **domain objects**, named the same way. The payoff is traceability - grep the domain name and the whole path, from the click that triggers it down to the SQL, lights up; the qualifiers keep the stem greppable.

### Anchor names in the domain

Name after the *fachliche Handlung* (the domain action), never after the technical operation.

- When users talk about "publishing a blog post" or "archiving it", the respective functions should be `publishPost` and `archivePost` - not `updatePost`, even though both end as a database `UPDATE`.
- When users talk about "setting an article's category", the respective function should be `setArticleCategory`.
- When users talk about "saving an article", the function should be `saveArticle` with the argument being a compound object of everything the users mean with "the article" in this context - that could contain the category.
- The source of truth for these names is `UBIQUITOUS_LANGUAGE.md` if it exists. Use the terms documented there; if you coin a new domain term while working, it belongs in that glossary.

The examples share one test: name the function at the granularity the users talk about the action, and let a compound argument carry the details. The schema does not decide the split - one action may write several columns, and one column may be written by several distinct actions.

The rule holds even at the leaf: an async function may call `fetch`/`axios` or issue a query, but its name still carries `archivePost` - a qualifier is fine, a technical rename like `postPatch` or `updatePostRow` is not.

### The seams

There are a small number of boundaries. Each is a real translation point; everything between two seams speaks the same domain language.

**Write path** (and any client-initiated read):

```
client component → (custom) hook → business logic → API function → controller → business logic → data-access function → DB layer
```

**Read path from a server component** is leaner - no hook, no API function, no controller:

```
server component → business logic → data-access function → DB layer
```

Note that two nodes each appear twice in the write path, and the pairs are distinct - do not conflate them. The two **async functions**: the API function on the client (wraps the network call) and the data-access function on the server (wraps the database). And **business logic** appears client-side (working on frontend data, often synchronous) and server-side (the authoritative domain rules); the server never assumes the client ran its copy.

Responsibilities along the path:

- **Client component** - presentation only. Uses (custom) hooks; never calls `fetch`/`axios` directly.
- **Custom hook** - encapsulates presentation logic (e.g. TanStack Query for reads). Calls client business logic, which reaches the server through the API function; for a trivial case it may call the API function directly. Holds no business logic itself.
- **Business logic (client)** - domain logic that runs in the frontend, e.g. on already-loaded data. May be synchronous or asynchronous; when it needs the server it goes through the API function, never `fetch`/`axios` directly.
- **API function** - the client-side async function that performs the actual `fetch`/`axios` call. This is the seam named "API"; it is named after the domain action (`archivePost`), not the transport.
- **Controller** - the server-receiving function that does only the minimal translation between the interface and the business logic, then calls a business-logic function. No business rules live here. **In Next.js a Server Action fills both roles at once** - the hook calls it like the API function, and it runs on the server as the controller, so you rarely write `fetch`/`axios` by hand.
- **Business logic (server)** - the authoritative domain rules. Lives in its own functions, not in the hook or the controller, and is usually async because it reaches the database. **It never touches the database directly** - it goes through a data-access function.
- **Data-access function** - the server-side async function, and the only caller of the DB layer (see the intention-revealing rule below).
- **DB layer** - the only place that knows the persistence representation.

**The data-access function reaches external systems through an intention-revealing name.** It is a domain-named query (`getActiveFoo()`, `getFooByCompanyId()`) that names the intent and keeps framework/ORM detail out of the business logic, ideally returning a domain type - structurally identical to the row is fine, but it must be your own domain type, not the imported `Prisma` type (that is the coupling the "define domain types early" rule below forbids). A passthrough that just relays a framework query object (`getFoo(prismaWhereClause)` → `prisma.foo.findMany(...)`) does not count - it leaks the composable ORM query through a thin disguise. This is abstraction, not dependency injection; don't over-abstract (YAGNI). A one-line `getActiveFoo()` is not a shallow module: its payment is isolating the ORM, so the caller thinks "active foos," not "this where-clause."

### Domain objects across the seams

Domain objects are what flow between the seams. Translation happens at two ends:

- **On the way in (writes):** the component/hook assemble the user's presentation input into a domain-shaped object. In the frontend, this is then trusted. But once that object transitions the API/Controller seam, the data is again untrusted. The controller validates it - e.g. with Zod - and only from there inward is it a trusted domain object again.
- **On the way out (reads):** the DB layer produces domain objects; they flow outward unchanged, and the component renders them.
- **Parse, don't validate.** Each trust boundary validates once - the frontend's input boundary, then the server's request boundary - and inside a trust zone you rely on the type rather than re-checking it. The two are not redundant: the server can never trust that the client ran its validation. This is what makes each boundary worth having.
- **The DB layer** is the only place that translates a domain object to and from its database representation.
- **Define domain types early**, from the domain analysis, and use them throughout. Do not drag `Prisma` (or other ORM) types through the whole application - that couples every layer to storage and defeats the seams.

### Conceptual granularity, not premature abstraction

The layers above describe *conceptual* granularity - the boundaries at which you abstract *once it pays off*. They are not a mandate to create half a dozen one-line functions for every trivial action.

- **Inline the trivial.** A pass-through that does nothing but forward its argument, or a 1:1 domain-to-storage mapping, can stay inline. Do not manufacture a seam for it.
- **Abstract when it gets complex.** The moment a responsibility grows past trivial - real translation, real rules, more than one caller - pull it out along exactly these boundaries.
- **Few, deep seams.** Prefer a small number of boundaries that each hide real substance over many thin layers that only relay calls. Indirection has to earn its place.

## Clarity and least astonishment

- **Intent is obvious.** No gap between what the code says and what it does. Names are descriptive, and the wider a name's scope the more descriptive it should be (`i` is fine for a loop index, not for a function).
- **Least astonishment.** Behavior matches the contract a caller infers from the name, signature, and type *before* reading the body. Hidden surprises break this: a query that mutates (a `get`/`is`/pure-looking call with side effects), error handling that diverges from its siblings (one throws where the next returns null for the same condition), a parameter or default whose effect contradicts its name. The test is a wrong assumption a caller would make and how it breaks, not a matter of taste.
- **Reuse the established vocabulary.** Use the term already in use for a concept rather than coining a synonym. If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, names in code, tests, and comments should match its terms; coining a synonym for a concept the glossary already defines violates this.

## Test coverage

- **Every piece of business logic is pinned by a test:** removing or changing it would make a test fail. For each piece, you should be able to name the test that pins it; if you can't, that's a coverage gap.
- **External adapters** - the thin edge that talks to a third-party SDK, the network, or IO - may be untested when they genuinely can't be tested at all. The business logic behind them must be fully tested. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested.

## Security

These hold even when the spec doesn't name them.

- Every internet-reachable endpoint enforces authentication and authorization.
- All user input is validated and sanitized.

## Dependency versions

When adding a dependency, look up its current latest stable release (or latest LTS line, where the ecosystem distinguishes one) and use that. Do not rely on a version from memory - it is almost always stale.
