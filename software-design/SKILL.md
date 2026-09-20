---
name: software-design
description: Use when a change being planned introduces a concept the codebase has no name for, or moves a boundary between the ones it does - the domain's own names carried through every layer, where the seams are, how few and how deep they should be, and which decisions are worth an ADR. Not for a three-line edit inside an existing seam, and not for code already being typed: that is `coding-standard`.
---

# Shaping a change

Where `coding-standard` says what good code looks like once it is written, this says what shape it should take - decided while planning, because it is expensive to change afterwards.

Read this when a change introduces a concept the codebase does not have a name for, or moves a boundary between the ones it does. A three-line edit inside an existing seam does not need it.

## Domain layering

One idea runs through everything here: **a domain action has one name, and that name is present in the identifier at every layer that touches it.** The core `archivePost` runs through the hook, the action, the business logic, and the database helper; a layer may add a qualifier (`archivePostAction`, `archivePostSync`) but never replace or hide the domain name - never `updatePost` or `postPatch`. Only the database itself, at the very bottom, turns it into a generic `UPDATE`.

Two things follow: the layers are a small number of **deep seams** (not a stack of thin pass-through functions), and the objects that cross those seams are **domain objects**, named the same way. The payoff is traceability - grep the domain name and the whole path, from the click that triggers it down to the SQL, lights up; the qualifiers keep the stem greppable.

### Anchor names in the domain

Name after the domain action, never after the technical operation.

- When users talk about "publishing a blog post" or "archiving it", the respective functions should be `publishPost` and `archivePost` - not `updatePost`, even though both end as a database `UPDATE`.
- When users talk about "setting an article's category", the respective function should be `setArticleCategory`.
- When users talk about "saving an article", the function should be `saveArticle` with the argument being a compound object of everything the users mean with "the article" in this context - that could contain the category.
- The source of truth for these names is `UBIQUITOUS_LANGUAGE.md` if it exists - see `## The glossary`.

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

Two concerns straddle the client/server split, and their halves are distinct - do not conflate them. The **async functions** carry different names at each end: the API function on the client (wraps the network call) and the data-access function on the server (wraps the database). **Business logic** appears under that one label at both ends: client-side (working on frontend data, often synchronous) and server-side (the authoritative domain rules); the server never assumes the client ran its copy.

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
- **Few, deep seams.** Prefer a small number of boundaries that each hide real substance over many thin layers that only relay calls.

## The glossary

`UBIQUITOUS_LANGUAGE.md`, where the project keeps one, is the source of truth for the domain's names: use the identifiers it documents, and put a term you coin while planning into it. A term already there that the plan contradicts is either a mistake in the plan or a rename that has to be made everywhere at once - there is no third option where both spellings live.

`/ubiquitous-language-init` bootstraps that file in a project that has none, and audits an existing one for drift. It stays a separate skill because bootstrapping a glossary is a one-off act on a codebase, not something a change needs.

## What deserves an ADR

A decision earns a record when it will outlive the change that produced it and someone will later wonder why. In practice:

- **A boundary** - what the seams are, and what may cross them.
- **A representation** the whole codebase has to agree on - money as integer cents, times as UTC instants.
- **A dependency** taken on, or refused, for a reason the code cannot show.
- **A constraint accepted** - the thing that will look like an oversight to whoever reads it next.

A decision that only shapes the change in front of you is not one of these; it belongs in the solution, and is deleted with the rest of the paper when the work is accepted.

**Never write one unilaterally.** `ADR_FORMAT.md` is emphatic about this and it is the rule most worth keeping: put the decision and a recommendation to the person, and write the record only once they have said yes.

**Write it at plan exit**, with the tickets - while the argument that produced it is still in front of you. By the time the work is accepted, the alternatives that were live and the reason the winner won are gone, and an ADR that records only the conclusion is the half nobody needed.
